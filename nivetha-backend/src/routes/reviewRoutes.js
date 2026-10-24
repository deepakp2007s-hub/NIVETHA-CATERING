import express from 'express';
import jwt from 'jsonwebtoken';
import {
  getPublicReviews,
  createReview,
  getAllReviewsForOwner,
  deleteReview,
} from '../controllers/reviewController.js';
import { protectCustomer } from '../middleware/customerAuthMiddleware.js';
import { protectOwner } from '../middleware/authMiddleware.js';
import Owner from '../models/Owner.js';
import Customer from '../models/Customer.js';

const router = express.Router();

/**
 * Middleware allowing either Owner or Customer for review deletion
 */
const protectAnyForDelete = async (req, res, next) => {
  let token;
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return res.status(401).json({ success: false, message: 'Authentication required' });
  }

  try {
    const secret = process.env.JWT_SECRET || 'nivetha_catering_jwt_secret_production_2026';
    const decoded = jwt.verify(token, secret);
    if (decoded.role === 'owner') {
      const owner = await Owner.findById(decoded.id);
      if (!owner) return res.status(401).json({ success: false, message: 'Owner not found' });
      req.user = owner;
      return next();
    } else if (decoded.role === 'customer') {
      const customer = await Customer.findById(decoded.id);
      if (!customer) return res.status(401).json({ success: false, message: 'Customer not found' });
      req.user = customer;
      return next();
    }
    return res.status(403).json({ success: false, message: 'Unauthorized role' });
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid token' });
  }
};

// Public reviews
router.get('/', getPublicReviews);

// Customer submits review
router.post('/', protectCustomer, createReview);

// Owner moderates reviews
router.get('/all', protectOwner, getAllReviewsForOwner);

// Author or Owner deletes review
router.delete('/:id', protectAnyForDelete, deleteReview);

export default router;
