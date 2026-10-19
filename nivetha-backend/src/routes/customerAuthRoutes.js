
const express = require("express");
const router = express.Router();

const customerAuthController = require("../controllers/customerAuthController");
const customerAuthMiddleware = require("../middleware/customerAuthMiddleware");

// Customer registration
router.post("/register", customerAuthController.register);

// Customer login
router.post("/login", customerAuthController.login);

// Get logged-in customer profile
router.get(
  "/me",
  customerAuthMiddleware,
  customerAuthController.getMe
);

module.exports = router;
