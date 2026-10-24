
import jwt from 'jsonwebtoken';
import Owner from '../models/Owner.js';

// Normalize Indian phone numbers.
export const normalizePhone = (input) => {
  if (input === undefined || input === null) {
    return '';
  }

  const cleaned = String(input)
    .replace(/[\s\-()]/g, '')
    .trim();

  if (cleaned.startsWith('+91') && cleaned.length === 13) {
    return cleaned.slice(3);
  }

  if (cleaned.startsWith('91') && cleaned.length === 12) {
    return cleaned.slice(2);
  }

  return cleaned;
};

// Generate an authenticated Owner JWT.
const generateToken = (id, role = 'owner') => {
  const secret = process.env.JWT_SECRET;

  if (!secret || secret.length < 32) {
    throw new Error(
      'JWT_SECRET must be configured with at least 32 characters.'
    );
  }

  return jwt.sign(
    { id: String(id), role },
    secret,
    {
      expiresIn: process.env.JWT_EXPIRE || '7d',
    }
  );
};

/**
 * POST /api/auth/login
 * Owner login.
 */
export const loginOwner = async (req, res, next) => {
  try {
    const rawPhone =
      req.body?.phone ??
      req.body?.phoneNumber ??
      req.body?.mobile;

    const password = req.body?.password;
    const phone = normalizePhone(rawPhone);

    if (!phone || typeof password !== 'string' || !password) {
      return res.status(400).json({
        success: false,
        message: 'Phone number and password are required.',
      });
    }

    const owner = await Owner.findOne({ phone }).select('+password');

    if (!owner) {
      return res.status(401).json({
        success: false,
        message: 'Invalid phone number or password.',
      });
    }

    if (owner.isAuthorized === false) {
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

    return res.status(200).json({
      success: true,
      message: 'Owner login successful.',
      token,
      owner: {
        _id: owner._id,
        name: owner.name,
        phone: owner.phone,
        role: 'owner',
      },
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * GET /api/auth/me
 * Get the authenticated Owner profile.
 */
export const getOwnerProfile = async (req, res, next) => {
  try {
    if (!req.owner?._id) {
      return res.status(401).json({
        success: false,
        message: 'Owner authentication is required.',
      });
    }

    const owner = await Owner.findById(req.owner._id).select('-password');

    if (!owner) {
      return res.status(404).json({
        success: false,
        message: 'Owner not found.',
      });
    }

    if (owner.isAuthorized === false) {
      return res.status(403).json({
        success: false,
        message: 'Owner account has been deactivated.',
      });
    }

    return res.status(200).json({
      success: true,
      owner: {
        _id: owner._id,
        name: owner.name,
        phone: owner.phone,
        role: 'owner',
      },
    });
  } catch (error) {
    return next(error);
  }
};
