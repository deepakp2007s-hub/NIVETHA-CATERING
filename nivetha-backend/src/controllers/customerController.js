
const mongoose = require("mongoose");
const Customer = require("../models/Customer");

const getPagination = (query) => {
  const page = Math.max(1, Number.parseInt(query.page, 10) || 1);
  const limit = Math.min(
    100,
    Math.max(1, Number.parseInt(query.limit, 10) || 20)
  );

  return {
    page,
    limit,
    skip: (page - 1) * limit,
  };
};

// Owner: Get all customers
const getCustomers = async (req, res, next) => {
  try {
    const { page, limit, skip } = getPagination(req.query);

    const [customers, total] = await Promise.all([
      Customer.find()
        .select("-passwordHash -password")
        .sort({ createdAt: -1, _id: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      Customer.countDocuments(),
    ]);

    return res.status(200).json({
      success: true,
      data: customers,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        hasNextPage: page * limit < total,
        hasPreviousPage: page > 1,
      },
    });
  } catch (error) {
    next(error);
  }
};

// Owner: Get one customer
const getCustomerById = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid customer ID",
      });
    }

    const customer = await Customer.findById(id)
      .select("-passwordHash -password")
      .lean();

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: "Customer not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: customer,
    });
  } catch (error) {
    next(error);
  }
};

// Customer: Update own profile
const updateMyProfile = async (req, res, next) => {
  try {
    // The customer ID must come from authenticated middleware,
    // never from the request body.
    const customerId = req.user?.id || req.user?._id;

    if (!customerId || !mongoose.isValidObjectId(customerId)) {
      return res.status(401).json({
        success: false,
        message: "Customer authentication required.",
      });
    }

    const allowedFields = ["name", "email", "phone", "address"];
    const updates = {};

    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        if (typeof req.body[field] !== "string") {
          return res.status(400).json({
            success: false,
            message: `${field} must be a string.`,
          });
        }

        updates[field] = req.body[field].trim();
      }
    }

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({
        success: false,
        message: "Provide at least one profile field to update.",
      });
    }

    if (updates.name !== undefined && !updates.name) {
      return res.status(400).json({
        success: false,
        message: "Name cannot be empty.",
      });
    }

    if (updates.name && updates.name.length > 100) {
      return res.status(400).json({
        success: false,
        message: "Name cannot exceed 100 characters.",
      });
    }

    if (updates.email !== undefined) {
      updates.email = updates.email.toLowerCase();

      if (
        updates.email &&
        !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(updates.email)
      ) {
        return res.status(400).json({
          success: false,
          message: "Enter a valid email address.",
        });
      }
    }

    if (updates.phone !== undefined) {
      if (!/^[6-9]\d{9}$/.test(updates.phone)) {
        return res.status(400).json({
          success: false,
          message: "Enter a valid 10-digit Indian mobile number.",
        });
      }
    }

    if (updates.address && updates.address.length > 500) {
      return res.status(400).json({
        success: false,
        message: "Address cannot exceed 500 characters.",
      });
    }

    const customer = await Customer.findByIdAndUpdate(
      customerId,
      { $set: updates },
      {
        new: true,
        runValidators: true,
      }
    ).select("-passwordHash -password");

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: "Customer not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Profile updated successfully.",
      data: { customer },
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({
        success: false,
        message: "Email or phone number is already registered.",
      });
    }

    next(error);
  }
};

module.exports = {
  getCustomers,
  getCustomerById,
  updateMyProfile,
};
