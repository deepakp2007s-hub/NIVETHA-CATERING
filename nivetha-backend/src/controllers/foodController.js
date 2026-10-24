/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import mongoose from 'mongoose';
import Food from '../models/Food.js';

const ALLOWED_CATEGORIES = [
  'Breakfast & Tiffin',
  'Meals & Vegetarian',
  'Biryani, Rice & Non-Vegetarian',
  'Dinner',
  'Sweets & Desserts',
];

const ALLOWED_TYPES = ['Veg', 'Non-Veg', 'Sweet'];

const ALLOWED_FIELDS = [
  'name',
  'tamilName',
  'category',
  'type',
  'description',
  'image',
  'available',
];

const escapeRegex = (value) => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

const isValidImageUrl = (value) => {
  if (typeof value !== 'string' || !value.trim()) return false;

  try {
    const url = new URL(value);
    return url.protocol === 'https:' || url.protocol === 'http:';
  } catch {
    return false;
  }
};

/**
 * Get all foods with optional filters.
 */
export const getAllFoods = async (req, res) => {
  try {
    const { category, type, search, available } = req.query;
    const filter = {};

    if (category && category !== 'All') {
      if (!ALLOWED_CATEGORIES.includes(category)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid food category',
        });
      }
      filter.category = category;
    }

    if (type && type !== 'All') {
      if (!ALLOWED_TYPES.includes(type)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid food type',
        });
      }
      filter.type = type;
    }

    if (available !== undefined) {
      if (!['true', 'false'].includes(available)) {
        return res.status(400).json({
          success: false,
          message: 'available must be true or false',
        });
      }
      filter.available = available === 'true';
    }

    if (search?.trim()) {
      const searchRegex = new RegExp(escapeRegex(search.trim()), 'i');

      filter.$or = [
        { name: searchRegex },
        { tamilName: searchRegex },
        { description: searchRegex },
      ];
    }

    const foods = await Food.find(filter).sort({ category: 1, name: 1 });

    return res.status(200).json({
      success: true,
      count: foods.length,
      data: foods,
    });
  } catch (error) {
    console.error('getAllFoods error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch food items',
    });
  }
};

/**
 * Get one food by ID.
 */
export const getFoodById = async (req, res) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food ID',
      });
    }

    const food = await Food.findById(req.params.id);

    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found',
      });
    }

    return res.status(200).json({
      success: true,
      data: food,
    });
  } catch (error) {
    console.error('getFoodById error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch food item',
    });
  }
};

/**
 * Create a food item.
 * This route must use protectOwner in foodRoutes.js.
 */
export const createFood = async (req, res) => {
  try {
    const {
      name,
      tamilName,
      category,
      type,
      description = '',
      image,
      available = true,
    } = req.body;

    if (typeof name !== 'string' || !name.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Food name is required',
      });
    }

    if (typeof tamilName !== 'string' || !tamilName.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Tamil food name is required',
      });
    }

    if (!ALLOWED_CATEGORIES.includes(category)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food category',
      });
    }

    if (!ALLOWED_TYPES.includes(type || 'Veg')) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food type',
      });
    }

    if (!isValidImageUrl(image)) {
      return res.status(400).json({
        success: false,
        message: 'A valid HTTP or HTTPS image URL is required',
      });
    }

    if (typeof available !== 'boolean') {
      return res.status(400).json({
        success: false,
        message: 'available must be a boolean',
      });
    }

    const normalizedName = name.trim();
    const existingFood = await Food.findOne({
      name: { $regex: `^${escapeRegex(normalizedName)}$`, $options: 'i' },
    });

    if (existingFood) {
      return res.status(409).json({
        success: false,
        message: `Food "${normalizedName}" already exists`,
      });
    }

    const food = await Food.create({
      name: normalizedName,
      tamilName: tamilName.trim(),
      category,
      type: type || 'Veg',
      description: typeof description === 'string' ? description.trim() : '',
      image: image.trim(),
      available,
    });

    return res.status(201).json({
      success: true,
      message: 'Food item created successfully',
      data: food,
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({
        success: false,
        message: 'A food item with this name already exists',
      });
    }

    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    console.error('createFood error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to create food item',
    });
  }
};

