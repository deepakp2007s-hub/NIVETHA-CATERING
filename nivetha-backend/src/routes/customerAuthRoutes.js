import express from 'express';
import {
  registerCustomer,
  loginCustomer,
  getCustomerProfile,
  updateCustomerProfile,
} from '../controllers/customerAuthController.js';
import { protectCustomer } from '../middleware/customerAuthMiddleware.js';

const router = express.Router();

// Public authentication routes
router.post('/register', registerCustomer);
router.post('/login', loginCustomer);

// Customer profile routes (supports both /profile and /me with GET, PUT, and PATCH)
router.get('/profile', protectCustomer, getCustomerProfile);
router.get('/me', protectCustomer, getCustomerProfile);
router.put('/profile', protectCustomer, updateCustomerProfile);
router.patch('/profile', protectCustomer, updateCustomerProfile);
router.put('/me', protectCustomer, updateCustomerProfile);
router.patch('/me', protectCustomer, updateCustomerProfile);

export default router;

