import mongoose from 'mongoose';

const bookingSchema = new mongoose.Schema(
  {
    bookingId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    customer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Customer',
      required: [true, 'Customer reference is required'],
      index: true,
    },
    customerName: {
      type: String,
      required: [true, 'Customer name is required'],
      trim: true,
    },
    customerPhone: {
      type: String,
      required: [true, 'Customer phone number is required'],
      trim: true,
    },
    eventType: {
      type: String,
      required: [true, 'Event type is required'],
      trim: true,
      enum: [
        'Wedding',
        'Reception',
        'Birthday Party',
        'Housewarming (Grahapravesam)',
        'Engagement',
        'Baby Shower (Valaikappu)',
        'Ear Piercing',
        'Corporate Event',
        'Other Function',
      ],
      default: 'Wedding',
    },
    eventDate: {
      type: Date,
      required: [true, 'Function date is required'],
      index: true,
    },
    eventTime: {
      type: String,
      required: [true, 'Function session/time is required'],
      trim: true,
      default: 'Morning',
    },
    eventLocation: {
      type: String,
      required: [true, 'Event location/venue address is required'],
      trim: true,
    },
    numberOfPersons: {
      type: Number,
      required: [true, 'Number of guests/persons is required'],
      min: [10, 'Minimum order is 10 persons'],
    },
    selectedFoods: [
      {
        foodId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'Food',
        },
        name: { type: String, required: true },
        tamilName: { type: String },
        category: { type: String },
        type: { type: String },
        price: { type: Number, default: 0 },
      },
    ],
    cateringServices: {
      type: [String],
      default: ['Traditional Banana Leaf Service (வாழை இலை விருந்து)'],
    },
    extraRequirements: {
      type: String,
      trim: true,
      default: '',
    },
    status: {
      type: String,
      enum: ['pending', 'confirmed', 'rejected', 'completed', 'cancelled'],
      default: 'pending',
      index: true,
    },
    totalAmount: {
      type: Number,
      default: 0,
      min: 0,
    },
    notes: {
      type: String,
      trim: true,
      default: '',
    },
  },
  {
    timestamps: true,
  }
);

// Helpful compound indexes
bookingSchema.index({ customer: 1, createdAt: -1 });
bookingSchema.index({ status: 1, eventDate: 1 });

export const Booking = mongoose.models.Booking || mongoose.model('Booking', bookingSchema);
export default Booking;
