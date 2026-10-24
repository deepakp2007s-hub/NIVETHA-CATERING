import jwt from 'jsonwebtoken';
import Customer from '../models/Customer.js';
import { normalizePhone } from './authController.js';

const generateCustomerToken = (id) => {
  const secret = process.env.JWT_SECRET || 'nivetha_catering_jwt_secret_production_2026';
  return jwt.sign({ id, role: 'customer' }, secret, {
    expiresIn: process.env.JWT_EXPIRE || '30d',
  });
};

/**
 * @desc    Customer Registration (Flutter App)
 * @route   POST /api/customer-auth/register
 * @access  Public
 */
export const registerCustomer = async (req, res, next) => {
  try {
    const { name, email, address, password } = req.body;
    const rawPhone = req.body.phone || req.body.phoneNumber || req.body.mobile;

    const phone = normalizePhone(rawPhone);

    if (!name || !phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'Name, phone number, and password are required.',
      });
    }

    if (phone.length < 10) {
      return res.status(400).json({
        success: false,
        message: 'Please provide a valid 10-digit mobile number.',
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters long.',
      });
    }

    // Check existing customer
    const existingCustomer = await Customer.findOne({ phone });
    if (existingCustomer) {
      return res.status(409).json({
        success: false,
        message: 'A customer account with this phone number already exists. Please log in.',
      });
    }

    const customer = await Customer.create({
      name: name.trim(),
      phone,
      email: email ? email.trim().toLowerCase() : '',
      address: address ? address.trim() : '',
      password,
    });

    const token = generateCustomerToken(customer._id);

    res.status(201).json({
      success: true,
      message: 'Customer account created successfully',
      token,
      customer: {
        _id: customer._id,
        name: customer.name,
        phone: customer.phone,
        email: customer.email,
        address: customer.address,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Customer Login (Flutter App)
 * @route   POST /api/customer-auth/login
 * @access  Public
 */
export const loginCustomer = async (req, res, next) => {
  try {
    // ROOT CAUSE FIX: Check both phone and phoneNumber
    const rawPhone = req.body.phone || req.body.phoneNumber || req.body.mobile;
    const password = req.body.password;

    const phone = normalizePhone(rawPhone);

    if (!phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'Phone number and password are required.',
      });
    }

    const customer = await Customer.findOne({ phone }).select('+password');

    if (!customer) {
      return res.status(401).json({
        success: false,
        message: 'Invalid phone number or password.',
      });
    }

    if (customer.isActive === false) {
      return res.status(403).json({
        success: false,
        message: 'Your customer account is suspended. Please contact Nivetha Catering support.',
      });
    }

    const isMatch = await customer.matchPassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid phone number or password.',
      });
    }

    const token = generateCustomerToken(customer._id);

    res.json({
      success: true,
      message: 'Customer login successful',
      token,
      customer: {
        _id: customer._id,
        name: customer.name,
        phone: customer.phone,
        email: customer.email,
        address: customer.address,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get Current Customer Profile
 * @route   GET /api/customer-auth/profile
 * @access  Private (Customer)
 */
export const getCustomerProfile = async (req, res, next) => {
  try {
    const customer = await Customer.findById(req.customer._id);
    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer profile not found.',
      });
    }

    res.json({
      success: true,
      customer: {
        _id: customer._id,
        name: customer.name,
        phone: customer.phone,
        email: customer.email,
        address: customer.address,
        createdAt: customer.createdAt,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Update Current Customer Profile
 * @route   PUT /api/customer-auth/profile
 * @access  Private (Customer)
 */
export const updateCustomerProfile = async (req, res, next) => {
  try {
    const customer = await Customer.findById(req.customer._id);
    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found.',
      });
    }

    if (req.body.name) customer.name = req.body.name.trim();
    if (req.body.email !== undefined) customer.email = req.body.email.trim().toLowerCase();
    if (req.body.address !== undefined) customer.address = req.body.address.trim();

    // If customer wants to update password
    if (req.body.password) {
      if (req.body.password.length < 6) {
        return res.status(400).json({
          success: false,
          message: 'New password must be at least 6 characters long.',
        });
      }
      customer.password = req.body.password;
    }

    await customer.save();

    res.json({
      success: true,
      message: 'Profile updated successfully',
      customer: {
        _id: customer._id,
        name: customer.name,
        phone: customer.phone,
        email: customer.email,
        address: customer.address,
      },
    });
  } catch (error) {
    next(error);
  }
};
