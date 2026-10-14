const express = require("express");
const router = express.Router();

const customerAuthController = require("../controllers/customerAuthController");
const customerAuthMiddleware = require("../middleware/customerAuthMiddleware");

router.post("/register", customerAuthController.register);
router.post("/login", customerAuthController.login);
router.get("/me", customerAuthMiddleware, customerAuthController.getMe);

module.exports = router;