/**
 * Update only supported food fields.
 */
export const updateFood = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food ID',
      });
    }

    const updates = {};

    for (const field of ALLOWED_FIELDS) {
      if (Object.prototype.hasOwnProperty.call(req.body, field)) {
        updates[field] = req.body[field];
      }
    }

    if (!Object.keys(updates).length) {
      return res.status(400).json({
        success: false,
        message: 'No valid food fields provided',
      });
    }

    if ('name' in updates) {
      if (typeof updates.name !== 'string' || !updates.name.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Food name cannot be empty',
        });
      }
      updates.name = updates.name.trim();

      const duplicate = await Food.findOne({
        name: { $regex: `^${escapeRegex(updates.name)}$`, $options: 'i' },
        _id: { $ne: id },
      });

      if (duplicate) {
        return res.status(409).json({
          success: false,
          message: 'Another food already uses this name',
        });
      }
    }

    if ('tamilName' in updates) {
      if (typeof updates.tamilName !== 'string' || !updates.tamilName.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Tamil name cannot be empty',
        });
      }
      updates.tamilName = updates.tamilName.trim();
    }

    if ('category' in updates && !ALLOWED_CATEGORIES.includes(updates.category)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food category',
      });
    }

    if ('type' in updates && !ALLOWED_TYPES.includes(updates.type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food type',
      });
    }

    if ('image' in updates && !isValidImageUrl(updates.image)) {
      return res.status(400).json({
        success: false,
        message: 'A valid HTTP or HTTPS image URL is required',
      });
    }

    if ('available' in updates && typeof updates.available !== 'boolean') {
      return res.status(400).json({
        success: false,
        message: 'available must be a boolean',
      });
    }

    if ('description' in updates) {
      if (typeof updates.description !== 'string') {
        return res.status(400).json({
          success: false,
          message: 'Description must be text',
        });
      }
      updates.description = updates.description.trim();
    }

    const food = await Food.findByIdAndUpdate(id, updates, {
      new: true,
      runValidators: true,
    });

    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Food item updated successfully',
      data: food,
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({
        success: false,
        message: 'A food item with this name already exists',
      });
    }

    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    console.error('updateFood error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to update food item',
    });
  }
};

/**
 * Delete a food item.
 * This route must use protectOwner in foodRoutes.js.
 */
export const deleteFood = async (req, res) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food ID',
      });
    }

    const food = await Food.findByIdAndDelete(req.params.id);

    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found',
      });
    }

    return res.status(200).json({
      success: true,
      message: `Deleted food item "${food.name}"`,
    });
  } catch (error) {
    console.error('deleteFood error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to delete food item',
    });
  }
};

/**
 * Get live food catalog statistics.
 */
export const getCatalogStats = async (req, res) => {
  try {
    const [total, available, veg, nonVeg, sweets, categories] =
      await Promise.all([
        Food.countDocuments(),
        Food.countDocuments({ available: true }),
        Food.countDocuments({ type: 'Veg' }),
        Food.countDocuments({ type: 'Non-Veg' }),
        Food.countDocuments({ type: 'Sweet' }),
        Food.aggregate([
          {
            $group: {
              _id: '$category',
              count: { $sum: 1 },
              available: {
                $sum: { $cond: ['$available', 1, 0] },
              },
            },
          },
          { $sort: { _id: 1 } },
        ]),
      ]);

    return res.status(200).json({
      success: true,
      data: {
        total,
        available,
        unavailable: total - available,
        veg,
        nonVeg,
        sweets,
        categories,
      },
    });
  } catch (error) {
    console.error('getCatalogStats error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch food statistics',
    });
  }
};