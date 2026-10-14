const express = require("express");
const router = express.Router();

const {
  getBookings,
  createBooking,
  getMyBookings,
  getBookingById,
  updateMyBooking,
  updateBooking,
  cancelBooking,
} = require("../controllers/bookingController");

const { protect } = require("../middleware/authMiddleware");

const ownerOnly = (req, res, next) => {
  if (req.user?.role !== "owner") {
    return res.status(403).json({
      success: false,
      message: "Owner access required",
    });
  }
  next();
};

const customerOnly = (req, res, next) => {
  if (req.user?.role !== "customer") {
    return res.status(403).json({
      success: false,
      message: "Customer access required",
    });
  }
  next();
};

router.post("/", protect, customerOnly, createBooking);
router.get("/my-bookings", protect, customerOnly, getMyBookings);
router.patch("/:id/cancel", protect, customerOnly, cancelBooking);
router.patch("/:id", protect, customerOnly, updateMyBooking);
router.get("/:id", protect, getBookingById);

router.get("/", protect, ownerOnly, getBookings);
router.patch("/:id/status", protect, ownerOnly, updateBooking);

module.exports = router;
