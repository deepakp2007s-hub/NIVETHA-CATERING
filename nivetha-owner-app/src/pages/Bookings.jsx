
import { useCallback, useEffect, useMemo, useState } from "react";
import { Link, useLocation } from "react-router-dom";
import {
  CalendarDays,
  Search,
  RefreshCw,
  Eye,
  Users,
  Clock3,
  CheckCircle2,
  XCircle,
  AlertCircle,
  ClipboardList,
  Trash2,
  Filter,
  Phone,
  ArrowUpRight,
  Sparkles,
  CalendarCheck,
  Check,
  X,
} from "lucide-react";
import api from "../services/api";
import "./Bookings.css";

const STATUS_OPTIONS = [
  "all",
  "pending",
  "confirmed",
  "rejected",
  "completed",
  "cancelled",
];

const getValue = (...values) =>
  values.find((value) => value !== undefined && value !== null && value !== "");

const getBookingId = (booking) =>
  String(booking?._id || booking?.id || "");

const getStatus = (booking) =>
  String(booking?.status || "pending").trim().toLowerCase();

const getCustomerName = (booking) =>
  getValue(
    booking?.customer_name,
    booking?.customerName,
    booking?.customer?.name,
    booking?.name,
    "Customer"
  );

const getCustomerPhone = (booking) =>
  getValue(
    booking?.customer_phone,
    booking?.customerPhone,
    booking?.customer?.phone,
    booking?.phone,
    "Not provided"
  );

const getEventType = (booking) =>
  getValue(
    booking?.function_type,
    booking?.event_type,
    booking?.eventType,
    booking?.functionType,
    "Function"
  );

const getEventDate = (booking) =>
  getValue(
    booking?.event_date,
    booking?.function_date,
    booking?.eventDate,
    booking?.functionDate,
    booking?.date,
    null
  );

const getPersons = (booking) =>
  getValue(
    booking?.persons_count,
    booking?.number_of_persons,
    booking?.numberOfPersons,
    booking?.persons,
    booking?.guest_count,
    booking?.guestCount,
    0
  );

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

const normalizeDate = (value) => {
  if (!value) return "";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) return "";

  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");

  return `${year}-${month}-${day}`;
};

const getBookingList = (response) => {
  const data = response?.data;

  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.bookings)) return data.bookings;
  if (Array.isArray(data?.data)) return data.data;
  if (Array.isArray(data?.data?.bookings)) return data.data.bookings;

  return [];
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
    "Unable to complete the request. Please try again."
  );
};

const getStatusLabel = (status) => {
  const labels = {
    pending: "Pending",
    confirmed: "Confirmed",
    rejected: "Rejected",
    completed: "Completed",
    cancelled: "Cancelled",
  };

  return labels[status] || status.charAt(0).toUpperCase() + status.slice(1);
};

