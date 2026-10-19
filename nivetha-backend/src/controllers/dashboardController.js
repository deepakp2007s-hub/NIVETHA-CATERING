
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
      availableFoods,
    ] = await Promise.all([
      Booking.countDocuments().exec(),
      Booking.countDocuments({ status: "pending" }).exec(),
      Booking.countDocuments({ status: "confirmed" }).exec(),
      Booking.countDocuments({ status: "completed" }).exec(),
      Customer.countDocuments().exec(),
      Food.countDocuments().exec(),
      Food.countDocuments({ available: true }).exec(),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        totalBookings,
        pendingBookings,
        confirmedBookings,
        completedBookings,
        totalCustomers,
        totalFoods,
        availableFoods,
      },
    });
  } catch (error) {
    return next(error);
  }
};

module.exports = { getDashboard };
