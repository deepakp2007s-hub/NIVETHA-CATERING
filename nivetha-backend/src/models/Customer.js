
const mongoose = require("mongoose");

const customerSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
      maxlength: 100,
    },

    phone: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      match: /^[6-9]\d{9}$/,
    },

    passwordHash: {
      type: String,
      required: true,
      select: false,
    },

    email: {
      type: String,
      trim: true,
      lowercase: true,
      maxlength: 254,
      sparse: true,
      unique: true,
      validate: {
        validator: (value) =>
          value == null ||
          value === "" ||
          /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value),
        message: "Please provide a valid email address.",
      },
    },

    address: {
      type: String,
      trim: true,
      maxlength: 500,
      default: "",
    },
  },
  {
    timestamps: true,
    versionKey: false,
  }
);

// Support sorting customer records by creation date.
customerSchema.index({ createdAt: -1 });

module.exports =
  mongoose.models.Customer ||
  mongoose.model("Customer", customerSchema);
