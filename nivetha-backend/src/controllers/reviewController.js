import Review from '../models/Review.js';
import Booking from '../models/Booking.js';

/**
 * @desc    Get All Approved Reviews (Public)
 * @route   GET /api/reviews
 * @access  Public
 */
export const getPublicReviews = async (req, res, next) => {
  try {
    const reviews = await Review.find({ isApproved: true })
      .sort({ createdAt: -1 })
      .limit(50)
      .lean();

    // Average rating
    const avgStats = await Review.aggregate([
      { $match: { isApproved: true } },
      {
        $group: {
          _id: null,
          avgRating: { $avg: '$rating' },
          totalReviews: { $sum: 1 },
        },
      },
    ]);

    const averageRating = avgStats.length > 0 ? Number(avgStats[0].avgRating.toFixed(1)) : 5.0;
    const totalReviews = avgStats.length > 0 ? avgStats[0].totalReviews : 0;

    res.json({
      success: true,
      averageRating,
      totalReviews,
      count: reviews.length,
      reviews,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Submit a Review (Customer Only)
 * @route   POST /api/reviews
 * @access  Private (Customer)
 */
export const createReview = async (req, res, next) => {
  try {
    const { rating, comment, bookingId } = req.body;

    if (!rating || !comment) {
      return res.status(400).json({
        success: false,
        message: 'Rating and comment are required.',
      });
    }

    const numericRating = Number(rating);
    if (isNaN(numericRating) || numericRating < 1 || numericRating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be a number between 1 and 5.',
      });
    }

    let bookingRef = null;
    if (bookingId) {
      const booking = await Booking.findOne({
        $or: [{ _id: bookingId }, { bookingId }],
        customer: req.customer._id,
      });
      if (booking) {
        bookingRef = booking._id;
      }
    }

    const review = await Review.create({
      customer: req.customer._id,
      customerName: req.customer.name,
      booking: bookingRef,
      rating: numericRating,
      comment: comment.trim(),
      isApproved: true,
    });

    res.status(201).json({
      success: true,
      message: 'Thank you for your feedback!',
      review,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get All Reviews for Owner Moderation
 * @route   GET /api/reviews/all
 * @access  Private (Owner Only)
 */
export const getAllReviewsForOwner = async (req, res, next) => {
  try {
    const reviews = await Review.find().sort({ createdAt: -1 });

    res.json({
      success: true,
      count: reviews.length,
      reviews,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Delete a Review
 * @route   DELETE /api/reviews/:id
 * @access  Private (Owner or Author)
 */
export const deleteReview = async (req, res, next) => {
  try {
    const review = await Review.findById(req.params.id);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found.',
      });
    }

    // Check authorization: Owner or author
    const isAuthor = req.user.role === 'customer' && review.customer.toString() === req.user._id.toString();
    const isOwner = req.user.role === 'owner';

    if (!isAuthor && !isOwner) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this review.',
      });
    }

    await Review.deleteOne({ _id: review._id });

    res.json({
      success: true,
      message: 'Review deleted successfully.',
    });
  } catch (error) {
    next(error);
  }
};
