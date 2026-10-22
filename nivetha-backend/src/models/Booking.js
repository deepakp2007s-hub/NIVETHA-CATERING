
const mongoose = require("mongoose");

const bookingSchema = new mongoose.Schema(
  {
    customer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Customer",
      required: true,
      index: false,
    },

    eventType: {
      type: String,
      required: [true, "Event type is required"],
      trim: true,
      maxlength: [100, "Event type cannot exceed 100 characters"],
    },

    functionDate: {
      type: Date,
      required: [true, "Function date is required"],
    },

    functionTime: {
      type: String,
      required: [true, "Function time is required"],
      trim: true,
      match: [
        /^(?:[01]\d|2[0-3]):[0-5]\d$/,
        "Function time must be in HH:mm format",
      ],
    },

    location: {
      type: String,
      required: [true, "Event location is required"],
      trim: true,
      maxlength: [500, "Location cannot exceed 500 characters"],
    },

    numberOfPersons: {
      type: Number,
      required: [true, "Number of persons is required"],
      min: [1, "At least one person is required"],
      max: [1000000, "Number of persons exceeds the limit"],
      validate: {
        validator: Number.isSafeInteger,
        message: "Number of persons must be a whole number",
      },
    },

    cateringService: {
      type: String,
      trim: true,
      default: "cooking",
      maxlength: [100, "Catering service cannot exceed 100 characters"],
    },

    cateringServices: {
      type: [
        {
          type: String,
          trim: true,
          maxlength: [100, "Each catering service cannot exceed 100 characters"],
        },
      ],
      default: [],
    },

    mealType: {
      type: String,
      trim: true,
      default: "",
      maxlength: [50, "Meal type cannot exceed 50 characters"],
    },

    foodType: {
      type: String,
      enum: {
        values: ["veg", "non-veg", "both"],
        message: "Food type must be veg, non-veg, or both",
      },
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
          maxlength: [150, "Food name cannot exceed 150 characters"],
        },
      ],
      default: [],
    },

    extraRequirements: {
      type: String,
      trim: true,
      default: "",
      maxlength: [2000, "Extra requirements cannot exceed 2000 characters"],
    },

    status: {
      type: String,
      enum: {
        values: [
          "pending",
          "confirmed",
          "rejected",
          "cancelled",
          "completed",
        ],
        message: "Invalid booking status",
      },
      default: "pending",
      required: true,
    },
  },
  {
    timestamps: true,
    versionKey: false,
    strict: true,
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
