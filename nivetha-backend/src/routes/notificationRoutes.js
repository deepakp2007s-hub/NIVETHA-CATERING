import express from 'express';
import {
  getMyNotifications,
  markNotificationAsRead,
  markAllNotificationsAsRead,
  deleteNotification,
} from '../controllers/notificationController.js';
import { protectCustomer } from '../middleware/customerAuthMiddleware.js';

const router = express.Router();

router.use(protectCustomer);

router.get('/', getMyNotifications);
router.patch('/read-all', markAllNotificationsAsRead);
router.patch('/:id/read', markNotificationAsRead);
router.delete('/:id', deleteNotification);

export default router;

