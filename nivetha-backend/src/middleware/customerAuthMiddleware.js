
const jwt = require("jsonwebtoken");
const mongoose = require("mongoose");

module.exports = function customerAuthMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;

  // Require a Bearer token
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

    // Customer endpoints accept only customer tokens.
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
            : "Invalid authentication token. Please log in again.",
      });
    }

    console.error("Customer authentication error:", error.message);

    return res.status(500).json({
      success: false,
      message: "Customer authentication failed. Please try again.",
    });
  }
};
