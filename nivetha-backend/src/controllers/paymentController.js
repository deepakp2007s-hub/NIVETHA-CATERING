/**
 * Payment Controller — owner-only management of booking payments.
 *
 * IMPORTANT: This module records manual payments (cash / bank transfer / UPI).
 * It does NOT integrate with any payment gateway and DOES NOT mark a payment
 * as "successful" on behalf of a provider. All status changes are
 * owner-initiated confirmations of offline transactions.
 *
 * Balance calculation:
 *   balanceAmount = totalAmount - advanceAmount
 * This is enforced in the Payment pre-save hook (see models/Payment.js).
 */

"use strict";

const mongoose = require("mongoose");
const Payment = require("../models/Payment");
const Booking = require("../models/Booking");

// ─── helpers ──────────────────────────────────────────────────────────────────

function isPositiveFinite(n) {
  return typeof n === "number" && isFinite(n) && n >= 0;
}

function parseAmount(raw) {
  const n = Number(raw);
  return isFinite(n) && n >= 0 ? Math.round(n * 100) / 100 : null;
}

// ─── list all payments ────────────────────────────────────────────────────────

const getPayments = async (req, res, next) => {
  try {
    const payments = await Payment.find()
      .sort({ createdAt: -1 })
      .populate("booking", "eventType functionDate status")
      .populate("customer", "name phone");

    return res.json({
      success: true,
      count: payments.length,
      data: payments,
    });
  } catch (err) {
    next(err);
  }
};

// ─── single payment by id ─────────────────────────────────────────────────────

const getPaymentById = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid payment ID" });
    }

    const payment = await Payment.findById(req.params.id)
      .populate("booking", "eventType functionDate numberOfPersons status")
      .populate("customer", "name phone email");

    if (!payment) {
      return res.status(404).json({ success: false, message: "Payment not found" });
    }

    return res.json({ success: true, data: payment });
  } catch (err) {
    next(err);
  }
};

// ─── payments for a single booking ───────────────────────────────────────────

const getPaymentsByBooking = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.bookingId)) {
      return res.status(400).json({ success: false, message: "Invalid booking ID" });
    }

    const payments = await Payment.find({ booking: req.params.bookingId })
      .sort({ createdAt: -1 })
      .populate("customer", "name phone");

    return res.json({ success: true, count: payments.length, data: payments });
  } catch (err) {
    next(err);
  }
};

// ─── create payment record ────────────────────────────────────────────────────

const createPayment = async (req, res, next) => {
  try {
    const {
      bookingId,
      totalAmount: rawTotal,
      advanceAmount: rawAdvance = 0,
      paymentMethod,
      advancePaidDate,
      notes,
    } = req.body || {};

    // Validate booking reference
    if (!bookingId || !mongoose.isValidObjectId(bookingId)) {
      return res.status(400).json({
        success: false,
        message: "A valid bookingId is required",
      });
    }

    const booking = await Booking.findById(bookingId);
    if (!booking) {
      return res.status(404).json({ success: false, message: "Booking not found" });
    }

    // Prevent duplicate payment records for the same booking
    const existing = await Payment.findOne({ booking: bookingId });
    if (existing) {
      return res.status(409).json({
        success: false,
        message: "A payment record already exists for this booking. Use update instead.",
        data: existing,
      });
    }

    // Parse and validate amounts
    const totalAmount = parseAmount(rawTotal);
    const advanceAmount = parseAmount(rawAdvance);

    if (totalAmount === null || totalAmount <= 0) {
      return res.status(400).json({
        success: false,
        message: "totalAmount must be a positive number",
      });
    }

    if (advanceAmount === null) {
      return res.status(400).json({
        success: false,
        message: "advanceAmount must be a non-negative number",
      });
    }

    if (advanceAmount > totalAmount) {
      return res.status(400).json({
        success: false,
        message: "Advance amount cannot exceed the total amount",
      });
    }

    // Determine initial status
    let paymentStatus = "unpaid";
    if (advanceAmount >= totalAmount) paymentStatus = "paid";
    else if (advanceAmount > 0) paymentStatus = "advance";

    const payment = await Payment.create({
      booking: bookingId,
      customer: booking.customer,
      totalAmount,
      advanceAmount,
      // balanceAmount computed by pre-save hook
      paymentMethod: paymentMethod || "cash",
      paymentStatus,
      advancePaidDate: advanceAmount > 0 ? advancePaidDate || new Date() : undefined,
      notes: notes || "",
    });

    return res.status(201).json({
      success: true,
      message: "Payment record created",
      data: payment,
    });
  } catch (err) {
    next(err);
  }
};

// ─── update payment record ────────────────────────────────────────────────────

const updatePayment = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid payment ID" });
    }

    const payment = await Payment.findById(req.params.id);
    if (!payment) {
      return res.status(404).json({ success: false, message: "Payment not found" });
    }

    const {
      totalAmount: rawTotal,
      advanceAmount: rawAdvance,
      paymentMethod,
      paymentStatus,
      advancePaidDate,
      balancePaidDate,
      notes,
    } = req.body || {};

    // Apply amount updates with validation
    if (rawTotal !== undefined) {
      const t = parseAmount(rawTotal);
      if (t === null || t <= 0) {
        return res.status(400).json({ success: false, message: "totalAmount must be a positive number" });
      }
      payment.totalAmount = t;
    }

    if (rawAdvance !== undefined) {
      const a = parseAmount(rawAdvance);
      if (a === null) {
        return res.status(400).json({ success: false, message: "advanceAmount must be a non-negative number" });
      }
      if (a > payment.totalAmount) {
        return res.status(400).json({ success: false, message: "Advance amount cannot exceed total amount" });
      }
      payment.advanceAmount = a;
    }

    const validStatuses = ["unpaid", "advance", "paid", "refunded"];
    if (paymentStatus !== undefined) {
      if (!validStatuses.includes(paymentStatus)) {
        return res.status(400).json({
          success: false,
          message: `paymentStatus must be one of: ${validStatuses.join(", ")}`,
        });
      }
      payment.paymentStatus = paymentStatus;
    }

    const validMethods = ["cash", "bank_transfer", "upi", "cheque", "other"];
    if (paymentMethod !== undefined) {
      if (!validMethods.includes(paymentMethod)) {
        return res.status(400).json({
          success: false,
          message: `paymentMethod must be one of: ${validMethods.join(", ")}`,
        });
      }
      payment.paymentMethod = paymentMethod;
    }

    if (advancePaidDate !== undefined) payment.advancePaidDate = advancePaidDate;
    if (balancePaidDate !== undefined) payment.balancePaidDate = balancePaidDate;
    if (notes !== undefined) payment.notes = notes;

    await payment.save(); // triggers pre-save hook to recompute balanceAmount

    return res.json({ success: true, message: "Payment updated", data: payment });
  } catch (err) {
    next(err);
  }
};

// ─── delete payment record ────────────────────────────────────────────────────

const deletePayment = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid payment ID" });
    }

    const payment = await Payment.findByIdAndDelete(req.params.id);
    if (!payment) {
      return res.status(404).json({ success: false, message: "Payment not found" });
    }

    return res.json({ success: true, message: "Payment record deleted" });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getPayments,
  getPaymentById,
  getPaymentsByBooking,
  createPayment,
  updatePayment,
  deletePayment,
};
