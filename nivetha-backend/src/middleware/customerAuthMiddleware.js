
const jwt = require("jsonwebtoken");
const mongoose = require("mongoose");

module.exports = function customerAuthMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;

  if (
    typeof authHeader !== "string" ||
    !authHeader.startsWith("Bearer ")
  ) {
    return res.status(401).json({
      success: false,
      message: "Please log in to continue.",
    });
  }

  const token = authHeader.slice(7).trim();

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
      decoded.role !== "customer" ||
      typeof decoded.id !== "string" ||
      !mongoose.isValidObjectId(decoded.id)
    ) {
      return res.status(403).json({
        success: false,
        message: "Customer access only.",
      });
    }

    req.user = {
      id: decoded.id,
      role: "customer",
    };

    return next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message:
        error.name === "TokenExpiredError"
          ? "Session expired. Please log in again."
          : "Invalid authentication token. Please log in again.",
    });
  }
};
