
import { useCallback, useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import {
  CalendarDays,
  CheckCircle2,
  Clock3,
  ClipboardList,
  UtensilsCrossed,
  ArrowUpRight,
  RefreshCw,
  AlertCircle,
  CalendarCheck,
  Sparkles,
  TrendingUp,
  Users,
} from "lucide-react";
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

const getBookingId = (booking) =>
  String(booking?._id || booking?.id || booking?.bookingId || "");

const getCustomerName = (booking) =>
  booking?.customerName ||
  booking?.customer_name ||
  booking?.customer?.name ||
  booking?.customer?.fullName ||
  booking?.name ||
  "Customer";

const getEventName = (booking) =>
  booking?.eventType ||
  booking?.event_type ||
  booking?.functionType ||
  booking?.eventName ||
  booking?.event?.type ||
  "Catering Event";

const getStatus = (booking) =>
  String(booking?.status || "pending").trim().toLowerCase();

const getEventDate = (booking) =>
  booking?.eventDate ||
  booking?.event_date ||
  booking?.functionDate ||
  booking?.event?.date ||
  booking?.bookingDate ||
  null;

const getCreatedDate = (booking) =>
  booking?.createdAt ||
  booking?.created_at ||
  booking?.createdDate ||
  getEventDate(booking);

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

const formatCurrency = (value) => {
  const amount = Number(value);

  if (!Number.isFinite(amount)) return "—";

  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(amount);
};

const getErrorMessage = (error) => {
  const detail = error?.response?.data?.detail;

  if (typeof detail === "string") return detail;

  if (Array.isArray(detail)) {
    return detail.map((item) => item.msg || "Invalid data").join(", ");
  }

  return (
    error?.response?.data?.message ||
    error?.response?.data?.error ||
    error?.message ||
    "Unable to load dashboard data."
  );
};

const getStatusLabel = (status) => {
  const labels = {
    pending: "Pending",
    confirmed: "Confirmed",
    completed: "Completed",
    cancelled: "Cancelled",
    rejected: "Rejected",
  };

  return labels[status] || status.charAt(0).toUpperCase() + status.slice(1);
};

export default function Dashboard() {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState("");

  const loadBookings = useCallback(async (isRefresh = false) => {
    try {
      if (isRefresh) {
        setRefreshing(true);
      } else {
        setLoading(true);
      }

      setError("");

      const response = await api.get("/bookings");

      setBookings(getBookingList(response));
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

  const stats = useMemo(() => {
    const countByStatus = (status) =>
      bookings.filter((booking) => getStatus(booking) === status).length;

    return [
      {
        label: "Total Bookings",
        value: bookings.length,
        description: "All customer requests",
        icon: ClipboardList,
        theme: "violet",
      },
      {
        label: "Pending Requests",
        value: countByStatus("pending"),
        description: "Awaiting your response",
        icon: Clock3,
        theme: "orange",
      },
      {
        label: "Confirmed Events",
        value: countByStatus("confirmed"),
        description: "Ready for planning",
        icon: CalendarCheck,
        theme: "cyan",
      },
      {
        label: "Completed Events",
        value: countByStatus("completed"),
        description: "Successfully completed",
        icon: CheckCircle2,
        theme: "green",
      },
    ];
  }, [bookings]);

  const recentBookings = useMemo(() => {
    return [...bookings]
      .sort((a, b) => {
        const dateA = new Date(getCreatedDate(a) || 0).getTime();
        const dateB = new Date(getCreatedDate(b) || 0).getTime();

        return (
          (Number.isNaN(dateB) ? 0 : dateB) -
          (Number.isNaN(dateA) ? 0 : dateA)
        );
      })
      .slice(0, 5);
  }, [bookings]);

  const pendingCount = stats[1].value;
  const confirmedCount = stats[2].value;

  return (
    <main className="dashboard-page">
      <section className="dashboard-hero">
        <div className="dashboard-hero-content">
          <div className="dashboard-eyebrow">
            <Sparkles size={15} />
            NIVETHA CATERING SERVICE
          </div>

          <h1>
            Welcome back,
            <span> Owner!</span>
          </h1>

          <p>
            Your business at a glance. Manage bookings, monitor events and keep
            your catering operations running smoothly.
          </p>

          <div className="dashboard-hero-actions">
            <Link to="/bookings" className="dashboard-btn dashboard-btn-primary">
              <CalendarDays size={17} />
              Manage Bookings
              <ArrowUpRight size={16} />
            </Link>

            <Link to="/food-menu" className="dashboard-btn dashboard-btn-glass">
              <UtensilsCrossed size={17} />
              Food Menu
            </Link>
          </div>

          <div className="dashboard-hero-meta">
            <span>
              <span className="dashboard-live-dot" />
              Dashboard overview
            </span>
            <span>
              <Users size={15} />
              {loading ? "Loading customers..." : `${bookings.length} bookings`}
            </span>
          </div>
        </div>

        <div className="dashboard-hero-art" aria-hidden="true">
          <div className="hero-orbit hero-orbit-one" />
          <div className="hero-orbit hero-orbit-two" />
          <div className="hero-glow" />
          <div className="hero-emblem">
            <span>N</span>
            <small>EST.</small>
          </div>
          <div className="hero-floating-card hero-floating-top">
            <Sparkles size={17} />
            <span>Premium Service</span>
          </div>
          <div className="hero-floating-card hero-floating-bottom">
            <TrendingUp size={18} />
            <div>
              <strong>{loading ? "—" : confirmedCount}</strong>
              <small>Confirmed events</small>
            </div>
          </div>
        </div>
      </section>

      <section className="dashboard-content-section">
        <div className="dashboard-section-title">
          <div>
            <span className="dashboard-section-label">BUSINESS ANALYTICS</span>
            <h2>Business Overview</h2>
            <p>Track your catering business performance.</p>
          </div>

          <button
            type="button"
            className="dashboard-refresh-btn"
            onClick={() => loadBookings(true)}
            disabled={loading || refreshing}
          >
            <RefreshCw
              size={16}
              className={refreshing ? "dashboard-spinning" : ""}
            />
            {refreshing ? "Refreshing..." : "Refresh"}
          </button>
        </div>

        {error && (
          <div className="dashboard-error" role="alert">
            <AlertCircle size={20} />
            <div>
              <strong>Unable to load dashboard</strong>
              <p>{error}</p>
            </div>
            <button type="button" onClick={() => loadBookings()}>
              Retry
            </button>
          </div>
        )}

        <div className="dashboard-stats-grid">
          {stats.map((stat, index) => {
            const Icon = stat.icon;

            return (
              <article
                className={`dashboard-stat-card stat-${stat.theme}`}
                key={stat.label}
                style={{ animationDelay: `${index * 80}ms` }}
              >
                <div className="dashboard-stat-top">
                  <div className="dashboard-stat-icon">
                    <Icon size={22} strokeWidth={1.9} />
                  </div>
                  <span className="dashboard-stat-indicator">
                    <span />
                    Live
                  </span>
                </div>

                <p className="dashboard-stat-label">{stat.label}</p>

                <div className="dashboard-stat-value">
                  {loading ? (
                    <span className="dashboard-skeleton" />
                  ) : (
                    stat.value.toLocaleString("en-IN")
                  )}
                </div>

                <p className="dashboard-stat-description">
                  {stat.description}
                </p>

                <div className="dashboard-stat-bottom-line" />
              </article>
            );
          })}
        </div>
      </section>

      <section className="dashboard-quick-grid">
        <Link to="/bookings" className="dashboard-quick-card quick-pending">
          <div className="dashboard-quick-icon">
            <Clock3 size={21} />
          </div>
          <div>
            <span>Needs attention</span>
            <strong>{loading ? "—" : pendingCount}</strong>
            <p>Pending requests</p>
          </div>
          <ArrowUpRight size={18} className="dashboard-quick-arrow" />
        </Link>

        <Link to="/bookings" className="dashboard-quick-card quick-confirmed">
          <div className="dashboard-quick-icon">
            <CalendarCheck size={21} />
          </div>
          <div>
            <span>Event planning</span>
            <strong>{loading ? "—" : confirmedCount}</strong>
            <p>Confirmed events</p>
          </div>
          <ArrowUpRight size={18} className="dashboard-quick-arrow" />
        </Link>
      </section>

      <section className="dashboard-content-section recent-section">
        <div className="dashboard-section-title">
          <div>
            <span className="dashboard-section-label">LATEST ACTIVITY</span>
            <h2>Recent Bookings</h2>
            <p>Your five most recent customer requests.</p>
          </div>

          <Link to="/bookings" className="dashboard-view-all">
            View all bookings
            <ArrowUpRight size={16} />
          </Link>
        </div>

        <div className="dashboard-recent-card">
          <div className="dashboard-recent-header">
            <div>
              <h3>Booking Requests</h3>
              <p>Latest activity from your customers</p>
            </div>

            <span className="dashboard-total-badge">
              {loading ? "Loading..." : `${bookings.length} total`}
            </span>
          </div>

          {loading ? (
            <div className="dashboard-loading">
              <span className="dashboard-spinner" />
              <p>Loading your bookings...</p>
            </div>
          ) : recentBookings.length === 0 ? (
            <div className="dashboard-empty">
              <div className="dashboard-empty-icon">
                <CalendarDays size={30} />
              </div>
              <h3>No bookings yet</h3>
              <p>
                Customer booking requests will appear here once they start
                placing orders.
              </p>
              <Link to="/bookings" className="dashboard-btn dashboard-btn-primary">
                Open Bookings
                <ArrowUpRight size={16} />
              </Link>
            </div>
          ) : (
            <div className="dashboard-table-wrap">
              <table className="dashboard-table">
                <thead>
                  <tr>
                    <th>BOOKING ID</th>
                    <th>CUSTOMER</th>
                    <th>EVENT</th>
                    <th>EVENT DATE</th>
                    <th>STATUS</th>
                    <th>ACTION</th>
                  </tr>
                </thead>

                <tbody>
                  {recentBookings.map((booking, index) => {
                    const id = getBookingId(booking);
                    const customerName = getCustomerName(booking);
                    const status = getStatus(booking);
                    const safeStatus = status.replace(/[^a-z0-9-]/g, "");

                    return (
                      <tr key={id || `booking-${index}`}>
                        <td>
                          <span className="dashboard-booking-id">
                            {booking.bookingId ||
                              (id ? `#${id.slice(-6).toUpperCase()}` : "—")}
                          </span>
                        </td>

                        <td>
                          <div className="dashboard-customer">
                            <span className="dashboard-avatar">
                              {customerName.charAt(0).toUpperCase()}
                            </span>
                            <span>{customerName}</span>
                          </div>
                        </td>

                        <td>
                          <span className="dashboard-event-name">
                            {getEventName(booking)}
                          </span>
                        </td>

                        <td>{formatDate(getEventDate(booking))}</td>

                        <td>
                          <span
                            className={`dashboard-status status-${safeStatus}`}
                          >
                            <span />
                            {getStatusLabel(status)}
                          </span>
                        </td>

                        <td>
                          {id ? (
                            <Link
                              to={`/bookings/${encodeURIComponent(id)}`}
                              className="dashboard-table-action"
                              aria-label={`View booking for ${customerName}`}
                            >
                              View
                              <ArrowUpRight size={15} />
                            </Link>
                          ) : (
                            <span className="dashboard-no-action">—</span>
                          )}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}

          {!loading && recentBookings.length > 0 && (
            <div className="dashboard-recent-footer">
              <span>
                Showing {recentBookings.length} of {bookings.length} bookings
              </span>
              <Link to="/bookings">
                Explore all bookings
                <ArrowUpRight size={15} />
              </Link>
            </div>
          )}
        </div>
      </section>

      <footer className="dashboard-footer">
        <span className="dashboard-footer-star">✦</span>
        Crafted with care for
        <strong>Nivetha Catering Service</strong>
      </footer>
    </main>
  );
}
