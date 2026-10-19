
const mongoose = require("mongoose");
const Food = require("../models/Food");

const isValidId = (id) => mongoose.isValidObjectId(id);

const getFoods = async (req, res, next) => {
  try {
    const foods = await Food.find()
      .sort({ createdAt: -1 })
      .lean();

    return res.status(200).json({
      success: true,
      count: foods.length,
      data: foods,
    });
  } catch (error) {
    next(error);
  }
};

// Customer app: return available foods only
const getCustomerFoods = async (req, res, next) => {
  try {
    const foods = await Food.find({ available: true })
      .sort({ category: 1, name: 1 })
      .lean();

    return res.status(200).json({
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
    const {
      name,
      tamilName,
      category,
      type,
      description,
      price,
      image,
      available,
    } = req.body || {};

    if (
      typeof name !== "string" ||
      !name.trim() ||
      typeof category !== "string" ||
      !category.trim() ||
      price === undefined ||
      price === null ||
      price === ""
    ) {
      return res.status(400).json({
        success: false,
        message: "Food name, category and price are required.",
      });
    }

    const parsedPrice = Number(price);

    if (!Number.isFinite(parsedPrice) || parsedPrice < 0) {
      return res.status(400).json({
        success: false,
        message: "Price must be a valid non-negative number.",
      });
    }

    if (available !== undefined && typeof available !== "boolean") {
      return res.status(400).json({
        success: false,
        message: "Availability must be true or false.",
      });
    }

    const food = await Food.create({
      name: name.trim(),
      tamilName:
        typeof tamilName === "string" ? tamilName.trim() : "",
      category: category.trim(),
      type: typeof type === "string" ? type.trim() : "",
      description:
        typeof description === "string" ? description.trim() : "",
      price: parsedPrice,
      image: typeof image === "string" ? image.trim() : "",
      available: available ?? true,
    });

    return res.status(201).json({
      success: true,
      message: "Food added successfully.",
      data: food,
    });
  } catch (error) {
    next(error);
  }
};

const updateFood = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!isValidId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid food ID.",
      });
    }

    const allowedFields = [
      "name",
      "tamilName",
      "category",
      "type",
      "description",
      "price",
      "image",
      "available",
    ];

    const body = req.body || {};
    const updates = {};

    for (const field of allowedFields) {
      if (Object.prototype.hasOwnProperty.call(body, field)) {
        updates[field] = body[field];
      }
    }

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({
        success: false,
        message: "No valid food fields provided to update.",
      });
    }

    for (const field of ["name", "category"]) {
      if (
        field in updates &&
        (typeof updates[field] !== "string" || !updates[field].trim())
      ) {
        return res.status(400).json({
          success: false,
          message: `${field} must be a non-empty string.`,
        });
      }

      if (field in updates) {
        updates[field] = updates[field].trim();
      }
    }

    for (const field of ["tamilName", "type", "description", "image"]) {
      if (field in updates) {
        if (typeof updates[field] !== "string") {
          return res.status(400).json({
            success: false,
            message: `${field} must be a string.`,
          });
        }
        updates[field] = updates[field].trim();
      }
    }

    if ("price" in updates) {
      const parsedPrice = Number(updates.price);

      if (
        updates.price === "" ||
        updates.price === null ||
        !Number.isFinite(parsedPrice) ||
        parsedPrice < 0
      ) {
        return res.status(400).json({
          success: false,
          message: "Price must be a valid non-negative number.",
        });
      }

      updates.price = parsedPrice;
    }

    if ("available" in updates && typeof updates.available !== "boolean") {
      return res.status(400).json({
        success: false,
        message: "Availability must be true or false.",
      });
    }

    const food = await Food.findByIdAndUpdate(
      id,
      { $set: updates },
      { new: true, runValidators: true }
    );

    if (!food) {
      return res.status(404).json({
        success: false,
        message: "Food not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Food updated successfully.",
      data: food,
    });
  } catch (error) {
    next(error);
  }
};

const deleteFood = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!isValidId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid food ID.",
      });
    }

    const food = await Food.findByIdAndDelete(id);

    if (!food) {
      return res.status(404).json({
        success: false,
        message: "Food not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Food deleted successfully.",
    });
  } catch (error) {
    next(error);
  }
};

const toggleFoodAvailability = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!isValidId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid food ID.",
      });
    }

    const food = await Food.findById(id);

    if (!food) {
      return res.status(404).json({
        success: false,
        message: "Food not found.",
      });
    }

    food.available = !food.available;
    await food.save();

    return res.status(200).json({
      success: true,
      message: "Food availability updated successfully.",
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
