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
 * Middleware allowing either authenticated Owner or authenticated Customer
 */
const protectAnyUser = async (req, res, next) => {
  let token;
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Not authorized. Token is required.',
    });
  }

  try {
    const secret = process.env.JWT_SECRET || 'nivetha_catering_jwt_secret_production_2026';
    const decoded = jwt.verify(token, secret);

    if (decoded.role === 'owner') {
      const owner = await Owner.findById(decoded.id);
      if (!owner) return res.status(401).json({ success: false, message: 'Owner not found' });
      req.owner = owner;
      req.user = owner;
      return next();
    } else if (decoded.role === 'customer') {
      const customer = await Customer.findById(decoded.id);
      if (!customer) return res.status(401).json({ success: false, message: 'Customer not found' });
      req.customer = customer;
      req.user = customer;
      return next();
    } else {
      return res.status(403).json({ success: false, message: 'Unauthorized role' });
    }
  } catch (error) {
    return res.status(401).json({ success: false, message: 'Invalid or expired token' });
  }
};

// Customer routes
router.post('/', protectCustomer, createBooking);
router.get('/my', protectCustomer, getMyBookings);

// Owner list all bookings
router.get('/', protectOwner, getAllBookings);

// Shared / Role-checked endpoints
router.get('/:id', protectAnyUser, getBookingById);
router.patch('/:id/cancel', protectAnyUser, cancelBooking);

// Owner update status
router.patch('/:id/status', protectOwner, updateBookingStatus);

export default router;
