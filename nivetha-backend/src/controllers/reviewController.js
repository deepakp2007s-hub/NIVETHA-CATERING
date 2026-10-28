
import mongoose from 'mongoose';
import Review from '../models/Review.js';
import Booking from '../models/Booking.js';

/**
 * GET /api/reviews
 * Get approved public reviews.
 */
export const getPublicReviews = async (req, res, next) => {
  try {
    const [reviews, avgStats] = await Promise.all([
      Review.find({ isApproved: true })
        .sort({ createdAt: -1 })
        .limit(50)
        .lean(),

      Review.aggregate([
        { $match: { isApproved: true } },
        {
          $group: {
            _id: null,
            avgRating: { $avg: '$rating' },
            totalReviews: { $sum: 1 },
          },
        },
      ]),
    ]);

    const averageRating = avgStats[0]
      ? Number(avgStats[0].avgRating.toFixed(1))
      : 0;

    const totalReviews = avgStats[0]?.totalReviews ?? 0;

    return res.status(200).json({
      success: true,
      averageRating,
      totalReviews,
      count: reviews.length,
      reviews,
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * POST /api/reviews
 * Submit a review as an authenticated customer.
 */
export const createReview = async (req, res, next) => {
  try {
    if (!req.customer?._id) {
      return res.status(401).json({
        success: false,
        message: 'Customer authentication required.',
      });
    }

    const { rating, comment, bookingId } = req.body;

    if (rating === undefined || rating === null || rating === '') {
      return res.status(400).json({
        success: false,
        message: 'Rating is required.',
      });
    }

    const numericRating = Number(rating);

    if (
      !Number.isInteger(numericRating) ||
      numericRating < 1 ||
      numericRating > 5
    ) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be a whole number between 1 and 5.',
      });
    }

    if (typeof comment !== 'string' || !comment.trim()) {
      return res.status(400).json({
        success: false,
        message: 'A review comment is required.',
      });
    }

    if (comment.trim().length > 2000) {
      return res.status(400).json({
        success: false,
        message: 'Review comment cannot exceed 2000 characters.',
      });
    }

    let bookingRef = null;

    if (bookingId !== undefined && bookingId !== null && bookingId !== '') {
      if (typeof bookingId !== 'string') {
        return res.status(400).json({
          success: false,
          message: 'Invalid booking ID.',
        });
      }

      const conditions = [{ bookingId }];

      if (mongoose.isValidObjectId(bookingId)) {
        conditions.push({ _id: bookingId });
      }

      const booking = await Booking.findOne({
        $or: conditions,
        customer: req.customer._id,
      }).select('_id');

      if (!booking) {
        return res.status(400).json({
          success: false,
          message: 'Booking not found for this customer.',
        });
      }

      bookingRef = booking._id;
    }

    const review = await Review.create({
      customer: req.customer._id,
      customerName: req.customer.name,
      booking: bookingRef,
      rating: numericRating,
      comment: comment.trim(),
      isApproved: false,
    });

    return res.status(201).json({
      success: true,
      message: 'Thank you! Your review has been submitted for approval.',
      review,
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * GET /api/reviews/all
 * Get reviews for owner moderation.
 */
export const getAllReviewsForOwner = async (req, res, next) => {
  try {
    const reviews = await Review.find()
      .sort({ createdAt: -1 })
      .lean();

    return res.status(200).json({
      success: true,
      count: reviews.length,
      reviews,
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * DELETE /api/reviews/:id
 * Review author or owner may delete a review.
 */
export const deleteReview = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid review ID.',
      });
    }

    const review = await Review.findById(id);

    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found.',
      });
    }

    const user = req.user;

    if (!user?._id || !user.role) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required.',
      });
    }

    const isAuthor =
      user.role === 'customer' &&
      review.customer?.toString() === user._id.toString();

    const isOwner = user.role === 'owner';

    if (!isAuthor && !isOwner) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this review.',
      });
    }

    await Review.deleteOne({ _id: review._id });

    return res.status(200).json({
      success: true,
      message: 'Review deleted successfully.',
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * GET /api/reviews/:id
 * Get a single review by ID.
 */
export const getReviewById = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid review ID.',
      });
    }

    const review = await Review.findById(id).lean();

    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found.',
      });
    }

    return res.status(200).json({
      success: true,
      review,
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * PATCH /api/reviews/:id/status
 * Owner can approve/reject review.
 */
export const updateReviewStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { isApproved } = req.body || {};

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid review ID.',
      });
    }

    const review = await Review.findById(id);

    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found.',
      });
    }

    if (isApproved !== undefined) {
      review.isApproved = Boolean(isApproved);
    }

    await review.save();

    return res.status(200).json({
      success: true,
      message: `Review ${review.isApproved ? 'approved' : 'hidden'} successfully.`,
      review,
    });
  } catch (error) {
    return next(error);
  }
};

