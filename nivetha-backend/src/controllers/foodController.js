import Food from '../models/Food.js';

/**
 * @desc    Get All Foods (with filtering and search)
 * @route   GET /api/foods
 * @access  Public / Customer / Owner
 */
export const getFoods = async (req, res, next) => {
  try {
    const { category, type, available, search } = req.query;
    const filter = {};

    if (category) {
      filter.category = category;
    }

    if (type) {
      filter.type = type.toLowerCase();
    }

    if (available !== undefined) {
      filter.available = available === 'true';
    }

    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { tamilName: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ];
    }

    const foods = await Food.find(filter).sort({ category: 1, name: 1 });

    res.json({
      success: true,
      count: foods.length,
      foods,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get Single Food by ID
 * @route   GET /api/foods/:id
 * @access  Public
 */
export const getFoodById = async (req, res, next) => {
  try {
    const food = await Food.findById(req.params.id);
    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found.',
      });
    }

    res.json({
      success: true,
      food,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Add New Food Item
 * @route   POST /api/foods
 * @access  Private (Owner Only)
 */
export const createFood = async (req, res, next) => {
  try {
    const { name, tamilName, category, type, description, price, image, available } = req.body;

    if (!name || !tamilName || !category || !type) {
      return res.status(400).json({
        success: false,
        message: 'Food English name, Tamil name, category, and type are required.',
      });
    }

    const existing = await Food.findOne({ name: name.trim() });
    if (existing) {
      return res.status(409).json({
        success: false,
        message: `A food item named "${name}" already exists in the menu.`,
      });
    }

    const food = await Food.create({
      name: name.trim(),
      tamilName: tamilName.trim(),
      category,
      type: type.toLowerCase(),
      description: description ? description.trim() : '',
      price: Number(price) >= 0 ? Number(price) : 0,
      image: image || undefined,
      available: available !== undefined ? available : true,
    });

    res.status(201).json({
      success: true,
      message: 'Food item created successfully',
      food,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Update Food Item
 * @route   PUT /api/foods/:id
 * @access  Private (Owner Only)
 */
export const updateFood = async (req, res, next) => {
  try {
    const food = await Food.findById(req.params.id);
    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found.',
      });
    }

    const updates = req.body;
    if (updates.name) food.name = updates.name.trim();
    if (updates.tamilName) food.tamilName = updates.tamilName.trim();
    if (updates.category) food.category = updates.category;
    if (updates.type) food.type = updates.type.toLowerCase();
    if (updates.description !== undefined) food.description = updates.description.trim();
    if (updates.price !== undefined) food.price = Number(updates.price);
    if (updates.image !== undefined) food.image = updates.image;
    if (updates.available !== undefined) food.available = updates.available;

    await food.save();

    res.json({
      success: true,
      message: 'Food item updated successfully',
      food,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Toggle Food Availability
 * @route   PATCH /api/foods/:id/toggle-availability
 * @access  Private (Owner Only)
 */
export const toggleFoodAvailability = async (req, res, next) => {
  try {
    const food = await Food.findById(req.params.id);
    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found.',
      });
    }

    food.available = !food.available;
    await food.save();

    res.json({
      success: true,
      message: `Food "${food.name}" availability set to ${food.available ? 'Available' : 'Unavailable'}`,
      available: food.available,
      food,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Delete Food Item
 * @route   DELETE /api/foods/:id
 * @access  Private (Owner Only)
 */
export const deleteFood = async (req, res, next) => {
  try {
    const food = await Food.findById(req.params.id);
    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found.',
      });
    }

    await Food.deleteOne({ _id: food._id });

    res.json({
      success: true,
      message: `Food item "${food.name}" deleted successfully.`,
    });
  } catch (error) {
    next(error);
  }
};
