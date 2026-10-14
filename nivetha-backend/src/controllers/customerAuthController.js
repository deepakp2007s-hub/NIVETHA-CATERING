const Customer = require("../models/Customer");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

function createToken(customerId) {
  if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET is missing in .env");
  }

  return jwt.sign(
    { id: customerId.toString(), role: "customer" },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );
}

function formatCustomer(customer) {
  return {
    id: customer._id,
    name: customer.name,
    email: customer.email || "",
    phone: customer.phone,
    address: customer.address || "",
  };
}

exports.register = async (req, res) => {
  try {
    const { name, email, phone, password, address } = req.body;

    if (!name?.trim() || !phone?.trim() || !password) {
      return res.status(400).json({
        success: false,
        message: "Name, phone number and password are required.",
      });
    }

    const cleanPhone = phone.trim();

    if (!/^[6-9]\d{9}$/.test(cleanPhone)) {
      return res.status(400).json({
        success: false,
        message: "Enter a valid 10-digit mobile number.",
      });
    }

    if (password.length < 8) {
      return res.status(400).json({
        success: false,
        message: "Password must contain at least 8 characters.",
      });
    }

    if (email?.trim()) {
      const existingEmail = await Customer.findOne({
        email: email.trim().toLowerCase(),
      });

      if (existingEmail) {
        return res.status(409).json({
          success: false,
          message: "This email address is already registered.",
        });
      }
    }

    const existingCustomer = await Customer.findOne({
      phone: cleanPhone,
    });

    if (existingCustomer) {
      return res.status(409).json({
        success: false,
        message: "This mobile number is already registered. Please log in.",
      });
    }

    const passwordHash = await bcrypt.hash(password, 12);

    const customer = await Customer.create({
      name: name.trim(),
      email: email?.trim().toLowerCase() || undefined,
      phone: cleanPhone,
      address: address?.trim() || undefined,
      passwordHash,
    });

    const token = createToken(customer._id);

    return res.status(201).json({
      success: true,
      message: "Customer registered successfully.",
      token,
      customer: formatCustomer(customer),
    });
  } catch (error) {
    console.error("Customer registration error:", error);

    if (error.code === 11000) {
      return res.status(409).json({
        success: false,
        message: "This mobile number or email is already registered.",
      });
    }

    return res.status(500).json({
      success: false,
      message: "Customer registration failed. Please try again.",
    });
  }
};

exports.login = async (req, res) => {
  try {
    const { phone, password } = req.body;

    if (!phone?.trim() || !password) {
      return res.status(400).json({
        success: false,
        message: "Phone number and password are required.",
      });
    }

    const customer = await Customer.findOne({
      phone: phone.trim(),
    }).select("+passwordHash");

    if (!customer) {
      return res.status(401).json({
        success: false,
        message: "Invalid phone number or password.",
      });
    }

    const passwordMatches = await bcrypt.compare(
      password,
      customer.passwordHash
    );

    if (!passwordMatches) {
      return res.status(401).json({
        success: false,
        message: "Invalid phone number or password.",
      });
    }

    const token = createToken(customer._id);

    return res.status(200).json({
      success: true,
      message: "Login successful.",
      token,
      customer: formatCustomer(customer),
    });
  } catch (error) {
    console.error("Customer login error:", error);

    return res.status(500).json({
      success: false,
      message: "Customer login failed. Please try again.",
    });
  }
};

exports.getMe = async (req, res) => {
  try {
    const customerId = req.user?.id;

    const customer = await Customer.findById(customerId);

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: "Customer account not found.",
      });
    }

    return res.status(200).json({
      success: true,
      customer: formatCustomer(customer),
    });
  } catch (error) {
    console.error("Get customer profile error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to load customer profile.",
    });
  }
};