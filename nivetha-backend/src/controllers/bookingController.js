
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

const allowedStatuses = [
  "pending",
  "confirmed",
  "rejected",
  "cancelled",
  "completed",
];

function normalizeBookingInput(body = {}) {
  const input = {};

  for (const field of bookingFields) {
    if (Object.prototype.hasOwnProperty.call(body, field)) {
      input[field] = body[field];
    }
  }

  for (const field of [
    "eventType",
    "functionTime",
    "location",
    "extraRequirements",
    "mealType",
    "foodType",
    "cateringService",
  ]) {
    if (typeof input[field] === "string") {
      input[field] = input[field].trim();
    }
  }

  if (Object.hasOwn(input, "cateringServices")) {
    if (
      !Array.isArray(input.cateringServices) ||
      input.cateringServices.some((item) => typeof item !== "string")
    ) {
      return { error: "Catering services must be an array of strings." };
    }

    input.cateringServices = [
      ...new Set(
        input.cateringServices.map((item) => item.trim()).filter(Boolean)
      ),
    ];

    if (!input.cateringService && input.cateringServices.length) {
      input.cateringService = input.cateringServices.join(", ");
    }
  }

  if (Object.hasOwn(input, "selectedFoodNames")) {
    if (
      !Array.isArray(input.selectedFoodNames) ||
      input.selectedFoodNames.some((name) => typeof name !== "string")
    ) {
      return { error: "Selected food names must be an array of strings." };
    }

    input.selectedFoodNames = [
      ...new Set(
        input.selectedFoodNames.map((name) => name.trim()).filter(Boolean)
      ),
    ];
  }

  if (Object.hasOwn(input, "selectedFoods")) {
    if (!Array.isArray(input.selectedFoods)) {
      return { error: "Selected foods must be an array." };
    }

    const ids = [];
    const names = [];

    for (const food of input.selectedFoods) {
      if (typeof food === "string") {
        const value = food.trim();

        if (mongoose.isValidObjectId(value)) {
          ids.push(value);
        } else if (value) {
          names.push(value);
        }
      } else if (food && typeof food === "object" && !Array.isArray(food)) {
        const id = food._id || food.id;

        if (id && mongoose.isValidObjectId(String(id))) {
          ids.push(String(id));
        }

        if (typeof food.name === "string" && food.name.trim()) {
          names.push(food.name.trim());
        }
      } else {
        return { error: "Invalid selected food item." };
      }
    }

    input.selectedFoods = [...new Set(ids)];
    input.selectedFoodNames = [
      ...new Set([...names, ...(input.selectedFoodNames || [])]),
    ];
  }

  return input;
}

function getCalendarDate(value) {
  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    return [
      value.getFullYear(),
      String(value.getMonth() + 1).padStart(2, "0"),
      String(value.getDate()).padStart(2, "0"),
    ].join("-");
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
  ) {
    return null;
  }

  if (value.includes("T") && Number.isNaN(new Date(value).getTime())) {
    return null;
  }

  return `${yearText}-${monthText}-${dayText}`;
}

function validateBooking(input, requireCateringServices = false) {
  if (
    typeof input.eventType !== "string" ||
    !input.eventType.trim() ||
    input.eventType.length > 100
  ) {
    return "A valid event type is required.";
  }

  const eventDate = getCalendarDate(input.functionDate);

  if (!eventDate) {
    return "A valid function date is required.";
  }

  if (
    typeof input.location !== "string" ||
    !input.location.trim() ||
    input.location.length > 500
  ) {
    return "A valid event location is required.";
  }

  if (
    typeof input.functionTime !== "string" ||
    !/^(?:[01]\d|2[0-3]):[0-5]\d$/.test(input.functionTime)
  ) {
    return "A valid function time (HH:mm) is required.";
  }

  const persons = Number(input.numberOfPersons);

  if (
    !["number", "string"].includes(typeof input.numberOfPersons) ||
    (typeof input.numberOfPersons === "string" &&
      !input.numberOfPersons.trim()) ||
    !Number.isSafeInteger(persons) ||
    persons < 1 ||
    persons > 1000000
  ) {
    return "Enter a valid number of persons.";
  }

  if (
    input.extraRequirements !== undefined &&
    (typeof input.extraRequirements !== "string" ||
      input.extraRequirements.length > 2000)
  ) {
    return "Extra requirements must not exceed 2000 characters.";
  }

  if (
    input.foodType !== undefined &&
    !["veg", "non-veg", "both"].includes(input.foodType)
  ) {
    return "Invalid food type.";
  }

  const [year, month, day] = eventDate.split("-").map(Number);
  const functionDate = new Date(year, month - 1, day);
  const today = new Date();

  today.setHours(0, 0, 0, 0);
  functionDate.setHours(0, 0, 0, 0);

  if (functionDate < today) {
    return "Function date cannot be in the past.";
  }

  if (
    requireCateringServices &&
    !(Array.isArray(input.cateringServices) && input.cateringServices.length) &&
    !(typeof input.cateringService === "string" &&
      input.cateringService.trim())
  ) {
    return "Select at least one catering service.";
  }

  return null;
}

