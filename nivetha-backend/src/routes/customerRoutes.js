
const express = require("express");
const router = express.Router();

const {
  getCustomers,
  getCustomerById,
  updateMyProfile,
} = require("../controllers/customerController");

const {
  protect,
  allowRoles,
} = require("../middleware/authMiddleware");

const customerAuthMiddleware = require("../middleware/customerAuthMiddleware");

// Customer: Update own profile
router.patch("/profile", customerAuthMiddleware, updateMyProfile);

// Owner-only customer management
router.get("/", protect, allowRoles("owner"), getCustomers);
router.get("/:id", protect, allowRoles("owner"), getCustomerById);

module.exports = router;
