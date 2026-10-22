
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

// ======================================
// CUSTOMER BOOKING ROUTES
// ======================================

// Create a booking
// POST /api/bookings
router.post(
  "/",
  protect,
  allowRoles("customer"),
  createBooking
);

// Get logged-in customer's bookings
// GET /api/bookings/my-bookings
router.get(
  "/my-bookings",
  protect,
  allowRoles("customer"),
  getMyBookings
);

// Cancel own booking
// PATCH /api/bookings/:id/cancel
router.patch(
  "/:id/cancel",
  protect,
  allowRoles("customer"),
  cancelBooking
);

// Update own booking
// PATCH /api/bookings/:id
router.patch(
  "/:id",
  protect,
  allowRoles("customer"),
  updateMyBooking
);

// View a single booking
// Controller must verify customer ownership or owner role.
router.get(
  "/:id",
  protect,
  allowRoles("customer", "owner"),
  getBookingById
);

// ======================================
// OWNER BOOKING ROUTES
// ======================================

// Get all bookings
// GET /api/bookings
router.get(
  "/",
  protect,
  allowRoles("owner"),
  getBookings
);

// Update booking status
// PATCH /api/bookings/:id/status
router.patch(
  "/:id/status",
  protect,
  allowRoles("owner"),
  updateBooking
);

module.exports = router;
