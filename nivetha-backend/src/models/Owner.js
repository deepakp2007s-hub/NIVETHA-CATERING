
const mongoose = require("mongoose");

const ownerSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Owner name is required"],
      trim: true,
      maxlength: [100, "Owner name cannot exceed 100 characters"],
    },

    phone: {
      type: String,
      required: [true, "Owner phone number is required"],
      unique: true,
      trim: true,
      match: [
        /^[6-9]\d{9}$/,
        "Enter a valid 10-digit Indian mobile number",
      ],
    },

    passwordHash: {
      type: String,
      required: [true, "Owner password hash is required"],
      select: false,
    },

    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
    versionKey: false,
    strict: true,
  }
);

module.exports =
  mongoose.models.Owner || mongoose.model("Owner", ownerSchema);
