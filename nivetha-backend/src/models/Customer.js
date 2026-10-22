
const mongoose = require("mongoose");

const customerSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Customer name is required"],
      trim: true,
      maxlength: [100, "Name cannot exceed 100 characters"],
    },

    phone: {
      type: String,
      required: [true, "Phone number is required"],
      unique: true,
      trim: true,
      match: [
        /^[6-9]\d{9}$/,
        "Enter a valid 10-digit Indian mobile number",
      ],
    },

    passwordHash: {
      type: String,
      required: [true, "Password hash is required"],
      select: false,
    },

    email: {
      type: String,
      trim: true,
      lowercase: true,
      maxlength: [254, "Email cannot exceed 254 characters"],
      sparse: true,
      unique: true,
      default: undefined,
      set: (value) =>
        typeof value === "string" && value.trim() === ""
          ? undefined
          : value,
      validate: {
        validator: (value) =>
          value == null || /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value),
        message: "Please provide a valid email address.",
      },
    },

    address: {
      type: String,
      trim: true,
      maxlength: [500, "Address cannot exceed 500 characters"],
      default: "",
    },
  },
  {
    timestamps: true,
    versionKey: false,
    strict: true,
  }
);

// Customer registration/history lookup
customerSchema.index({ createdAt: -1 });

module.exports =
  mongoose.models.Customer ||
  mongoose.model("Customer", customerSchema);
