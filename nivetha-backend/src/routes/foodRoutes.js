
import express from 'express';

import {
  getAllFoods,
  getFoodById,
  createFood,
  updateFood,
  deleteFood,
  getCatalogStats
} from '../controllers/foodController.js';

import { protectOwner } from '../middleware/authMiddleware.js';

const router = express.Router();

// Public: get all foods with optional filters
router.get('/', getAllFoods);

// Owner only: catalogue statistics
// Keep this route before /:id
router.get('/stats', protectOwner, getCatalogStats);

// Public: get one food item by ID
router.get('/:id', getFoodById);

// Owner only: create food
router.post('/', protectOwner, createFood);

// Owner only: update food
router.put('/:id', protectOwner, updateFood);
router.patch('/:id', protectOwner, updateFood);

// Owner only: delete food
router.delete('/:id', protectOwner, deleteFood);

export default router;
