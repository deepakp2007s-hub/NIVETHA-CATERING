
import mongoose from 'mongoose';
import Notification from '../models/Notification.js';

/**
 * GET /api/notifications
 * Get current customer's notifications.
 */
export const getMyNotifications = async (req, res, next) => {
  try {
    if (!req.customer?._id) {
      return res.status(401).json({
        success: false,
        message: 'Customer authentication required.',
      });
    }

    const recipient = req.customer._id;

    const [notifications, unreadCount] = await Promise.all([
      Notification.find({ recipient })
        .sort({ createdAt: -1 })
        .limit(50)
        .lean(),

      Notification.countDocuments({
        recipient,
        read: false,
      }),
    ]);

    return res.status(200).json({
      success: true,
      unreadCount,
      count: notifications.length,
      notifications,
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * PATCH /api/notifications/:id/read
 * Mark one notification as read.
 */
export const markNotificationAsRead = async (req, res, next) => {
  try {
    if (!req.customer?._id) {
      return res.status(401).json({
        success: false,
        message: 'Customer authentication required.',
      });
    }

    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid notification ID.',
      });
    }

    const notification = await Notification.findOneAndUpdate(
      {
        _id: id,
        recipient: req.customer._id,
      },
      {
        $set: { read: true },
      },
      {
        new: true,
        runValidators: true,
      }
    );

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found.',
      });
    }

    return res.status(200).json({
      success: true,
      notification,
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * PATCH /api/notifications/read-all
 * Mark all current customer's notifications as read.
 */
export const markAllNotificationsAsRead = async (req, res, next) => {
  try {
    if (!req.customer?._id) {
      return res.status(401).json({
        success: false,
        message: 'Customer authentication required.',
      });
    }

    const result = await Notification.updateMany(
      {
        recipient: req.customer._id,
        read: false,
      },
      {
        $set: { read: true },
      }
    );

    return res.status(200).json({
      success: true,
      message: 'All notifications marked as read.',
      modifiedCount: result.modifiedCount,
    });
  } catch (error) {
    return next(error);
  }
};
