
const Booking = require("../models/Booking");
const Customer = require("../models/Customer");
const Food = require("../models/Food");

// Owner Dashboard Statistics
const getDashboard = async (req, res, next) => {
  try {
    const [
      totalBookings,
      pendingBookings,
      confirmedBookings,
      completedBookings,
      rejectedBookings,
      cancelledBookings,
      totalCustomers,
      totalFoods,
      availableFoods,
      unavailableFoods,
    ] = await Promise.all([
      Booking.countDocuments().exec(),

      Booking.countDocuments({
        status: "pending",
      }).exec(),

      Booking.countDocuments({
        status: "confirmed",
      }).exec(),

      Booking.countDocuments({
        status: "completed",
      }).exec(),

      Booking.countDocuments({
        status: "rejected",
      }).exec(),

      Booking.countDocuments({
        status: "cancelled",
      }).exec(),

      Customer.countDocuments().exec(),

      Food.countDocuments().exec(),

      Food.countDocuments({
        available: true,
      }).exec(),

      Food.countDocuments({
        available: false,
      }).exec(),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        totalBookings,
        pendingBookings,
        confirmedBookings,
        completedBookings,
        rejectedBookings,
        cancelledBookings,
        totalCustomers,
        totalFoods,
        availableFoods,
        unavailableFoods,
      },
    });
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  getDashboard,
};
