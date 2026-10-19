
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

// Owner can view reviews
router.get(
  "/",
  protect,
  allowRoles("owner"),
  getReviews
);

// Customer can submit a review
router.post(
  "/",
  protect,
  allowRoles("customer"),
  createReview
);

module.exports = router;
