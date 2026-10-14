/**
 * Material Controller — owner-only management of raw materials.
 *
 * Planning estimate formula (per material):
 *   estimatedQty = baseQtyPerPerson * numberOfPersons * wastageBuffer
 *
 * baseQtyPerPerson and wastageBuffer are configured by the owner on each
 * Material record — no quantities are hardcoded here.
 * If baseQtyPerPerson is null (unconfigured), the planning API will report
 * that the material is "unconfigured" and skip the calculation for it.
 */

"use strict";

const mongoose = require("mongoose");
const Material = require("../models/Material");

// ─── list all materials ───────────────────────────────────────────────────────

const getMaterials = async (req, res, next) => {
  try {
    const materials = await Material.find().sort({ category: 1, name: 1 });
    return res.json({ success: true, count: materials.length, data: materials });
  } catch (err) {
    next(err);
  }
};

// ─── single material ──────────────────────────────────────────────────────────

const getMaterialById = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid material ID" });
    }
    const material = await Material.findById(req.params.id);
    if (!material) {
      return res.status(404).json({ success: false, message: "Material not found" });
    }
    return res.json({ success: true, data: material });
  } catch (err) {
    next(err);
  }
};

// ─── create material ──────────────────────────────────────────────────────────

const createMaterial = async (req, res, next) => {
  try {
    const {
      name,
      unit,
      category,
      baseQtyPerPerson,
      wastageBuffer,
      currentStock,
      minimumStock,
      notes,
    } = req.body || {};

    if (!name?.trim()) {
      return res.status(400).json({ success: false, message: "Material name is required" });
    }
    if (!unit?.trim()) {
      return res.status(400).json({ success: false, message: "Unit is required (e.g. kg, litres, packets)" });
    }

    const material = await Material.create({
      name: name.trim(),
      unit: unit.trim(),
      category: category?.trim() || "general",
      baseQtyPerPerson: baseQtyPerPerson ?? null,
      wastageBuffer: wastageBuffer ?? 1.0,
      currentStock: currentStock ?? 0,
      minimumStock: minimumStock ?? 0,
      notes: notes?.trim() || "",
    });

    return res.status(201).json({ success: true, message: "Material created", data: material });
  } catch (err) {
    next(err);
  }
};

// ─── update material ──────────────────────────────────────────────────────────

const updateMaterial = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid material ID" });
    }

    const allowed = [
      "name", "unit", "category", "baseQtyPerPerson",
      "wastageBuffer", "currentStock", "minimumStock", "notes",
    ];
    const updates = {};
    for (const key of allowed) {
      if (Object.prototype.hasOwnProperty.call(req.body || {}, key)) {
        updates[key] = req.body[key];
      }
    }

    const material = await Material.findByIdAndUpdate(
      req.params.id,
      { $set: updates },
      { new: true, runValidators: true }
    );

    if (!material) {
      return res.status(404).json({ success: false, message: "Material not found" });
    }

    return res.json({ success: true, message: "Material updated", data: material });
  } catch (err) {
    next(err);
  }
};

// ─── delete material ──────────────────────────────────────────────────────────

const deleteMaterial = async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid material ID" });
    }
    const material = await Material.findByIdAndDelete(req.params.id);
    if (!material) {
      return res.status(404).json({ success: false, message: "Material not found" });
    }
    return res.json({ success: true, message: "Material deleted" });
  } catch (err) {
    next(err);
  }
};

// ─── planning estimate for a given headcount ─────────────────────────────────

const getMaterialPlan = async (req, res, next) => {
  try {
    const numberOfPersons = Number(req.query.numberOfPersons);
    if (!Number.isInteger(numberOfPersons) || numberOfPersons < 1) {
      return res.status(400).json({
        success: false,
        message: "Query param numberOfPersons must be a positive integer",
      });
    }

    const materials = await Material.find().sort({ category: 1, name: 1 });

    const plan = materials.map((m) => {
      if (m.baseQtyPerPerson === null || m.baseQtyPerPerson === undefined) {
        return {
          _id: m._id,
          name: m.name,
          unit: m.unit,
          category: m.category,
          estimatedQty: null,
          note: "baseQtyPerPerson not configured — update the material record to enable planning",
        };
      }
      const raw = m.baseQtyPerPerson * numberOfPersons * (m.wastageBuffer || 1);
      return {
        _id: m._id,
        name: m.name,
        unit: m.unit,
        category: m.category,
        baseQtyPerPerson: m.baseQtyPerPerson,
        wastageBuffer: m.wastageBuffer,
        numberOfPersons,
        estimatedQty: Math.ceil(raw * 100) / 100, // round up to 2dp
        currentStock: m.currentStock,
        stockShortfall: Math.max(0, Math.ceil(raw * 100) / 100 - m.currentStock),
      };
    });

    return res.json({
      success: true,
      numberOfPersons,
      count: plan.length,
      data: plan,
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getMaterials,
  getMaterialById,
  createMaterial,
  updateMaterial,
  deleteMaterial,
  getMaterialPlan,
};
