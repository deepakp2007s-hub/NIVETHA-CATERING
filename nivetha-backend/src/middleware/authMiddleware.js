
import jwt from 'jsonwebtoken';
import Owner from '../models/Owner.js';

export const protectOwner = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'Not authorized. Owner token is missing.',
    });
  }

  const token = authHeader.slice(7).trim();

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Not authorized. Owner token is missing.',
    });
  }

  const jwtSecret = process.env.JWT_SECRET;

  if (!jwtSecret || jwtSecret.length < 32) {
    console.error('JWT_SECRET must contain at least 32 characters.');

    return res.status(500).json({
      success: false,
      message: 'Server authentication configuration error.',
    });
  }

  try {
    const decoded = jwt.verify(token, jwtSecret);

    if (
      !decoded ||
      typeof decoded !== 'object' ||
      decoded.role !== 'owner' ||
      typeof decoded.id !== 'string'
    ) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Owner privileges required.',
      });
    }

    const owner = await Owner.findById(decoded.id).select('-password');

    if (!owner) {
      return res.status(401).json({
        success: false,
        message: 'Owner account no longer exists.',
      });
    }

    if (owner.isAuthorized === false) {
      return res.status(403).json({
        success: false,
        message: 'Owner account is deactivated.',
      });
    }

    req.owner = owner;
    req.user = {
      ...owner.toObject(),
      role: 'owner',
    };

    return next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Session expired. Please log in again.',
      });
    }

    if (
      error.name === 'JsonWebTokenError' ||
      error.name === 'NotBeforeError'
    ) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized. Invalid token.',
      });
    }

    console.error('Owner authentication error:', error.message);

    return next(error);
  }
};

export default protectOwner;
