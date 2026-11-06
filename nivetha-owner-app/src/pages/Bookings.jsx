
import { useCallback, useEffect, useMemo, useState } from "react";
import { Link, useLocation } from "react-router-dom";
import {
  CalendarDays,
  Search,
  RefreshCw,
  Eye,
  Users,
  Clock,
  CheckCircle2,
  XCircle,
  AlertCircle,
  ClipboardList,
  Trash2,
  Filter,
  Phone,
} from "lucide-react";
import api from "../services/api";
import "./Bookings.css";

const getBookingId = (booking) =>
  String(booking?._id || booking?.id || "");

const getValue = (...values) =>
  values.find((value) => value !== undefined && value !== null && value !== "");

const getStatus = (booking) =>
  String(booking?.status || "pending").toLowerCase();

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
    ""
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

const getBookingList = (response) => {
  const data = response?.data;

  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.bookings)) return data.bookings;
  if (Array.isArray(data?.data)) return data.data;
  if (Array.isArray(data?.data?.bookings)) return data.data.bookings;

  return [];
};

const getErrorMessage = (error) =>
  error?.response?.data?.detail ||
  error?.response?.data?.message ||
  error?.message ||
  "Unable to complete the request. Please try again.";

const STATUS_OPTIONS = [
  "all",
  "pending",
  "confirmed",
  "rejected",
  "completed",
  "cancelled",
];

const getStatusLabel = (status) =>
  status.charAt(0).toUpperCase() + status.slice(1);

