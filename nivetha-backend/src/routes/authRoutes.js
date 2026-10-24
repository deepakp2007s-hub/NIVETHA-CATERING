import express from 'express';
import { loginOwner, getOwnerProfile } from '../controllers/authController.js';
import { protectOwner } from '../middleware/authMiddleware.js';

const router = express.Router();

// Owner login (Public endpoint, but only authorized owner credentials succeed)
router.post('/login', loginOwner);

// Owner profile
router.get('/me', protectOwner, getOwnerProfile);

export default router;
