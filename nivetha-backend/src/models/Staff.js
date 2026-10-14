const mongoose = require("mongoose");

/**
 * Staff model.
 *
 * eventAssignments – links a staff member to one or more bookings,
 * with the role they will serve (cook, server, helper, etc.).
 */
const staffSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    phone: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    role: {
      type: String,
      required: true,
      trim: true,
      // e.g. "cook", "server", "helper", "manager", "driver"
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    dailyWage: {
      type: Number,
      min: [0, "Daily wage cannot be negative"],
      default: 0,
    },
    notes: {
      type: String,
      default: "",
      trim: true,
    },
    /**
     * Event assignments for this staff member.
     * Each entry links to a Booking and records the role for that event.
     */
    eventAssignments: [
      {
        booking: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Booking",
          required: true,
        },
        eventRole: {
          type: String,
          trim: true,
          default: "",
        },
        assignedDate: {
          type: Date,
          default: Date.now,
        },
      },
    ],
  },
  { timestamps: true }
);

module.exports =
  mongoose.models.Staff || mongoose.model("Staff", staffSchema);