export default function Bookings() {
  const location = useLocation();

  const [bookings, setBookings] = useState([]);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [dateFilter, setDateFilter] = useState("");
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [deletingId, setDeletingId] = useState("");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(
    location.state?.successMessage || ""
  );
  const [deleteTarget, setDeleteTarget] = useState(null);

  const fetchBookings = useCallback(async (isRefresh = false) => {
    try {
      if (isRefresh) {
        setRefreshing(true);
      } else {
        setLoading(true);
      }

      setError("");

      const response = await api.get("/bookings/");
      const result = getBookingList(response);

      setBookings(
        result.filter((booking) => getStatus(booking) !== "deleted")
      );
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    fetchBookings();
  }, [fetchBookings]);

  const handleDelete = async () => {
    if (!deleteTarget || deletingId) return;

    const bookingId = getBookingId(deleteTarget);

    if (!/^[a-fA-F0-9]{24}$/.test(bookingId)) {
      setError("Invalid booking ID.");
      setDeleteTarget(null);
      return;
    }

    setDeletingId(bookingId);
    setError("");
    setSuccess("");

    try {
      await api.delete(
        `/bookings/owner/${encodeURIComponent(bookingId)}`
      );

      setBookings((previous) =>
        previous.filter((item) => getBookingId(item) !== bookingId)
      );

      setSuccess("Booking deleted successfully.");
      setDeleteTarget(null);
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setDeletingId("");
    }
  };

  const filteredBookings = useMemo(() => {
    const query = search.trim().toLowerCase();

    return bookings.filter((booking) => {
      const bookingId = getBookingId(booking);
      const customerName = String(getCustomerName(booking));
      const phone = String(getCustomerPhone(booking));
      const eventType = String(getEventType(booking));
      const status = getStatus(booking);

      const matchesSearch =
        !query ||
        bookingId.toLowerCase().includes(query) ||
        String(booking.bookingId || "").toLowerCase().includes(query) ||
        customerName.toLowerCase().includes(query) ||
        phone.toLowerCase().includes(query) ||
        eventType.toLowerCase().includes(query);

      const matchesStatus =
        statusFilter === "all" || status === statusFilter;

      const matchesDate =
        !dateFilter || normalizeDate(getEventDate(booking)) === dateFilter;

      return matchesSearch && matchesStatus && matchesDate;
    });
  }, [bookings, search, statusFilter, dateFilter]);

  const stats = useMemo(() => ({
    total: bookings.length,
    pending: bookings.filter(
      (item) => getStatus(item) === "pending"
    ).length,
    confirmed: bookings.filter(
      (item) => getStatus(item) === "confirmed"
    ).length,
    completed: bookings.filter(
      (item) => getStatus(item) === "completed"
    ).length,
  }), [bookings]);

  const clearFilters = () => {
    setSearch("");
    setStatusFilter("all");
    setDateFilter("");
  };

  const hasFilters = Boolean(
    search || statusFilter !== "all" || dateFilter
  );

  return (
    <main className="bookings-page">
      <section className="bookings-hero">
        <div className="bookings-hero-content">
          <span className="bookings-eyebrow">
            <Sparkles size={15} />
            NIVETHA CATERING SERVICE
          </span>

          <h1>
            Booking <span>Management</span>
          </h1>

          <p>
            Manage customer bookings, event schedules and reservations
            from one place.
          </p>

          <div className="bookings-hero-meta">
            <span>
              <span className="bookings-live-dot" />
              Live booking management
            </span>
            <span>
              <ClipboardList size={15} />
              {loading ? "Loading..." : `${stats.total} total bookings`}
            </span>
          </div>
        </div>

        <div className="bookings-hero-art" aria-hidden="true">
          <div className="bookings-orbit orbit-one" />
          <div className="bookings-orbit orbit-two" />
          <div className="bookings-hero-emblem">
            <CalendarCheck size={54} />
          </div>
          <span className="bookings-floating-star">✦</span>
        </div>
      </section>

      <section className="bookings-stats">
        <article className="booking-stat-card stat-total">
          <div className="booking-stat-top">
            <div className="booking-stat-icon">
              <ClipboardList size={22} />
            </div>
            <span>Overview</span>
          </div>
          <p>Total Bookings</p>
          <h3>{loading ? "—" : stats.total.toLocaleString("en-IN")}</h3>
          <small>All customer requests</small>
        </article>

        <article className="booking-stat-card stat-pending">
          <div className="booking-stat-top">
            <div className="booking-stat-icon">
              <Clock3 size={22} />
            </div>
            <span>Attention</span>
          </div>
          <p>Pending Requests</p>
          <h3>{loading ? "—" : stats.pending.toLocaleString("en-IN")}</h3>
          <small>Awaiting your response</small>
        </article>

        <article className="booking-stat-card stat-confirmed">
          <div className="booking-stat-top">
            <div className="booking-stat-icon">
              <CheckCircle2 size={22} />
            </div>
            <span>Scheduled</span>
          </div>
          <p>Confirmed Events</p>
          <h3>{loading ? "—" : stats.confirmed.toLocaleString("en-IN")}</h3>
          <small>Ready for planning</small>
        </article>

        <article className="booking-stat-card stat-completed">
          <div className="booking-stat-top">
            <div className="booking-stat-icon">
              <CalendarCheck size={22} />
            </div>
            <span>Finished</span>
          </div>
          <p>Completed Events</p>
          <h3>{loading ? "—" : stats.completed.toLocaleString("en-IN")}</h3>
          <small>Successfully completed</small>
        </article>
      </section>

      {error && (
        <div className="bookings-alert bookings-alert-error" role="alert">
          <AlertCircle size={19} />
          <span>{error}</span>
          <button
            type="button"
            onClick={() => setError("")}
            aria-label="Dismiss error"
          >
            <X size={17} />
          </button>
        </div>
      )}

      {success && (
        <div className="bookings-alert bookings-alert-success" role="status">
          <CheckCircle2 size={19} />
          <span>{success}</span>
          <button
            type="button"
            onClick={() => setSuccess("")}
            aria-label="Dismiss success"
          >
            <X size={17} />
          </button>
        </div>
      )}

      <section className="bookings-content">
        <div className="bookings-section-heading">
          <div>
            <span className="bookings-section-label">CUSTOMER ACTIVITY</span>
            <h2>All Bookings</h2>
            <p>Search, filter and manage customer reservations.</p>
          </div>

          <button
            type="button"
            className="bookings-refresh-btn"
            onClick={() => fetchBookings(true)}
            disabled={loading || refreshing || Boolean(deletingId)}
          >
            <RefreshCw
              size={16}
              className={refreshing ? "bookings-spin" : ""}
            />
            {refreshing ? "Refreshing..." : "Refresh"}
          </button>
        </div>

        <div className="bookings-filter-panel">
          <div className="bookings-search">
            <Search size={18} />
            <input
              type="search"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Search booking ID, customer, phone..."
              aria-label="Search bookings"
            />

            {search && (
              <button
                type="button"
                onClick={() => setSearch("")}
                aria-label="Clear search"
              >
                <X size={16} />
              </button>
            )}
          </div>

          <label className="bookings-filter-control">
            <Filter size={17} />
            <select
              value={statusFilter}
              onChange={(event) => setStatusFilter(event.target.value)}
              aria-label="Filter booking status"
            >
              {STATUS_OPTIONS.map((status) => (
                <option key={status} value={status}>
                  {status === "all"
                    ? "All Statuses"
                    : status.charAt(0).toUpperCase() + status.slice(1)}
                </option>
              ))}
            </select>
          </label>

          <label className="bookings-date-filter">
            <CalendarDays size={17} />
            <input
              type="date"
              value={dateFilter}
              onChange={(event) => setDateFilter(event.target.value)}
              aria-label="Filter by event date"
            />
          </label>

          {hasFilters && (
            <button
              type="button"
              className="bookings-clear-filter"
              onClick={clearFilters}
            >
              Clear Filters
            </button>
          )}

          <span className="bookings-result-count">
            {loading ? "Loading..." : `${filteredBookings.length} booking(s)`}
          </span>
        </div>

        <div className="bookings-table-card">
          <div className="bookings-table-heading">
            <div>
              <h3>Booking Requests</h3>
              <p>Customer reservations and event details</p>
            </div>
            <span className="bookings-table-count">
              {loading ? "..." : `${filteredBookings.length} results`}
            </span>
          </div>

          <div className="bookings-table-wrapper">
            <table className="bookings-table">
              <thead>
                <tr>
                  <th>BOOKING ID</th>
                  <th>CUSTOMER</th>
                  <th>EVENT</th>
                  <th>EVENT DATE</th>
                  <th>PERSONS</th>
                  <th>STATUS</th>
                  <th>ACTIONS</th>
                </tr>
              </thead>

              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={7} className="bookings-table-message">
                      <div className="bookings-loading">
                        <span className="bookings-spinner" />
                        Loading bookings...
                      </div>
                    </td>
                  </tr>
                ) : filteredBookings.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="bookings-table-message">
                      <div className="bookings-empty">
                        <div className="bookings-empty-icon">
                          {error ? (
                            <AlertCircle size={30} />
                          ) : (
                            <ClipboardList size={30} />
                          )}
                        </div>

                        <strong>
                          {error
                            ? "Bookings could not be loaded"
                            : hasFilters
                              ? "No matching bookings"
                              : "No bookings found"}
                        </strong>

                        <span>
                          {error
                            ? "Check your API connection and try again."
                            : hasFilters
                              ? "Try changing your search or filters."
                              : "Customer bookings will appear here."}
                        </span>

                        {error ? (
                          <button
                            type="button"
                            onClick={() => fetchBookings()}
                          >
                            Try Again
                          </button>
                        ) : hasFilters ? (
                          <button type="button" onClick={clearFilters}>
                            Clear Filters
                          </button>
                        ) : null}
                      </div>
                    </td>
                  </tr>
                ) : (
                  filteredBookings.map((booking) => {
                    const id = getBookingId(booking);
                    const status = getStatus(booking);
                    const safeStatus = status.replace(/[^a-z0-9-]/g, "");
                    const customerName = String(getCustomerName(booking));
                    const phone = String(getCustomerPhone(booking));
                    const eventType = String(getEventType(booking));
                    const isDeleting = deletingId === id;

                    return (
                      <tr key={id || `${customerName}-${eventType}`}>
                        <td>
                          <span className="booking-id-cell">
                            #{id ? id.slice(-8).toUpperCase() : "N/A"}
                          </span>
                        </td>

                        <td>
                          <div className="booking-customer-cell">
                            <span className="booking-customer-avatar">
                              {customerName.charAt(0).toUpperCase()}
                            </span>
                            <div>
                              <strong>{customerName}</strong>
                              <span className="booking-phone">
                                <Phone size={12} />
                                {phone}
                              </span>
                            </div>
                          </div>
                        </td>

                        <td>
                          <span className="booking-event-name">
                            {eventType}
                          </span>
                        </td>

                        <td>
                          <span className="booking-date-cell">
                            <CalendarDays size={15} />
                            {formatDate(getEventDate(booking))}
                          </span>
                        </td>

                        <td>
                          <span className="booking-persons-cell">
                            <Users size={15} />
                            {getPersons(booking)}
                          </span>
                        </td>

                        <td>
                          <span className={`booking-status-badge status-${safeStatus}`}>
                            <span />
                            {getStatusLabel(status)}
                          </span>
                        </td>

                        <td>
                          <div className="booking-actions">
                            {id && (
                              <Link
                                to={`/bookings/${encodeURIComponent(id)}`}
                                className="booking-view-btn"
                                aria-label={`View booking for ${customerName}`}
                                title="View booking"
                              >
                                <Eye size={16} />
                              </Link>
                            )}

                            <button
                              type="button"
                              className="booking-delete-btn"
                              onClick={() => setDeleteTarget(booking)}
                              disabled={Boolean(deletingId)}
                              aria-label={`Delete booking for ${customerName}`}
                              title="Soft delete booking"
                            >
                              {isDeleting ? (
                                <RefreshCw size={16} className="bookings-spin" />
                              ) : (
                                <Trash2 size={16} />
                              )}
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>

          <div className="bookings-table-footer">
            <span>
              Showing {loading ? "—" : filteredBookings.length} of{" "}
              {bookings.length} active bookings
            </span>
            <Link to="/dashboard">
              Back to Dashboard
              <ArrowUpRight size={15} />
            </Link>
          </div>
        </div>
      </section>

      {deleteTarget && (
        <div
          className="booking-modal-overlay"
          role="presentation"
          onMouseDown={(event) => {
            if (event.target === event.currentTarget && !deletingId) {
              setDeleteTarget(null);
            }
          }}
        >
          <section
            className="booking-confirm-modal"
            role="dialog"
            aria-modal="true"
            aria-labelledby="booking-delete-title"
          >
            <div className="booking-modal-icon">
              <Trash2 size={25} />
            </div>

            <button
              type="button"
              className="booking-modal-close"
              onClick={() => setDeleteTarget(null)}
              disabled={Boolean(deletingId)}
              aria-label="Close confirmation"
            >
              <X size={18} />
            </button>

            <h3 id="booking-delete-title">Delete this booking?</h3>
            <p>
              Booking for{" "}
              <strong>{getCustomerName(deleteTarget)}</strong> will be marked
              as deleted and hidden from the active bookings list. It will
              not be permanently removed from the database.
            </p>

            <div className="booking-modal-actions">
              <button
                type="button"
                className="booking-modal-cancel"
                onClick={() => setDeleteTarget(null)}
                disabled={Boolean(deletingId)}
              >
                Cancel
              </button>

              <button
                type="button"
                className="booking-modal-delete"
                onClick={handleDelete}
                disabled={Boolean(deletingId)}
              >
                {deletingId ? (
                  <>
                    <RefreshCw size={15} className="bookings-spin" />
                    Deleting...
                  </>
                ) : (
                  <>
                    <Trash2 size={15} />
                    Delete Booking
                  </>
                )}
              </button>
            </div>
          </section>
        </div>
      )}
    </main>
  );
}
