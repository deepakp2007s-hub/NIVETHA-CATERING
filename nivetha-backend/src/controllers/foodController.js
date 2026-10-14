const Food = require("../models/Food");

const getFoods = async (req, res, next) => {
  try {
    const foods = await Food.find().sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: foods.length,
      data: foods,
    });
  } catch (error) {
    next(error);
  }
};

// Customer app: available foods only
const getCustomerFoods = async (req, res, next) => {
  try {
    const foods = await Food.find({ available: true }).sort({
      category: 1,
      name: 1,
    });

    res.status(200).json({
      success: true,
      count: foods.length,
      data: foods,
    });
  } catch (error) {
    next(error);
  }
};

const createFood = async (req, res, next) => {
  try {
    const { name, tamilName, category, type, description, price, image, available } =
      req.body;

    if (!name || !category || price === undefined) {
      return res.status(400).json({
        success: false,
        message: "Food name, category and price are required",
      });
    }

    const food = await Food.create({
      name,
      tamilName,
      category,
      type,
      description,
      price,
      image,
      available: available ?? true,
    });

    res.status(201).json({
      success: true,
      message: "Food added successfully",
      data: food,
    });
  } catch (error) {
    next(error);
  }
};

const updateFood = async (req, res, next) => {
  try {
    const food = await Food.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true, runValidators: true }
    );

    if (!food) {
      return res.status(404).json({
        success: false,
        message: "Food not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Food updated successfully",
      data: food,
    });
  } catch (error) {
    next(error);
  }
};

const deleteFood = async (req, res, next) => {
  try {
    const food = await Food.findByIdAndDelete(req.params.id);

    if (!food) {
      return res.status(404).json({
        success: false,
        message: "Food not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Food deleted successfully",
    });
  } catch (error) {
    next(error);
  }
};

const toggleFoodAvailability = async (req, res, next) => {
  try {
    const food = await Food.findById(req.params.id);

    if (!food) {
      return res.status(404).json({
        success: false,
        message: "Food not found",
      });
    }

    food.available = !food.available;
    await food.save();

    res.status(200).json({
      success: true,
      message: "Food availability updated",
      data: food,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getFoods,
  getCustomerFoods,
  createFood,
  updateFood,
  deleteFood,
  toggleFoodAvailability,
};