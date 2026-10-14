
import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import api from "../services/api";
import "./Dashboard.css";

const getBookingList = (response) => {
  const data = response?.data;
  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.bookings)) return data.bookings;
  if (Array.isArray(data?.data)) return data.data;
  if (Array.isArray(data?.data?.bookings)) return data.data.bookings;
  return [];
};

const formatDate = (value) => {
  if (!value) return "—";

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "—";

  return date.toLocaleDateString("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
};

const getCustomerName = (booking) =>
  booking.customerName ||
  booking.customer?.name ||
  booking.customer?.fullName ||
  booking.name ||
  "Customer";

const getEventName = (booking) =>
  booking.eventType ||
  booking.functionType ||
  booking.eventName ||
  booking.event?.type ||
  "Catering Event";

const getStatus = (booking) =>
  String(booking.status || "pending").toLowerCase();

const getBookingId = (booking) =>
  booking._id || booking.id || booking.bookingId || "";

function Dashboard() {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let active = true;

    const loadBookings = async () => {
      try {
        setLoading(true);
        setError("");

        const response = await api.get("/bookings");

        if (active) {
          setBookings(getBookingList(response));
        }
      } catch (err) {
        if (active) {
          setError(
            err.response?.data?.message ||
              "Unable to load bookings. Please check the backend connection."
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

  const stats = useMemo(() => {
    const pending = bookings.filter(
      (booking) => getStatus(booking) === "pending"
    ).length;

    const confirmed = bookings.filter(
      (booking) => getStatus(booking) === "confirmed"
    ).length;

    const completed = bookings.filter(
      (booking) => getStatus(booking) === "completed"
    ).length;

    return [
      {
        label: "Total Bookings",
        value: bookings.length,
        icon: "▦",
        detail: "All booking requests",
        className: "stat-maroon",
      },
      {
        label: "Pending Requests",
        value: pending,
        icon: "◷",
        detail: "Awaiting your response",
        className: "stat-gold",
      },
      {
        label: "Confirmed Events",
        value: confirmed,
        icon: "✓",
        detail: "Ready for planning",
        className: "stat-green",
      },
      {
        label: "Completed Events",
        value: completed,
        icon: "★",
        detail: "Successfully completed",
        className: "stat-purple",
      },
    ];
  }, [bookings]);

  const recentBookings = useMemo(() => {
    return [...bookings]
      .sort((a, b) => {
        const dateA = new Date(a.createdAt || a.bookingDate || 0).getTime();
        const dateB = new Date(b.createdAt || b.bookingDate || 0).getTime();
        return dateB - dateA;
      })
      .slice(0, 5);
  }, [bookings]);

  return (
    <main className="dashboard page-enter">
      <section className="dashboard-welcome">
        <div className="welcome-copy">
          <span className="welcome-eyebrow">NIVETHA CATERING SERVICE</span>
          <h1>Welcome back, Anna! 👋</h1>
          <p>
            Here's your business overview. Manage bookings and keep every
            event running smoothly.
          </p>

          <div className="welcome-actions">
            <Link to="/bookings" className="dashboard-primary-btn">
              <span>＋</span> View Bookings
            </Link>
            <Link to="/food-menu" className="dashboard-outline-btn">
              Manage Food Menu <span>↗</span>
            </Link>
          </div>
        </div>

        <div className="welcome-decoration" aria-hidden="true">
          <div className="decoration-circle circle-one" />
          <div className="decoration-circle circle-two" />
          <div className="welcome-emblem">N</div>
          <span className="emblem-star">✦</span>
        </div>
      </section>

      <section className="dashboard-section">
        <div className="dashboard-section-heading">
          <div>
            <span className="section-eyebrow">AT A GLANCE</span>
            <h2>Business Overview</h2>
            <p>Your catering business at a glance.</p>
          </div>
          <Link to="/reports" className="dashboard-text-link">
            View Reports <span>→</span>
          </Link>
        </div>

        {error && (
          <div className="dashboard-error" role="alert">
            <span>!</span>
            <div>
              <strong>Could not load dashboard data</strong>
              <p>{error}</p>
            </div>
          </div>
        )}

        <div className="dashboard-stats-grid">
          {stats.map((stat, index) => (
            <article
              className={`dashboard-stat-card ${stat.className}`}
              key={stat.label}
              style={{ animationDelay: `${index * 90}ms` }}
            >
              <div className="stat-card-top">
                <span className="stat-label">{stat.label}</span>
                <span className="stat-icon" aria-hidden="true">
                  {stat.icon}
                </span>
              </div>

              <div className="stat-value">
                {loading ? <span className="stat-skeleton" /> : stat.value}
              </div>

              <p className="stat-detail">{stat.detail}</p>
              <div className="stat-bottom-line" />
            </article>
          ))}
        </div>
      </section>

      <section className="dashboard-section recent-bookings-section">
        <div className="dashboard-section-heading">
          <div>
            <span className="section-eyebrow">LATEST ACTIVITY</span>
            <h2>Recent Bookings</h2>
            <p>Keep track of your latest customer requests.</p>
          </div>
          <Link to="/bookings" className="dashboard-text-link">
            All Bookings <span>→</span>
          </Link>
        </div>

        <div className="recent-bookings-card">
          <div className="recent-bookings-header">
            <div>
              <h3>Booking Requests</h3>
              <p>Your five most recent bookings</p>
            </div>
            <span className="booking-count">
              {loading ? "Loading..." : `${bookings.length} total`}
            </span>
          </div>

          {loading ? (
            <div className="dashboard-loading" aria-live="polite">
              <span className="loading-spinner" />
              <p>Loading your bookings...</p>
            </div>
          ) : recentBookings.length === 0 ? (
            <div className="dashboard-empty">
              <div className="empty-icon">▦</div>
              <h3>No bookings yet</h3>
              <p>New customer bookings will appear here.</p>
              <Link to="/bookings" className="dashboard-primary-btn">
                Open Bookings
              </Link>
            </div>
          ) : (
            <div className="bookings-table-wrap">
              <table className="dashboard-bookings-table">
                <thead>
                  <tr>
                    <th>Booking</th>
                    <th>Customer</th>
                    <th>Event</th>
                    <th>Event Date</th>
                    <th>Status</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  {recentBookings.map((booking, index) => {
                    const id = getBookingId(booking);
                    const status = getStatus(booking);

                    return (
                      <tr
                        key={id || `booking-${index}`}
                        style={{ animationDelay: `${index * 70}ms` }}
                      >
                        <td>
                          <span className="booking-reference">
                            {booking.bookingId ||
                              (id ? `#${id.slice(-6).toUpperCase()}` : "—")}
                          </span>
                        </td>
                        <td>
                          <div className="booking-customer">
                            <span className="customer-avatar">
                              {getCustomerName(booking)
                                .charAt(0)
                                .toUpperCase()}
                            </span>
                            <span>{getCustomerName(booking)}</span>
                          </div>
                        </td>
                        <td>{getEventName(booking)}</td>
                        <td>
                          {formatDate(
                            booking.eventDate ||
                              booking.functionDate ||
                              booking.event?.date
                          )}
                        </td>
                        <td>
                          <span
                            className={`booking-status status-${status.replace(
                              /[^a-z0-9-]/g,
                              ""
                            )}`}
                          >
                            {status.charAt(0).toUpperCase() + status.slice(1)}
                          </span>
                        </td>
                        <td>
                          {id ? (
                            <Link
                              className="booking-view-link"
                              to={`/bookings/${id}`}
                              aria-label={`View booking for ${getCustomerName(
                                booking
                              )}`}
                            >
                              View <span>↗</span>
                            </Link>
                          ) : (
                            <span className="booking-no-link">—</span>
                          )}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </section>

      <footer className="dashboard-footer">
        <span>✦</span> Made with care for <strong>Nivetha Catering Service</strong>
      </footer>
    </main>
  );
}

export default Dashboard;