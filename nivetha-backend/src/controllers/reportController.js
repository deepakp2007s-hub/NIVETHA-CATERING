
import Booking from '../models/Booking.js';

/**
 * GET /api/reports
 * GET /api/reports/summary
 * Owner-only business reports.
 */
export const getReportsSummary = async (req, res, next) => {
  try {
    const { startDate, endDate } = req.query;
    const matchFilter = {};

    const parseDate = (value, endOfDay = false) => {
      if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) {
        return null;
      }

      const date = new Date(`${value}T00:00:00.000Z`);

      if (
        Number.isNaN(date.getTime()) ||
        date.toISOString().slice(0, 10) !== value
      ) {
        return null;
      }

      if (endOfDay) {
        date.setUTCHours(23, 59, 59, 999);
      }

      return date;
    };

    if (startDate !== undefined) {
      const date = parseDate(startDate);

      if (!date) {
        return res.status(400).json({
          success: false,
          message: 'Invalid startDate. Use YYYY-MM-DD format.',
        });
      }

      matchFilter.eventDate = {
        ...matchFilter.eventDate,
        $gte: date,
      };
    }

    if (endDate !== undefined) {
      const date = parseDate(endDate, true);

      if (!date) {
        return res.status(400).json({
          success: false,
          message: 'Invalid endDate. Use YYYY-MM-DD format.',
        });
      }

      matchFilter.eventDate = {
        ...matchFilter.eventDate,
        $lte: date,
      };
    }

    if (
      startDate &&
      endDate &&
      new Date(`${startDate}T00:00:00.000Z`) >
        new Date(`${endDate}T00:00:00.000Z`)
    ) {
      return res.status(400).json({
        success: false,
        message: 'startDate cannot be later than endDate.',
      });
    }

    const [byEventType, byMonth, guestDistribution, summary] =
      await Promise.all([
        Booking.aggregate([
          { $match: matchFilter },
          {
            $group: {
              _id: '$eventType',
              count: { $sum: 1 },
              totalPersons: { $sum: { $ifNull: ['$numberOfPersons', 0] } },
              totalBookingValue: { $sum: { $ifNull: ['$totalAmount', 0] } },
            },
          },
          { $sort: { count: -1 } },
        ]),

        Booking.aggregate([
          { $match: matchFilter },
          {
            $group: {
              _id: {
                year: { $year: '$eventDate' },
                month: { $month: '$eventDate' },
              },
              count: { $sum: 1 },
              revenue: { $sum: { $ifNull: ['$totalAmount', 0] } },
              guests: { $sum: { $ifNull: ['$numberOfPersons', 0] } },
            },
          },
          { $sort: { '_id.year': -1, '_id.month': -1 } },
          { $limit: 12 },
        ]),

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

        Booking.aggregate([
          { $match: matchFilter },
          {
            $group: {
              _id: null,
              totalBookings: { $sum: 1 },
              totalBookingValue: {
                $sum: { $ifNull: ['$totalAmount', 0] },
              },
              totalPersons: {
                $sum: { $ifNull: ['$numberOfPersons', 0] },
              },
            },
          },
        ]),
      ]);

    const totals = summary[0] ?? {
      totalBookings: 0,
      totalBookingValue: 0,
      totalPersons: 0,
    };

    return res.status(200).json({
      success: true,
      report: {
        summary: {
          totalBookings: totals.totalBookings,
          totalBookingValue: totals.totalBookingValue,
          totalPersons: totals.totalPersons,
        },
        byEventType,
        byMonth,
        guestDistribution,
      },
    });
  } catch (error) {
    return next(error);
  }
};