function getPagination(query = {}) {
  const requestedPage = Number.parseInt(query.page, 10) || 1;
  const requestedLimit = Number.parseInt(query.limit, 10) || 20;

  return {
    page: Math.max(1, requestedPage),
    limit: Math.min(100, Math.max(1, requestedLimit)),
  };
}

// OWNER: Get all bookings
const getBookings = async (req, res, next) => {
  try {
    const { page, limit } = getPagination(req.query);
    const skip = (page - 1) * limit;

    const [data, total] = await Promise.all([
      Booking.find()
        .sort({ createdAt: -1, _id: -1 })
        .skip(skip)
        .limit(limit)
        .populate("customer", "name phone email")
        .populate("selectedFoods", "name category type")
        .lean(),
      Booking.countDocuments(),
    ]);

    return res.status(200).json({
      success: true,
      data,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    return next(error);
  }
};

// CUSTOMER: Create a booking
const createBooking = async (req, res, next) => {
  try {
    const input = normalizeBookingInput(req.body || {});

    if (input.error) {
      return res.status(400).json({ success: false, message: input.error });
    }

    const validationError = validateBooking(input, true);

    if (validationError) {
      return res.status(400).json({
        success: false,
        message: validationError,
      });
    }

    const booking = await Booking.create({
      ...input,
      customer: req.user.id,
      numberOfPersons: Number(input.numberOfPersons),
      status: "pending",
    });

    return res.status(201).json({
      success: true,
      message: "Booking created successfully.",
      data: booking,
    });
  } catch (error) {
    return next(error);
  }
};

// CUSTOMER: Get own bookings
const getMyBookings = async (req, res, next) => {
  try {
    const { page, limit } = getPagination(req.query);
    const filter = { customer: req.user.id };
    const skip = (page - 1) * limit;

    const [data, total] = await Promise.all([
      Booking.find(filter)
        .sort({ createdAt: -1, _id: -1 })
        .skip(skip)
        .limit(limit)
        .populate("selectedFoods", "name category type")
        .lean(),
      Booking.countDocuments(filter),
    ]);

    return res.status(200).json({
      success: true,
      data,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    return next(error);
  }
};

// OWNER or booking-owning CUSTOMER: Get one booking
const getBookingById = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid booking ID.",
      });
    }

    const filter = { _id: req.params.id };

    if (req.user.role === "customer") {
      filter.customer = req.user.id;
    } else if (req.user.role !== "owner") {
      return res.status(403).json({
        success: false,
        message: "You are not authorized to view this booking.",
      });
    }

    const booking = await Booking.findOne(filter)
      .populate("customer", "name phone email")
      .populate("selectedFoods", "name category type")
      .lean();

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found.",
      });
    }

    return res.status(200).json({ success: true, data: booking });
  } catch (error) {
    return next(error);
  }
};

// CUSTOMER: Update own pending booking
const updateMyBooking = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid booking ID.",
      });
    }

    const booking = await Booking.findOne({
      _id: req.params.id,
      customer: req.user.id,
      status: "pending",
    });

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Pending booking not found.",
      });
    }

    const updates = normalizeBookingInput(req.body || {});

    if (updates.error) {
      return res.status(400).json({
        success: false,
        message: updates.error,
      });
    }

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({
        success: false,
        message: "No valid booking fields provided.",
      });
    }

    const merged = {
      ...booking.toObject(),
      ...updates,
    };

    const validationError = validateBooking(merged);

    if (validationError) {
      return res.status(400).json({
        success: false,
        message: validationError,
      });
    }

    for (const field of bookingFields) {
      if (Object.hasOwn(updates, field)) {
        booking[field] =
          field === "numberOfPersons"
            ? Number(updates[field])
            : updates[field];
      }
    }

    await booking.save();

    return res.status(200).json({
      success: true,
      message: "Booking updated successfully.",
      data: booking,
    });
  } catch (error) {
    return next(error);
  }
};

// OWNER: Update booking status
const updateBooking = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid booking ID.",
      });
    }

    const { status } = req.body || {};

    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Invalid booking status.",
      });
    }

    const booking = await Booking.findByIdAndUpdate(
      req.params.id,
      { $set: { status } },
      { new: true, runValidators: true }
    );

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Booking status updated successfully.",
      data: booking,
    });
  } catch (error) {
    return next(error);
  }
};

// CUSTOMER: Cancel own pending booking
const cancelBooking = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid booking ID.",
      });
    }

    const booking = await Booking.findOneAndUpdate(
      {
        _id: req.params.id,
        customer: req.user.id,
        status: "pending",
      },
      { $set: { status: "cancelled" } },
      { new: true, runValidators: true }
    );

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Pending booking not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Booking cancelled successfully.",
      data: booking,
    });
  } catch (error) {
    return next(error);
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
