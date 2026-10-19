
const express = require("express");
const router = express.Router();

const {
  getDashboard,
} = require("../controllers/dashboardController");

const {
  protect,
  allowRoles,
} = require("../middleware/authMiddleware");

// Owner-only dashboard
router.get("/", protect, allowRoles("owner"), getDashboard);

module.exports = router;