export default function Bookings() {
  const location = useLocation();

  const [bookings, setBookings] = useState([]);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [dateFilter, setDateFilter] = useState("");
  const [loading, setLoading] = useState(true);
  const [deletingId, setDeletingId] = useState("");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(
    location.state?.successMessage || ""
  );

  const fetchBookings = useCallback(async () => {
    setLoading(true);
    setError("");

    try {
      const response = await api.get("/bookings/");
      const result = getBookingList(response);

      setBookings(
        result.filter((booking) => getStatus(booking) !== "deleted")
      );
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchBookings();
  }, [fetchBookings]);

  const handleDelete = async (booking) => {
    const bookingId = getBookingId(booking);

    if (!/^[a-fA-F0-9]{24}$/.test(bookingId)) {
      setError("Invalid booking ID.");
      return;
    }

    if (deletingId) return;

    const confirmed = window.confirm(
      `Are you sure you want to delete booking #${bookingId.slice(-8)}?\n\nThis booking will be marked as deleted and hidden from the active bookings list. It will not be permanently removed from the database.`
    );

    if (!confirmed) return;

    setDeletingId(bookingId);
    setError("");
    setSuccess("");

    try {
      await api.delete(
        `/bookings/owner/${encodeURIComponent(bookingId)}`
      );

      setBookings((previous) =>
        previous.filter(
          (item) => getBookingId(item) !== bookingId
        )
      );

      setSuccess("Booking deleted successfully.");
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
      const customerName = getCustomerName(booking);
      const phone = getCustomerPhone(booking);
      const eventType = getEventType(booking);
      const status = getStatus(booking);

      const matchesSearch =
        !query ||
        bookingId.toLowerCase().includes(query) ||
        String(customerName).toLowerCase().includes(query) ||
        String(phone).toLowerCase().includes(query) ||
        String(eventType).toLowerCase().includes(query);

      const matchesStatus =
        statusFilter === "all" || status === statusFilter;

      const eventDate = getEventDate(booking);
      const normalizedDate = eventDate
        ? new Date(eventDate).toISOString().slice(0, 10)
        : "";

      const matchesDate =
        !dateFilter || normalizedDate === dateFilter;

      return matchesSearch && matchesStatus && matchesDate;
    });
  }, [bookings, search, statusFilter, dateFilter]);

  const stats = useMemo(() => {
    const total = bookings.length;

    return {
      total,
      pending: bookings.filter(
        (item) => getStatus(item) === "pending"
      ).length,
      confirmed: bookings.filter(
        (item) => getStatus(item) === "confirmed"
      ).length,
      completed: bookings.filter(
        (item) => getStatus(item) === "completed"
      ).length,
    };
  }, [bookings]);

  return (
    <section className="bookings-page">
      <div className="bookings-hero">
        <div>
          <span className="bookings-eyebrow">
            NIVETHA CATERING SERVICE
          </span>
          <h1>Booking Management</h1>
          <p>
            Manage customer bookings, event schedules and booking status.
          </p>
        </div>

        <div className="bookings-hero-icon">
          <ClipboardList size={38} />
        </div>
      </div>

      <div className="bookings-stats">
        <article className="booking-stat-card">
          <div className="booking-stat-icon booking-stat-blue">
            <ClipboardList size={22} />
          </div>
          <div>
            <span>Total Bookings</span>
            <h3>{stats.total}</h3>
          </div>
        </article>

        <article className="booking-stat-card">
          <div className="booking-stat-icon booking-stat-orange">
            <Clock size={22} />
          </div>
          <div>
            <span>Pending</span>
            <h3>{stats.pending}</h3>
          </div>
        </article>

        <article className="booking-stat-card">
          <div className="booking-stat-icon booking-stat-green">
            <CheckCircle2 size={22} />
          </div>
          <div>
            <span>Confirmed</span>
            <h3>{stats.confirmed}</h3>
          </div>
        </article>

        <article className="booking-stat-card">
          <div className="booking-stat-icon booking-stat-purple">
            <Users size={22} />
          </div>
          <div>
            <span>Completed</span>
            <h3>{stats.completed}</h3>
          </div>
        </article>
      </div>

      {error && (
        <div className="bookings-alert error" role="alert">
          <XCircle size={18} />
          <span>{error}</span>
          <button
            type="button"
            onClick={() => setError("")}
            aria-label="Dismiss error"
          >
            ×
          </button>
        </div>
      )}

      {success && (
        <div className="bookings-alert success" role="status">
          <CheckCircle2 size={18} />
          <span>{success}</span>
          <button
            type="button"
            onClick={() => setSuccess("")}
            aria-label="Dismiss success"
          >
            ×
          </button>
        </div>
      )}

      <div className="bookings-toolbar">
        <div>
          <h2>All Bookings</h2>
          <p>Search, filter and manage customer bookings.</p>
        </div>

        <button
          type="button"
          className="bookings-refresh-btn"
          onClick={fetchBookings}
          disabled={loading || Boolean(deletingId)}
        >
          <RefreshCw size={17} />
          Refresh
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
              ×
            </button>
          )}
        </div>

        <div className="bookings-filter-control">
          <Filter size={17} />
          <select
            value={statusFilter}
            onChange={(event) => setStatusFilter(event.target.value)}
            aria-label="Filter booking status"
          >
            {STATUS_OPTIONS.map((status) => (
              <option key={status} value={status}>
                {status === "all" ? "All Statuses" : getStatusLabel(status)}
              </option>
            ))}
          </select>
        </div>

        <div className="bookings-date-filter">
          <CalendarDays size={17} />
          <input
            type="date"
            value={dateFilter}
            onChange={(event) => setDateFilter(event.target.value)}
            aria-label="Filter by event date"
          />
        </div>

        {(search || statusFilter !== "all" || dateFilter) && (
          <button
            type="button"
            className="bookings-clear-filter"
            onClick={() => {
              setSearch("");
              setStatusFilter("all");
              setDateFilter("");
            }}
          >
            Clear Filters
          </button>
        )}

        <span className="bookings-result-count">
          {filteredBookings.length} booking(s)
        </span>
      </div>

      <div className="bookings-table-card">
        <div className="bookings-table-wrapper">
          <table className="bookings-table">
            <thead>
              <tr>
                <th>Booking ID</th>
                <th>Customer</th>
                <th>Event</th>
                <th>Event Date</th>
                <th>Persons</th>
                <th>Status</th>
                <th>Actions</th>
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
                      {error ? (
                        <AlertCircle size={36} />
                      ) : (
                        <ClipboardList size={36} />
                      )}
                      <strong>
                        {error
                          ? "Bookings could not be loaded"
                          : search || statusFilter !== "all" || dateFilter
                            ? "No matching bookings"
                            : "No bookings found"}
                      </strong>
                      <span>
                        {error
                          ? "Check your API connection and try again."
                          : "Bookings will appear here when customers submit them."}
                      </span>
                      {error && (
                        <button type="button" onClick={fetchBookings}>
                          Try Again
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ) : (
                filteredBookings.map((booking) => {
                  const id = getBookingId(booking);
                  const status = getStatus(booking);
                  const customerName = getCustomerName(booking);
                  const phone = getCustomerPhone(booking);
                  const eventType = getEventType(booking);
                  const eventDate = getEventDate(booking);
                  const isDeleting = deletingId === id;

                  return (
                    <tr key={id}>
                      <td>
                        <span className="booking-id-cell">
                          #{id.slice(-8) || "N/A"}
                        </span>
                      </td>

                      <td>
                        <div className="booking-customer-cell">
                          <span className="booking-customer-avatar">
                            {String(customerName).charAt(0).toUpperCase()}
                          </span>
                          <div>
                            <strong>{customerName}</strong>
                            <span>
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
                          {formatDate(eventDate)}
                        </span>
                      </td>

                      <td>
                        <span className="booking-persons-cell">
                          <Users size={15} />
                          {getPersons(booking)}
                        </span>
                      </td>

                      <td>
                        <span className={`booking-status-badge status-${status}`}>
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
                              aria-label="View booking details"
                              title="View booking"
                            >
                              <Eye size={16} />
                            </Link>
                          )}

                          <button
                            type="button"
                            className="booking-delete-btn"
                            onClick={() => handleDelete(booking)}
                            disabled={Boolean(deletingId)}
                            aria-label="Delete booking"
                            title="Soft delete booking"
                          >
                            {isDeleting ? (
                              <RefreshCw
                                size={16}
                                className="booking-delete-spin"
                              />
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
            Showing {filteredBookings.length} of {bookings.length} active bookings
          </span>
        </div>
      </div>
    </section>
  );
}
