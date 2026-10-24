
/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import mongoose from 'mongoose';

const foodSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Food name is required'],
      trim: true,
      unique: true,
    },

    tamilName: {
      type: String,
      required: [true, 'Tamil name is required'],
      trim: true,
    },

    category: {
      type: String,
      required: [true, 'Category is required'],
      enum: [
        'Breakfast & Tiffin',
        'Meals & Vegetarian',
        'Biryani, Rice & Non-Vegetarian',
        'Dinner',
        'Sweets & Desserts',
      ],
      required: true,
      trim: true,
    },

    type: {
      type: String,
      required: [true, 'Food type is required'],
      enum: ['Veg', 'Non-Veg', 'Sweet'],
      default: 'Veg',
      trim: true,
    },

    description: {
      type: String,
      default: '',
      trim: true,
      maxlength: 1000,
    },

    price: {
      type: Number,
      required: [true, 'Price is required'],
      min: [0, 'Price cannot be negative'],
    },

    image: {
      type: String,
      required: [true, 'Image URL is required'],
      trim: true,
    },

    available: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

foodSchema.index({ category: 1, available: 1 });
foodSchema.index({ type: 1 });
foodSchema.index({ name: 'text', tamilName: 'text' });

const Food = mongoose.models.Food || mongoose.model('Food', foodSchema);

export default Food;
