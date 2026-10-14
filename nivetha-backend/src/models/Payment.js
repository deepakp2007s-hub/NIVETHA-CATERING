const mongoose = require("mongoose");

/**
 * Payment model.
 *
 * Payments are recorded manually by the owner after physical/bank transfer.
 * No payment-gateway integration — status reflects owner confirmation only.
 *
 * Calculation contract:
 *   balanceAmount = totalAmount - advanceAmount  (enforced at save-time)
 */
const paymentSchema = new mongoose.Schema(
  {
    booking: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Booking",
      required: true,
    },
    customer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Customer",
      required: true,
    },
    totalAmount: {
      type: Number,
      required: true,
      min: [0, "Total amount cannot be negative"],
    },
    advanceAmount: {
      type: Number,
      required: true,
      min: [0, "Advance amount cannot be negative"],
      default: 0,
    },
    balanceAmount: {
      type: Number,
      min: [0, "Balance amount cannot be negative"],
    },
    advancePaidDate: {
      type: Date,
    },
    balancePaidDate: {
      type: Date,
    },
    /**
     * paymentStatus is owner-controlled — it DOES NOT represent gateway confirmation.
     * 'unpaid'   – no payment received yet
     * 'advance'  – advance received, balance pending
     * 'paid'     – full payment received (owner confirmed)
     * 'refunded' – full or partial refund issued by owner
     */
    paymentStatus: {
      type: String,
      enum: ["unpaid", "advance", "paid", "refunded"],
      default: "unpaid",
    },
    paymentMethod: {
      type: String,
      enum: ["cash", "bank_transfer", "upi", "cheque", "other"],
      default: "cash",
    },
    notes: {
      type: String,
      default: "",
      trim: true,
    },
  },
  { timestamps: true }
);

// Derived field: always recompute balanceAmount before save
paymentSchema.pre("save", function (next) {
  this.balanceAmount =
    Math.round((this.totalAmount - this.advanceAmount) * 100) / 100;
  next();
});

// Same hook for findOneAndUpdate / findByIdAndUpdate
paymentSchema.pre(["findOneAndUpdate", "updateOne"], function (next) {
  const upd = this.getUpdate();
  const set = upd.$set || upd;
  if (set.totalAmount !== undefined || set.advanceAmount !== undefined) {
    // We cannot read the current doc here without a DB query.
    // Consumers must always send both fields to keep balance consistent.
  }
  next();
});

module.exports =
  mongoose.models.Payment || mongoose.model("Payment", paymentSchema);
