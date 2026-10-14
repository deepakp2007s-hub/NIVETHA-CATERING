const mongoose = require("mongoose");

/**
 * Material model.
 *
 * Materials are raw / consumable items used at events.
 * Quantities in planning estimates are derived from configurable rules
 * (see materialRules below) — never hardcoded magic numbers.
 *
 * Planning formula (per material item):
 *   estimatedQty = baseQtyPerPerson * numberOfPersons * wastageBuffer
 *
 * The wastageBuffer and baseQtyPerPerson are stored on the material record
 * so the business owner can adjust them without code changes.
 */
const materialSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    unit: {
      type: String,
      required: true,
      trim: true,
      // e.g. "kg", "litres", "packets", "pieces"
    },
    /**
     * Base quantity required per person.
     * Owner must configure this for each material; no default quantity
     * is invented — the field defaults to null (unconfigured).
     */
    baseQtyPerPerson: {
      type: Number,
      min: [0, "Base quantity cannot be negative"],
      default: null,
    },
    /**
     * Wastage buffer multiplier (e.g. 1.1 = 10% extra).
     * Defaults to 1.0 (no wastage buffer until owner configures it).
     */
    wastageBuffer: {
      type: Number,
      min: [1, "Wastage buffer must be at least 1.0 (no wastage)"],
      default: 1.0,
    },
    category: {
      type: String,
      trim: true,
      default: "general",
    },
    currentStock: {
      type: Number,
      min: [0, "Stock cannot be negative"],
      default: 0,
    },
    minimumStock: {
      type: Number,
      min: [0, "Minimum stock cannot be negative"],
      default: 0,
    },
    notes: {
      type: String,
      default: "",
      trim: true,
    },
  },
  { timestamps: true }
);

module.exports =
  mongoose.models.Material || mongoose.model("Material", materialSchema);
