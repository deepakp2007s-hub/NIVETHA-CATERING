import express from 'express';
import { getCustomers, getCustomerById } from '../controllers/customerController.js';
import { protectOwner } from '../middleware/authMiddleware.js';

const router = express.Router();

// All customer management routes require Owner privileges
router.use(protectOwner);

router.get('/', getCustomers);
router.get('/:id', getCustomerById);

export default router;
