
const mongoose = require("mongoose");
const Food = require("../models/Food");

const isValidId = (id) => mongoose.isValidObjectId(id);

const sendError = (res, status, message) => {
  return res.status(status).json({
    success: false,
    message,
  });
};

// Owner: Get all foods, including unavailable foods.
const getFoods = async (req, res, next) => {
  try {
    const foods = await Food.find()
      .sort({ createdAt: -1, _id: -1 })
      .lean();

    return res.status(200).json({
      success: true,
      count: foods.length,
      data: foods,
    });
  } catch (error) {
    return next(error);
  }
};

// Customer: Get available foods without exposing prices.
const getCustomerFoods = async (req, res, next) => {
  try {
    const foods = await Food.find({ available: true })
      .select("name tamilName category type description image available")
      .sort({ category: 1, name: 1 })
      .lean();

    return res.status(200).json({
      success: true,
      count: foods.length,
      data: foods,
    });
  } catch (error) {
    return next(error);
  }
};

// Owner: Create a food item.
const createFood = async (req, res, next) => {
  try {
    const body = req.body || {};
    const {
      name,
      tamilName,
      category,
      type,
      description,
      price,
      image,
      available,
    } = body;

    if (
      typeof name !== "string" ||
      !name.trim() ||
      typeof category !== "string" ||
      !category.trim()
    ) {
      return sendError(
        res,
        400,
        "Food name and category are required."
      );
    }

    if (name.trim().length > 100 || category.trim().length > 100) {
      return sendError(
        res,
        400,
        "Food name and category cannot exceed 100 characters."
      );
    }

    const optionalStrings = {
      tamilName,
      type,
      description,
      image,
    };

    for (const [field, value] of Object.entries(optionalStrings)) {
      if (value !== undefined && typeof value !== "string") {
        return sendError(res, 400, `${field} must be a string.`);
      }
    }

    if (available !== undefined && typeof available !== "boolean") {
      return sendError(
        res,
        400,
        "Availability must be true or false."
      );
    }

    const foodData = {
      name: name.trim(),
      category: category.trim(),
      tamilName: typeof tamilName === "string" ? tamilName.trim() : "",
      type: typeof type === "string" ? type.trim().toLowerCase() : "veg",
      description:
        typeof description === "string" ? description.trim() : "",
      image: typeof image === "string" ? image.trim() : "",
      available: available ?? true,
    };

    // Price is optional here, but Food.js must define a price field
    // for Mongoose to persist it.
    if (price !== undefined && price !== null && price !== "") {
      const parsedPrice = Number(price);

      if (!Number.isFinite(parsedPrice) || parsedPrice < 0) {
        return sendError(
          res,
          400,
          "Price must be a valid non-negative number."
        );
      }

      foodData.price = parsedPrice;
    }

    const food = await Food.create(foodData);

    return res.status(201).json({
      success: true,
      message: "Food added successfully.",
      data: food,
    });
  } catch (error) {
    if (error.name === "ValidationError") {
      return sendError(res, 400, error.message);
    }

    return next(error);
  }
};

// Owner: Update a food item.
const updateFood = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!isValidId(id)) {
      return sendError(res, 400, "Invalid food ID.");
    }

    const body = req.body || {};
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

    const updates = {};

    for (const field of allowedFields) {
      if (Object.prototype.hasOwnProperty.call(body, field)) {
        updates[field] = body[field];
      }
    }

    if (Object.keys(updates).length === 0) {
      return sendError(
        res,
        400,
        "No valid food fields provided to update."
      );
    }

    for (const field of ["name", "category"]) {
      if (field in updates) {
        if (
          typeof updates[field] !== "string" ||
          !updates[field].trim()
        ) {
          return sendError(
            res,
            400,
            `${field} must be a non-empty string.`
          );
        }

        updates[field] = updates[field].trim();

        if (updates[field].length > 100) {
          return sendError(
            res,
            400,
            `${field} cannot exceed 100 characters.`
          );
        }
      }
    }

    for (const field of [
      "tamilName",
      "type",
      "description",
      "image",
    ]) {
      if (field in updates) {
        if (typeof updates[field] !== "string") {
          return sendError(res, 400, `${field} must be a string.`);
        }

        updates[field] = updates[field].trim();

        if (field === "type") {
          updates[field] = updates[field].toLowerCase();
        }
      }
    }

    if ("price" in updates) {
      if (
        updates.price === "" ||
        updates.price === null ||
        updates.price === undefined
      ) {
        return sendError(
          res,
          400,
          "Price must be a valid non-negative number."
        );
      }

      const parsedPrice = Number(updates.price);

      if (!Number.isFinite(parsedPrice) || parsedPrice < 0) {
        return sendError(
          res,
          400,
          "Price must be a valid non-negative number."
        );
      }

      updates.price = parsedPrice;
    }

    if (
      "available" in updates &&
      typeof updates.available !== "boolean"
    ) {
      return sendError(
        res,
        400,
        "Availability must be true or false."
      );
    }

    const food = await Food.findByIdAndUpdate(
      id,
      { $set: updates },
      {
        new: true,
        runValidators: true,
      }
    );

    if (!food) {
      return sendError(res, 404, "Food not found.");
    }

    return res.status(200).json({
      success: true,
      message: "Food updated successfully.",
      data: food,
    });
  } catch (error) {
    if (error.name === "ValidationError") {
      return sendError(res, 400, error.message);
    }

    return next(error);
  }
};

// Owner: Delete a food item.
const deleteFood = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!isValidId(id)) {
      return sendError(res, 400, "Invalid food ID.");
    }

    const food = await Food.findByIdAndDelete(id);

    if (!food) {
      return sendError(res, 404, "Food not found.");
    }

    return res.status(200).json({
      success: true,
      message: "Food deleted successfully.",
    });
  } catch (error) {
    return next(error);
  }
};

// Owner: Toggle food availability.
const toggleFoodAvailability = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!isValidId(id)) {
      return sendError(res, 400, "Invalid food ID.");
    }

    const food = await Food.findById(id);

    if (!food) {
      return sendError(res, 404, "Food not found.");
    }

    food.available = !food.available;
    await food.save();

    return res.status(200).json({
      success: true,
      message: "Food availability updated successfully.",
      data: food,
    });
  } catch (error) {
    if (error.name === "ValidationError") {
      return sendError(res, 400, error.message);
    }

    return next(error);
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
