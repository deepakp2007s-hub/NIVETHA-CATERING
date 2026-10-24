
import crypto from 'crypto';
import mongoose from 'mongoose';
import Booking from '../models/Booking.js';
import Notification from '../models/Notification.js';

const VALID_STATUSES = [
  'pending',
  'confirmed',
  'rejected',
  'completed',
  'cancelled',
];

const DEFAULT_CATERING_SERVICES = [
  'Traditional Banana Leaf Service (வாழை இலை விருந்து)',
];

const ALLOWED_EVENT_TYPES = [
  'Wedding',
  'Reception',
  'Birthday Party',
  'Housewarming (Grahapravesam)',
  'Engagement',
  'Baby Shower (Valaikappu)',
  'Ear Piercing',
  'Corporate Event',
  'Other Function',
];

const createBookingId = () => {
  const date = new Date().toISOString().slice(0, 10).replace(/-/g, '');
  const random = crypto.randomBytes(4).toString('hex').toUpperCase();

  return `NIV-${date}-${random}`;
};

const isNonEmptyString = (value) =>
  typeof value === 'string' && value.trim().length > 0;

const parsePositiveInteger = (value) => {
  const number = Number(value);

  if (!Number.isSafeInteger(number) || number < 1) {
    return null;
  }

  return number;
};

const notifyCustomer = async ({
  recipient,
  type,
  title,
  message,
  bookingId,
}) => {
  try {
    await Notification.create({
      recipient,
      type,
      title,
      message,
      bookingId,
    });
  } catch (error) {
    // Notification failure should not undo a successfully saved booking.
    console.error('Booking notification failed:', error.message);
  }
};

const makeStatusNotification = (booking, status) => {
  const messages = {
    confirmed: {
      type: 'booking_confirmed',
      title: 'Booking Confirmed!',
      message: `Your booking ${booking.bookingId} for ${booking.eventType} has been confirmed by Nivetha Catering.`,
    },
    rejected: {
      type: 'booking_updated',
      title: 'Booking Update',
      message: `Your booking ${booking.bookingId} could not be accepted for the requested date. Please contact Nivetha Catering.`,
    },
    completed: {
      type: 'booking_completed',
      title: 'Event Completed — Thank You!',
      message: `Thank you for choosing Nivetha Catering Service for your ${booking.eventType}. Please leave us a review.`,
    },
    cancelled: {
      type: 'booking_cancelled',
      title: 'Booking Cancelled',
      message: `Booking ${booking.bookingId} has been marked as cancelled.`,
    },
  };

  return messages[status] || null;
};

/**
 * POST /api/bookings
 * Create a booking for the authenticated customer.
 */
