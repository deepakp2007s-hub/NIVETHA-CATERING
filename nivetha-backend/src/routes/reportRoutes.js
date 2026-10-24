import express from 'express';
import { getReportsSummary } from '../controllers/reportController.js';
import { protectOwner } from '../middleware/authMiddleware.js';

const router = express.Router();

router.use(protectOwner);

router.get('/', getReportsSummary);
router.get('/summary', getReportsSummary);

export default router;
