
import mongoose from 'mongoose';

const EVENT_TYPES = [
  'Wedding',
  'Reception',
  'Birthday Party',
  'Housewarming (Grahapravesam)',
  'Engagement',
  'Baby Shower (Valaikappu)',
  'Ear Piercing',
  'Corporate Event',
  'Other Function',
];

const BOOKING_STATUSES = [
  'pending',
  'confirmed',
  'rejected',
  'completed',
  'cancelled',
];

const bookingSchema = new mongoose.Schema(
  {
    bookingId: {
      type: String,
      required: [true, 'Booking ID is required'],
      unique: true,
      trim: true,
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
      maxlength: [100, 'Customer name cannot exceed 100 characters'],
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
      enum: EVENT_TYPES,
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
      maxlength: [100, 'Event time cannot exceed 100 characters'],
    },

    eventLocation: {
      type: String,
      required: [true, 'Event location is required'],
      trim: true,
      maxlength: [500, 'Event location cannot exceed 500 characters'],
    },

    numberOfPersons: {
      type: Number,
      required: [true, 'Number of guests is required'],
      min: [10, 'Minimum order is 10 persons'],
      max: [100000, 'Number of persons is too large'],
      validate: {
        validator: Number.isInteger,
        message: 'Number of persons must be a whole number',
      },
    },

    selectedFoods: {
      type: [
        {
          foodId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Food',
          },
          name: {
            type: String,
            required: [true, 'Food name is required'],
            trim: true,
          },
          tamilName: {
            type: String,
            trim: true,
            default: '',
          },
          category: {
            type: String,
            trim: true,
            default: '',
          },
          type: {
            type: String,
            trim: true,
            default: '',
          },
          price: {
            type: Number,
            min: [0, 'Food price cannot be negative'],
            default: 0,
          },
        },
      ],
      default: [],
    },

    cateringServices: {
      type: [String],
      default: ['Traditional Banana Leaf Service (வாழை இலை விருந்து)'],
    },

    extraRequirements: {
      type: String,
      trim: true,
      default: '',
      maxlength: [2000, 'Extra requirements cannot exceed 2000 characters'],
    },

    status: {
      type: String,
      enum: BOOKING_STATUSES,
      default: 'pending',
      index: true,
    },

    totalAmount: {
      type: Number,
      min: [0, 'Total amount cannot be negative'],
      default: 0,
    },

    notes: {
      type: String,
      trim: true,
      default: '',
      maxlength: [2000, 'Notes cannot exceed 2000 characters'],
    },
  },
  {
    timestamps: true,
  }
);

bookingSchema.index({ customer: 1, createdAt: -1 });
bookingSchema.index({ status: 1, eventDate: 1 });

const Booking =
  mongoose.models.Booking || mongoose.model('Booking', bookingSchema);

export default Booking;