export const createBooking = async (req, res, next) => {
  try {
    if (!req.customer?._id) {
      return res.status(401).json({
        success: false,
        message: 'Customer authentication is required.',
      });
    }

    const {
      eventType,
      eventDate,
      eventTime,
      eventLocation,
      numberOfPersons,
      guestCount,
      selectedFoods,
      cateringServices,
      extraRequirements,
      notes,
    } = req.body || {};

    if (!isNonEmptyString(eventType) || !ALLOWED_EVENT_TYPES.includes(eventType.trim())) {
      return res.status(400).json({
        success: false,
        message: 'Please select a valid event type.',
        allowedEventTypes: ALLOWED_EVENT_TYPES,
      });
    }

    if (!isNonEmptyString(eventDate)) {
      return res.status(400).json({
        success: false,
        message: 'Event date is required.',
      });
    }

    const parsedDate = new Date(eventDate);

    if (Number.isNaN(parsedDate.getTime())) {
      return res.status(400).json({
        success: false,
        message: 'Invalid event date.',
      });
    }

    // Require the event date to be today or later.
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const eventDay = new Date(parsedDate);
    eventDay.setHours(0, 0, 0, 0);

    if (eventDay < today) {
      return res.status(400).json({
        success: false,
        message: 'Event date cannot be in the past.',
      });
    }

    if (!isNonEmptyString(eventLocation)) {
      return res.status(400).json({
        success: false,
        message: 'Event location is required.',
      });
    }

    const rawPersons = numberOfPersons ?? guestCount;
    const persons = Number(rawPersons);

    if (
      rawPersons === undefined ||
      rawPersons === null ||
      rawPersons === '' ||
      !Number.isSafeInteger(persons)
    ) {
      return res.status(400).json({
        success: false,
        message: 'Number of persons must be a valid whole number.',
      });
    }

    if (persons < 10) {
      return res.status(400).json({
        success: false,
        message: 'Catering service minimum order is 10 persons.',
      });
    }

    if (persons > 100000) {
      return res.status(400).json({
        success: false,
        message: 'Number of persons exceeds the allowed limit.',
      });
    }

    if (
      selectedFoods !== undefined &&
      !Array.isArray(selectedFoods)
    ) {
      return res.status(400).json({
        success: false,
        message: 'Selected foods must be an array.',
      });
    }

    const foods = (selectedFoods || []).map((food) => {
      if (!food || typeof food !== 'object' || Array.isArray(food)) {
        return null;
      }

      const name =
        typeof food.name === 'string'
          ? food.name.trim()
          : '';

      if (!name) {
        return null;
      }

      const price = food.price === undefined ? 0 : Number(food.price);

      if (!Number.isFinite(price) || price < 0) {
        return null;
      }

      const item = {
        name,
        price,
      };

      if (food.foodId && mongoose.isValidObjectId(food.foodId)) {
        item.foodId = food.foodId;
      }

      for (const key of ['tamilName', 'category', 'type']) {
        if (typeof food[key] === 'string') {
          item[key] = food[key].trim();
        }
      }

      return item;
    });

    if (foods.some((food) => food === null)) {
      return res.status(400).json({
        success: false,
        message: 'Each selected food must contain a valid name and price.',
      });
    }

    let services = DEFAULT_CATERING_SERVICES;

    if (cateringServices !== undefined) {
      if (
        !Array.isArray(cateringServices) ||
        cateringServices.some((service) => !isNonEmptyString(service))
      ) {
        return res.status(400).json({
          success: false,
          message: 'Catering services must be an array of non-empty strings.',
        });
      }

      services = cateringServices.map((service) => service.trim());
    }

    const optionalString = (value, fieldName) => {
      if (value === undefined || value === null) return '';

      if (typeof value !== 'string') {
        throw new TypeError(`${fieldName} must be a string.`);
      }

      return value.trim();
    };

    let cleanedEventTime;
    let cleanedExtraRequirements;
    let cleanedNotes;

    try {
      cleanedEventTime =
        eventTime === undefined || eventTime === null || eventTime === ''
          ? 'Morning'
          : optionalString(eventTime, 'Event time');

      cleanedExtraRequirements = optionalString(
        extraRequirements,
        'Extra requirements'
      );

      cleanedNotes = optionalString(notes, 'Notes');
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    if (!cleanedEventTime) {
      return res.status(400).json({
        success: false,
        message: 'Event time cannot be empty.',
      });
    }

    const bookingId = createBookingId();

    const booking = await Booking.create({
      bookingId,
      customer: req.customer._id,
      customerName: req.customer.name,
      customerPhone: req.customer.phone,
      eventType: eventType.trim(),
      eventDate: parsedDate,
      eventTime: cleanedEventTime,
      eventLocation: eventLocation.trim(),
      numberOfPersons: persons,
      selectedFoods: foods,
      cateringServices: services,
      extraRequirements: cleanedExtraRequirements,
      notes: cleanedNotes,
      status: 'pending',
    });

    await notifyCustomer({
      recipient: req.customer._id,
      type: 'booking_received',
      title: 'Booking Received!',
      message: `Your booking ${bookingId} for ${eventType} on ${parsedDate.toDateString()} has been received. Our team will review it shortly.`,
      bookingId,
    });

    return res.status(201).json({
      success: true,
      message: 'Catering booking placed successfully.',
      booking,
    });
  } catch (error) {
    if (error?.code === 11000) {
      return res.status(409).json({
        success: false,
        message: 'A booking ID conflict occurred. Please submit the booking again.',
      });
    }

    if (error?.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    return next(error);
  }
};

/**
 * GET /api/bookings/my
 * Get bookings belonging to the authenticated customer.
 */
export const getMyBookings = async (req, res, next) => {
  try {
    if (!req.customer?._id) {
      return res.status(401).json({
        success: false,
        message: 'Customer authentication is required.',
      });
    }

    const bookings = await Booking.find({
      customer: req.customer._id,
    }).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: bookings.length,
      bookings,
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * GET /api/bookings/:id
 * Customer may view their own booking; owner may view any booking.
 */
export const getBookingById = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid booking ID.',
      });
    }

    const booking = await Booking.findById(id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found.',
      });
    }

    if (
      req.user?.role === 'customer' &&
      String(booking.customer) !== String(req.user._id)
    ) {
      return res.status(403).json({
        success: false,
        message: 'You cannot view another customer’s booking.',
      });
    }

    if (!['customer', 'owner'].includes(req.user?.role)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied.',
      });
    }

    return res.status(200).json({
      success: true,
      booking,
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * PATCH /api/bookings/:id/cancel
 * Customer may cancel their own booking; owner may cancel any booking.
 */
export const cancelBooking = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid booking ID.',
      });
    }

    const booking = await Booking.findById(id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found.',
      });
    }

    if (
      req.user?.role === 'customer' &&
      String(booking.customer) !== String(req.user._id)
    ) {
      return res.status(403).json({
        success: false,
        message: 'You cannot cancel another customer’s booking.',
      });
    }

    if (!['customer', 'owner'].includes(req.user?.role)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied.',
      });
    }

    if (booking.status === 'completed') {
      return res.status(400).json({
        success: false,
        message: 'Completed bookings cannot be cancelled.',
      });
    }

    if (booking.status === 'cancelled') {
      return res.status(400).json({
        success: false,
        message: 'Booking is already cancelled.',
      });
    }

    const reason = req.body?.reason;

    if (reason !== undefined && typeof reason !== 'string') {
      return res.status(400).json({
        success: false,
        message: 'Cancellation reason must be a string.',
      });
    }

    booking.status = 'cancelled';

    if (reason?.trim()) {
      booking.notes = [
        booking.notes,
        `Cancellation reason: ${reason.trim()}`,
      ]
        .filter(Boolean)
        .join(' | ');
    }

    await booking.save();

    await notifyCustomer({
      recipient: booking.customer,
      type: 'booking_cancelled',
      title: 'Booking Cancelled',
      message: `Booking ${booking.bookingId} has been cancelled.`,
      bookingId: booking.bookingId,
    });

    return res.status(200).json({
      success: true,
      message: 'Booking cancelled successfully.',
      booking,
    });
  } catch (error) {
    if (error?.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    return next(error);
  }
};

