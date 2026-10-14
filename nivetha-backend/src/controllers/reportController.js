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
    ] = await Promise.all([
      Booking.countDocuments(),
      Booking.countDocuments({ status: "pending" }),
      Booking.countDocuments({ status: "confirmed" }),
      Booking.countDocuments({ status: "rejected" }),
      Booking.countDocuments({ status: "cancelled" }),
      Booking.countDocuments({ status: "completed" }),
      Customer.countDocuments(),
      Food.countDocuments(),
    ]);

    return res.json({
      success: true,
      data: {
        totalBookings,
        pendingBookings,
        confirmedBookings,
        rejectedBookings,
        cancelledBookings,
        completedBookings,
        totalCustomers,
        totalFoods,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = { getReports };