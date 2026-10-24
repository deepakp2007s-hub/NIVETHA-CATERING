import Booking from '../models/Booking.js';

/**
 * @desc    Get Detailed Business Reports (Owner Only)
 * @route   GET /api/reports/summary
 * @access  Private (Owner Only)
 */
export const getReportsSummary = async (req, res, next) => {
  try {
    const { startDate, endDate } = req.query;
    const matchFilter = {};

    if (startDate || endDate) {
      matchFilter.eventDate = {};
      if (startDate) matchFilter.eventDate.$gte = new Date(startDate);
      if (endDate) matchFilter.eventDate.$lte = new Date(endDate);
    }

    const [byEventType, byMonth, guestDistribution] = await Promise.all([
      // Bookings grouped by event type
      Booking.aggregate([
        { $match: matchFilter },
        {
          $group: {
            _id: '$eventType',
            count: { $sum: 1 },
            totalPersons: { $sum: '$numberOfPersons' },
            totalRevenue: { $sum: '$totalAmount' },
          },
        },
        { $sort: { count: -1 } },
      ]),

      // Bookings grouped by Month
      Booking.aggregate([
        { $match: matchFilter },
        {
          $group: {
            _id: {
              year: { $year: '$eventDate' },
              month: { $month: '$eventDate' },
            },
            count: { $sum: 1 },
            revenue: { $sum: '$totalAmount' },
            guests: { $sum: '$numberOfPersons' },
          },
        },
        { $sort: { '_id.year': -1, '_id.month': -1 } },
        { $limit: 12 },
      ]),

      // Guest tier distribution
      Booking.aggregate([
        { $match: matchFilter },
        {
          $bucket: {
            groupBy: '$numberOfPersons',
            boundaries: [10, 50, 200, 500, 1000, 5000],
            default: '5000+',
            output: {
              count: { $sum: 1 },
            },
          },
        },
      ]),
    ]);

    res.json({
      success: true,
      report: {
        byEventType,
        byMonth,
        guestDistribution,
      },
    });
  } catch (error) {
    next(error);
  }
};
