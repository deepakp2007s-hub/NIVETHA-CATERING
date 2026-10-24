import Customer from '../models/Customer.js';
import Booking from '../models/Booking.js';

/**
 * @desc    Get All Customers (Owner Only)
 * @route   GET /api/customers
 * @access  Private (Owner)
 */
export const getCustomers = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 20;
    const skip = (page - 1) * limit;

    const searchQuery = req.query.search
      ? {
          $or: [
            { name: { $regex: req.query.search, $options: 'i' } },
            { phone: { $regex: req.query.search, $options: 'i' } },
          ],
        }
      : {};

    const [customers, total] = await Promise.all([
      Customer.find(searchQuery)
        .select('-password')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      Customer.countDocuments(searchQuery),
    ]);

    res.json({
      success: true,
      total,
      page,
      pages: Math.ceil(total / limit),
      count: customers.length,
      customers,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get Customer by ID with Booking History (Owner Only)
 * @route   GET /api/customers/:id
 * @access  Private (Owner)
 */
export const getCustomerById = async (req, res, next) => {
  try {
    const customer = await Customer.findById(req.params.id).select('-password');
    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found.',
      });
    }

    const bookings = await Booking.find({ customer: customer._id }).sort({ createdAt: -1 });

    res.json({
      success: true,
      customer,
      bookings,
    });
  } catch (error) {
    next(error);
  }
};
