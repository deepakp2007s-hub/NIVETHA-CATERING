const express = require("express");
const router = express.Router();

const {
  getMaterials,
  getMaterialById,
  createMaterial,
  updateMaterial,
  deleteMaterial,
  getMaterialPlan,
} = require("../controllers/materialController");

const { protect, allowRoles } = require("../middleware/authMiddleware");

// All material routes require authentication + owner role
router.use(protect, allowRoles("owner"));

// Planning endpoint: GET /api/materials/plan?numberOfPersons=200
router.get("/plan", getMaterialPlan);

router.get("/", getMaterials);
router.get("/:id", getMaterialById);
router.post("/", createMaterial);
router.patch("/:id", updateMaterial);
router.delete("/:id", deleteMaterial);

module.exports = router;
