import { useCallback, useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import {
  Search,
  CalendarDays,
  Users,
  ClipboardList,
  Clock,
  CheckCircle2,
  RefreshCw,
  Eye,
  XCircle,
} from "lucide-react";
import api from "../services/api";
import "./Bookings.css";

const STATUSES = [
  "pending",
  "confirmed",
  "rejected",
  "cancelled",
  "completed",
];

const getBookingList = (response) => {
  const data = response?.data;

  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.bookings)) return data.bookings;
  if (Array.isArray(data?.data)) return data.data;
  if (Array.isArray(data?.data?.bookings)) return data.data.bookings;

  return [];
};

const getBookingId = (booking) =>
  String(booking?._id || booking?.id || "");

const getStatus = (booking) =>
  String(booking?.status || "pending").toLowerCase();

const getCustomerName = (booking) =>
  booking?.customer?.name ||
  booking?.customerName ||
  booking?.name ||
  "Customer";

const getEventName = (booking) =>
  booking?.eventType ||
  booking?.functionType ||
  booking?.eventName ||
  booking?.customerType ||
  "Function";

const getEventDate = (booking) =>
  booking?.eventDate ||
  booking?.functionDate ||
  booking?.date ||
  "";

const getPersons = (booking) =>
  booking?.numberOfPersons ??
  booking?.persons ??
  booking?.guestCount ??
  0;

const getReference = (booking) =>
  booking?.bookingId ||
  booking?.referenceId ||
  getBookingId(booking);

const formatDate = (value) => {
  if (!value) return "Not specified";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) return "Not specified";

  return date.toLocaleDateString("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
};

const isValidBookingId = (id) =>
  /^[a-fA-F0-9]{24}$/.test(id);

const getErrorMessage = (error) =>
  error?.response?.data?.message ||
  "Something went wrong. Please try again.";

