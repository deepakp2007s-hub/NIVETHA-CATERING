
import { useCallback, useEffect, useMemo, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import {
  ArrowLeft,
  CalendarDays,
  Clock,
  MapPin,
  Users,
  Phone,
  UserRound,
  ClipboardList,
  CheckCircle2,
  XCircle,
  RefreshCw,
  IndianRupee,
  Utensils,
  AlertCircle,
  Mail,
  Trash2,
} from "lucide-react";
import api from "../services/api";
import "./BookingDetails.css";

const getErrorMessage = (error) =>
  error?.response?.data?.detail ||
  error?.response?.data?.message ||
  error?.message ||
  "Unable to complete the request. Please try again.";

const getBookingId = (booking) =>
  String(booking?._id || booking?.id || "");

const getValue = (...values) =>
  values.find((value) => value !== undefined && value !== null && value !== "");

const formatDate = (value) => {
  if (!value) return "Not specified";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) return "Not specified";

  return date.toLocaleDateString("en-IN", {
    weekday: "short",
    day: "2-digit",
    month: "long",
    year: "numeric",
  });
};

const formatCurrency = (value) => {
  const amount = Number(value);

  if (!Number.isFinite(amount)) return "₹0";

  return amount.toLocaleString("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 2,
  });
};

const getCustomerName = (booking) =>
  getValue(
    booking?.customer_name,
    booking?.customerName,
    booking?.customer?.name,
    booking?.name,
    "Customer"
  );

const getPhone = (booking) =>
  getValue(
    booking?.customer_phone,
    booking?.customerPhone,
    booking?.customer?.phone,
    booking?.phone,
    "Not provided"
  );

