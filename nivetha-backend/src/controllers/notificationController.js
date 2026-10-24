import Notification from '../models/Notification.js';

/**
 * @desc    Get Current Customer's Notifications
 * @route   GET /api/notifications
 * @access  Private (Customer)
 */
export const getMyNotifications = async (req, res, next) => {
  try {
    const notifications = await Notification.find({ recipient: req.customer._id })
      .sort({ createdAt: -1 })
      .limit(50);

    const unreadCount = await Notification.countDocuments({
      recipient: req.customer._id,
      read: false,
    });

    res.json({
      success: true,
      unreadCount,
      count: notifications.length,
      notifications,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Mark a Single Notification as Read
 * @route   PATCH /api/notifications/:id/read
 * @access  Private (Customer)
 */
export const markNotificationAsRead = async (req, res, next) => {
  try {
    const notification = await Notification.findOne({
      _id: req.params.id,
      recipient: req.customer._id,
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found.',
      });
    }

    notification.read = true;
    await notification.save();

    res.json({
      success: true,
      notification,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Mark All Customer Notifications as Read
 * @route   PATCH /api/notifications/read-all
 * @access  Private (Customer)
 */
export const markAllNotificationsAsRead = async (req, res, next) => {
  try {
    await Notification.updateMany({ recipient: req.customer._id, read: false }, { read: true });

    res.json({
      success: true,
      message: 'All notifications marked as read.',
    });
  } catch (error) {
    next(error);
  }
};
