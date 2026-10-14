import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import api from "../services/api";
import "./Reports.css";

const STATUSES = [
  "pending",
  "confirmed",
  "rejected",
  "cancelled",
  "completed",
];

const STATUS_LABELS = {
  pending: "Pending",
  confirmed: "Confirmed",
  rejected: "Rejected",
  cancelled: "Cancelled",
  completed: "Completed",
};

const getList = (response) => {
  const data = response?.data;

  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.bookings)) return data.bookings;
  if (Array.isArray(data?.data)) return data.data;
  if (Array.isArray(data?.data?.bookings)) return data.data.bookings;

  return [];
};

const getStatus = (booking) => {
  const status = String(booking?.status || "pending").toLowerCase();
  return STATUSES.includes(status) ? status : "pending";
};

const getDate = (booking) => {
  const value =
    booking?.functionDate ||
    booking?.eventDate ||
    booking?.bookingDate ||
    booking?.createdAt;

  if (!value) return null;

  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
};

const getEventType = (booking) =>
  booking?.eventType ||
  booking?.functionType ||
  booking?.eventName ||
  booking?.customerType ||
  "Other";

const formatMonth = (date) =>
  date.toLocaleDateString("en-IN", { month: "short" });

const formatDate = (date) =>
  date
    ? date.toLocaleDateString("en-IN", {
        day: "2-digit",
        month: "short",
        year: "numeric",
      })
    : "Date unavailable";

