
const express = require("express");
const router = express.Router();

const {
  getReviews,
  createReview,
} = require("../controllers/reviewController");

const {
  protect,
  allowRoles,
} = require("../middleware/authMiddleware");

// Owner-only: View customer reviews
router.get(
  "/",
  protect,
  allowRoles("owner"),
  getReviews
);

// Customer-only: Submit a review
router.post(
  "/",
  protect,
  allowRoles("customer"),
  createReview
);

module.exports = router;
