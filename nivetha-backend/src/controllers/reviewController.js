
const mongoose = require("mongoose");
const Review = require("../models/Review");

// Owner: Get all reviews with pagination
const getReviews = async (req, res, next) => {
  try {
    const parsedPage = Number.parseInt(req.query.page, 10);
    const parsedLimit = Number.parseInt(req.query.limit, 10);

    const page =
      Number.isSafeInteger(parsedPage) && parsedPage > 0
        ? parsedPage
        : 1;

    const limit =
      Number.isSafeInteger(parsedLimit) && parsedLimit > 0
        ? Math.min(parsedLimit, 100)
        : 20;

    const skip = (page - 1) * limit;

    const [reviews, total] = await Promise.all([
      Review.find()
        .sort({ createdAt: -1, _id: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      Review.countDocuments(),
    ]);

    return res.status(200).json({
      success: true,
      data: reviews,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        hasNextPage: page * limit < total,
        hasPreviousPage: page > 1,
      },
    });
  } catch (error) {
    return next(error);
  }
};

// Customer: Submit a review
const createReview = async (req, res, next) => {
  try {
    const customerId = req.user?.id || req.user?._id;

    if (
      !customerId ||
      !mongoose.isValidObjectId(String(customerId))
    ) {
      return res.status(401).json({
        success: false,
        message: "Valid customer authentication is required.",
      });
    }

    const body = req.body || {};
    const { rating, comment } = body;

    const parsedRating =
      typeof rating === "number" ? rating : Number(rating);

    if (
      rating === undefined ||
      rating === null ||
      rating === "" ||
      !Number.isInteger(parsedRating) ||
      parsedRating < 1 ||
      parsedRating > 5
    ) {
      return res.status(400).json({
        success: false,
        message: "Rating must be an integer between 1 and 5.",
      });
    }

    if (
      comment !== undefined &&
      (typeof comment !== "string" || comment.trim().length > 2000)
    ) {
      return res.status(400).json({
        success: false,
        message: "Comment must be text with at most 2000 characters.",
      });
    }

    const review = await Review.create({
      customer: customerId,
      rating: parsedRating,
      comment: typeof comment === "string" ? comment.trim() : "",
    });

    return res.status(201).json({
      success: true,
      message: "Review submitted successfully.",
      data: review,
    });
  } catch (error) {
    if (error.name === "ValidationError") {
      return res.status(400).json({
        success: false,
        message: "Invalid review data.",
      });
    }

    if (error.code === 11000) {
      return res.status(409).json({
        success: false,
        message: "A review already exists for this record.",
      });
    }

    return next(error);
  }
};

module.exports = {
  getReviews,
  createReview,
};
