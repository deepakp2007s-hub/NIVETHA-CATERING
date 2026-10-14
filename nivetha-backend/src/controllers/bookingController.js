const mongoose = require("mongoose");
const Booking = require("../models/Booking");

const bookingFields = [
  "eventType",
  "functionDate",
  "functionTime",
  "location",
  "numberOfPersons",
  "cateringService",
  "cateringServices",
  "mealType",
  "foodType",
  "selectedFoods",
  "selectedFoodNames",
  "extraRequirements",
];

function normalizeBookingInput(body) {
  const input = {};
  for (const field of bookingFields) {
    if (Object.prototype.hasOwnProperty.call(body, field)) input[field] = body[field];
  }

  for (const field of ["eventType", "functionTime", "location", "extraRequirements"]) {
    if (typeof input[field] === "string") input[field] = input[field].trim();
  }

  // Preserve the legacy singular field while accepting the customer app's list.
  if (Array.isArray(input.cateringServices)) {
    input.cateringServices = input.cateringServices
      .filter((item) => typeof item === "string")
      .map((item) => item.trim())
      .filter(Boolean);
    if (!input.cateringService && input.cateringServices.length) {
      input.cateringService = input.cateringServices.join(", ");
    }
  }

  // The menu UI can select live Food documents or offline/sample entries.
  // Keep only valid references and separately persist display names for every choice.
  const selectedFoods = Array.isArray(input.selectedFoods) ? input.selectedFoods : [];
  input.selectedFoodNames = selectedFoods
    .map((food) => (typeof food === "string" ? food : food?.name))
    .filter((name) => typeof name === "string")
    .map((name) => name.trim())
    .filter(Boolean);
  input.selectedFoods = selectedFoods
    .map((food) => (typeof food === "string" ? food : food?._id || food?.id))
    .filter((id) => typeof id === "string" && mongoose.isValidObjectId(id));
  return input;
}

function getCalendarDate(value) {
  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    const year = value.getFullYear();
    const month = String(value.getMonth() + 1).padStart(2, "0");
    const day = String(value.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
  }
  if (typeof value !== "string") return null;

  const match = /^(\d{4})-(\d{2})-(\d{2})(?:$|T)/.exec(value);
  if (!match) return null;
  const [, yearText, monthText, dayText] = match;
  const year = Number(yearText);
  const month = Number(monthText);
  const day = Number(dayText);
  const check = new Date(Date.UTC(year, month - 1, day));
  if (
    check.getUTCFullYear() !== year ||
    check.getUTCMonth() + 1 !== month ||
    check.getUTCDate() !== day
  ) return null;
  if (value.includes("T") && Number.isNaN(new Date(value).getTime())) return null;
  return `${yearText}-${monthText}-${dayText}`;
}

function validateNewBooking(input, { requireCateringServices = false } = {}) {
  if (typeof input.eventType !== "string" || !input.eventType.trim()) return "Event type is required.";
  const eventDate = getCalendarDate(input.functionDate);
  if (!eventDate) {
    return "A valid function date is required.";
  }
  if (typeof input.location !== "string" || !input.location.trim()) return "Event location is required.";
  if (typeof input.functionTime !== "string" || !/^(?:[01]\d|2[0-3]):[0-5]\d$/.test(input.functionTime)) {
    return "A valid function time (HH:mm) is required.";
  }
  const personsType = typeof input.numberOfPersons;
  const persons = Number(input.numberOfPersons);
  if (
    !["number", "string"].includes(personsType) ||
    (personsType === "string" && !input.numberOfPersons.trim()) ||
    !Number.isInteger(persons) ||
    !Number.isFinite(persons) ||
    persons < 1
  ) {
    return "Number of persons must be a positive whole number.";
  }
  // Convert to Date object for proper comparison (today inclusive)
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  // Parse as LOCAL midnight (not UTC) to avoid timezone-offset rejecting today
  const [yy, mm, dd] = eventDate.split("-").map(Number);
  const funcDate = new Date(yy, mm - 1, dd);
  if (isNaN(funcDate.getTime())) {
    return "A valid function date is required.";
  }
  funcDate.setHours(0, 0, 0, 0);
  if (funcDate < today) {
    return "Function date cannot be in the past.";
  }
  if (
    requireCateringServices &&
    !(Array.isArray(input.cateringServices) && input.cateringServices.length > 0) &&
    !(typeof input.cateringService === "string" && input.cateringService.trim())
  ) return "Select at least one catering service.";
  return null;
}

