import { useCallback, useEffect, useMemo, useState } from "react";
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

const getBookingList = (response) => {
  let data = response?.data ?? response;

  for (let index = 0; index < 4; index += 1) {
    if (Array.isArray(data)) return data;

    if (!data || typeof data !== "object") return [];

    if (Array.isArray(data.bookings)) return data.bookings;
    if (Array.isArray(data.items)) return data.items;
    if (Array.isArray(data.results)) return data.results;

    if (data.data !== undefined) {
      data = data.data;
      continue;
    }

    break;
  }

  return [];
};

const getStatus = (booking) => {
  const value = String(booking?.status || "pending")
    .trim()
    .toLowerCase();

  return STATUSES.includes(value) ? value : "pending";
};

const getDate = (booking) => {
  const value =
    booking?.functionDate ||
    booking?.function_date ||
    booking?.eventDate ||
    booking?.event_date ||
    booking?.bookingDate ||
    booking?.booking_date ||
    booking?.createdAt ||
    booking?.created_at;

  if (!value) return null;

  const date = new Date(value);

  return Number.isNaN(date.getTime()) ? null : date;
};

const getEventType = (booking) =>
  booking?.eventType ||
  booking?.event_type ||
  booking?.functionType ||
  booking?.function_type ||
  booking?.eventName ||
  booking?.event_name ||
  booking?.customerType ||
  booking?.customer_type ||
  "Other";

const getCustomerName = (booking) =>
  booking?.customerName ||
  booking?.customer_name ||
  booking?.name ||
  booking?.customer?.name ||
  booking?.customer?.fullName ||
  booking?.customer?.full_name ||
  "Customer";

const getBookingId = (booking, index) =>
  booking?._id ||
  booking?.id ||
  booking?.bookingId ||
  booking?.booking_id ||
  `booking-${index}`;

const formatDate = (date) =>
  date
    ? date.toLocaleDateString("en-IN", {
        day: "2-digit",
        month: "short",
        year: "numeric",
      })
    : "Date unavailable";

const formatMonth = (date) =>
  date.toLocaleDateString("en-IN", { month: "short" });

const formatNumber = (value) => Number(value || 0).toLocaleString("en-IN");

const getErrorMessage = (error) =>
  error?.response?.data?.detail ||
  error?.response?.data?.message ||
  error?.response?.data?.error?.message ||
  error?.message ||
  "Unable to load booking reports. Please check your backend connection.";

