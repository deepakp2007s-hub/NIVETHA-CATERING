import jwt from 'jsonwebtoken';
import Owner from '../models/Owner.js';

export const protectOwner = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Not authorized. Owner token is missing.',
    });
  }

  try {
    const jwtSecret = process.env.JWT_SECRET || 'nivetha_catering_jwt_secret_production_2026';
    const decoded = jwt.verify(token, jwtSecret);

    // Enforce role isolation: Customer tokens MUST NOT access Owner endpoints
    if (decoded.role !== 'owner') {
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
    req.user = owner;
    next();
  } catch (error) {
    console.error('Owner auth error:', error.message);
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Session expired. Please log in again.',
      });
    }
    return res.status(401).json({
      success: false,
      message: 'Not authorized. Invalid token.',
    });
  }
};

export default protectOwner;