const getEmail = (booking) =>
  getValue(
    booking?.customer_email,
    booking?.customerEmail,
    booking?.customer?.email,
    ""
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

const getFoodItems = (booking) => {
  const items = getValue(
    booking?.selected_foods,
    booking?.selectedFoods,
    booking?.foods,
    booking?.menu_items,
    booking?.menuItems,
    booking?.food_items,
    booking?.foodItems,
    []
  );

  return Array.isArray(items) ? items : [];
};

const getStatus = (booking) =>
  String(booking?.status || "pending").toLowerCase();

const getAvailableStatuses = (status) => {
  switch (status) {
    case "pending":
      return ["pending", "confirmed", "rejected"];
    case "confirmed":
      return ["confirmed", "completed"];
    case "rejected":
    case "completed":
    case "cancelled":
      return [status];
    default:
      return [status];
  }
};

const getStatusLabel = (status) =>
  status.charAt(0).toUpperCase() + status.slice(1);

export default function BookingDetails() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [booking, setBooking] = useState(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const fetchBooking = useCallback(async () => {
    if (!id || !/^[a-fA-F0-9]{24}$/.test(id)) {
      setBooking(null);
      setError("Invalid booking ID.");
      setLoading(false);
      return;
    }

    setLoading(true);
    setError("");

    try {
      const response = await api.get(
        `/bookings/owner/${encodeURIComponent(id)}`
      );

      const data = response?.data;
      const result =
        data?.booking ||
        data?.data?.booking ||
        data?.data ||
        data;

      if (!result || typeof result !== "object" || Array.isArray(result)) {
        throw new Error("Booking details were not found.");
      }

      if (getStatus(result) === "deleted") {
        throw new Error("This booking has already been deleted.");
      }

      setBooking(result);
    } catch (err) {
      setBooking(null);
      setError(getErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    fetchBooking();
  }, [fetchBooking]);

  const handleStatusUpdate = async (nextStatus) => {
    if (!booking || updating || deleting) return;

    const bookingId = getBookingId(booking);
    const currentStatus = getStatus(booking);
    const allowedStatuses = getAvailableStatuses(currentStatus);

    if (!/^[a-fA-F0-9]{24}$/.test(bookingId)) {
      setError("Invalid booking ID.");
      return;
    }

    if (
      !allowedStatuses.includes(nextStatus) ||
      nextStatus === currentStatus
    ) {
      setError("This status transition is not allowed.");
      return;
    }

    if (
      !window.confirm(
        `Are you sure you want to change this booking to ${nextStatus}?`
      )
    ) {
      return;
    }

    setUpdating(true);
    setError("");
    setSuccess("");

    try {
      const response = await api.patch(
        `/bookings/owner/${encodeURIComponent(bookingId)}/status`,
        { status: nextStatus }
      );

      const updatedBooking =
        response?.data?.booking ||
        response?.data?.data ||
        response?.data;

      if (updatedBooking && typeof updatedBooking === "object") {
        setBooking((previous) => ({
          ...previous,
          ...updatedBooking,
        }));
      } else {
        setBooking((previous) => ({
          ...previous,
          status: nextStatus,
        }));
      }

      setSuccess("Booking status updated successfully.");
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setUpdating(false);
    }
  };

  const handleDeleteBooking = async () => {
    if (!booking || deleting || updating) return;

    const bookingId = getBookingId(booking);

    if (!/^[a-fA-F0-9]{24}$/.test(bookingId)) {
      setError("Invalid booking ID.");
      return;
    }

    const confirmed = window.confirm(
      "Are you sure you want to delete this booking?\n\nThis booking will be hidden from the active bookings list. It will not be permanently removed from the database."
    );

    if (!confirmed) return;

    setDeleting(true);
    setError("");
    setSuccess("");

    try {
      await api.delete(
        `/bookings/owner/${encodeURIComponent(bookingId)}`
      );

      setSuccess("Booking moved to deleted status successfully.");

      navigate("/bookings", {
        replace: true,
        state: {
          successMessage: "Booking deleted successfully.",
        },
      });
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setDeleting(false);
    }
  };

  const details = useMemo(() => {
    if (!booking) return null;

    const payment = booking.payment || {};

    const total = Number(
      getValue(
        payment.total_payment,
        payment.totalPayment,
        booking.total_payment,
        booking.totalPayment,
        booking.total_amount,
        booking.totalAmount,
        0
      )
    );

    const advance = Number(
      getValue(
        payment.advance_payment,
        payment.advancePayment,
        booking.advance_payment,
        booking.advancePayment,
        0
      )
    );

    const balance = Number(
      getValue(
        payment.balance_payment,
        payment.balancePayment,
        booking.balance_payment,
        booking.balancePayment,
        Math.max(total - advance, 0)
      )
    );

    const services = [
      ...(Array.isArray(booking.catering_services)
        ? booking.catering_services
        : Array.isArray(booking.cateringServices)
          ? booking.cateringServices
          : []),
      (booking.cooking_service || booking.cookingService) &&
        "Cooking Service",
      (booking.serving_staff || booking.servingStaff) &&
        "Serving Staff",
    ].filter(Boolean);

    return {
      status: getStatus(booking),
      customerName: getCustomerName(booking),
      phone: getPhone(booking),
      email: getEmail(booking),
      eventType: getEventType(booking),
      eventDate: getEventDate(booking),
      eventTime: getValue(
        booking.event_time,
        booking.eventTime,
        booking.function_time,
        booking.functionTime,
        booking.time,
        "Not specified"
      ),
      persons: getPersons(booking),
      location: getValue(
        booking.event_location,
        booking.eventLocation,
        booking.location,
        booking.address,
        "Not provided"
      ),
      foods: getFoodItems(booking),
      services,
      requirements: getValue(
        booking.extra_requirements,
        booking.extraRequirements,
        booking.requirements,
        booking.notes,
        ""
      ),
      total,
      advance,
      balance,
    };
  }, [booking]);

  if (loading) {
    return (
      <div className="booking-details-state">
        <div className="booking-details-spinner" />
        <p>Loading booking details...</p>
      </div>
    );
  }

  if (!booking || !details) {
    return (
      <div className="booking-details-state booking-details-error-state">
        <AlertCircle size={42} />
        <h2>Booking not found</h2>
        <p>{error || "The requested booking could not be loaded."}</p>

        <div className="booking-details-state-actions">
          <button type="button" onClick={fetchBooking}>
            <RefreshCw size={16} />
            Try Again
          </button>

          <button
            type="button"
            className="booking-details-secondary-btn"
            onClick={() => navigate("/bookings")}
          >
            Back to Bookings
          </button>
        </div>
      </div>
    );
  }

  const availableStatuses = getAvailableStatuses(details.status);

  return (
    <section className="booking-details-page">
      <div className="booking-details-topbar">
        <button
          type="button"
          className="booking-details-back-btn"
          onClick={() => navigate("/bookings")}
        >
          <ArrowLeft size={18} />
          Back to Bookings
        </button>

        <div className="booking-details-topbar-actions">
          <button
            type="button"
            className="booking-details-refresh-btn"
            onClick={fetchBooking}
            disabled={updating || deleting}
          >
            <RefreshCw size={16} />
            Refresh
          </button>

          <button
            type="button"
            className="booking-details-delete-btn"
            onClick={handleDeleteBooking}
            disabled={updating || deleting}
          >
            {deleting ? (
              <RefreshCw size={16} className="booking-details-delete-spin" />
            ) : (
              <Trash2 size={16} />
            )}
            {deleting ? "Deleting..." : "Delete Booking"}
          </button>
        </div>
      </div>

      <div className="booking-details-hero">
        <div className="booking-details-hero-main">
          <span className="booking-details-eyebrow">
            NIVETHA CATERING SERVICE
          </span>

          <h1>Booking Details</h1>

          <p>
            Reference ID:{" "}
            <strong>#{getBookingId(booking).slice(-8)}</strong>
          </p>
        </div>

        <div className={`booking-details-status status-${details.status}`}>
          <span className="booking-details-status-dot" />
          {getStatusLabel(details.status)}
        </div>
      </div>

      {error && (
        <div className="booking-details-alert error" role="alert">
          <XCircle size={18} />
          <span>{error}</span>
          <button type="button" onClick={() => setError("")}>
            ×
          </button>
        </div>
      )}

      {success && (
        <div className="booking-details-alert success" role="status">
          <CheckCircle2 size={18} />
          <span>{success}</span>
          <button type="button" onClick={() => setSuccess("")}>
            ×
          </button>
        </div>
      )}

      <div className="booking-details-grid">
        <div className="booking-details-main-column">
          <article className="booking-details-card">
            <div className="booking-details-card-heading">
              <div className="booking-details-heading-icon">
                <CalendarDays size={20} />
              </div>
              <div>
                <h2>Event Information</h2>
                <p>Function date, location and guest details</p>
              </div>
            </div>

            <div className="booking-details-info-grid">
              <div className="booking-details-info-item">
                <span>Event Type</span>
                <strong>{details.eventType}</strong>
              </div>

              <div className="booking-details-info-item">
                <span>Function Date</span>
                <strong>{formatDate(details.eventDate)}</strong>
              </div>

              <div className="booking-details-info-item">
                <span>Function Time</span>
                <strong className="booking-details-icon-value">
                  <Clock size={15} />
                  {details.eventTime}
                </strong>
              </div>

              <div className="booking-details-info-item">
                <span>Number of Persons</span>
                <strong className="booking-details-icon-value">
                  <Users size={16} />
                  {details.persons}
                </strong>
              </div>

              <div className="booking-details-info-item full-width">
                <span>Event Location</span>
                <strong className="booking-details-icon-value">
                  <MapPin size={16} />
                  {details.location}
                </strong>
              </div>
            </div>
          </article>

          <article className="booking-details-card">
            <div className="booking-details-card-heading">
              <div className="booking-details-heading-icon">
                <UserRound size={20} />
              </div>
              <div>
                <h2>Customer Information</h2>
                <p>Customer contact details</p>
              </div>
            </div>

            <div className="booking-details-customer">
              <div className="booking-details-customer-avatar">
                {details.customerName.charAt(0).toUpperCase()}
              </div>

              <div className="booking-details-customer-content">
                <h3>{details.customerName}</h3>

                <p>
                  <Phone size={15} />
                  {details.phone}
                </p>

                {details.email && (
                  <p>
                    <Mail size={15} />
                    {details.email}
                  </p>
                )}
              </div>
            </div>
          </article>

          <article className="booking-details-card">
            <div className="booking-details-card-heading">
              <div className="booking-details-heading-icon">
                <Utensils size={20} />
              </div>
              <div>
                <h2>Food & Catering</h2>
                <p>Selected menu and requested services</p>
              </div>
            </div>

            <div className="booking-details-service-list">
              {details.services.length > 0 ? (
                details.services.map((service, index) => (
                  <span
                    key={`${typeof service === "string" ? service : service?.name}-${index}`}
                    className="booking-details-service-tag"
                  >
                    <CheckCircle2 size={15} />
                    {typeof service === "string"
                      ? service
                      : service?.name || "Catering Service"}
                  </span>
                ))
              ) : (
                <p className="booking-details-muted">
                  No catering services specified.
                </p>
              )}
            </div>

            {details.foods.length > 0 ? (
              <div className="booking-details-food-list">
                {details.foods.map((food, index) => {
                  const foodName =
                    typeof food === "string"
                      ? food
                      : food?.name ||
                        food?.food_name ||
                        food?.foodName ||
                        "Food item";

                  const foodId =
                    typeof food === "object"
                      ? food?._id || food?.id || `${foodName}-${index}`
                      : `${food}-${index}`;

                  return (
                    <div
                      className="booking-details-food-item"
                      key={foodId}
                    >
                      <div>
                        <Utensils size={16} />
                        <span>{foodName}</span>
                      </div>

                      {typeof food === "object" &&
                        food?.quantity != null && (
                          <strong>Qty: {food.quantity}</strong>
                        )}
                    </div>
                  );
                })}
              </div>
            ) : (
              <p className="booking-details-muted">
                No menu items available for this booking.
              </p>
            )}

            {details.requirements && (
              <div className="booking-details-requirements">
                <span>Extra Requirements</span>
                <p>{details.requirements}</p>
              </div>
            )}
          </article>
        </div>

        <aside className="booking-details-side-column">
          <article className="booking-details-card">
            <div className="booking-details-card-heading">
              <div className="booking-details-heading-icon">
                <ClipboardList size={20} />
              </div>
              <div>
                <h2>Manage Booking</h2>
                <p>Update the current status</p>
              </div>
            </div>

            <label
              className="booking-details-field-label"
              htmlFor="booking-detail-status"
            >
              Booking Status
            </label>

            <select
              id="booking-detail-status"
              className={`booking-details-status-select status-${details.status}`}
              value={details.status}
              disabled={
                updating ||
                deleting ||
                availableStatuses.length === 1
              }
              onChange={(event) => handleStatusUpdate(event.target.value)}
            >
              {availableStatuses.map((status) => (
                <option key={status} value={status}>
                  {getStatusLabel(status)}
                </option>
              ))}
            </select>

            {updating && (
              <p className="booking-details-updating">
                Updating booking status...
              </p>
            )}

            <div className="booking-details-status-note">
              <AlertCircle size={16} />
              <p>
                Pending bookings can be confirmed or rejected. Confirmed
                bookings can be marked completed.
              </p>
            </div>
          </article>

          <article className="booking-details-card">
            <div className="booking-details-card-heading">
              <div className="booking-details-heading-icon">
                <IndianRupee size={20} />
              </div>
              <div>
                <h2>Payment Summary</h2>
                <p>Recorded booking payment details</p>
              </div>
            </div>

            <div className="booking-details-payment-row">
              <span>Total Amount</span>
              <strong>{formatCurrency(details.total)}</strong>
            </div>

            <div className="booking-details-payment-row">
              <span>Advance Paid</span>
              <strong className="payment-positive">
                {formatCurrency(details.advance)}
              </strong>
            </div>

            <div className="booking-details-payment-row payment-balance">
              <span>Balance Amount</span>
              <strong>{formatCurrency(details.balance)}</strong>
            </div>

            <p className="booking-details-payment-note">
              Amounts are shown from the booking data available in the API.
            </p>
          </article>

          <button
            type="button"
            className="booking-details-back-link"
            onClick={() => navigate("/bookings")}
          >
            <ArrowLeft size={17} />
            Return to All Bookings
          </button>

          <button
            type="button"
            className="booking-details-delete-bottom-btn"
            onClick={handleDeleteBooking}
            disabled={updating || deleting}
          >
            <Trash2 size={17} />
            {deleting ? "Deleting Booking..." : "Delete This Booking"}
          </button>
        </aside>
      </div>
    </section>
  );
}
