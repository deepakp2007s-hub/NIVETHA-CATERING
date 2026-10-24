
import Booking from '../models/Booking.js';
import Customer from '../models/Customer.js';
import Food from '../models/Food.js';

/**
 * GET /api/dashboard
 * GET /api/dashboard/stats
 * Owner-only dashboard statistics.
 */
export const getDashboardStats = async (req, res, next) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const twoWeeksLater = new Date(today);
    twoWeeksLater.setDate(twoWeeksLater.getDate() + 14);

    const [
      bookingStatusCounts,
      totalCustomers,
      totalFoods,
      recentBookings,
      upcomingBookings,
      revenueData,
    ] = await Promise.all([
      Booking.aggregate([
        {
          $group: {
            _id: '$status',
            count: { $sum: 1 },
          },
        },
      ]),

      Customer.countDocuments({ isActive: true }),

      Food.countDocuments({ available: true }),

      Booking.find()
        .sort({ createdAt: -1 })
        .limit(5)
        .lean(),

      Booking.find({
        eventDate: {
          $gte: today,
          $lt: twoWeeksLater,
        },
        status: { $in: ['confirmed', 'pending'] },
      })
        .sort({ eventDate: 1 })
        .limit(6)
        .lean(),

      Booking.aggregate([
        {
          $match: {
            status: { $in: ['confirmed', 'completed'] },
          },
        },
        {
          $group: {
            _id: null,
            totalBookingValue: {
              $sum: { $ifNull: ['$totalAmount', 0] },
            },
            totalGuests: {
              $sum: { $ifNull: ['$numberOfPersons', 0] },
            },
          },
        },
      ]),
    ]);

    const statusMap = {
      pending: 0,
      confirmed: 0,
      rejected: 0,
      completed: 0,
      cancelled: 0,
    };

    let totalBookings = 0;

    for (const item of bookingStatusCounts) {
      totalBookings += item.count;

      if (Object.prototype.hasOwnProperty.call(statusMap, item._id)) {
        statusMap[item._id] = item.count;
      }
    }

    const revenue = revenueData[0]?.totalBookingValue ?? 0;
    const totalGuests = revenueData[0]?.totalGuests ?? 0;

    return res.status(200).json({
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
    return next(error);
  }
};
