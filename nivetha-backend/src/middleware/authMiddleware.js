
const jwt = require("jsonwebtoken");
const mongoose = require("mongoose");
const Owner = require("../models/Owner");

const getAllowedOwnerPhones = () =>
  [process.env.OWNER_PHONE_1, process.env.OWNER_PHONE_2]
    .filter((phone) => typeof phone === "string" && phone.trim())
    .map((phone) => phone.trim());

const protect = async (req, res, next) => {
  const authorization = req.headers.authorization;

  if (
    typeof authorization !== "string" ||
    !authorization.startsWith("Bearer ")
  ) {
    return res.status(401).json({
      success: false,
      message: "Authentication token required. Please log in.",
    });
  }

  const token = authorization.slice(7).trim();

  if (!token) {
    return res.status(401).json({
      success: false,
      message: "Authentication token is missing.",
    });
  }

  const jwtSecret = process.env.JWT_SECRET;

  if (!jwtSecret || jwtSecret.length < 32) {
    console.error("JWT_SECRET is missing or too short.");

    return res.status(500).json({
      success: false,
      message: "Authentication service is not configured correctly.",
    });
  }

  try {
    const decoded = jwt.verify(token, jwtSecret, {
      algorithms: ["HS256"],
    });

    if (
      !decoded ||
      typeof decoded.id !== "string" ||
      !mongoose.isValidObjectId(decoded.id) ||
      !["owner", "customer"].includes(decoded.role)
    ) {
      return res.status(401).json({
        success: false,
        message: "Invalid authentication token.",
      });
    }

    // Verify owner account and enforce the two-phone allowlist.
    if (decoded.role === "owner") {
      const allowedPhones = getAllowedOwnerPhones();

      if (
        allowedPhones.length !== 2 ||
        allowedPhones[0] === allowedPhones[1] ||
        allowedPhones.some((phone) => !/^[6-9]\d{9}$/.test(phone))
      ) {
        console.error("Owner phone allowlist is not configured correctly.");

        return res.status(500).json({
          success: false,
          message: "Owner authentication is not configured correctly.",
        });
      }

      const owner = await Owner.findById(decoded.id).select("phone isActive");

      if (
        !owner ||
        owner.isActive !== true ||
        !allowedPhones.includes(owner.phone)
      ) {
        return res.status(403).json({
          success: false,
          message: "This owner account is not authorized.",
        });
      }
    }

    req.user = {
      id: decoded.id,
      role: decoded.role,
    };

    return next();
  } catch (error) {
    if (
      error.name === "JsonWebTokenError" ||
      error.name === "TokenExpiredError" ||
      error.name === "NotBeforeError"
    ) {
      return res.status(401).json({
        success: false,
        message:
          error.name === "TokenExpiredError"
            ? "Session expired. Please log in again."
            : "Invalid authentication token.",
      });
    }

    return next(error);
  }
};

const allowRoles = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: "Please log in first.",
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: "You are not authorized to access this resource.",
      });
    }

    return next();
  };
};

module.exports = {
  protect,
  allowRoles,
};
