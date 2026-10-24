
import mongoose from 'mongoose';
import Food from '../models/Food.js';

const escapeRegex = (value) =>
  value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

const validateFoodId = (id) => mongoose.isValidObjectId(id);

const handleFoodError = (error, res, next) => {
  if (error?.code === 11000) {
    return res.status(409).json({
      success: false,
      message: 'A food item with this name already exists.',
    });
  }

  if (error?.name === 'ValidationError' || error?.name === 'CastError') {
    return res.status(400).json({
      success: false,
      message: error.message,
    });
  }

  return next(error);
};

/**
 * GET /api/foods
 * Public food list with optional filters.
 */
export const getFoods = async (req, res, next) => {
  try {
    const { category, type, available, search } = req.query;
    const filter = {};

    if (category !== undefined) {
      if (typeof category !== 'string' || !category.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Invalid category.',
        });
      }
      filter.category = category.trim();
    }

    if (type !== undefined) {
      if (typeof type !== 'string' || !type.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Invalid food type.',
        });
      }
      filter.type = type.trim().toLowerCase();
    }

    if (available !== undefined) {
      if (!['true', 'false'].includes(available)) {
        return res.status(400).json({
          success: false,
          message: 'Available must be true or false.',
        });
      }
      filter.available = available === 'true';
    }

    if (search !== undefined) {
      if (typeof search !== 'string' || search.length > 100) {
        return res.status(400).json({
          success: false,
          message: 'Search must be a string of at most 100 characters.',
        });
      }

      const query = search.trim();

      if (query) {
        const escaped = escapeRegex(query);
        filter.$or = [
          { name: { $regex: escaped, $options: 'i' } },
          { tamilName: { $regex: escaped, $options: 'i' } },
          { description: { $regex: escaped, $options: 'i' } },
        ];
      }
    }

    const foods = await Food.find(filter)
      .sort({ category: 1, name: 1 })
      .lean();

    return res.status(200).json({
      success: true,
      count: foods.length,
      foods,
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * GET /api/foods/:id
 */
export const getFoodById = async (req, res, next) => {
  try {
    if (!validateFoodId(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food ID.',
      });
    }

    const food = await Food.findById(req.params.id).lean();

    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found.',
      });
    }

    return res.status(200).json({ success: true, food });
  } catch (error) {
    return next(error);
  }
};

/**
 * POST /api/foods — Owner only.
 */
export const createFood = async (req, res, next) => {
  try {
    const {
      name,
      tamilName,
      category,
      type,
      description = '',
      price = 0,
      image = '',
      available = true,
    } = req.body;

    if (
      typeof name !== 'string' ||
      !name.trim() ||
      typeof tamilName !== 'string' ||
      !tamilName.trim() ||
      typeof category !== 'string' ||
      !category.trim() ||
      typeof type !== 'string' ||
      !type.trim()
    ) {
      return res.status(400).json({
        success: false,
        message: 'Food name, Tamil name, category, and type are required.',
      });
    }

    if (
      typeof description !== 'string' ||
      typeof image !== 'string' ||
      typeof available !== 'boolean'
    ) {
      return res.status(400).json({
        success: false,
        message: 'Invalid description, image, or availability value.',
      });
    }

    const parsedPrice = Number(price);

    if (!Number.isFinite(parsedPrice) || parsedPrice < 0) {
      return res.status(400).json({
        success: false,
        message: 'Price must be a valid non-negative number.',
      });
    }

    const normalizedName = name.trim();

    const existing = await Food.findOne({
      name: normalizedName,
    }).select('_id');

    if (existing) {
      return res.status(409).json({
        success: false,
        message: 'A food item with this name already exists.',
      });
    }

    const food = await Food.create({
      name: normalizedName,
      tamilName: tamilName.trim(),
      category: category.trim(),
      type: type.trim().toLowerCase(),
      description: description.trim(),
      price: parsedPrice,
      image: image.trim(),
      available,
    });

    return res.status(201).json({
      success: true,
      message: 'Food item created successfully.',
      food,
    });
  } catch (error) {
    return handleFoodError(error, res, next);
  }
};

