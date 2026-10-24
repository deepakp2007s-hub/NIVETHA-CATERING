
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const ownerSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Owner name is required'],
      trim: true,
    },

    phone: {
      type: String,
      required: [true, 'Phone number is required'],
      unique: true,
      trim: true,
    },

    password: {
      type: String,
      required: [true, 'Password is required'],
      minlength: [6, 'Password must be at least 6 characters'],
      select: false,
    },

    role: {
      type: String,
      enum: ['owner'],
      default: 'owner',
      immutable: true,
    },

    isAuthorized: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Hash password only when it changes.
ownerSchema.pre('save', async function () {
  if (!this.isModified('password')) {
    return;
  }

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

// Compare entered password with stored hash.
ownerSchema.methods.matchPassword = async function (enteredPassword) {
  if (typeof enteredPassword !== 'string' || !this.password) {
    return false;
  }

  return bcrypt.compare(enteredPassword, this.password);
};

const Owner =
  mongoose.models.Owner ||
  mongoose.model('Owner', ownerSchema);

export { Owner };
export default Owner;
