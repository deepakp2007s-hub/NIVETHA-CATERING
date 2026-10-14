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
    },
    functionDate: {
      type: Date,
      required: true,
    },
    functionTime: {
      type: String,
      default: "",
    },
    location: {
      type: String,
      required: true,
    },
    numberOfPersons: {
      type: Number,
      required: true,
      min: 1,
    },
    cateringService: {
      type: String,
      default: "cooking",
    },
    cateringServices: {
      type: [String],
      default: [],
    },
    mealType: {
      type: String,
      default: "",
    },
    foodType: {
      type: String,
      default: "veg",
    },
    selectedFoods: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Food",
      },
    ],
    selectedFoodNames: {
      type: [String],
      default: [],
    },
    extraRequirements: {
      type: String,
      default: "",
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
    },
  },
  { timestamps: true }
);

module.exports =
  mongoose.models.Booking || mongoose.model("Booking", bookingSchema);
