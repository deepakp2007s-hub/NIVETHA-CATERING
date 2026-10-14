const Notification = require("../models/Notification");

const getNotifications = async (req, res, next) => {
  try {
    const filter =
      req.user.role === "owner"
        ? {}
        : { recipient: req.user.id };

    const notifications = await Notification.find(filter)
      .sort({ createdAt: -1 });

    return res.json({
      success: true,
      count: notifications.length,
      data: notifications,
    });
  } catch (error) {
    next(error);
  }
};

const createNotification = async (req, res, next) => {
  try {
    const { recipient, title, message, type } = req.body;

    if (!recipient || !title || !message) {
      return res.status(400).json({
        success: false,
        message: "Recipient, title and message are required",
      });
    }

    const notification = await Notification.create({
      recipient,
      title,
      message,
      type: type || "general",
      isRead: false,
    });

    return res.status(201).json({
      success: true,
      data: notification,
    });
  } catch (error) {
    next(error);
  }
};

const markNotificationRead = async (req, res, next) => {
  try {
    const notification = await Notification.findOneAndUpdate(
      {
        _id: req.params.id,
        recipient: req.user.id,
      },
      { isRead: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found",
      });
    }

    return res.json({
      success: true,
      data: notification,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getNotifications,
  createNotification,
  markNotificationRead,
};