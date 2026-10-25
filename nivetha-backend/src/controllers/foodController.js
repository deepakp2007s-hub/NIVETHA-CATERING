
import mongoose from 'mongoose';
import Food from '../models/Food.js';

const ALLOWED_CATEGORIES = [
  'Breakfast',
  'Meals',
  'Rice',
  'Veg Gravy',
  'Non-Veg Gravy',
  'Biryani',
  'Starter',
  'Seafood',
  'Bread',
  'Sweets'
];

const ALLOWED_FIELDS = [
  'name',
  'tamilName',
  'category',
  'type',
  'description',
  'imageUrl',
  'isAvailable'
];

const sendError = (res, message, status = 500) =>
  res.status(status).json({
    success: false,
    message
  });

const escapeRegex = (value) =>
  value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

const normalizeType = (value) => {
  if (typeof value !== 'string') return null;

  const normalized = value.trim().toLowerCase();

  if (normalized === 'veg') return 'Veg';

  if (
    normalized === 'non-veg' ||
    normalized === 'nonveg' ||
    normalized === 'non veg'
  ) {
    return 'Non-Veg';
  }

  return null;
};

const normalizeCategory = (value) => {
  if (typeof value !== 'string') return null;

  return (
    ALLOWED_CATEGORIES.find(
      (category) =>
        category.toLowerCase() === value.trim().toLowerCase()
    ) || null
  );
};

const sanitizeFood = (food) => {
  if (!food) return food;

  const result =
    typeof food.toObject === 'function'
      ? food.toObject()
      : { ...food };

  delete result.price;
  delete result.__v;

  return result;
};

const isValidImageUrl = (value) => {
  if (typeof value !== 'string' || !value.trim()) {
    return false;
  }

  try {
    const url = new URL(value.trim());

    return (
      ['https:', 'http:'].includes(url.protocol) &&
      Boolean(url.hostname)
    );
  } catch {
    return false;
  }
};

const isValidId = (id) => mongoose.isValidObjectId(id);

// GET /api/foods
// Public food catalogue with optional filters.
export const getAllFoods = async (req, res) => {
  try {
    const { category, type, search, available } = req.query;
    const filter = {};

    if (category && category.trim().toLowerCase() !== 'all') {
      const normalizedCategory = normalizeCategory(category);

      if (!normalizedCategory) {
        return sendError(res, 'Invalid food category', 400);
      }

      filter.category = normalizedCategory;
    }

    if (type && type.trim().toLowerCase() !== 'all') {
      const normalizedType = normalizeType(type);

      if (!normalizedType) {
        return sendError(res, 'Type must be Veg or Non-Veg', 400);
      }

      filter.type = normalizedType;
    }

    // Support both ?available=true and ?isAvailable=true.
    const availabilityValue = req.query.isAvailable ?? available;

    if (availabilityValue !== undefined) {
      if (!['true', 'false'].includes(availabilityValue)) {
        return sendError(
          res,
          'available/isAvailable must be true or false',
          400
        );
      }

      filter.isAvailable = availabilityValue === 'true';
    }

    if (typeof search === 'string' && search.trim()) {
      const searchRegex = new RegExp(
        escapeRegex(search.trim()),
        'i'
      );

      filter.$or = [
        { name: searchRegex },
        { tamilName: searchRegex },
        { description: searchRegex }
      ];
    }

    const foods = await Food.find(filter)
      .select('-price')
      .sort({ category: 1, name: 1 })
      .lean();

    const data = foods.map(sanitizeFood);

    return res.status(200).json({
      success: true,
      count: data.length,
      data
    });
  } catch (error) {
    console.error('getAllFoods error:', error);
    return sendError(res, 'Failed to fetch food items');
  }
};

// GET /api/foods/:id
export const getFoodById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!isValidId(id)) {
      return sendError(res, 'Invalid food ID', 400);
    }

    const food = await Food.findById(id)
      .select('-price')
      .lean();

    if (!food) {
      return sendError(res, 'Food item not found', 404);
    }

    return res.status(200).json({
      success: true,
      data: sanitizeFood(food)
    });
  } catch (error) {
    console.error('getFoodById error:', error);
    return sendError(res, 'Failed to fetch food item');
  }
};

// POST /api/foods
// Owner authentication is applied in foodRoutes.js.
export const createFood = async (req, res) => {
  try {
    const {
      name,
      tamilName = '',
      category,
      type = 'Veg',
      description = '',
      imageUrl = '',
      isAvailable = true
    } = req.body;

    if (typeof name !== 'string' || !name.trim()) {
      return sendError(res, 'Food name is required', 400);
    }

    if (typeof tamilName !== 'string') {
      return sendError(res, 'Tamil name must be text', 400);
    }

    const normalizedCategory = normalizeCategory(category);

    if (!normalizedCategory) {
      return sendError(res, 'Invalid food category', 400);
    }

    const normalizedType = normalizeType(type);

    if (!normalizedType) {
      return sendError(res, 'Type must be Veg or Non-Veg', 400);
    }

    if (imageUrl && !isValidImageUrl(imageUrl)) {
      return sendError(
        res,
        'imageUrl must be a valid HTTP or HTTPS URL',
        400
      );
    }

    if (typeof isAvailable !== 'boolean') {
      return sendError(res, 'isAvailable must be a boolean', 400);
    }

    if (typeof description !== 'string') {
      return sendError(res, 'Description must be text', 400);
    }

    const normalizedName = name.trim();

    const existingFood = await Food.findOne({
      name: {
        $regex: `^${escapeRegex(normalizedName)}$`,
        $options: 'i'
      }
    });

    if (existingFood) {
      return sendError(
        res,
        `Food "${normalizedName}" already exists`,
        409
      );
    }

    const food = await Food.create({
      name: normalizedName,
      tamilName: tamilName.trim(),
      category: normalizedCategory,
      type: normalizedType,
      description: description.trim(),
      imageUrl: imageUrl ? imageUrl.trim() : '',
      isAvailable
    });

    return res.status(201).json({
      success: true,
      message: 'Food item created successfully',
      data: sanitizeFood(food)
    });
  } catch (error) {
    if (error.code === 11000) {
      return sendError(
        res,
        'A food item with this name already exists',
        409
      );
    }

    if (error.name === 'ValidationError') {
      return sendError(res, error.message, 400);
    }

    console.error('createFood error:', error);
    return sendError(res, 'Failed to create food item');
  }
};

