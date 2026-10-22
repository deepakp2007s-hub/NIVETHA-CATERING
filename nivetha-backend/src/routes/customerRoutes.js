
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

// Customer: Update only their own profile
router.patch(
  "/profile",
  customerAuthMiddleware,
  updateMyProfile
);

// Owner-only: View all customers
router.get(
  "/",
  protect,
  allowRoles("owner"),
  getCustomers
);

// Owner-only: View a specific customer
router.get(
  "/:id",
  protect,
  allowRoles("owner"),
  getCustomerById
);

module.exports = router;