const getBookings = async (req, res, next) => {
  try {
    const bookings = await Booking.find()
      .sort({ createdAt: -1 })
      .populate("customer", "name phone email")
      .populate("selectedFoods", "name category type");
    return res.json({ success: true, count: bookings.length, data: bookings });
  } catch (error) {
    next(error);
  }
};

const createBooking = async (req, res, next) => {
  try {
    const input = normalizeBookingInput(req.body || {});
    const validationError = validateNewBooking(input, { requireCateringServices: true });
    if (validationError) {
      return res.status(400).json({ success: false, message: validationError });
    }
    const booking = await Booking.create({
      ...input,
      customer: req.user.id,
      numberOfPersons: Number(input.numberOfPersons),
      status: "pending",
    });
    return res.status(201).json({
      success: true,
      message: "Booking created successfully",
      data: booking,
    });
  } catch (error) {
    next(error);
  }
};

const getMyBookings = async (req, res, next) => {
  try {
    const bookings = await Booking.find({ customer: req.user.id })
      .sort({ createdAt: -1 })
      .populate("selectedFoods", "name category type");
    return res.json({ success: true, count: bookings.length, data: bookings });
  } catch (error) {
    next(error);
  }
};

const getBookingById = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid booking ID" });
    }
    const query = { _id: req.params.id };
    if (req.user.role === "customer") query.customer = req.user.id;
    const booking = await Booking.findOne(query)
      .populate("customer", "name phone email")
      .populate("selectedFoods", "name category type");
    if (!booking) {
      return res.status(404).json({ success: false, message: "Booking not found" });
    }
    return res.json({ success: true, data: booking });
  } catch (error) {
    next(error);
  }
};

const updateMyBooking = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid booking ID" });
    }
    const booking = await Booking.findOne({
      _id: req.params.id,
      customer: req.user.id,
      status: "pending",
    });
    if (!booking) {
      return res.status(404).json({ success: false, message: "Pending booking not found" });
    }
    const updates = normalizeBookingInput(req.body || {});
    const merged = { ...booking.toObject(), ...updates };
    const validationError = validateNewBooking(merged);
    if (validationError) {
      return res.status(400).json({ success: false, message: validationError });
    }
    for (const field of ["functionDate", "functionTime", "location", "numberOfPersons", "extraRequirements"]) {
      if (Object.prototype.hasOwnProperty.call(updates, field)) booking[field] = updates[field];
    }
    if (Object.prototype.hasOwnProperty.call(updates, "numberOfPersons")) {
      booking.numberOfPersons = Number(updates.numberOfPersons);
    }
    await booking.save();
    return res.json({ success: true, message: "Booking updated successfully", data: booking });
  } catch (error) {
    next(error);
  }
};

const updateBooking = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid booking ID" });
    }
    const allowedStatuses = ["pending", "confirmed", "rejected", "cancelled", "completed"];
    const { status } = req.body || {};
    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({ success: false, message: "Invalid booking status" });
    }
    const booking = await Booking.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true, runValidators: true }
    );
    if (!booking) {
      return res.status(404).json({ success: false, message: "Booking not found" });
    }
    return res.json({ success: true, message: "Booking updated successfully", data: booking });
  } catch (error) {
    next(error);
  }
};

const cancelBooking = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid booking ID" });
    }
    const booking = await Booking.findOneAndUpdate(
      { _id: req.params.id, customer: req.user.id, status: "pending" },
      { status: "cancelled" },
      { new: true, runValidators: true }
    );
    if (!booking) {
      return res.status(404).json({ success: false, message: "Pending booking not found" });
    }
    return res.json({ success: true, message: "Booking cancelled successfully", data: booking });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getBookings,
  createBooking,
  getMyBookings,
  getBookingById,
  updateMyBooking,
  updateBooking,
  cancelBooking,
};
