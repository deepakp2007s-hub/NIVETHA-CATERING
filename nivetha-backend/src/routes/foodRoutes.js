
import express from 'express';

import {
  getAllFoods,
  getFoodById,
  createFood,
  updateFood,
  deleteFood,
  getCatalogStats,
} from '../controllers/foodController.js';

import { protectOwner } from '../middleware/authMiddleware.js';

const router = express.Router();

// Public: customers and owner app can view available foods
router.get('/', getAllFoods);

// Owner only: food catalog statistics
router.get('/stats', protectOwner, getCatalogStats);

// Public: get a single food item
router.get('/:id', getFoodById);

// Owner only: add a food item
router.post('/', protectOwner, createFood);

// Owner only: update a food item
router.put('/:id', protectOwner, updateFood);
router.patch('/:id', protectOwner, updateFood);

// Owner only: delete a food item
router.delete('/:id', protectOwner, deleteFood);

export default router;