export default function Reports() {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [period, setPeriod] = useState("all");

  useEffect(() => {
    let active = true;

    const loadBookings = async () => {
      try {
        setLoading(true);
        setError("");

        const response = await api.get("/bookings");

        if (active) {
          setBookings(getList(response));
        }
      } catch (err) {
        if (active) {
          setError(
            err?.response?.data?.message ||
              "Unable to load booking reports. Please check the backend connection."
          );
        }
      } finally {
        if (active) setLoading(false);
      }
    };

    loadBookings();

    return () => {
      active = false;
    };
  }, []);

  const filteredBookings = useMemo(() => {
    const now = new Date();

    return bookings.filter((booking) => {
      if (period === "all") return true;

      const date = getDate(booking);
      if (!date) return false;

      if (period === "month") {
        return (
          date.getMonth() === now.getMonth() &&
          date.getFullYear() === now.getFullYear()
        );
      }

      if (period === "30days") {
        const daysAgo = new Date(now);
        daysAgo.setDate(now.getDate() - 29);
        daysAgo.setHours(0, 0, 0, 0);

        return date >= daysAgo && date <= now;
      }

      return true;
    });
  }, [bookings, period]);

  const summary = useMemo(() => {
    const statusCounts = Object.fromEntries(
      STATUSES.map((status) => [status, 0])
    );

    const eventCounts = {};
    let datedBookings = 0;

    filteredBookings.forEach((booking) => {
      statusCounts[getStatus(booking)] += 1;

      const eventType = getEventType(booking);
      eventCounts[eventType] = (eventCounts[eventType] || 0) + 1;

      if (getDate(booking)) datedBookings += 1;
    });

    const eventTypes = Object.entries(eventCounts)
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => b.count - a.count);

    const now = new Date();

    const monthlyActivity = Array.from({ length: 6 }, (_, index) => {
      const date = new Date(
        now.getFullYear(),
        now.getMonth() - (5 - index),
        1
      );

      return {
        key: `${date.getFullYear()}-${date.getMonth()}`,
        label: formatMonth(date),
        year: date.getFullYear(),
        month: date.getMonth(),
        count: 0,
      };
    });

    filteredBookings.forEach((booking) => {
      const date = getDate(booking);
      if (!date) return;

      const month = monthlyActivity.find(
        (item) =>
          item.year === date.getFullYear() &&
          item.month === date.getMonth()
      );

      if (month) month.count += 1;
    });

    const maxMonthlyCount = Math.max(
      1,
      ...monthlyActivity.map((item) => item.count)
    );

    const recentBookings = [...filteredBookings]
      .sort((a, b) => {
        const dateA = getDate(a)?.getTime() || 0;
        const dateB = getDate(b)?.getTime() || 0;
        return dateB - dateA;
      })
      .slice(0, 5);

    return {
      total: filteredBookings.length,
      statusCounts,
      eventTypes,
      monthlyActivity,
      maxMonthlyCount,
      recentBookings,
      datedBookings,
    };
  }, [filteredBookings]);

  if (loading) {
    return (
      <div className="reports-page">
        <div className="reports-state">
          <span className="reports-spinner" />
          <p>Preparing booking reports...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="reports-page">
        <div className="reports-error">
          <div className="reports-error-icon">!</div>
          <h2>Reports unavailable</h2>
          <p>{error}</p>
          <button
            className="reports-btn reports-btn-primary"
            onClick={() => window.location.reload()}
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="reports-page">
      <div className="reports-header">
        <div>
          <span className="reports-eyebrow">BUSINESS OVERVIEW</span>
          <h1>Reports & Analytics</h1>
          <p>Review booking activity and event trends.</p>
        </div>

        <label className="reports-filter">
          <span>Report period</span>
          <select
            value={period}
            onChange={(event) => setPeriod(event.target.value)}
          >
            <option value="all">All time</option>
            <option value="month">This month</option>
            <option value="30days">Last 30 days</option>
          </select>
        </label>
      </div>

      <div className="reports-notice">
        <span className="reports-notice-mark">i</span>
        <p>
          These reports are calculated from the booking records currently
          available in your backend.
        </p>
      </div>

      <section className="reports-summary-grid">
        <article className="reports-summary-card reports-summary-primary">
          <div className="reports-card-top">
            <span>Total Bookings</span>
            <span className="reports-card-icon">▤</span>
          </div>
          <strong>{summary.total}</strong>
          <small>Bookings in selected period</small>
        </article>

        <article className="reports-summary-card">
          <div className="reports-card-top">
            <span>Confirmed</span>
            <span className="reports-card-icon">✓</span>
          </div>
          <strong>{summary.statusCounts.confirmed}</strong>
          <small>Confirmed event bookings</small>
        </article>

        <article className="reports-summary-card">
          <div className="reports-card-top">
            <span>Pending</span>
            <span className="reports-card-icon">◷</span>
          </div>
          <strong>{summary.statusCounts.pending}</strong>
          <small>Awaiting a decision</small>
        </article>

        <article className="reports-summary-card">
          <div className="reports-card-top">
            <span>Completed</span>
            <span className="reports-card-icon">★</span>
          </div>
          <strong>{summary.statusCounts.completed}</strong>
          <small>Completed bookings</small>
        </article>
      </section>

      <section className="reports-main-grid">
        <article className="reports-panel">
          <div className="reports-panel-heading">
            <div>
              <h2>Monthly Booking Activity</h2>
              <p>Booking dates over the last six months</p>
            </div>
            <span className="reports-panel-symbol">↗</span>
          </div>

          <div className="reports-chart">
            {summary.monthlyActivity.map((item) => (
              <div className="reports-chart-column" key={item.key}>
                <span className="reports-chart-value">{item.count}</span>
                <div className="reports-chart-track">
                  <div
                    className="reports-chart-bar"
                    style={{
                      height: `${
                        item.count === 0
                          ? 0
                          : Math.max(
                              8,
                              (item.count / summary.maxMonthlyCount) * 100
                            )
                      }%`,
                    }}
                    title={`${item.count} booking(s)`}
                  />
                </div>
                <span className="reports-chart-label">{item.label}</span>
              </div>
            ))}
          </div>

          <p className="reports-chart-footnote">
            {summary.datedBookings} booking(s) have a usable date in the
            selected period.
          </p>
        </article>

        <article className="reports-panel">
          <div className="reports-panel-heading">
            <div>
              <h2>Booking Status</h2>
              <p>Current distribution by status</p>
            </div>
          </div>

          <div className="reports-status-list">
            {STATUSES.map((status) => {
              const count = summary.statusCounts[status];
              const percentage = summary.total
                ? Math.round((count / summary.total) * 100)
                : 0;

              return (
                <div className="reports-status-item" key={status}>
                  <div className="reports-status-label-row">
                    <span className="reports-status-name">
                      <i className={`reports-status-dot ${status}`} />
                      {STATUS_LABELS[status]}
                    </span>
                    <strong>
                      {count} <small>({percentage}%)</small>
                    </strong>
                  </div>
                  <div className="reports-progress-track">
                    <div
                      className={`reports-progress-fill ${status}`}
                      style={{ width: `${percentage}%` }}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        </article>
      </section>

      <section className="reports-panel reports-event-panel">
        <div className="reports-panel-heading">
          <div>
            <h2>Event Type Summary</h2>
            <p>Types of events requested by customers</p>
          </div>
          <span className="reports-total-chip">
            {summary.eventTypes.length} event type(s)
          </span>
        </div>

        {summary.eventTypes.length === 0 ? (
          <div className="reports-empty">
            <span>◇</span>
            <h3>No event data available</h3>
            <p>Event types will appear here when booking records are available.</p>
          </div>
        ) : (
          <div className="reports-event-grid">
            {summary.eventTypes.map((event) => {
              const percentage = summary.total
                ? Math.round((event.count / summary.total) * 100)
                : 0;

              return (
                <div className="reports-event-card" key={event.name}>
                  <div className="reports-event-card-top">
                    <span className="reports-event-icon">✦</span>
                    <span className="reports-event-percent">
                      {percentage}%
                    </span>
                  </div>
                  <strong>{event.name}</strong>
                  <p>
                    {event.count} booking{event.count === 1 ? "" : "s"}
                  </p>
                  <div className="reports-progress-track">
                    <div
                      className="reports-progress-fill event"
                      style={{ width: `${percentage}%` }}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </section>

      <section className="reports-panel reports-recent-panel">
        <div className="reports-panel-heading">
          <div>
            <h2>Recent Bookings</h2>
            <p>Latest five bookings with available dates</p>
          </div>
          <Link to="/bookings" className="reports-text-link">
            View all bookings →
          </Link>
        </div>

        {summary.recentBookings.length === 0 ? (
          <div className="reports-empty">
            <span>▤</span>
            <h3>No bookings found</h3>
            <p>Bookings will appear here after customers submit requests.</p>
          </div>
        ) : (
          <div className="reports-table-wrap">
            <table className="reports-table">
              <thead>
                <tr>
                  <th>Customer</th>
                  <th>Event</th>
                  <th>Function Date</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {summary.recentBookings.map((booking, index) => {
                  const id =
                    booking._id || booking.id || booking.bookingId || index;
                  const customer =
                    booking.customerName ||
                    booking.name ||
                    booking.customer?.name ||
                    booking.customer?.fullName ||
                    "Customer";
                  const eventType = getEventType(booking);
                  const status = getStatus(booking);

                  return (
                    <tr key={id}>
                      <td>
                        <div className="reports-customer-cell">
                          <span className="reports-customer-avatar">
                            {customer.charAt(0).toUpperCase()}
                          </span>
                          <span>{customer}</span>
                        </div>
                      </td>
                      <td>{eventType}</td>
                      <td>{formatDate(getDate(booking))}</td>
                      <td>
                        <span className={`reports-status-badge ${status}`}>
                          {STATUS_LABELS[status]}
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <footer className="reports-footer">
        <span> NIVETHA CATERING SERVICE</span>
        <span>Booking reports · Updated when the page loads</span>
      </footer>
    </div>
  );
}
