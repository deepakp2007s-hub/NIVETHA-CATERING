
/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

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

// Public routes — customers can view foods
router.get('/stats', getCatalogStats);
router.get('/', getAllFoods);
router.get('/:id', getFoodById);

// Owner-only routes — authentication required
router.post('/', protectOwner, createFood);
router.put('/:id', protectOwner, updateFood);
router.patch('/:id', protectOwner, updateFood);
router.delete('/:id', protectOwner, deleteFood);

export default router;
