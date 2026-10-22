
const express = require("express");
const router = express.Router();

const authController = require("../controllers/authController");
const {
  protect,
  allowRoles,
} = require("../middleware/authMiddleware");

// Owner login
// POST /api/auth/login
router.post("/login", authController.login);

// Get logged-in owner profile
// GET /api/auth/me
router.get(
  "/me",
  protect,
  allowRoles("owner"),
  authController.getMe
);

module.exports = router;
