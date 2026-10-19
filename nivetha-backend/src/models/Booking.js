
const mongoose = require("mongoose");

const bookingSchema = new mongoose.Schema(
  {
    customer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Customer",
      required: true,
    },

    eventType: {
      type: String,
      required: true,
      trim: true,
      maxlength: 100,
    },

    functionDate: {
      type: Date,
      required: true,
    },

    functionTime: {
      type: String,
      required: true,
      trim: true,
      match: [
        /^(?:[01]\d|2[0-3]):[0-5]\d$/,
        "Function time must be in HH:mm format",
      ],
    },

    location: {
      type: String,
      required: true,
      trim: true,
      maxlength: 500,
    },

    numberOfPersons: {
      type: Number,
      required: true,
      min: 1,
      max: 1000000,
      validate: {
        validator: Number.isSafeInteger,
        message: "Number of persons must be a whole number",
      },
    },

    cateringService: {
      type: String,
      trim: true,
      default: "cooking",
      maxlength: 100,
    },

    cateringServices: {
      type: [
        {
          type: String,
          trim: true,
          maxlength: 100,
        },
      ],
      default: [],
    },

    mealType: {
      type: String,
      trim: true,
      default: "",
      maxlength: 50,
    },

    foodType: {
      type: String,
      enum: ["veg", "non-veg", "both"],
      default: "veg",
      required: true,
    },

    selectedFoods: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Food",
      },
    ],

    selectedFoodNames: {
      type: [
        {
          type: String,
          trim: true,
          maxlength: 150,
        },
      ],
      default: [],
    },

    extraRequirements: {
      type: String,
      trim: true,
      default: "",
      maxlength: 2000,
    },

    status: {
      type: String,
      enum: [
        "pending",
        "confirmed",
        "rejected",
        "cancelled",
        "completed",
      ],
      default: "pending",
      required: true,
    },
  },
  {
    timestamps: true,
    versionKey: false,
  }
);

// Customer booking history
bookingSchema.index({ customer: 1, createdAt: -1 });

// Owner booking status dashboard
bookingSchema.index({ status: 1, createdAt: -1 });

// Event scheduling
bookingSchema.index({ functionDate: 1, status: 1 });

module.exports =
  mongoose.models.Booking ||
  mongoose.model("Booking", bookingSchema);
