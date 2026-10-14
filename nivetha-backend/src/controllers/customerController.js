const Customer = require("../models/Customer");

const getCustomers = async (req, res, next) => {
  try {
    const customers = await Customer.find()
      .select("-passwordHash -password")
      .sort({ createdAt: -1 });

    return res.json({
      success: true,
      count: customers.length,
      data: customers,
    });
  } catch (error) {
    next(error);
  }
};

const getCustomerById = async (req, res, next) => {
  try {
    const customer = await Customer.findById(req.params.id)
      .select("-passwordHash -password");

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: "Customer not found",
      });
    }

    return res.json({ success: true, data: customer });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getCustomers,
  getCustomerById,
};