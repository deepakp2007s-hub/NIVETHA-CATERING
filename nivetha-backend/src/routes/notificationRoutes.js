
const express = require("express");
const router = express.Router();

const {
  getNotifications,
  createNotification,
  markNotificationRead,
  markAllNotificationsRead,
  deleteNotification,
} = require("../controllers/notificationController");

const {
  protect,
  allowRoles,
} = require("../middleware/authMiddleware");

// All notification routes require authentication.
router.use(protect);

// Get notifications for the authenticated user.
router.get("/", getNotifications);

// Owner only: create notifications.
router.post(
  "/",
  allowRoles("owner"),
  createNotification
);

// Mark one notification as read.
router.patch(
  "/:id/read",
  markNotificationRead
);

// Mark all notifications as read.
router.patch(
  "/read-all",
  markAllNotificationsRead
);

// Delete a notification.
// Controller must verify ownership or owner permissions.
router.delete(
  "/:id",
  deleteNotification
);

module.exports = router;
