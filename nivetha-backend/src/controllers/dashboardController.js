const Booking = require("../models/Booking");
const Customer = require("../models/Customer");
const Food = require("../models/Food");

const getDashboard = async (req, res, next) => {
  try {
    const [
      totalBookings,
      pendingBookings,
      confirmedBookings,
      completedBookings,
      totalCustomers,
      totalFoods,
    ] = await Promise.all([
      Booking.countDocuments(),
      Booking.countDocuments({ status: "pending" }),
      Booking.countDocuments({ status: "confirmed" }),
      Booking.countDocuments({ status: "completed" }),
      Customer.countDocuments(),
      Food.countDocuments(),
    ]);

    res.status(200).json({
      success: true,
      data: {
        totalBookings,
        pendingBookings,
        confirmedBookings,
        completedBookings,
        totalCustomers,
        totalFoods,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = { getDashboard };