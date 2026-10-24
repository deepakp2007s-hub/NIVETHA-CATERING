import express from 'express';
import {
  getFoods,
  getFoodById,
  createFood,
  updateFood,
  toggleFoodAvailability,
  deleteFood,
} from '../controllers/foodController.js';
import { protectOwner } from '../middleware/authMiddleware.js';

const router = express.Router();

// Public / Customer read access
router.get('/', getFoods);
router.get('/:id', getFoodById);

// Owner-only write / modify access
router.post('/', protectOwner, createFood);
router.put('/:id', protectOwner, updateFood);
router.patch('/:id/toggle-availability', protectOwner, toggleFoodAvailability);
router.delete('/:id', protectOwner, deleteFood);

export default router;
