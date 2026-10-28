
import express from 'express';
import jwt from 'jsonwebtoken';

import {
  getPublicReviews,
  createReview,
  getAllReviewsForOwner,
  getReviewById,
  updateReviewStatus,
  deleteReview,
} from '../controllers/reviewController.js';

import { protectCustomer } from '../middleware/customerAuthMiddleware.js';
import { protectOwner } from '../middleware/authMiddleware.js';

import Owner from '../models/Owner.js';
import Customer from '../models/Customer.js';

const router = express.Router();

/**
 * Allow the review author or an authorized owner to delete a review.
 */
const protectAnyForDelete = async (req, res, next) => {
  try {
    const authorization = req.headers.authorization;

    if (!authorization || !authorization.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required.',
      });
    }

    const token = authorization.slice(7).trim();

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Authentication token is required.',
      });
    }

    const secret = process.env.JWT_SECRET;

    if (!secret || secret.length < 32) {
      return res.status(500).json({
        success: false,
        message: 'Authentication is not configured correctly.',
      });
    }

    const decoded = jwt.verify(token, secret);

    if (!decoded.id || typeof decoded.id !== 'string') {
      return res.status(401).json({
        success: false,
        message: 'Invalid authentication token.',
      });
    }

    if (decoded.role === 'owner') {
      const owner = await Owner.findById(decoded.id);

      if (!owner || owner.isAuthorized === false) {
        return res.status(403).json({
          success: false,
          message: 'Owner is not authorized.',
        });
      }

      req.user = owner;
      req.user.role = 'owner';

      return next();
    }

    if (decoded.role === 'customer') {
      const customer = await Customer.findById(decoded.id);

      if (!customer || customer.isActive === false) {
        return res.status(403).json({
          success: false,
          message: 'Customer account is inactive or unavailable.',
        });
      }

      req.user = customer;
      req.user.role = 'customer';

      return next();
    }

    return res.status(403).json({
      success: false,
      message: 'Unauthorized role.',
    });
  } catch (error) {
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired authentication token.',
      });
    }

    return next(error);
  }
};

// Public: view approved/public reviews.
router.get('/', getPublicReviews);

// Customer: submit a review.
router.post('/', protectCustomer, createReview);

// Owner: view reviews for moderation.
router.get('/all', protectOwner, getAllReviewsForOwner);

// Single review detail
router.get('/:id', getReviewById);

// Owner: moderate / approve / reject review
router.patch('/:id/approve', protectOwner, updateReviewStatus);
router.patch('/:id/status', protectOwner, updateReviewStatus);
router.patch('/:id', protectOwner, updateReviewStatus);

// Review author or owner: delete a review.
// Ownership authorization must also be checked inside deleteReview.
router.delete('/:id', protectAnyForDelete, deleteReview);

export default router;
