
const Customer = require("../models/Customer");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const createToken = (customerId) => {
  const secret = process.env.JWT_SECRET;

  if (!secret || secret.length < 32) {
    throw new Error("JWT_SECRET must contain at least 32 characters.");
  }

  return jwt.sign(
    { id: customerId.toString(), role: "customer" },
    secret,
    {
      expiresIn: "7d",
      algorithm: "HS256",
    }
  );
};

const formatCustomer = (customer) => ({
  id: customer._id,
  name: customer.name,
  email: customer.email || "",
  phone: customer.phone,
  address: customer.address || "",
});

const normalizeEmail = (email) =>
  typeof email === "string" ? email.trim().toLowerCase() : "";

const isValidEmail = (email) =>
  /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

exports.register = async (req, res) => {
  try {
    const body = req.body || {};
    const { password, address } = body;

    const cleanName =
      typeof body.name === "string" ? body.name.trim() : "";

    const cleanPhone =
      typeof body.phone === "string" ? body.phone.trim() : "";

    const email = normalizeEmail(body.email);

    if (!cleanName || !cleanPhone || typeof password !== "string" || !password) {
      return res.status(400).json({
        success: false,
        message: "Name, phone number and password are required.",
      });
    }

    if (cleanName.length > 100) {
      return res.status(400).json({
        success: false,
        message: "Name must not exceed 100 characters.",
      });
    }

    if (!/^[6-9]\d{9}$/.test(cleanPhone)) {
      return res.status(400).json({
        success: false,
        message: "Enter a valid 10-digit Indian mobile number.",
      });
    }

    if (password.length < 8 || password.length > 128) {
      return res.status(400).json({
        success: false,
        message: "Password must contain between 8 and 128 characters.",
      });
    }

    if (email && (email.length > 254 || !isValidEmail(email))) {
      return res.status(400).json({
        success: false,
        message: "Enter a valid email address.",
      });
    }

    if (address !== undefined && typeof address !== "string") {
      return res.status(400).json({
        success: false,
        message: "Address must be a string.",
      });
    }

    const existingConditions = [{ phone: cleanPhone }];

    if (email) {
      existingConditions.push({ email });
    }

    const existingCustomer = await Customer.findOne({
      $or: existingConditions,
    }).select("_id");

    if (existingCustomer) {
      return res.status(409).json({
        success: false,
        message: "This mobile number or email is already registered.",
      });
    }

    const passwordHash = await bcrypt.hash(password, 12);

    const customer = await Customer.create({
      name: cleanName,
      phone: cleanPhone,
      ...(email ? { email } : {}),
      address: typeof address === "string" ? address.trim() : "",
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
    if (error.code === 11000) {
      return res.status(409).json({
        success: false,
        message: "This mobile number or email is already registered.",
      });
    }

    console.error("Customer registration error:", error.message);

    return res.status(500).json({
      success: false,
      message: "Customer registration failed. Please try again.",
    });
  }
};

exports.login = async (req, res) => {
  try {
    const body = req.body || {};
    const password = body.password;

    const cleanPhone =
      typeof body.phone === "string" ? body.phone.trim() : "";

    if (!cleanPhone || typeof password !== "string" || !password) {
      return res.status(400).json({
        success: false,
        message: "Phone number and password are required.",
      });
    }

    if (
      !/^[6-9]\d{9}$/.test(cleanPhone) ||
      password.length > 128
    ) {
      return res.status(401).json({
        success: false,
        message: "Invalid phone number or password.",
      });
    }

    const customer = await Customer.findOne({
      phone: cleanPhone,
    }).select("+passwordHash");

    if (!customer || !customer.passwordHash) {
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
    console.error("Customer login error:", error.message);

    return res.status(500).json({
      success: false,
      message: "Customer login failed. Please try again.",
    });
  }
};

exports.getMe = async (req, res) => {
  try {
    const customerId = req.user?.id;

    if (!customerId) {
      return res.status(401).json({
        success: false,
        message: "Authentication required.",
      });
    }

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
    console.error("Get customer profile error:", error.message);

    return res.status(500).json({
      success: false,
      message: "Unable to load customer profile.",
    });
  }
};
