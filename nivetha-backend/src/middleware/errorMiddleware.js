
export const notFound = (req, res, next) => {
  const error = new Error(`Route not found: ${req.method} ${req.originalUrl}`);
  res.status(404);
  next(error);
};

export const errorHandler = (err, req, res, next) => {
  if (res.headersSent) {
    return next(err);
  }

  let statusCode =
    res.statusCode && res.statusCode !== 200
      ? res.statusCode
      : err.statusCode || err.status || 500;

  let message = err.message || 'Internal Server Error';

  // Invalid MongoDB ObjectId
  if (err.name === 'CastError') {
    statusCode = 400;
    message = 'Invalid resource identifier.';
  }

  // Duplicate MongoDB record
  if (err.code === 11000) {
    statusCode = 409;
    const field = Object.keys(err.keyValue || {})[0] || 'field';
    message = `A record with this ${field} already exists.`;
  }

  // Mongoose validation
  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = Object.values(err.errors || {})
      .map((item) => item.message)
      .join(', ');
  }

  // Invalid JSON request body
  if (err instanceof SyntaxError && 'body' in err) {
    statusCode = 400;
    message = 'Invalid JSON request body.';
  }

  // Authentication errors
  if (
    err.name === 'JsonWebTokenError' ||
    err.name === 'NotBeforeError'
  ) {
    statusCode = 401;
    message = 'Invalid authentication token.';
  }

  if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Session expired. Please log in again.';
  }

  if (statusCode >= 500) {
    console.error('Server error:', err);
    message =
      process.env.NODE_ENV === 'development'
        ? err.message || 'Internal Server Error'
        : 'Internal Server Error';
  }

  return res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && {
      stack: err.stack,
    }),
  });
};

export default errorHandler;
