const express = require("express");
const router = express.Router();

const { getReports } = require("../controllers/reportController");
const { protect } = require("../middleware/authMiddleware");

router.get("/", protect, (req, res, next) => {
  if (req.user?.role !== "owner") {
    return res.status(403).json({
      success: false,
      message: "Owner access required",
    });
  }
  next();
}, getReports);

module.exports = router;