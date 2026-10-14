const express = require("express");
const router = express.Router();

const {
  getNotifications,
  createNotification,
  markNotificationRead,
} = require("../controllers/notificationController");

const { protect } = require("../middleware/authMiddleware");

router.use(protect);

router.get("/", getNotifications);

router.post("/", (req, res, next) => {
  if (req.user?.role !== "owner") {
    return res.status(403).json({
      success: false,
      message: "Owner access required",
    });
  }
  next();
}, createNotification);

router.patch("/:id/read", markNotificationRead);

module.exports = router;