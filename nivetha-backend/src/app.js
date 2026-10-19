
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");

const notFoundMiddleware = require("./middleware/notFoundMiddleware");
const errorMiddleware = require("./middleware/errorMiddleware");

const app = express();

// Render proxy configuration.
app.set("trust proxy", 1);

app.disable("x-powered-by");
app.use(helmet());

// Production frontend URLs.
const productionOrigins = [
  "https://nivetha-catering.vercel.app",
  "https://nivetha-catering-kjh1.vercel.app",
];

// Local development frontend URLs.
const localOrigins = [
  "http://localhost:5173",
  "http://localhost:5174",
  "http://127.0.0.1:5173",
  "http://127.0.0.1:5174",
];

// Optional origins from environment variables.
const configuredOrigins = [
  process.env.CLIENT_URL,
  process.env.OWNER_URL,
]
  .filter(Boolean)
  .flatMap((value) => value.split(","))
  .map((url) => url.trim().replace(/^["']|["']$/g, "").replace(/\/+$/, ""))
  .filter(Boolean);

const allowedOrigins = [
  ...new Set([
    ...localOrigins,
    ...productionOrigins,
    ...configuredOrigins,
  ]),
];

app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin) {
        return callback(null, true);
      }

      const normalizedOrigin = origin.replace(/\/+$/, "");

      if (allowedOrigins.includes(normalizedOrigin)) {
        return callback(null, true);
      }

      console.warn(`CORS blocked origin: ${origin}`);
      return callback(new Error("Origin not allowed by CORS"));
    },
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
  })
);

app.use(express.json({ limit: "1mb" }));
app.use(express.urlencoded({ extended: true, limit: "1mb" }));

// API rate limiter.
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

// Health check.
app.get("/api/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Nivetha Catering API is running",
    timestamp: new Date().toISOString(),
  });
});

// Authentication routes.
app.use("/api/auth", require("./routes/authRoutes"));
app.use(
  "/api/customer-auth",
  require("./routes/customerAuthRoutes")
);

// Other API routes.
app.use("/api/bookings", require("./routes/bookingRoutes"));
app.use("/api/customers", require("./routes/customerRoutes"));
app.use("/api/dashboard", require("./routes/dashboardRoutes"));
app.use("/api/foods", require("./routes/foodRoutes"));
app.use("/api/notifications", require("./routes/notificationRoutes"));
app.use("/api/reports", require("./routes/reportRoutes"));
app.use("/api/reviews", require("./routes/reviewRoutes"));

// Materials, Staff and Payment routes are intentionally not mounted.

// Error handling.
app.use(notFoundMiddleware);
app.use(errorMiddleware);

module.exports = app;
