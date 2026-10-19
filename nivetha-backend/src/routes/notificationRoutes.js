
const express = require("express");
const router = express.Router();

const {
  getNotifications,
  createNotification,
  markNotificationRead,
} = require("../controllers/notificationController");

const {
  protect,
  allowRoles,
} = require("../middleware/authMiddleware");

// All notification routes require authentication.
router.use(protect);

// Customers and owners can view their own notifications.
// Controller must filter results by the authenticated user.
router.get("/", getNotifications);

// Only the owner can create notifications.
router.post(
  "/",
  allowRoles("owner"),
  createNotification
);

// Controller must verify notification ownership before marking it read.
router.patch("/:id/read", markNotificationRead);

module.exports = router;
