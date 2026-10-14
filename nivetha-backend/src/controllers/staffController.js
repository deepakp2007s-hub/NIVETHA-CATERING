/**
 * Staff Controller — owner-only management of staff members.
 * Supports CRUD + assignment to bookings.
 */

"use strict";

const mongoose = require("mongoose");
const Staff = require("../models/Staff");
const Booking = require("../models/Booking");

// ─── list all staff ───────────────────────────────────────────────────────────

const getStaff = async (req, res, next) => {
  try {
    const filter = {};
    if (req.query.isActive !== undefined) {
      filter.isActive = req.query.isActive === "true";
    }
    const staff = await Staff.find(filter)
      .sort({ name: 1 })
      .populate("eventAssignments.booking", "eventType functionDate status");

    return res.json({ success: true, count: staff.length, data: staff });
  } catch (err) {
    next(err);
  }
};

// ─── single staff member ──────────────────────────────────────────────────────

const getStaffById = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid staff ID" });
    }
    const member = await Staff.findById(req.params.id)
      .populate("eventAssignments.booking", "eventType functionDate numberOfPersons status");

    if (!member) {
      return res.status(404).json({ success: false, message: "Staff member not found" });
    }
    return res.json({ success: true, data: member });
  } catch (err) {
    next(err);
  }
};

// ─── create staff member ──────────────────────────────────────────────────────

const createStaff = async (req, res, next) => {
  try {
    const { name, phone, role, isActive, dailyWage, notes } = req.body || {};

    if (!name?.trim()) {
      return res.status(400).json({ success: false, message: "Staff name is required" });
    }

    if (!phone?.trim()) {
      return res.status(400).json({ success: false, message: "Phone number is required" });
    }

    if (!/^[6-9]\d{9}$/.test(phone.trim())) {
      return res.status(400).json({
        success: false,
        message: "Enter a valid 10-digit Indian mobile number",
      });
    }

    if (!role?.trim()) {
      return res.status(400).json({ success: false, message: "Role is required (e.g. cook, server, helper)" });
    }

    // Check for duplicate phone
    const existing = await Staff.findOne({ phone: phone.trim() });
    if (existing) {
      return res.status(409).json({
        success: false,
        message: "A staff member with this phone number already exists",
      });
    }

    const member = await Staff.create({
      name: name.trim(),
      phone: phone.trim(),
      role: role.trim(),
      isActive: isActive !== undefined ? Boolean(isActive) : true,
      dailyWage: dailyWage ?? 0,
      notes: notes?.trim() || "",
    });

    return res.status(201).json({ success: true, message: "Staff member created", data: member });
  } catch (err) {
    next(err);
  }
};

// ─── update staff member ──────────────────────────────────────────────────────

const updateStaff = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid staff ID" });
    }

    const allowed = ["name", "phone", "role", "isActive", "dailyWage", "notes"];
    const updates = {};
    for (const key of allowed) {
      if (Object.prototype.hasOwnProperty.call(req.body || {}, key)) {
        updates[key] = req.body[key];
      }
    }

    if (updates.phone && !/^[6-9]\d{9}$/.test(updates.phone.trim())) {
      return res.status(400).json({
        success: false,
        message: "Enter a valid 10-digit Indian mobile number",
      });
    }

    const member = await Staff.findByIdAndUpdate(
      req.params.id,
      { $set: updates },
      { new: true, runValidators: true }
    );

    if (!member) {
      return res.status(404).json({ success: false, message: "Staff member not found" });
    }

    return res.json({ success: true, message: "Staff member updated", data: member });
  } catch (err) {
    next(err);
  }
};

// ─── delete staff member ──────────────────────────────────────────────────────

const deleteStaff = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid staff ID" });
    }
    const member = await Staff.findByIdAndDelete(req.params.id);
    if (!member) {
      return res.status(404).json({ success: false, message: "Staff member not found" });
    }
    return res.json({ success: true, message: "Staff member deleted" });
  } catch (err) {
    next(err);
  }
};

// ─── assign staff to a booking ────────────────────────────────────────────────

const assignToBooking = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid staff ID" });
    }

    const { bookingId, eventRole } = req.body || {};

    if (!bookingId || !mongoose.isValidObjectId(bookingId)) {
      return res.status(400).json({ success: false, message: "A valid bookingId is required" });
    }

    const booking = await Booking.findById(bookingId);
    if (!booking) {
      return res.status(404).json({ success: false, message: "Booking not found" });
    }

    const member = await Staff.findById(req.params.id);
    if (!member) {
      return res.status(404).json({ success: false, message: "Staff member not found" });
    }
    if (!member.isActive) {
      return res.status(400).json({ success: false, message: "Inactive staff cannot be assigned to events" });
    }

    // Prevent duplicate assignment to same booking
    const alreadyAssigned = member.eventAssignments.some(
      (a) => a.booking.toString() === bookingId
    );
    if (alreadyAssigned) {
      return res.status(409).json({
        success: false,
        message: "This staff member is already assigned to that booking",
      });
    }

    member.eventAssignments.push({
      booking: bookingId,
      eventRole: eventRole?.trim() || member.role,
      assignedDate: new Date(),
    });

    await member.save();

    return res.json({ success: true, message: "Staff assigned to booking", data: member });
  } catch (err) {
    next(err);
  }
};

// ─── remove assignment from a booking ────────────────────────────────────────

const removeFromBooking = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid staff ID" });
    }

    const { bookingId } = req.body || {};
    if (!bookingId || !mongoose.isValidObjectId(bookingId)) {
      return res.status(400).json({ success: false, message: "A valid bookingId is required" });
    }

    const member = await Staff.findById(req.params.id);
    if (!member) {
      return res.status(404).json({ success: false, message: "Staff member not found" });
    }

    const before = member.eventAssignments.length;
    member.eventAssignments = member.eventAssignments.filter(
      (a) => a.booking.toString() !== bookingId
    );

    if (member.eventAssignments.length === before) {
      return res.status(404).json({ success: false, message: "Assignment not found" });
    }

    await member.save();

    return res.json({ success: true, message: "Assignment removed", data: member });
  } catch (err) {
    next(err);
  }
};

// ─── staff assigned to a specific booking ────────────────────────────────────

const getStaffByBooking = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.bookingId)) {
      return res.status(400).json({ success: false, message: "Invalid booking ID" });
    }

    const staff = await Staff.find({
      "eventAssignments.booking": req.params.bookingId,
    }).select("name phone role isActive eventAssignments dailyWage");

    return res.json({ success: true, count: staff.length, data: staff });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getStaff,
  getStaffById,
  createStaff,
  updateStaff,
  deleteStaff,
  assignToBooking,
  removeFromBooking,
  getStaffByBooking,
};
