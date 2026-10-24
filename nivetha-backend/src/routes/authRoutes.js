
import express from 'express';
import {
  loginOwner,
  getOwnerProfile,
} from '../controllers/authController.js';
import { protectOwner } from '../middleware/authMiddleware.js';

const router = express.Router();

// Owner login
router.post('/login', loginOwner);

// Authenticated owner profile
router.get('/me', protectOwner, getOwnerProfile);

export default router;
