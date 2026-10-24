import mongoose from 'mongoose';

const foodSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Food English name is required'],
      unique: true,
      trim: true,
      index: true,
    },
    tamilName: {
      type: String,
      required: [true, 'Food Tamil name is required'],
      trim: true,
    },
    category: {
      type: String,
      required: [true, 'Category is required'],
      enum: [
        'Meals',
        'Tiffin & Breakfast',
        'Biryani & Rice',
        'Curries & Gravies',
        'Sides & Starters',
        'Sweets & Desserts',
        'Breads',
      ],
      default: 'Meals',
    },
    type: {
      type: String,
      required: [true, 'Food type is required'],
      enum: ['veg', 'non-veg', 'sweet'],
      index: true,
    },
    description: {
      type: String,
      trim: true,
      default: '',
    },
    price: {
      type: Number,
      required: [true, 'Price is required'],
      min: [0, 'Price cannot be negative'],
      default: 0,
    },
    image: {
      type: String,
      trim: true,
      default: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=600&q=80',
    },
    available: {
      type: Boolean,
      default: true,
      index: true,
    },
  },
  {
    timestamps: true,
  }
);

// Compound index for category and availability
foodSchema.index({ category: 1, available: 1 });
foodSchema.index({ type: 1, available: 1 });

export const Food = mongoose.models.Food || mongoose.model('Food', foodSchema);
export default Food;
