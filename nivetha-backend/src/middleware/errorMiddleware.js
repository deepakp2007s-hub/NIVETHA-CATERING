
const errorMiddleware = (err, req, res, next) => {
  if (res.headersSent) {
    return next(err);
  }

  let statusCode = Number(err.statusCode || err.status) || 500;
  let message = err.message || "Internal server error.";

  // Invalid JSON request body
  if (
    err instanceof SyntaxError &&
    err.status === 400 &&
    Object.prototype.hasOwnProperty.call(err, "body")
  ) {
    statusCode = 400;
    message = "Invalid JSON request body.";
  }

  // Invalid MongoDB ObjectId
  if (err.name === "CastError") {
    statusCode = 400;
    message = "Invalid resource ID.";
  }

  // Mongoose schema validation errors
  if (err.name === "ValidationError") {
    statusCode = 400;
    message = Object.values(err.errors || {})
      .map((item) => item.message)
      .join(", ");
  }

  // MongoDB duplicate key errors
  if (err.code === 11000) {
    statusCode = 409;

    const field = Object.keys(err.keyPattern || {})[0];

    message = field
      ? `${field} already exists.`
      : "Duplicate record already exists.";
  }

  // Normalize invalid HTTP status codes
  if (
    !Number.isInteger(statusCode) ||
    statusCode < 400 ||
    statusCode > 599
  ) {
    statusCode = 500;
  }

  // Hide internal server details in production
  if (statusCode >= 500) {
    message = "Internal server error.";
    console.error("Server error:", err);
  }

  const response = {
    success: false,
    message,
  };

  // Extra debugging details only in development
  if (process.env.NODE_ENV === "development") {
    response.details = err.message;
  }

  return res.status(statusCode).json(response);
};

module.exports = errorMiddleware;