export default function Reports() {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState("");
  const [period, setPeriod] = useState("all");
  const [lastUpdated, setLastUpdated] = useState(null);

  const loadBookings = useCallback(async (isRefresh = false) => {
    try {
      if (isRefresh) {
        setRefreshing(true);
      } else {
        setLoading(true);
      }

      setError("");

      const response = await api.get("/bookings");
      const bookingList = getBookingList(response);

      setBookings(bookingList);
      setLastUpdated(new Date());
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    loadBookings();
  }, [loadBookings]);

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
        const startDate = new Date(now);
        startDate.setDate(now.getDate() - 29);
        startDate.setHours(0, 0, 0, 0);

        return date >= startDate && date <= now;
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

      const eventType = String(getEventType(booking)).trim() || "Other";
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

  const getPercentage = (count) =>
    summary.total
      ? Math.round((count / summary.total) * 100)
      : 0;

  if (loading) {
    return (
      <main className="reports-page">
        <div className="reports-state">
          <span className="reports-spinner" />
          <h2>Preparing your reports</h2>
          <p>Fetching the latest booking information...</p>
        </div>
      </main>
    );
  }

  if (error && bookings.length === 0) {
    return (
      <main className="reports-page">
        <div className="reports-error">
          <div className="reports-error-icon">!</div>
          <h2>Reports unavailable</h2>
          <p>{error}</p>
          <button
            type="button"
            className="reports-btn reports-btn-primary"
            onClick={() => loadBookings()}
          >
            Try Again
          </button>
        </div>
      </main>
    );
  }

  return (
    <main className="reports-page">
      <header className="reports-header">
        <div className="reports-heading-content">
          <span className="reports-eyebrow">
            <span className="reports-eyebrow-dot" />
            BUSINESS INTELLIGENCE
          </span>

          <h1>Reports & Analytics</h1>

          <p>
            Track booking performance, monitor events and understand your
            catering business.
          </p>

          {lastUpdated && (
            <span className="reports-updated">
              Last updated: {lastUpdated.toLocaleTimeString("en-IN")}
            </span>
          )}
        </div>

        <div className="reports-header-actions">
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

          <button
            type="button"
            className="reports-refresh-btn"
            onClick={() => loadBookings(true)}
            disabled={refreshing}
          >
            <span className={refreshing ? "reports-refresh-icon spinning" : "reports-refresh-icon"}>
              ↻
            </span>
            {refreshing ? "Refreshing..." : "Refresh"}
          </button>
        </div>
      </header>

      {error && (
        <div className="reports-inline-error" role="alert">
          <span>!</span>
          <p>{error} Showing previously loaded data.</p>
        </div>
      )}

      <section className="reports-summary-grid">
        <article className="reports-summary-card reports-summary-primary">
          <div className="reports-card-top">
            <span>Total Bookings</span>
            <span className="reports-card-icon">▤</span>
          </div>
          <strong>{formatNumber(summary.total)}</strong>
          <small>Bookings in selected period</small>
          <div className="reports-card-accent" />
        </article>

        <article className="reports-summary-card">
          <div className="reports-card-top">
            <span>Confirmed</span>
            <span className="reports-card-icon confirmed-icon">✓</span>
          </div>
          <strong>{formatNumber(summary.statusCounts.confirmed)}</strong>
          <small>{getPercentage(summary.statusCounts.confirmed)}% of bookings</small>
          <div className="reports-card-accent confirmed-accent" />
        </article>

        <article className="reports-summary-card">
          <div className="reports-card-top">
            <span>Pending</span>
            <span className="reports-card-icon pending-icon">◷</span>
          </div>
          <strong>{formatNumber(summary.statusCounts.pending)}</strong>
          <small>Awaiting a decision</small>
          <div className="reports-card-accent pending-accent" />
        </article>

        <article className="reports-summary-card">
          <div className="reports-card-top">
            <span>Completed</span>
            <span className="reports-card-icon completed-icon">★</span>
          </div>
          <strong>{formatNumber(summary.statusCounts.completed)}</strong>
          <small>Successfully completed</small>
          <div className="reports-card-accent completed-accent" />
        </article>
      </section>

      <section className="reports-main-grid">
        <article className="reports-panel reports-chart-panel">
          <div className="reports-panel-heading">
            <div>
              <span className="reports-section-label">PERFORMANCE</span>
              <h2>Monthly Booking Activity</h2>
              <p>Booking activity over the last six months</p>
            </div>
            <span className="reports-panel-symbol">↗</span>
          </div>

          <div className="reports-chart">
            {summary.monthlyActivity.map((item) => {
              const height =
                item.count === 0
                  ? 0
                  : Math.max(
                      8,
                      (item.count / summary.maxMonthlyCount) * 100
                    );

              return (
                <div className="reports-chart-column" key={item.key}>
                  <span className="reports-chart-value">{item.count}</span>

                  <div className="reports-chart-track">
                    <div
                      className="reports-chart-bar"
                      style={{ height: `${height}%` }}
                      title={`${item.count} booking(s)`}
                    />
                  </div>

                  <span className="reports-chart-label">{item.label}</span>
                </div>
              );
            })}
          </div>

          <div className="reports-chart-footer">
            <span className="reports-chart-legend">
              <i />
              Monthly bookings
            </span>
            <span>
              {summary.datedBookings} dated booking(s)
            </span>
          </div>
        </article>

        <article className="reports-panel">
          <div className="reports-panel-heading">
            <div>
              <span className="reports-section-label">OVERVIEW</span>
              <h2>Booking Status</h2>
              <p>Distribution by current status</p>
            </div>
          </div>

          <div className="reports-status-list">
            {STATUSES.map((status) => {
              const count = summary.statusCounts[status];
              const percentage = getPercentage(count);

              return (
                <div className="reports-status-item" key={status}>
                  <div className="reports-status-label-row">
                    <span className="reports-status-name">
                      <i className={`reports-status-dot ${status}`} />
                      {STATUS_LABELS[status]}
                    </span>

                    <strong>
                      {count}
                      <small>{percentage}%</small>
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
            <span className="reports-section-label">CUSTOMER DEMAND</span>
            <h2>Event Type Summary</h2>
            <p>Most requested event categories</p>
          </div>

          <span className="reports-total-chip">
            {summary.eventTypes.length} event type(s)
          </span>
        </div>

        {summary.eventTypes.length === 0 ? (
          <div className="reports-empty">
            <span className="reports-empty-icon">◇</span>
            <h3>No event data available</h3>
            <p>Event types will appear here when bookings are available.</p>
          </div>
        ) : (
          <div className="reports-event-grid">
            {summary.eventTypes.map((event) => {
              const percentage = getPercentage(event.count);

              return (
                <article className="reports-event-card" key={event.name}>
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
                </article>
              );
            })}
          </div>
        )}
      </section>

      <section className="reports-panel reports-recent-panel">
        <div className="reports-panel-heading">
          <div>
            <span className="reports-section-label">LATEST ACTIVITY</span>
            <h2>Recent Bookings</h2>
            <p>Latest five bookings in the selected period</p>
          </div>

          <Link to="/bookings" className="reports-text-link">
            View all bookings <span>→</span>
          </Link>
        </div>

        {summary.recentBookings.length === 0 ? (
          <div className="reports-empty">
            <span className="reports-empty-icon">▤</span>
            <h3>No bookings found</h3>
            <p>New customer bookings will appear here.</p>
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
                  const id = getBookingId(booking, index);
                  const customer = getCustomerName(booking);
                  const eventType = getEventType(booking);
                  const status = getStatus(booking);

                  return (
                    <tr key={id}>
                      <td>
                        <div className="reports-customer-cell">
                          <span className="reports-customer-avatar">
                            {String(customer).charAt(0).toUpperCase()}
                          </span>
                          <span>{customer}</span>
                        </div>
                      </td>

                      <td>{eventType}</td>
                      <td>{formatDate(getDate(booking))}</td>

                      <td>
                        <span className={`reports-status-badge ${status}`}>
                          <i />
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
        <span>NIVETHA CATERING SERVICE</span>
        <span>Reports are calculated from available booking records.</span>
      </footer>
    </main>
  );
}