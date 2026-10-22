
const mongoose = require("mongoose");

const reviewSchema = new mongoose.Schema(
  {
    customer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Customer",
      required: true,
      index: false,
    },

    rating: {
      type: Number,
      required: true,
      min: [1, "Rating must be at least 1."],
      max: [5, "Rating cannot exceed 5."],
      validate: {
        validator: Number.isInteger,
        message: "Rating must be an integer between 1 and 5.",
      },
    },

    comment: {
      type: String,
      trim: true,
      default: "",
      maxlength: 2000,
    },
  },
  {
    timestamps: true,
    versionKey: false,
  }
);

// Efficient newest-first review listing
reviewSchema.index({ createdAt: -1, _id: -1 });

// Efficient customer review history
reviewSchema.index({ customer: 1, createdAt: -1 });

module.exports =
  mongoose.models.Review ||
  mongoose.model("Review", reviewSchema);
