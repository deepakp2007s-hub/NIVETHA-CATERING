
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

const {
  protect,
  allowRoles,
} = require("../middleware/authMiddleware");

// Customer routes
router.post(
  "/",
  protect,
  allowRoles("customer"),
  createBooking
);

router.get(
  "/my-bookings",
  protect,
  allowRoles("customer"),
  getMyBookings
);

router.patch(
  "/:id/cancel",
  protect,
  allowRoles("customer"),
  cancelBooking
);

router.patch(
  "/:id",
  protect,
  allowRoles("customer"),
  updateMyBooking
);

// View booking — controller must verify customer ownership
router.get("/:id", protect, getBookingById);

// Owner-only routes
router.get(
  "/",
  protect,
  allowRoles("owner"),
  getBookings
);

router.patch(
  "/:id/status",
  protect,
  allowRoles("owner"),
  updateBooking
);

module.exports = router;
