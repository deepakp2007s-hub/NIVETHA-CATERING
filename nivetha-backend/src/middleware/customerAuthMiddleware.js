import jwt from 'jsonwebtoken';
import Customer from '../models/Customer.js';

export const protectCustomer = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Not authorized. Customer authentication token missing.',
    });
  }

  try {
    const jwtSecret = process.env.JWT_SECRET || 'nivetha_catering_jwt_secret_production_2026';
    const decoded = jwt.verify(token, jwtSecret);

    if (decoded.role !== 'customer') {
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
    req.user = customer;
    next();
  } catch (error) {
    console.error('Customer auth error:', error.message);
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Session expired. Please log in again.',
      });
    }
    return res.status(401).json({
      success: false,
      message: 'Not authorized. Invalid token.',
    });
  }
};

export default protectCustomer;
