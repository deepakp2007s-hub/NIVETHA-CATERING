
import express from 'express';
import {
  loginOwner,
  getOwnerProfile,
} from '../controllers/authController.js';
import { protectOwner } from '../middleware/authMiddleware.js';

const router = express.Router();

// Owner login
router.post('/login', loginOwner);

// Authenticated owner profile (supports both /me and /profile)
router.get('/me', protectOwner, getOwnerProfile);
router.get('/profile', protectOwner, getOwnerProfile);

export default router;
