
import mongoose from 'mongoose';

const notificationSchema = new mongoose.Schema(
  {
    recipient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Customer',
      required: [true, 'Recipient customer is required'],
      index: true,
    },

    type: {
      type: String,
      enum: [
        'booking_received',
        'booking_confirmed',
        'booking_rejected',
        'booking_updated',
        'booking_cancelled',
        'booking_completed',
        'general',
      ],
      default: 'booking_received',
      required: true,
    },

    title: {
      type: String,
      required: [true, 'Notification title is required'],
      trim: true,
      maxlength: [150, 'Title cannot exceed 150 characters'],
    },

    message: {
      type: String,
      required: [true, 'Notification message is required'],
      trim: true,
      maxlength: [1000, 'Message cannot exceed 1000 characters'],
    },

    bookingId: {
      type: String,
      trim: true,
      default: '',
      maxlength: [100, 'Booking ID cannot exceed 100 characters'],
    },

    read: {
      type: Boolean,
      default: false,
      index: true,
    },
  },
  {
    timestamps: true,
  }
);

notificationSchema.index({ recipient: 1, createdAt: -1 });

const Notification =
  mongoose.models.Notification ||
  mongoose.model('Notification', notificationSchema);

export default Notification;
