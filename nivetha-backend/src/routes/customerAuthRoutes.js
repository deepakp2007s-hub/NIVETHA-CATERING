
const express = require("express");
const router = express.Router();

const customerAuthController = require("../controllers/customerAuthController");
const customerAuthMiddleware = require("../middleware/customerAuthMiddleware");

// ======================================
// CUSTOMER AUTHENTICATION ROUTES
// ======================================

// Register a new customer
// POST /api/customer-auth/register
router.post("/register", customerAuthController.register);

// Login existing customer
// POST /api/customer-auth/login
router.post("/login", customerAuthController.login);

// Get logged-in customer's profile
// GET /api/customer-auth/me
router.get(
  "/me",
  customerAuthMiddleware,
  customerAuthController.getMe
);

module.exports = router;
