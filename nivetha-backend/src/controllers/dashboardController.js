import Booking from '../models/Booking.js';
import Customer from '../models/Customer.js';
import Food from '../models/Food.js';

/**
 * @desc    Get Owner Dashboard Statistics
 * @route   GET /api/dashboard/stats
 * @access  Private (Owner Only)
 */
export const getDashboardStats = async (req, res, next) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const twoWeeksLater = new Date(today);
    twoWeeksLater.setDate(today.getDate() + 14);

    // Parallel aggregation from real database collections
    const [
      bookingStatusCounts,
      totalCustomers,
      totalFoods,
      recentBookings,
      upcomingBookings,
      revenueData,
    ] = await Promise.all([
      // Status breakdown
      Booking.aggregate([
        {
          $group: {
            _id: '$status',
            count: { $sum: 1 },
          },
        },
      ]),
      // Customers count
      Customer.countDocuments({ isActive: true }),
      // Food menu count
      Food.countDocuments({ available: true }),
      // Recent bookings
      Booking.find().sort({ createdAt: -1 }).limit(5).lean(),
      // Upcoming events next 14 days
      Booking.find({
        eventDate: { $gte: today, $lte: twoWeeksLater },
        status: { $in: ['confirmed', 'pending'] },
      })
        .sort({ eventDate: 1 })
        .limit(6)
        .lean(),
      // Revenue summary
      Booking.aggregate([
        {
          $match: {
            status: { $in: ['confirmed', 'completed'] },
          },
        },
        {
          $group: {
            _id: null,
            totalRevenue: { $sum: '$totalAmount' },
            totalGuests: { $sum: '$numberOfPersons' },
          },
        },
      ]),
    ]);

    // Format status counts cleanly
    const statusMap = {
      pending: 0,
      confirmed: 0,
      rejected: 0,
      completed: 0,
      cancelled: 0,
    };

    let totalBookings = 0;
    bookingStatusCounts.forEach((item) => {
      if (statusMap[item._id] !== undefined) {
        statusMap[item._id] = item.count;
      }
      totalBookings += item.count;
    });

    const revenue = revenueData.length > 0 ? revenueData[0].totalRevenue : 0;
    const totalGuests = revenueData.length > 0 ? revenueData[0].totalGuests : 0;

    res.json({
      success: true,
      stats: {
        totalBookings,
        pendingBookings: statusMap.pending,
        confirmedBookings: statusMap.confirmed,
        rejectedBookings: statusMap.rejected,
        completedBookings: statusMap.completed,
        cancelledBookings: statusMap.cancelled,
        totalCustomers,
        totalActiveFoods: totalFoods,
        totalRevenue: revenue,
        totalGuestsServed: totalGuests,
      },
      recentBookings,
      upcomingBookings,
    });
  } catch (error) {
    next(error);
  }
};