/**
 * PUT /api/foods/:id — Owner only.
 */
export const updateFood = async (req, res, next) => {
  try {
    if (!validateFoodId(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food ID.',
      });
    }

    const food = await Food.findById(req.params.id);

    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found.',
      });
    }

    const updates = req.body;

    if (updates.name !== undefined) {
      if (typeof updates.name !== 'string' || !updates.name.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Food name must be a non-empty string.',
        });
      }

      const newName = updates.name.trim();

      if (newName !== food.name) {
        const duplicate = await Food.findOne({
          name: newName,
          _id: { $ne: food._id },
        }).select('_id');

        if (duplicate) {
          return res.status(409).json({
            success: false,
            message: 'A food item with this name already exists.',
          });
        }

        food.name = newName;
      }
    }

    if (updates.tamilName !== undefined) {
      if (typeof updates.tamilName !== 'string' || !updates.tamilName.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Tamil name must be a non-empty string.',
        });
      }
      food.tamilName = updates.tamilName.trim();
    }

    if (updates.category !== undefined) {
      if (typeof updates.category !== 'string') {
        return res.status(400).json({
          success: false,
          message: 'Invalid food category.',
        });
      }
      food.category = updates.category.trim();
    }

    if (updates.type !== undefined) {
      if (typeof updates.type !== 'string' || !updates.type.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Invalid food type.',
        });
      }
      food.type = updates.type.trim().toLowerCase();
    }

    if (updates.description !== undefined) {
      if (typeof updates.description !== 'string') {
        return res.status(400).json({
          success: false,
          message: 'Description must be a string.',
        });
      }
      food.description = updates.description.trim();
    }

    if (updates.price !== undefined) {
      const parsedPrice = Number(updates.price);

      if (!Number.isFinite(parsedPrice) || parsedPrice < 0) {
        return res.status(400).json({
          success: false,
          message: 'Price must be a valid non-negative number.',
        });
      }
      food.price = parsedPrice;
    }

    if (updates.image !== undefined) {
      if (typeof updates.image !== 'string') {
        return res.status(400).json({
          success: false,
          message: 'Image must be a string.',
        });
      }
      food.image = updates.image.trim();
    }

    if (updates.available !== undefined) {
      if (typeof updates.available !== 'boolean') {
        return res.status(400).json({
          success: false,
          message: 'Availability must be true or false.',
        });
      }
      food.available = updates.available;
    }

    await food.save();

    return res.status(200).json({
      success: true,
      message: 'Food item updated successfully.',
      food,
    });
  } catch (error) {
    return handleFoodError(error, res, next);
  }
};

/**
 * PATCH /api/foods/:id/toggle-availability — Owner only.
 */
export const toggleFoodAvailability = async (req, res, next) => {
  try {
    if (!validateFoodId(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food ID.',
      });
    }

    const food = await Food.findById(req.params.id);

    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found.',
      });
    }

    food.available = !food.available;
    await food.save();

    return res.status(200).json({
      success: true,
      message: `Food availability set to ${food.available ? 'Available' : 'Unavailable'}.`,
      available: food.available,
      food,
    });
  } catch (error) {
    return handleFoodError(error, res, next);
  }
};

/**
 * DELETE /api/foods/:id — Owner only.
 */
export const deleteFood = async (req, res, next) => {
  try {
    if (!validateFoodId(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid food ID.',
      });
    }

    const food = await Food.findById(req.params.id);

    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found.',
      });
    }

    await Food.deleteOne({ _id: food._id });

    return res.status(200).json({
      success: true,
      message: `Food item "${food.name}" deleted successfully.`,
    });
  } catch (error) {
    return next(error);
  }
};