// PUT/PATCH /api/foods/:id
export const updateFood = async (req, res) => {
  try {
    const { id } = req.params;

    if (!isValidId(id)) {
      return sendError(res, 'Invalid food ID', 400);
    }

    const updates = {};

    for (const field of ALLOWED_FIELDS) {
      if (Object.prototype.hasOwnProperty.call(req.body, field)) {
        updates[field] = req.body[field];
      }
    }

    if (Object.keys(updates).length === 0) {
      return sendError(res, 'No valid food fields provided', 400);
    }

    if ('name' in updates) {
      if (typeof updates.name !== 'string' || !updates.name.trim()) {
        return sendError(res, 'Food name cannot be empty', 400);
      }

      updates.name = updates.name.trim();

      const duplicate = await Food.findOne({
        name: {
          $regex: `^${escapeRegex(updates.name)}$`,
          $options: 'i'
        },
        _id: { $ne: id }
      });

      if (duplicate) {
        return sendError(
          res,
          'Another food already uses this name',
          409
        );
      }
    }

    if ('tamilName' in updates) {
      if (typeof updates.tamilName !== 'string') {
        return sendError(res, 'Tamil name must be text', 400);
      }

      updates.tamilName = updates.tamilName.trim();
    }

    if ('category' in updates) {
      const normalizedCategory = normalizeCategory(updates.category);

      if (!normalizedCategory) {
        return sendError(res, 'Invalid food category', 400);
      }

      updates.category = normalizedCategory;
    }

    if ('type' in updates) {
      const normalizedType = normalizeType(updates.type);

      if (!normalizedType) {
        return sendError(res, 'Type must be Veg or Non-Veg', 400);
      }

      updates.type = normalizedType;
    }

    if ('imageUrl' in updates) {
      if (
        updates.imageUrl !== '' &&
        !isValidImageUrl(updates.imageUrl)
      ) {
        return sendError(
          res,
          'imageUrl must be a valid HTTP or HTTPS URL',
          400
        );
      }

      if (typeof updates.imageUrl !== 'string') {
        return sendError(res, 'imageUrl must be text', 400);
      }

      updates.imageUrl = updates.imageUrl.trim();
    }

    if (
      'isAvailable' in updates &&
      typeof updates.isAvailable !== 'boolean'
    ) {
      return sendError(res, 'isAvailable must be a boolean', 400);
    }

    if ('description' in updates) {
      if (typeof updates.description !== 'string') {
        return sendError(res, 'Description must be text', 400);
      }

      updates.description = updates.description.trim();
    }

    const food = await Food.findByIdAndUpdate(
      id,
      { $set: updates },
      {
        new: true,
        runValidators: true
      }
    ).select('-price');

    if (!food) {
      return sendError(res, 'Food item not found', 404);
    }

    return res.status(200).json({
      success: true,
      message: 'Food item updated successfully',
      data: sanitizeFood(food)
    });
  } catch (error) {
    if (error.code === 11000) {
      return sendError(
        res,
        'A food item with this name already exists',
        409
      );
    }

    if (error.name === 'ValidationError') {
      return sendError(res, error.message, 400);
    }

    console.error('updateFood error:', error);
    return sendError(res, 'Failed to update food item');
  }
};

// DELETE /api/foods/:id
export const deleteFood = async (req, res) => {
  try {
    const { id } = req.params;

    if (!isValidId(id)) {
      return sendError(res, 'Invalid food ID', 400);
    }

    const food = await Food.findByIdAndDelete(id);

    if (!food) {
      return sendError(res, 'Food item not found', 404);
    }

    return res.status(200).json({
      success: true,
      message: `Deleted food item "${food.name}"`
    });
  } catch (error) {
    console.error('deleteFood error:', error);
    return sendError(res, 'Failed to delete food item');
  }
};

// GET /api/foods/stats
export const getCatalogStats = async (req, res) => {
  try {
    const [
      total,
      available,
      veg,
      nonVeg,
      categories
    ] = await Promise.all([
      Food.countDocuments(),
      Food.countDocuments({ isAvailable: true }),
      Food.countDocuments({ type: 'Veg' }),
      Food.countDocuments({ type: 'Non-Veg' }),
      Food.aggregate([
        {
          $group: {
            _id: '$category',
            count: { $sum: 1 },
            available: {
              $sum: {
                $cond: ['$isAvailable', 1, 0]
              }
            }
          }
        },
        { $sort: { _id: 1 } }
      ])
    ]);

    return res.status(200).json({
      success: true,
      data: {
        total,
        available,
        unavailable: total - available,
        veg,
        nonVeg,
        categories
      }
    });
  } catch (error) {
    console.error('getCatalogStats error:', error);
    return sendError(res, 'Failed to fetch food statistics');
  }
};
