
const Booking = require("../models/Booking");
const Customer = require("../models/Customer");
const Food = require("../models/Food");

const getReports = async (req, res, next) => {
  try {
    const [
      totalBookings,
      pendingBookings,
      confirmedBookings,
      rejectedBookings,
      cancelledBookings,
      completedBookings,
      totalCustomers,
      totalFoods,
      availableFoods,
    ] = await Promise.all([
      Booking.countDocuments().exec(),
      Booking.countDocuments({ status: "pending" }).exec(),
      Booking.countDocuments({ status: "confirmed" }).exec(),
      Booking.countDocuments({ status: "rejected" }).exec(),
      Booking.countDocuments({ status: "cancelled" }).exec(),
      Booking.countDocuments({ status: "completed" }).exec(),
      Customer.countDocuments().exec(),
      Food.countDocuments().exec(),
      Food.countDocuments({ available: true }).exec(),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        bookings: {
          total: totalBookings,
          pending: pendingBookings,
          confirmed: confirmedBookings,
          rejected: rejectedBookings,
          cancelled: cancelledBookings,
          completed: completedBookings,
        },
        customers: {
          total: totalCustomers,
        },
        foods: {
          total: totalFoods,
          available: availableFoods,
          unavailable: totalFoods - availableFoods,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
};

module.exports = { getReports };
