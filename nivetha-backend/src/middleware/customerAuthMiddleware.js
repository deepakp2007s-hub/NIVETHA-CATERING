
import jwt from 'jsonwebtoken';
import Customer from '../models/Customer.js';

export const protectCustomer = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'Not authorized. Customer authentication token missing.',
    });
  }

  const token = authHeader.slice(7).trim();

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Authentication token is missing.',
    });
  }

  const jwtSecret = process.env.JWT_SECRET;

  if (!jwtSecret || jwtSecret.length < 32) {
    console.error(
      'JWT_SECRET is missing or must contain at least 32 characters.'
    );

    return res.status(500).json({
      success: false,
      message: 'Server authentication configuration error.',
    });
  }

  try {
    const decoded = jwt.verify(token, jwtSecret);

    if (
      decoded.role !== 'customer' ||
      typeof decoded.id !== 'string' ||
      !decoded.id
    ) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Customer authentication required.',
      });
    }

    const customer = await Customer.findById(decoded.id).select('-password');

    if (!customer) {
      return res.status(401).json({
        success: false,
        message: 'Customer account not found.',
      });
    }

    if (customer.isActive === false) {
      return res.status(403).json({
        success: false,
        message: 'Customer account is suspended.',
      });
    }

    req.customer = customer;
    req.user = {
      ...customer.toObject(),
      role: 'customer',
    };

    return next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Session expired. Please log in again.',
      });
    }

    if (
      error.name === 'JsonWebTokenError' ||
      error.name === 'NotBeforeError'
    ) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized. Invalid token.',
      });
    }

    return next(error);
  }
};

export default protectCustomer;
