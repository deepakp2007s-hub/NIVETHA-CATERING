
const express = require("express");
const router = express.Router();

const authController = require("../controllers/authController");
const { protect, allowRoles } = require("../middleware/authMiddleware");

// Owner login
router.post("/login", authController.login);

// Get logged-in owner profile (owner only)
router.get(
  "/me",
  protect,
  allowRoles("owner"),
  authController.getMe
);

module.exports = router;
