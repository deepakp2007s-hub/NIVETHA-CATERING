
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const mongoose = require("mongoose");

const notFoundMiddleware = require("./middleware/notFoundMiddleware");
const errorMiddleware = require("./middleware/errorMiddleware");

const app = express();

app.disable("x-powered-by");
app.set("trust proxy", 1);

app.use(helmet());

const normalizeOrigin = (origin) =>
  String(origin || "")
    .trim()
    .replace(/^["']|["']$/g, "")
    .replace(/\/+$/, "");

const productionOrigins = [
  "https://nivetha-catering.vercel.app",
  "https://nivetha-catering-kjh1.vercel.app",
];

const configuredOrigins = [
  process.env.CLIENT_URL,
  process.env.OWNER_URL,
]
  .filter(Boolean)
  .flatMap((value) => value.split(","))
  .map(normalizeOrigin)
  .filter(Boolean);

const allowedOrigins = new Set([
  ...productionOrigins,
  ...configuredOrigins,
]);

// Flutter Web uses a dynamic localhost port during development.
const isFlutterWebLocalOrigin = (origin) =>
  /^http:\/\/(localhost|127\.0\.0\.1):\d+$/.test(
    normalizeOrigin(origin)
  );

const corsOptions = {
  origin(origin, callback) {
    // Allow requests without an Origin header.
    if (!origin) {
      return callback(null, true);
    }

    const normalizedOrigin = normalizeOrigin(origin);

    if (
      allowedOrigins.has(normalizedOrigin) ||
      isFlutterWebLocalOrigin(normalizedOrigin)
    ) {
      return callback(null, true);
    }

    console.warn(`CORS blocked origin: ${origin}`);

    const error = new Error("Origin not allowed by CORS");
    error.status = 403;

    return callback(error);
  },

  methods: [
    "GET",
    "POST",
    "PUT",
    "PATCH",
    "DELETE",
    "OPTIONS",
  ],

  allowedHeaders: [
    "Content-Type",
    "Authorization",
  ],

  credentials: true,
  optionsSuccessStatus: 204,
};

// CORS must run before API routes and error handling.
app.use(cors(corsOptions));

app.use(express.json({ limit: "1mb" }));
app.use(express.urlencoded({ extended: true, limit: "1mb" }));

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 300,
  standardHeaders: "draft-8",
  legacyHeaders: false,
  message: {
    success: false,
    message: "Too many requests. Please try again later.",
  },
});

app.use("/api", apiLimiter);

// Health check
app.get("/api/health", (req, res) => {
  const databaseConnected = mongoose.connection.readyState === 1;

  return res.status(databaseConnected ? 200 : 503).json({
    success: databaseConnected,
    message: databaseConnected
      ? "Nivetha Catering API is running"
      : "API is running, but database is not connected",
    database: databaseConnected ? "connected" : "disconnected",
    timestamp: new Date().toISOString(),
  });
});

// Authentication APIs
app.use("/api/auth", require("./routes/authRoutes"));
app.use("/api/customer-auth", require("./routes/customerAuthRoutes"));

// Main APIs
app.use("/api/bookings", require("./routes/bookingRoutes"));
app.use("/api/customers", require("./routes/customerRoutes"));
app.use("/api/dashboard", require("./routes/dashboardRoutes"));
app.use("/api/foods", require("./routes/foodRoutes"));
app.use("/api/notifications", require("./routes/notificationRoutes"));
app.use("/api/reports", require("./routes/reportRoutes"));
app.use("/api/reviews", require("./routes/reviewRoutes"));

// Mount Materials, Staff, and Payments only after verifying their files.

// Unknown API endpoints
app.use(notFoundMiddleware);

// Error handler must be last
app.use(errorMiddleware);

module.exports = app;
