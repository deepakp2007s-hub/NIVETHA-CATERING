const express = require("express");
const router = express.Router();

const {
  getFoods,
  getCustomerFoods,
  createFood,
  updateFood,
  deleteFood,
  toggleFoodAvailability,
} = require("../controllers/foodController");

const { protect } = require("../middleware/authMiddleware");

const ownerOnly = (req, res, next) => {
  if (req.user?.role !== "owner") {
    return res.status(403).json({
      success: false,
      message: "Owner access required",
    });
  }
  next();
};

// Customer menu — public, available foods only
router.get("/customer", getCustomerFoods);

// Owner food management
router.get("/", protect, ownerOnly, getFoods);
router.post("/", protect, ownerOnly, createFood);
router.patch("/:id", protect, ownerOnly, updateFood);
router.delete("/:id", protect, ownerOnly, deleteFood);
router.patch("/:id/availability", protect, ownerOnly, toggleFoodAvailability);

module.exports = router;