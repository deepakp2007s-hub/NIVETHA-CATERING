const express = require("express");
const router = express.Router();

const {
  getReviews,
  createReview,
} = require("../controllers/reviewController");

const { protect } = require("../middleware/authMiddleware");

router.get("/", protect, (req, res, next) => {
  if (req.user?.role !== "owner") {
    return res.status(403).json({
      success: false,
      message: "Owner access required",
    });
  }
  next();
}, getReviews);

router.post("/", protect, (req, res, next) => {
  if (req.user?.role !== "customer") {
    return res.status(403).json({
      success: false,
      message: "Customer access required",
    });
  }
  next();
}, createReview);

module.exports = router;