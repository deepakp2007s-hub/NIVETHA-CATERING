const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const notFoundMiddleware = require("./middleware/notFoundMiddleware");
const errorMiddleware = require("./middleware/errorMiddleware");


const app = express();

app.use(helmet());

const allowedOrigins = [
  "http://localhost:5173",
  "http://localhost:5174",
  "http://127.0.0.1:5173",
  "http://127.0.0.1:5174",
];

app.use(
  cors({
    origin(origin, callback) {
      if (!origin || allowedOrigins.includes(origin)) {
        return callback(null, true);
      }

      return callback(new Error("Origin not allowed by CORS"));
    },
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

app.use(express.json({ limit: "1mb" }));
app.use(express.urlencoded({ extended: true }));

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
});

app.use("/api", apiLimiter);

app.get("/api/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Nivetha Catering API is running",
    timestamp: new Date().toISOString(),
  });
});

// Existing owner authentication routes
app.use("/api/auth", require("./routes/authRoutes"));

// Customer authentication routes
app.use("/api/customer-auth", require("./routes/customerAuthRoutes"));

// Existing application routes
app.use("/api/bookings", require("./routes/bookingRoutes"));
app.use("/api/customers", require("./routes/customerRoutes"));
app.use("/api/dashboard", require("./routes/dashboardRoutes"));
app.use("/api/foods", require("./routes/foodRoutes"));
app.use("/api/notifications", require("./routes/notificationRoutes"));
app.use("/api/reports", require("./routes/reportRoutes"));
app.use("/api/reviews", require("./routes/reviewRoutes"));

// Phase-2 modules
app.use("/api/payments", require("./routes/paymentRoutes"));
app.use("/api/materials", require("./routes/materialRoutes"));
app.use("/api/staff", require("./routes/staffRoutes"));


// 404 handler — must come after all routes
app.use(notFoundMiddleware);

// Centralised error handler — must be last, needs 4 args
app.use(errorMiddleware);

module.exports = app;