const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");
const { protect, allowRoles } = require("../middleware/authMiddleware");

router.post("/login", authController.login);
router.get("/me", protect, allowRoles("owner"), authController.getMe);

module.exports = router;
