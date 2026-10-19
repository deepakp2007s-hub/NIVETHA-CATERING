
const express = require("express");
const router = express.Router();

const { getReports } = require("../controllers/reportController");
const {
  protect,
  allowRoles,
} = require("../middleware/authMiddleware");

// Owner-only reports
router.get("/", protect, allowRoles("owner"), getReports);

module.exports = router;