export default function Bookings() {
  const [bookings, setBookings] = useState([]);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [dateFilter, setDateFilter] = useState("");
  const [loading, setLoading] = useState(true);
  const [updatingId, setUpdatingId] = useState("");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const fetchBookings = useCallback(async () => {
    setLoading(true);
    setError("");

    try {
      const response = await api.get("/bookings");
      setBookings(getBookingList(response));
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchBookings();
  }, [fetchBookings]);

  const counts = useMemo(() => {
    const result = {
      total: bookings.length,
      pending: 0,
      confirmed: 0,
      rejected: 0,
      cancelled: 0,
      completed: 0,
    };

    bookings.forEach((booking) => {
      const status = getStatus(booking);

      if (Object.prototype.hasOwnProperty.call(result, status)) {
        result[status] += 1;
      }
    });

    return result;
  }, [bookings]);

  const filteredBookings = useMemo(() => {
    const query = search.trim().toLowerCase();

    return bookings.filter((booking) => {
      const customer = getCustomerName(booking).toLowerCase();
      const event = getEventName(booking).toLowerCase();
      const reference = String(getReference(booking)).toLowerCase();
      const phone = String(
        booking?.customer?.phone ||
        booking?.customerPhone ||
        booking?.phone ||
        ""
      ).toLowerCase();

      const matchesSearch =
        !query ||
        customer.includes(query) ||
        event.includes(query) ||
        reference.includes(query) ||
        phone.includes(query);

      const matchesStatus =
        statusFilter === "all" ||
        getStatus(booking) === statusFilter;

      const rawDate = getEventDate(booking);
      const parsedDate = rawDate ? new Date(rawDate) : null;
      const bookingDate =
        parsedDate && !Number.isNaN(parsedDate.getTime())
          ? [
              parsedDate.getFullYear(),
              String(parsedDate.getMonth() + 1).padStart(2, "0"),
              String(parsedDate.getDate()).padStart(2, "0"),
            ].join("-")
          : "";

      return (
        matchesSearch &&
        matchesStatus &&
        (!dateFilter || bookingDate === dateFilter)
      );
    });
  }, [bookings, search, statusFilter, dateFilter]);

  const handleStatusChange = async (booking, nextStatus) => {
    const bookingId = getBookingId(booking);

    if (!isValidBookingId(bookingId)) {
      setError("Invalid booking ID. Please refresh the page.");
      return;
    }

    if (!STATUSES.includes(nextStatus)) {
      setError("Invalid booking status.");
      return;
    }

    if (getStatus(booking) === nextStatus) return;

    if (
      !window.confirm(
        `Change this booking status to "${nextStatus}"?`
      )
    ) {
      return;
    }

    setUpdatingId(bookingId);
    setError("");
    setSuccess("");

    try {
      await api.patch(`/bookings/${bookingId}/status`, {
        status: nextStatus,
      });

      setBookings((previous) =>
        previous.map((item) =>
          getBookingId(item) === bookingId
            ? { ...item, status: nextStatus }
            : item
        )
      );

      setSuccess("Booking status updated successfully.");
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setUpdatingId("");
    }
  };

  const clearFilters = () => {
    setSearch("");
    setStatusFilter("all");
    setDateFilter("");
  };

  return (
    <section className="bookings-page">
      <div className="bookings-hero">
        <div>
          <span className="bookings-eyebrow">
            NIVETHA CATERING SERVICE
          </span>
          <h1>Booking Management</h1>
          <p>
            Manage customer bookings, event details and booking status.
          </p>
        </div>

        <div className="bookings-hero-icon">
          <ClipboardList size={38} />
        </div>
      </div>

      <div className="bookings-stats">
        <div className="booking-stat-card">
          <div className="booking-stat-icon stat-total">
            <ClipboardList size={22} />
          </div>
          <div>
            <span>Total Bookings</span>
            <h3>{counts.total}</h3>
          </div>
        </div>

        <div className="booking-stat-card">
          <div className="booking-stat-icon stat-pending">
            <Clock size={22} />
          </div>
          <div>
            <span>Pending</span>
            <h3>{counts.pending}</h3>
          </div>
        </div>

        <div className="booking-stat-card">
          <div className="booking-stat-icon stat-confirmed">
            <CheckCircle2 size={22} />
          </div>
          <div>
            <span>Confirmed</span>
            <h3>{counts.confirmed}</h3>
          </div>
        </div>

        <div className="booking-stat-card">
          <div className="booking-stat-icon stat-completed">
            <Users size={22} />
          </div>
          <div>
            <span>Completed</span>
            <h3>{counts.completed}</h3>
          </div>
        </div>
      </div>

      {error && (
        <div className="bookings-alert bookings-alert-error" role="alert">
          <XCircle size={18} />
          <span>{error}</span>
          <button type="button" onClick={() => setError("")}>
            ×
          </button>
        </div>
      )}

      {success && (
        <div className="bookings-alert bookings-alert-success" role="status">
          <CheckCircle2 size={18} />
          <span>{success}</span>
          <button type="button" onClick={() => setSuccess("")}>
            ×
          </button>
        </div>
      )}

      <div className="bookings-toolbar">
        <div>
          <h2>All Bookings</h2>
          <p>Search and filter customer event bookings.</p>
        </div>

        <button
          type="button"
          className="bookings-refresh-btn"
          onClick={fetchBookings}
          disabled={loading || Boolean(updatingId)}
        >
          <RefreshCw size={17} />
          Refresh
        </button>
      </div>

      <div className="bookings-filters">
        <div className="bookings-search">
          <Search size={19} />
          <input
            type="search"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            placeholder="Search customer, phone or booking ID..."
            aria-label="Search bookings"
          />
        </div>

        <div className="bookings-filter-control">
          <label htmlFor="booking-status-filter">Status</label>
          <select
            id="booking-status-filter"
            value={statusFilter}
            onChange={(event) => setStatusFilter(event.target.value)}
          >
            <option value="all">All statuses</option>
            {STATUSES.map((status) => (
              <option key={status} value={status}>
                {status.charAt(0).toUpperCase() + status.slice(1)}
              </option>
            ))}
          </select>
        </div>

        <div className="bookings-filter-control">
          <label htmlFor="booking-date-filter">Event date</label>
          <div className="bookings-date-input">
            <CalendarDays size={17} />
            <input
              id="booking-date-filter"
              type="date"
              value={dateFilter}
              onChange={(event) => setDateFilter(event.target.value)}
            />
          </div>
        </div>

        <button
          type="button"
          className="bookings-clear-btn"
          onClick={clearFilters}
        >
          Clear
        </button>
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
                    Loading bookings...
                  </td>
                </tr>
              ) : filteredBookings.length === 0 ? (
                <tr>
                  <td colSpan={7} className="bookings-table-message">
                    <div className="bookings-empty-state">
                      <ClipboardList size={34} />
                      <strong>No bookings found</strong>
                      <span>
                        Try changing your search or filter options.
                      </span>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredBookings.map((booking) => {
                  const id = getBookingId(booking);
                  const status = getStatus(booking);
                  const validStatus = STATUSES.includes(status)
                    ? status
                    : "pending";

                  return (
                    <tr key={id}>
                      <td>
                        <span className="booking-reference">
                          #{String(getReference(booking)).slice(-8)}
                        </span>
                      </td>

                      <td>
                        <div className="booking-customer-cell">
                          <span className="booking-customer-avatar">
                            {getCustomerName(booking)
                              .charAt(0)
                              .toUpperCase()}
                          </span>
                          <div>
                            <strong>{getCustomerName(booking)}</strong>
                            <span>
                              {booking?.customer?.phone ||
                                booking?.customerPhone ||
                                booking?.phone ||
                                "No phone"}
                            </span>
                          </div>
                        </div>
                      </td>

                      <td>{getEventName(booking)}</td>
                      <td>{formatDate(getEventDate(booking))}</td>

                      <td>
                        <span className="booking-persons">
                          <Users size={15} />
                          {getPersons(booking)}
                        </span>
                      </td>

                      <td>
                        <select
                          className={`booking-status-select status-${validStatus}`}
                          value={validStatus}
                          disabled={updatingId === id}
                          aria-label={`Update status for booking ${id}`}
                          onChange={(event) =>
                            handleStatusChange(booking, event.target.value)
                          }
                        >
                          {STATUSES.map((item) => (
                            <option key={item} value={item}>
                              {item.charAt(0).toUpperCase() + item.slice(1)}
                            </option>
                          ))}
                        </select>

                        {updatingId === id && (
                          <span className="booking-updating-label">
                            Updating...
                          </span>
                        )}
                      </td>

                      <td>
                        <Link
                          to={`/bookings/${encodeURIComponent(id)}`}
                          className="booking-view-btn"
                        >
                          <Eye size={16} />
                          View
                        </Link>
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
            Showing {filteredBookings.length} of {bookings.length} bookings
          </span>
        </div>
      </div>
    </section>
  );
}