import express from 'express';
import { getCustomers, getCustomerById } from '../controllers/customerController.js';
import {
  getCustomerProfile,
  updateCustomerProfile,
} from '../controllers/customerAuthController.js';
import { protectCustomer } from '../middleware/customerAuthMiddleware.js';
import { protectOwner } from '../middleware/authMiddleware.js';

const router = express.Router();

// Customer self-management routes (must be registered before /:id)
router.get('/profile', protectCustomer, getCustomerProfile);
router.get('/me', protectCustomer, getCustomerProfile);
router.put('/profile', protectCustomer, updateCustomerProfile);
router.patch('/profile', protectCustomer, updateCustomerProfile);
router.put('/me', protectCustomer, updateCustomerProfile);
router.patch('/me', protectCustomer, updateCustomerProfile);

// Owner-only customer management routes
router.get('/', protectOwner, getCustomers);
router.get('/:id', protectOwner, getCustomerById);

export default router;

