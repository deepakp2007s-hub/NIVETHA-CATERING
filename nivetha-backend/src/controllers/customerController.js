
import mongoose from 'mongoose';
import Customer from '../models/Customer.js';
import Booking from '../models/Booking.js';

/**
 * GET /api/customers
 * Owner-only customer list with search and pagination.
 */
export const getCustomers = async (req, res, next) => {
  try {
    const rawPage = req.query.page ?? '1';
    const rawLimit = req.query.limit ?? '20';
    const search = req.query.search;

    const page = Number(rawPage);
    const limit = Number(rawLimit);

    if (
      !Number.isSafeInteger(page) ||
      page < 1 ||
      !Number.isSafeInteger(limit) ||
      limit < 1 ||
      limit > 100
    ) {
      return res.status(400).json({
        success: false,
        message: 'Page must be positive. Limit must be between 1 and 100.',
      });
    }

    if (search !== undefined && typeof search !== 'string') {
      return res.status(400).json({
        success: false,
        message: 'Search must be a string.',
      });
    }

    const filter = {};
    const searchText = search?.trim();

    if (searchText) {
      if (searchText.length > 100) {
        return res.status(400).json({
          success: false,
          message: 'Search cannot exceed 100 characters.',
        });
      }

      // Escape regular-expression characters supplied by the user.
      const escapedSearch = searchText.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

      filter.$or = [
        { name: { $regex: escapedSearch, $options: 'i' } },
        { phone: { $regex: escapedSearch, $options: 'i' } },
      ];
    }

    const [customers, total] = await Promise.all([
      Customer.find(filter)
        .select('-password')
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean(),
      Customer.countDocuments(filter),
    ]);

    return res.status(200).json({
      success: true,
      total,
      page,
      limit,
      pages: Math.ceil(total / limit),
      count: customers.length,
      customers,
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * GET /api/customers/:id
 * Owner-only customer details and booking history.
 */
export const getCustomerById = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid customer ID.',
      });
    }

    const customer = await Customer.findById(id)
      .select('-password')
      .lean();

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found.',
      });
    }

    const bookings = await Booking.find({
      customer: customer._id,
    })
      .sort({ createdAt: -1 })
      .lean();

    return res.status(200).json({
      success: true,
      customer,
      count: bookings.length,
      bookings,
    });
  } catch (error) {
    return next(error);
  }
};
