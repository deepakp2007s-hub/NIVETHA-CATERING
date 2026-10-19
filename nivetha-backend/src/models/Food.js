
const mongoose = require("mongoose");

const foodSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
      maxlength: 150,
    },

    tamilName: {
      type: String,
      trim: true,
      default: "",
      maxlength: 150,
    },

    category: {
      type: String,
      required: true,
      trim: true,
      maxlength: 100,
    },

    type: {
      type: String,
      enum: ["veg", "non-veg", "both"],
      default: "veg",
      required: true,
    },

    description: {
      type: String,
      trim: true,
      default: "",
      maxlength: 1000,
    },

    price: {
      type: Number,
      required: true,
      min: 0,
      validate: {
        validator: Number.isFinite,
        message: "Price must be a valid number.",
      },
    },

    image: {
      type: String,
      trim: true,
      default: "",
      maxlength: 2048,
    },

    available: {
      type: Boolean,
      default: true,
      index: true,
    },
  },
  {
    timestamps: true,
    versionKey: false,
  }
);

// Indexes for menu sorting and filtering
foodSchema.index({ available: 1, category: 1, name: 1 });
foodSchema.index({ createdAt: -1 });

module.exports =
  mongoose.models.Food || mongoose.model("Food", foodSchema);
