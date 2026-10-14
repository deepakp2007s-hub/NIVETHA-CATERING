const express = require("express");
const router = express.Router();

const {
  getStaff,
  getStaffById,
  createStaff,
  updateStaff,
  deleteStaff,
  assignToBooking,
  removeFromBooking,
  getStaffByBooking,
} = require("../controllers/staffController");

const { protect, allowRoles } = require("../middleware/authMiddleware");

// All staff routes require authentication + owner role
router.use(protect, allowRoles("owner"));

// Staff by booking must be declared before /:id to avoid param clash
router.get("/booking/:bookingId", getStaffByBooking);

router.get("/", getStaff);
router.get("/:id", getStaffById);
router.post("/", createStaff);
router.patch("/:id", updateStaff);
router.delete("/:id", deleteStaff);

// Assignment sub-actions
router.post("/:id/assign", assignToBooking);
router.delete("/:id/assign", removeFromBooking);

module.exports = router;
