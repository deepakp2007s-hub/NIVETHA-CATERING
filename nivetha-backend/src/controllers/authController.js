import jwt from 'jsonwebtoken';
import Owner from '../models/Owner.js';

/**
 * Helper to normalize Indian phone numbers:
 * Strips whitespace, hyphens, and removes +91 or 91 country code prefix if 12 digits
 */
export const normalizePhone = (input) => {
  if (!input) return '';
  const cleaned = input.toString().replace(/[\s\-\(\)]/g, '').trim();
  if (cleaned.startsWith('+91') && cleaned.length === 13) {
    return cleaned.substring(3);
  }
  if (cleaned.startsWith('91') && cleaned.length === 12) {
    return cleaned.substring(2);
  }
  return cleaned;
};

const generateToken = (id, role = 'owner') => {
  const secret = process.env.JWT_SECRET || 'nivetha_catering_jwt_secret_production_2026';
  return jwt.sign({ id, role }, secret, {
    expiresIn: process.env.JWT_EXPIRE || '7d',
  });
};

/**
 * @desc    Owner Login
 * @route   POST /api/auth/login (or /api/owner/login)
 * @access  Private to authorized owners
 */
export const loginOwner = async (req, res, next) => {
  try {
    // ROOT CAUSE FIX: Check phone, phoneNumber, and mobile
    const rawPhone = req.body.phone || req.body.phoneNumber || req.body.mobile;
    const password = req.body.password;

    const phone = normalizePhone(rawPhone);

    if (!phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'Phone number and password are required.',
      });
    }

    // Lookup owner with password explicitly selected
    const owner = await Owner.findOne({ phone }).select('+password');

    if (!owner) {
      return res.status(401).json({
        success: false,
        message: 'Invalid phone number or password.',
      });
    }

    if (!owner.isAuthorized) {
      return res.status(403).json({
        success: false,
        message: 'This owner account has been deactivated.',
      });
    }

    const isMatch = await owner.matchPassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid phone number or password.',
      });
    }

    const token = generateToken(owner._id, 'owner');

    res.json({
      success: true,
      message: 'Owner login successful',
      token,
      owner: {
        _id: owner._id,
        name: owner.name,
        phone: owner.phone,
        role: owner.role,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get Current Owner Profile
 * @route   GET /api/auth/me
 * @access  Private (Owner)
 */
export const getOwnerProfile = async (req, res, next) => {
  try {
    const owner = await Owner.findById(req.owner._id);
    if (!owner) {
      return res.status(404).json({
        success: false,
        message: 'Owner not found',
      });
    }

    res.json({
      success: true,
      owner: {
        _id: owner._id,
        name: owner.name,
        phone: owner.phone,
        role: owner.role,
      },
    });
  } catch (error) {
    next(error);
  }
};
