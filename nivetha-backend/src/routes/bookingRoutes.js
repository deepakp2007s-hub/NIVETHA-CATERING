
import express from 'express';
import jwt from 'jsonwebtoken';

import {
  createBooking,
  getMyBookings,
  getBookingById,
  cancelBooking,
  getAllBookings,
  updateBookingStatus,
} from '../controllers/bookingController.js';

import { protectCustomer } from '../middleware/customerAuthMiddleware.js';
import { protectOwner } from '../middleware/authMiddleware.js';

import Owner from '../models/Owner.js';
import Customer from '../models/Customer.js';

const router = express.Router();

/**
 * Authenticate either an Owner or Customer.
 * Uses the same JWT_SECRET as the login controllers.
 */
const protectAnyUser = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'Not authorized. Token is required.',
    });
  }

  const token = authHeader.slice(7).trim();

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Not authorized. Token is required.',
    });
  }

  const secret = process.env.JWT_SECRET;

  if (!secret || secret.length < 32) {
    console.error('JWT_SECRET must contain at least 32 characters.');

    return res.status(500).json({
      success: false,
      message: 'Server authentication configuration error.',
    });
  }

  try {
    const decoded = jwt.verify(token, secret);

    if (
      !decoded ||
      typeof decoded !== 'object' ||
      typeof decoded.id !== 'string'
    ) {
      return res.status(401).json({
        success: false,
        message: 'Invalid authentication token.',
      });
    }

    if (decoded.role === 'owner') {
      const owner = await Owner.findById(decoded.id).select('-password');

      if (!owner) {
        return res.status(401).json({
          success: false,
          message: 'Owner account not found.',
        });
      }

      if (owner.isAuthorized === false) {
        return res.status(403).json({
          success: false,
          message: 'Owner account is deactivated.',
        });
      }

      req.owner = owner;
      req.user = {
        ...owner.toObject(),
        _id: owner._id,
        role: 'owner',
      };

      return next();
    }

    if (decoded.role === 'customer') {
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
          message: 'Customer account is deactivated.',
        });
      }

      req.customer = customer;
      req.user = {
        ...customer.toObject(),
        _id: customer._id,
        role: 'customer',
      };

      return next();
    }

    return res.status(403).json({
      success: false,
      message: 'Access denied. Unsupported account role.',
    });
  } catch (error) {
    if (
      error.name === 'TokenExpiredError' ||
      error.name === 'JsonWebTokenError' ||
      error.name === 'NotBeforeError'
    ) {
      return res.status(401).json({
        success: false,
        message:
          error.name === 'TokenExpiredError'
            ? 'Session expired. Please log in again.'
            : 'Not authorized. Invalid token.',
      });
    }

    return next(error);
  }
};

// Customer booking routes (supports both /my and /my-bookings)
router.post('/', protectCustomer, createBooking);
router.get('/my', protectCustomer, getMyBookings);
router.get('/my-bookings', protectCustomer, getMyBookings);

// Owner-only routes
router.get('/', protectOwner, getAllBookings);
router.patch('/:id/status', protectOwner, updateBookingStatus);
router.patch('/:id', protectOwner, updateBookingStatus);

// Shared routes with role and booking ownership checks
router.get('/:id', protectAnyUser, getBookingById);
router.patch('/:id/cancel', protectAnyUser, cancelBooking);

export default router;