/**
 * GET /api/bookings
 * Owner-only list of bookings with filtering and pagination.
 */
export const getAllBookings = async (req, res, next) => {
  try {
    const {
      status,
      eventType,
      startDate,
      endDate,
      page = '1',
      limit = '25',
    } = req.query;

    const pageNum = parsePositiveInteger(page);
    const limitNum = parsePositiveInteger(limit);

    if (!pageNum || !limitNum || limitNum > 100) {
      return res.status(400).json({
        success: false,
        message: 'Page must be positive and limit must be between 1 and 100.',
      });
    }

    if (status && !VALID_STATUSES.includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid booking status filter.',
        allowedStatuses: VALID_STATUSES,
      });
    }

    if (eventType && !ALLOWED_EVENT_TYPES.includes(eventType)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid event type filter.',
        allowedEventTypes: ALLOWED_EVENT_TYPES,
      });
    }

    const filter = {};

    if (status) filter.status = status;
    if (eventType) filter.eventType = eventType;

    if (startDate || endDate) {
      filter.eventDate = {};

      if (startDate) {
        const start = new Date(startDate);

        if (Number.isNaN(start.getTime())) {
          return res.status(400).json({
            success: false,
            message: 'Invalid startDate.',
          });
        }

        start.setHours(0, 0, 0, 0);
        filter.eventDate.$gte = start;
      }

      if (endDate) {
        const end = new Date(endDate);

        if (Number.isNaN(end.getTime())) {
          return res.status(400).json({
            success: false,
            message: 'Invalid endDate.',
          });
        }

        end.setHours(23, 59, 59, 999);
        filter.eventDate.$lte = end;
      }

      if (
        filter.eventDate.$gte &&
        filter.eventDate.$lte &&
        filter.eventDate.$gte > filter.eventDate.$lte
      ) {
        return res.status(400).json({
          success: false,
          message: 'startDate cannot be later than endDate.',
        });
      }
    }

    const [bookings, total] = await Promise.all([
      Booking.find(filter)
        .sort({ eventDate: 1, createdAt: -1 })
        .skip((pageNum - 1) * limitNum)
        .limit(limitNum)
        .lean(),
      Booking.countDocuments(filter),
    ]);

    return res.status(200).json({
      success: true,
      total,
      page: pageNum,
      limit: limitNum,
      pages: Math.ceil(total / limitNum),
      count: bookings.length,
      bookings,
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * PATCH /api/bookings/:id/status
 * Owner-only booking status and amount update.
 */
export const updateBookingStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status, totalAmount, notes } = req.body || {};

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid booking ID.',
      });
    }

    if (!VALID_STATUSES.includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid booking status.',
        allowedStatuses: VALID_STATUSES,
      });
    }

    if (
      totalAmount !== undefined &&
      (!Number.isFinite(Number(totalAmount)) || Number(totalAmount) < 0)
    ) {
      return res.status(400).json({
        success: false,
        message: 'Total amount must be a valid non-negative number.',
      });
    }

    if (notes !== undefined && typeof notes !== 'string') {
      return res.status(400).json({
        success: false,
        message: 'Notes must be a string.',
      });
    }

    const booking = await Booking.findById(id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found.',
      });
    }

    const previousStatus = booking.status;
    const statusChanged = previousStatus !== status;

    booking.status = status;

    if (totalAmount !== undefined) {
      booking.totalAmount = Number(totalAmount);
    }

    if (notes !== undefined) {
      booking.notes = notes.trim();
    }

    await booking.save();

    if (statusChanged) {
      const notification = makeStatusNotification(booking, status);

      if (notification) {
        await notifyCustomer({
          recipient: booking.customer,
          type: notification.type,
          title: notification.title,
          message: notification.message,
          bookingId: booking.bookingId,
        });
      }
    }

    return res.status(200).json({
      success: true,
      message: statusChanged
        ? `Booking status updated to ${status}.`
        : 'Booking details updated successfully.',
      booking,
    });
  } catch (error) {
    if (error?.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    return next(error);
  }
};
