const express = require("express");
const router = express.Router();

const {
  getPayments,
  getPaymentById,
  getPaymentsByBooking,
  createPayment,
  updatePayment,
  deletePayment,
} = require("../controllers/paymentController");

const { protect, allowRoles } = require("../middleware/authMiddleware");

// All payment routes require authentication + owner role
router.use(protect, allowRoles("owner"));

router.get("/", getPayments);
router.get("/booking/:bookingId", getPaymentsByBooking);
router.get("/:id", getPaymentById);
router.post("/", createPayment);
router.patch("/:id", updatePayment);
router.delete("/:id", deletePayment);

module.exports = router;
