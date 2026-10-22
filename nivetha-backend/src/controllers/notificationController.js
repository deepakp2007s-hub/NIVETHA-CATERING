
const mongoose = require("mongoose");
const Notification = require("../models/Notification");
const Customer = require("../models/Customer");

const getPagination = (query = {}) => {
  const parsedPage = Number.parseInt(query.page, 10);
  const parsedLimit = Number.parseInt(query.limit, 10);

  const page =
    Number.isSafeInteger(parsedPage) && parsedPage > 0
      ? parsedPage
      : 1;

  const limit =
    Number.isSafeInteger(parsedLimit) && parsedLimit > 0
      ? Math.min(parsedLimit, 100)
      : 20;

  return {
    page,
    limit,
    skip: (page - 1) * limit,
  };
};

const getAuthenticatedUserId = (req) => {
  const id = req.user?.id || req.user?._id;

  return id && mongoose.isValidObjectId(String(id))
    ? String(id)
    : null;
};

// Get notifications for the authenticated user.
// Owner sees all notifications; customers see only their own.
const getNotifications = async (req, res, next) => {
  try {
    const userId = getAuthenticatedUserId(req);

    if (!userId || !req.user?.role) {
      return res.status(401).json({
        success: false,
        message: "Authentication required.",
      });
    }

    const { page, limit, skip } = getPagination(req.query);

    const filter =
      req.user.role === "owner"
        ? {}
        : { recipient: userId };

    const [notifications, total] = await Promise.all([
      Notification.find(filter)
        .sort({ createdAt: -1, _id: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      Notification.countDocuments(filter),
    ]);

    return res.status(200).json({
      success: true,
      data: notifications,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        hasNextPage: page * limit < total,
        hasPreviousPage: page > 1,
      },
    });
  } catch (error) {
    return next(error);
  }
};

// Owner: Create a notification for a customer.
const createNotification = async (req, res, next) => {
  try {
    const { recipient, title, message, type } = req.body || {};

    if (
      typeof recipient !== "string" ||
      !mongoose.isValidObjectId(recipient)
    ) {
      return res.status(400).json({
        success: false,
        message: "A valid recipient ID is required.",
      });
    }

    if (
      typeof title !== "string" ||
      !title.trim() ||
      title.trim().length > 150
    ) {
      return res.status(400).json({
        success: false,
        message: "Title is required and must not exceed 150 characters.",
      });
    }

    if (
      typeof message !== "string" ||
      !message.trim() ||
      message.trim().length > 2000
    ) {
      return res.status(400).json({
        success: false,
        message: "Message is required and must not exceed 2000 characters.",
      });
    }

    const allowedTypes = [
      "general",
      "booking",
      "payment",
      "reminder",
      "update",
    ];

    const notificationType = type ?? "general";

    if (
      typeof notificationType !== "string" ||
      !allowedTypes.includes(notificationType)
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid notification type.",
      });
    }

    const customerExists = await Customer.exists({
      _id: recipient,
    });

    if (!customerExists) {
      return res.status(404).json({
        success: false,
        message: "Recipient customer not found.",
      });
    }

    const notification = await Notification.create({
      recipient,
      title: title.trim(),
      message: message.trim(),
      type: notificationType,
      isRead: false,
    });

    return res.status(201).json({
      success: true,
      message: "Notification created successfully.",
      data: notification,
    });
  } catch (error) {
    if (error.name === "ValidationError") {
      return res.status(400).json({
        success: false,
        message: "Invalid notification data.",
      });
    }

    return next(error);
  }
};

// Mark one notification as read.
const markNotificationRead = async (req, res, next) => {
  try {
    const userId = getAuthenticatedUserId(req);
    const { id } = req.params;

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Authentication required.",
      });
    }

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid notification ID.",
      });
    }

    const filter = { _id: id };

    if (req.user.role !== "owner") {
      filter.recipient = userId;
    }

    const notification = await Notification.findOneAndUpdate(
      filter,
      { $set: { isRead: true } },
      { new: true, runValidators: true }
    ).lean();

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Notification marked as read.",
      data: notification,
    });
  } catch (error) {
    return next(error);
  }
};

// Mark all notifications for the authenticated customer as read.
// Owner action affects all notifications.
const markAllNotificationsRead = async (req, res, next) => {
  try {
    const userId = getAuthenticatedUserId(req);

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Authentication required.",
      });
    }

    const filter =
      req.user.role === "owner"
        ? {}
        : { recipient: userId };

    const result = await Notification.updateMany(
      filter,
      { $set: { isRead: true } }
    );

    return res.status(200).json({
      success: true,
      message: "Notifications marked as read.",
      modifiedCount: result.modifiedCount,
    });
  } catch (error) {
    return next(error);
  }
};

// Delete a notification.
// Customers can delete only their own; owners can delete any.
const deleteNotification = async (req, res, next) => {
  try {
    const userId = getAuthenticatedUserId(req);
    const { id } = req.params;

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Authentication required.",
      });
    }

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid notification ID.",
      });
    }

    const filter = { _id: id };

    if (req.user.role !== "owner") {
      filter.recipient = userId;
    }

    const notification = await Notification.findOneAndDelete(filter);

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Notification deleted successfully.",
    });
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  getNotifications,
  createNotification,
  markNotificationRead,
  markAllNotificationsRead,
  deleteNotification,
};
