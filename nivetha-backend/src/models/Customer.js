
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const customerSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Customer name is required'],
      trim: true,
      minlength: [2, 'Customer name must contain at least 2 characters'],
      maxlength: [100, 'Customer name cannot exceed 100 characters'],
    },

    phone: {
      type: String,
      required: [true, 'Customer phone number is required'],
      unique: true,
      trim: true,
      match: [/^\d{10}$/, 'Phone number must contain exactly 10 digits'],
      index: true,
    },

    email: {
      type: String,
      trim: true,
      lowercase: true,
      default: '',
      maxlength: [254, 'Email cannot exceed 254 characters'],
      validate: {
        validator(value) {
          return !value || /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
        },
        message: 'Please enter a valid email address',
      },
    },

    address: {
      type: String,
      trim: true,
      default: '',
      maxlength: [500, 'Address cannot exceed 500 characters'],
    },

    password: {
      type: String,
      required: [true, 'Password is required'],
      minlength: [6, 'Password must be at least 6 characters'],
      select: false,
    },

    role: {
      type: String,
      enum: ['customer'],
      default: 'customer',
    },

    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Hash the password only when it changes.
customerSchema.pre('save', async function () {
  if (!this.isModified('password')) {
    return;
  }

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

// Compare entered password with the stored hash.
customerSchema.methods.matchPassword = async function (enteredPassword) {
  if (typeof enteredPassword !== 'string' || !this.password) {
    return false;
  }

  return bcrypt.compare(enteredPassword, this.password);
};

const Customer =
  mongoose.models.Customer ||
  mongoose.model('Customer', customerSchema);

export default Customer;
