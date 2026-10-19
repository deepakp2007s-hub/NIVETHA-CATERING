
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

const {
  protect,
  allowRoles,
} = require("../middleware/authMiddleware");

// Public customer menu — available foods only
router.get("/customer", getCustomerFoods);

// Owner-only food management
router.get("/", protect, allowRoles("owner"), getFoods);

router.post("/", protect, allowRoles("owner"), createFood);

router.patch("/:id", protect, allowRoles("owner"), updateFood);

router.delete("/:id", protect, allowRoles("owner"), deleteFood);

router.patch(
  "/:id/availability",
  protect,
  allowRoles("owner"),
  toggleFoodAvailability
);

module.exports = router;
