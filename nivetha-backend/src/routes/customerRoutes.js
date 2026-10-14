const express = require("express");
const router = express.Router();

const {
  getCustomers,
  getCustomerById,
} = require("../controllers/customerController");

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

router.get("/", protect, ownerOnly, getCustomers);
router.get("/:id", protect, ownerOnly, getCustomerById);

module.exports = router;