
const express = require("express");
const router = express.Router();

const {
  getCustomers,
  getCustomerById,
} = require("../controllers/customerController");

const {
  protect,
  allowRoles,
} = require("../middleware/authMiddleware");

// Owner-only customer management routes
router.get("/", protect, allowRoles("owner"), getCustomers);
router.get("/:id", protect, allowRoles("owner"), getCustomerById);

module.exports = router;
