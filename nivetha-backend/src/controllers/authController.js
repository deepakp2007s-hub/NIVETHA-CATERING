
const Owner = require("../models/Owner");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const getAllowedOwnerPhones = () => {
  return [
    process.env.OWNER_PHONE_1,
    process.env.OWNER_PHONE_2,
  ]
    .filter((phone) => typeof phone === "string" && phone.trim())
    .map((phone) => phone.trim());
};

const createOwnerToken = (ownerId) => {
  const secret = process.env.JWT_SECRET;

  if (!secret || secret.length < 32) {
    throw new Error("JWT_SECRET must contain at least 32 characters.");
  }

  return jwt.sign(
    {
      id: ownerId.toString(),
      role: "owner",
    },
    secret,
    {
      expiresIn: "1d",
      algorithm: "HS256",
    }
  );
};

const isAllowedOwner = (owner) => {
  if (!owner || !owner.isActive) {
    return false;
  }

  return getAllowedOwnerPhones().includes(owner.phone);
};

// Owner login
exports.login = async (req, res) => {
  try {
    const phone =
      typeof req.body?.phone === "string"
        ? req.body.phone.trim()
        : "";

    const password = req.body?.password;

    const allowedPhones = getAllowedOwnerPhones();

    if (allowedPhones.length !== 2) {
      console.error(
        "OWNER_PHONE_1 and OWNER_PHONE_2 must both be configured."
      );

      return res.status(500).json({
        success: false,
        message: "Owner login is not configured correctly.",
      });
    }

    if (!phone || typeof password !== "string" || !password) {
      return res.status(400).json({
        success: false,
        message: "Phone number and password are required.",
      });
    }

    if (phone.length > 32 || password.length > 128) {
      return res.status(401).json({
        success: false,
        message: "Invalid phone number or password.",
      });
    }

    // Only the two configured owner phone numbers are permitted.
    if (!allowedPhones.includes(phone)) {
      return res.status(401).json({
        success: false,
        message: "Invalid phone number or password.",
      });
    }

    const owner = await Owner.findOne({ phone }).select("+passwordHash");

    if (!owner || !isAllowedOwner(owner) || !owner.passwordHash) {
      return res.status(401).json({
        success: false,
        message: "Invalid phone number or password.",
      });
    }

    const isMatch = await bcrypt.compare(
      password,
      owner.passwordHash
    );

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid phone number or password.",
      });
    }

    const token = createOwnerToken(owner._id);

    return res.status(200).json({
      success: true,
      message: "Owner login successful.",
      token,
      user: {
        id: owner._id,
        name: owner.name,
        phone: owner.phone,
        role: "owner",
      },
    });
  } catch (error) {
    console.error("Owner login error:", error.message);

    return res.status(500).json({
      success: false,
      message: "Owner login failed. Please try again.",
    });
  }
};

// Get logged-in owner profile
exports.getMe = async (req, res) => {
  try {
    if (!req.user?.id || req.user.role !== "owner") {
      return res.status(401).json({
        success: false,
        message: "Owner authentication is required.",
      });
    }

    const owner = await Owner.findById(req.user.id);

    if (!owner || !owner.isActive) {
      return res.status(404).json({
        success: false,
        message: "Owner account not found or inactive.",
      });
    }

    if (!getAllowedOwnerPhones().includes(owner.phone)) {
      return res.status(403).json({
        success: false,
        message: "This owner is not authorized to use the Owner App.",
      });
    }

    const profile = {
      id: owner._id,
      name: owner.name,
      phone: owner.phone,
      role: "owner",
    };

    return res.status(200).json({
      success: true,
      owner: profile,
      user: profile,
    });
  } catch (error) {
    console.error("Owner profile error:", error.message);

    return res.status(500).json({
      success: false,
      message: "Unable to load owner profile.",
    });
  }
};
