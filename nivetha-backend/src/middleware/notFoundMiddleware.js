
const notFoundMiddleware = (req, res, next) => {
  return res.status(404).json({
    success: false,
    message: "API endpoint not found.",
    path: req.originalUrl,
    method: req.method,
  });
};

module.exports = notFoundMiddleware;
