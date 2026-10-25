
/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import mongoose from 'mongoose';

export const ALLOWED_CATEGORIES = [
  'Breakfast & Tiffin',
  'Meals & Vegetarian',
  'Biryani, Rice & Non-Vegetarian',
  'Dinner',
  'Sweets & Desserts',
  'Breakfast',
  'Lunch',
  'Dessert',
  'Meals',
  'Biryani & Rice',
  'Breads',
  'Curries & Gravies',
  'Sides & Starters',
  'Tiffin & Breakfast',
];

export const ALLOWED_TYPES = ['Veg', 'Non-Veg', 'Sweet'];

function normalizeFoodType(value) {
  if (typeof value !== 'string') return value;

  const normalized = value.trim().toLowerCase();

  if (['veg', 'vegetarian'].includes(normalized)) {
    return 'Veg';
  }

  if (
    [
      'non-veg',
      'non veg',
      'nonveg',
      'nonvegetarian',
      'non-vegetarian',
    ].includes(normalized)
  ) {
    return 'Non-Veg';
  }

  if (['sweet', 'dessert'].includes(normalized)) {
    return 'Sweet';
  }

  return value.trim();
}

const foodSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Food name is required'],
      trim: true,
      unique: true,
      minlength: 1,
      maxlength: 150,
    },

    tamilName: {
      type: String,
      required: [true, 'Tamil name is required'],
      trim: true,
      maxlength: 150,
    },

    category: {
      type: String,
      required: [true, 'Category is required'],
      enum: {
        values: ALLOWED_CATEGORIES,
        message: 'Invalid food category: {VALUE}',
      },
      trim: true,
    },

    type: {
      type: String,
      required: [true, 'Food type is required'],
      enum: {
        values: ALLOWED_TYPES,
        message: 'Food type must be Veg, Non-Veg, or Sweet',
      },
      default: 'Veg',
      set: normalizeFoodType,
      trim: true,
    },

    description: {
      type: String,
      default: '',
      trim: true,
      maxlength: 1000,
    },

    image: {
      type: String,
      required: [true, 'Image URL is required'],
      trim: true,
      validate: {
        validator(value) {
          if (typeof value !== 'string' || !value.trim()) {
            return false;
          }

          try {
            const url = new URL(value.trim());

            return (
              ['http:', 'https:'].includes(url.protocol) &&
              Boolean(url.hostname)
            );
          } catch {
            return false;
          }
        },
        message: 'Image must be a valid HTTP or HTTPS URL',
      },
    },

    available: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
    strict: true,
  }
);

foodSchema.index({ category: 1, available: 1 });
foodSchema.index({ type: 1 });
foodSchema.index({ name: 'text', tamilName: 'text' });

const Food =
  mongoose.models.Food ||
  mongoose.model('Food', foodSchema);

export default Food;
