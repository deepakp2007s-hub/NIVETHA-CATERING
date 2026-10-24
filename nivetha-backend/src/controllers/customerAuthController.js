
import jwt from 'jsonwebtoken';
import Customer from '../models/Customer.js';
import { normalizePhone } from './authController.js';

const generateCustomerToken = (id) => {
  const secret = process.env.JWT_SECRET;

  if (!secret || secret.length < 32) {
    throw new Error(
      'JWT_SECRET must be configured with at least 32 characters.'
    );
  }

  return jwt.sign(
    { id: String(id), role: 'customer' },
    secret,
    { expiresIn: process.env.JWT_EXPIRE || '7d' }
  );
};

const cleanOptionalString = (value, fieldName) => {
  if (value === undefined || value === null) {
    return '';
  }

  if (typeof value !== 'string') {
    throw new TypeError(`${fieldName} must be a string.`);
  }

  return value.trim();
};

const publicCustomer = (customer) => ({
  _id: customer._id,
  name: customer.name,
  phone: customer.phone,
  email: customer.email,
  address: customer.address,
  ...(customer.createdAt ? { createdAt: customer.createdAt } : {}),
});

/**
 * POST /api/customer-auth/register
 */
export const registerCustomer = async (req, res, next) => {
  try {
    const { name, password } = req.body || {};
    const rawPhone =
      req.body?.phone ??
      req.body?.phoneNumber ??
      req.body?.mobile;

    const phone = normalizePhone(rawPhone);

    if (!cleanOptionalString(name, 'Name') || !phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'Name, phone number, and password are required.',
      });
    }

    const cleanName = name.trim();

    if (cleanName.length > 100) {
      return res.status(400).json({
        success: false,
        message: 'Name cannot exceed 100 characters.',
      });
    }

    if (!/^\d{10}$/.test(phone)) {
      return res.status(400).json({
        success: false,
        message: 'Please provide a valid 10-digit mobile number.',
      });
    }

    if (typeof password !== 'string' || password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters long.',
      });
    }

    const email = cleanOptionalString(req.body?.email, 'Email').toLowerCase();
    const address = cleanOptionalString(req.body?.address, 'Address');

    const existingCustomer = await Customer.findOne({ phone });

    if (existingCustomer) {
      return res.status(409).json({
        success: false,
        message: 'An account with this phone number already exists. Please log in.',
      });
    }

    const customer = await Customer.create({
      name: cleanName,
      phone,
      email,
      address,
      password,
    });

    const token = generateCustomerToken(customer._id);

    return res.status(201).json({
      success: true,
      message: 'Customer account created successfully.',
      token,
      customer: publicCustomer(customer),
    });
  } catch (error) {
    if (error?.code === 11000) {
      return res.status(409).json({
        success: false,
        message: 'An account with this phone number already exists. Please log in.',
      });
    }

    if (error instanceof TypeError || error?.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    return next(error);
  }
};

/**
 * POST /api/customer-auth/login
 */
export const loginCustomer = async (req, res, next) => {
  try {
    const rawPhone =
      req.body?.phone ??
      req.body?.phoneNumber ??
      req.body?.mobile;

    const password = req.body?.password;
    const phone = normalizePhone(rawPhone);

    if (!phone || typeof password !== 'string' || !password) {
      return res.status(400).json({
        success: false,
        message: 'Phone number and password are required.',
      });
    }

    const customer = await Customer.findOne({ phone }).select('+password');

    if (!customer || !(await customer.matchPassword(password))) {
      return res.status(401).json({
        success: false,
        message: 'Invalid phone number or password.',
      });
    }

    if (customer.isActive === false) {
      return res.status(403).json({
        success: false,
        message: 'Your customer account is suspended. Please contact support.',
      });
    }

    const token = generateCustomerToken(customer._id);

    return res.status(200).json({
      success: true,
      message: 'Customer login successful.',
      token,
      customer: publicCustomer(customer),
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * GET /api/customer-auth/profile
 */
export const getCustomerProfile = async (req, res, next) => {
  try {
    if (!req.customer?._id) {
      return res.status(401).json({
        success: false,
        message: 'Customer authentication is required.',
      });
    }

    const customer = await Customer.findById(req.customer._id);

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer profile not found.',
      });
    }

    if (customer.isActive === false) {
      return res.status(403).json({
        success: false,
        message: 'Customer account is suspended.',
      });
    }

    return res.status(200).json({
      success: true,
      customer: publicCustomer(customer),
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * PUT /api/customer-auth/profile
 */
export const updateCustomerProfile = async (req, res, next) => {
  try {
    if (!req.customer?._id) {
      return res.status(401).json({
        success: false,
        message: 'Customer authentication is required.',
      });
    }

    const customer = await Customer.findById(req.customer._id);

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found.',
      });
    }

    if (customer.isActive === false) {
      return res.status(403).json({
        success: false,
        message: 'Customer account is suspended.',
      });
    }

    const body = req.body || {};

    if (body.name !== undefined) {
      if (typeof body.name !== 'string' || !body.name.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Name must be a non-empty string.',
        });
      }

      if (body.name.trim().length > 100) {
        return res.status(400).json({
          success: false,
          message: 'Name cannot exceed 100 characters.',
        });
      }

      customer.name = body.name.trim();
    }

    if (body.email !== undefined) {
      if (typeof body.email !== 'string') {
        return res.status(400).json({
          success: false,
          message: 'Email must be a string.',
        });
      }

      customer.email = body.email.trim().toLowerCase();
    }

    if (body.address !== undefined) {
      if (typeof body.address !== 'string') {
        return res.status(400).json({
          success: false,
          message: 'Address must be a string.',
        });
      }

      customer.address = body.address.trim();
    }

    if (body.password !== undefined) {
      if (
        typeof body.password !== 'string' ||
        body.password.length < 6
      ) {
        return res.status(400).json({
          success: false,
          message: 'New password must be at least 6 characters long.',
        });
      }

      customer.password = body.password;
    }

    await customer.save();

    return res.status(200).json({
      success: true,
      message: 'Profile updated successfully.',
      customer: publicCustomer(customer),
    });
  } catch (error) {
    if (error?.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    return next(error);
  }
};
