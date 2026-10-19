
const mongoose = require("mongoose");
const Review = require("../models/Review");

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

const createReview = async (req, res, next) => {
  try {
    const { rating, comment } = req.body;

    if (
      typeof rating !== "number" ||
      !Number.isInteger(rating) ||
      rating < 1 ||
      rating > 5
    ) {
      return res.status(400).json({
        success: false,
        message: "Rating must be an integer between 1 and 5",
      });
    }

    if (
      comment !== undefined &&
      (typeof comment !== "string" || comment.trim().length > 2000)
    ) {
      return res.status(400).json({
        success: false,
        message: "Comment must be text with at most 2000 characters",
      });
    }

    if (!mongoose.isValidObjectId(req.user.id)) {
      return res.status(401).json({
        success: false,
        message: "Invalid customer authentication",
      });
    }

    const review = await Review.create({
      customer: req.user.id,
      rating,
      comment: typeof comment === "string" ? comment.trim() : "",
    });

    return res.status(201).json({
      success: true,
      message: "Review submitted successfully",
      data: review,
    });
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  getReviews,
  createReview,
};
