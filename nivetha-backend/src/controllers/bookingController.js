import crypto from 'crypto';
import Booking from '../models/Booking.js';
import Notification from '../models/Notification.js';

// Helper to generate unique booking ID: NIV-YYYYMMDD-XXXX
const generateBookingId = () => {
  const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
  const randomSuffix = crypto.randomBytes(2).toString('hex').toUpperCase();
  return `NIV-${dateStr}-${randomSuffix}`;
};

/**
 * @desc    Create a New Booking
 * @route   POST /api/bookings
 * @access  Private (Customer)
 */
export const createBooking = async (req, res, next) => {
  try {
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
    } = req.body;

    const persons = Number(numberOfPersons || guestCount);

    if (!eventType || !eventDate || !eventLocation || !persons) {
      return res.status(400).json({
        success: false,
        message: 'Event type, event date, location, and number of persons are required.',
      });
    }

    if (persons < 10) {
      return res.status(400).json({
        success: false,
        message: 'Catering service minimum order is 10 persons.',
      });
    }

    const bookingDate = new Date(eventDate);
    if (isNaN(bookingDate.getTime())) {
      return res.status(400).json({
        success: false,
        message: 'Invalid event date provided.',
      });
    }

    const bookingId = generateBookingId();

    const booking = await Booking.create({
      bookingId,
      customer: req.customer._id,
      customerName: req.customer.name,
      customerPhone: req.customer.phone,
      eventType,
      eventDate: bookingDate,
      eventTime: eventTime || 'Morning',
      eventLocation: eventLocation.trim(),
      numberOfPersons: persons,
      selectedFoods: Array.isArray(selectedFoods) ? selectedFoods : [],
      cateringServices: Array.isArray(cateringServices) && cateringServices.length > 0
        ? cateringServices
        : ['Traditional Banana Leaf Service (வாழை இலை விருந்து)'],
      extraRequirements: extraRequirements ? extraRequirements.trim() : '',
      notes: notes ? notes.trim() : '',
      status: 'pending',
    });

    // Create automatic in-app notification for the customer
    await Notification.create({
      recipient: req.customer._id,
      type: 'booking_received',
      title: 'Booking Received!',
      message: `Your booking ${bookingId} for ${eventType} on ${bookingDate.toDateString()} has been received. Our team will review and confirm shortly.`,
      bookingId,
    }).catch((err) => console.error('Failed to create notification:', err.message));

    res.status(201).json({
      success: true,
      message: 'Catering booking placed successfully',
      booking,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get Current Customer's Bookings
 * @route   GET /api/bookings/my
 * @access  Private (Customer)
 */
export const getMyBookings = async (req, res, next) => {
  try {
    const bookings = await Booking.find({ customer: req.customer._id }).sort({ createdAt: -1 });

    res.json({
      success: true,
      count: bookings.length,
      bookings,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get Single Booking Details
 * @route   GET /api/bookings/:id
 * @access  Private (Customer for own booking, or Owner for any)
 */
export const getBookingById = async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found.',
      });
    }

    // Role check: customer can only view their own booking
    if (req.user.role === 'customer' && booking.customer.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. You cannot view another customer’s booking.',
      });
    }

    res.json({
      success: true,
      booking,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Cancel a Booking
 * @route   PATCH /api/bookings/:id/cancel
 * @access  Private (Customer for own, or Owner)
 */
export const cancelBooking = async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found.',
      });
    }

    if (req.user.role === 'customer' && booking.customer.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. You cannot cancel another customer’s booking.',
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

    booking.status = 'cancelled';
    if (req.body.reason) {
      booking.notes = `${booking.notes ? booking.notes + ' | ' : ''}Cancellation reason: ${req.body.reason}`;
    }
    await booking.save();

    // Notify customer
    await Notification.create({
      recipient: booking.customer,
      type: 'booking_cancelled',
      title: 'Booking Cancelled',
      message: `Booking ${booking.bookingId} has been cancelled.`,
      bookingId: booking.bookingId,
    }).catch((err) => console.error('Notification error:', err.message));

    res.json({
      success: true,
      message: 'Booking cancelled successfully.',
      booking,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get All Bookings (Owner Only)
 * @route   GET /api/bookings
 * @access  Private (Owner Only)
 */
export const getAllBookings = async (req, res, next) => {
  try {
    const { status, eventType, startDate, endDate, page = 1, limit = 25 } = req.query;
    const filter = {};

    if (status) filter.status = status;
    if (eventType) filter.eventType = eventType;
    if (startDate || endDate) {
      filter.eventDate = {};
      if (startDate) filter.eventDate.$gte = new Date(startDate);
      if (endDate) filter.eventDate.$lte = new Date(endDate);
    }

    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);
    const skip = (pageNum - 1) * limitNum;

    const [bookings, total] = await Promise.all([
      Booking.find(filter).sort({ eventDate: 1, createdAt: -1 }).skip(skip).limit(limitNum).lean(),
      Booking.countDocuments(filter),
    ]);

    res.json({
      success: true,
      total,
      page: pageNum,
      pages: Math.ceil(total / limitNum),
      count: bookings.length,
      bookings,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Update Booking Status (Owner Only)
 * @route   PATCH /api/bookings/:id/status
 * @access  Private (Owner Only)
 */
export const updateBookingStatus = async (req, res, next) => {
  try {
    const { status, totalAmount, notes } = req.body;

    const validStatuses = ['pending', 'confirmed', 'rejected', 'completed', 'cancelled'];
    if (!status || !validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status. Must be one of: ${validStatuses.join(', ')}`,
      });
    }

    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found.',
      });
    }

    booking.status = status;
    if (totalAmount !== undefined) booking.totalAmount = Number(totalAmount);
    if (notes) booking.notes = notes.trim();

    await booking.save();

    // Map status to notification title & message
    const statusMessages = {
      confirmed: {
        type: 'booking_confirmed',
        title: 'Booking Confirmed!',
        message: `Great news! Your booking ${booking.bookingId} for ${booking.eventType} has been confirmed by Nivetha Catering.`,
      },
      rejected: {
        type: 'booking_updated',
        title: 'Booking Update',
        message: `Your booking ${booking.bookingId} could not be accepted for the requested date. Please contact us.`,
      },
      completed: {
        type: 'booking_completed',
        title: 'Event Completed — Thank You!',
        message: `Thank you for choosing Nivetha Catering Service for your ${booking.eventType}. We hope you and your guests enjoyed the feast! Please leave us a review.`,
      },
      cancelled: {
        type: 'booking_cancelled',
        title: 'Booking Cancelled',
        message: `Booking ${booking.bookingId} has been marked as cancelled.`,
      },
    };

    if (statusMessages[status]) {
      const notifData = statusMessages[status];
      await Notification.create({
        recipient: booking.customer,
        type: notifData.type,
        title: notifData.title,
        message: notifData.message,
        bookingId: booking.bookingId,
      }).catch((err) => console.error('Notification error:', err.message));
    }

    res.json({
      success: true,
      message: `Booking status updated to ${status}.`,
      booking,
    });
  } catch (error) {
    next(error);
  }
};
