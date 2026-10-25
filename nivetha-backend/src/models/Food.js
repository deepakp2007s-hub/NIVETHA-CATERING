
import mongoose from 'mongoose';

const foodSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Food name is required'],
      trim: true,
      unique: true
    },
    tamilName: {
      type: String,
      trim: true,
      default: ''
    },
    category: {
      type: String,
      required: [true, 'Category is required'],
      enum: [
        'Breakfast',
        'Meals',
        'Rice',
        'Veg Gravy',
        'Non-Veg Gravy',
        'Biryani',
        'Starter',
        'Seafood',
        'Bread',
        'Sweets'
      ],
      trim: true
    },
    type: {
      type: String,
      required: [true, 'Food type is required'],
      enum: ['Veg', 'Non-Veg'],
      trim: true
    },
    description: {
      type: String,
      trim: true,
      default: ''
    },
    imageUrl: {
      type: String,
      trim: true,
      default: ''
    },
    isSeeded: {
      type: Boolean,
      default: true
    },
    isAvailable: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

foodSchema.index({ category: 1, type: 1 });
foodSchema.index({ name: 'text', tamilName: 'text' });

const Food =
  mongoose.models.Food ||
  mongoose.model('Food', foodSchema);

export default Food;
