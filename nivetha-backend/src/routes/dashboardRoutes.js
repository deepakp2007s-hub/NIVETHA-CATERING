import express from 'express';
import { getDashboardStats } from '../controllers/dashboardController.js';
import { protectOwner } from '../middleware/authMiddleware.js';

const router = express.Router();

router.use(protectOwner);

router.get('/', getDashboardStats);
router.get('/stats', getDashboardStats);

export default router;
