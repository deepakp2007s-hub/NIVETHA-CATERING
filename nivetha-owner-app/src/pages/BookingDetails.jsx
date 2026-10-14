import { useCallback, useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
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
} from "lucide-react";
import api from "../services/api";
import "./BookingDetails.css";

const STATUSES = [
  "pending",
  "confirmed",
  "rejected",
  "cancelled",
  "completed",
];

const getErrorMessage = (error) =>
  error?.response?.data?.message ||
  "Unable to complete the request. Please try again.";

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

const getBookingId = (booking) =>
  String(booking?._id || booking?.id || "");

const getCustomer = (booking) =>
  booking?.customer || {};

const getCustomerName = (booking) => {
  const customer = getCustomer(booking);

  return (
    customer?.name ||
    booking?.customerName ||
    booking?.name ||
    "Customer"
  );
};

const getPhone = (booking) => {
  const customer = getCustomer(booking);

  return (
    customer?.phone ||
    booking?.customerPhone ||
    booking?.phone ||
    "Not provided"
  );
};

const getEventType = (booking) =>
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

const getFoodItems = (booking) => {
  const items =
    (booking?.selectedFoodNames?.length
      ? booking.selectedFoodNames.map((name) => ({ name }))
      : null) ||
    booking?.selectedFoods ||
    booking?.foods ||
    booking?.menuItems ||
    booking?.foodItems;

  return Array.isArray(items) ? items : [];
};

export default function BookingDetails() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [booking, setBooking] = useState(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const fetchBooking = useCallback(async () => {
    if (!id || !/^[a-fA-F0-9]{24}$/.test(id)) {
      setError("Invalid booking ID.");
      setBooking(null);
      setLoading(false);
      return;
    }

    setLoading(true);
    setError("");

    try {
      const response = await api.get(
        `/bookings/${encodeURIComponent(id)}`
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

      setBooking(result);
    } catch (err) {
      setBooking(null);
      setError(
        err?.response?.data?.message ||
          err?.message ||
          "Unable to load booking details."
      );
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    fetchBooking();
  }, [fetchBooking]);

  const handleStatusUpdate = async (nextStatus) => {
    const bookingId = getBookingId(booking);

    if (!/^[a-fA-F0-9]{24}$/.test(bookingId)) {
      setError("Invalid booking ID.");
      return;
    }

    if (!STATUSES.includes(nextStatus)) {
      setError("Invalid booking status.");
      return;
    }

    if (String(booking?.status || "pending").toLowerCase() === nextStatus) {
      return;
    }

    const confirmed = window.confirm(
      `Are you sure you want to change the booking status to "${nextStatus}"?`
    );

    if (!confirmed) return;

    setUpdating(true);
    setError("");
    setSuccess("");

    try {
      await api.patch(`/bookings/${bookingId}/status`, {
        status: nextStatus,
      });

      setBooking((previous) => ({
        ...previous,
        status: nextStatus,
      }));

      setSuccess("Booking status updated successfully.");
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setUpdating(false);
    }
  };

  if (loading) {
    return (
      <div className="booking-details-state">
        <div className="booking-details-spinner" />
        <p>Loading booking details...</p>
      </div>
    );
  }

  if (!booking) {
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

  const status = String(booking.status || "pending").toLowerCase();
  const validStatus = STATUSES.includes(status) ? status : "pending";

  const customer = getCustomer(booking);
  const foodItems = getFoodItems(booking);

  const payment = booking?.payment || {};
  const paymentTotal = Number(
    payment?.totalPayment ??
      booking?.totalPayment ??
      booking?.totalAmount ??
      0
  );

  const advance = Number(
    payment?.advancePayment ??
      booking?.advancePayment ??
      0
  );

  const balance = Number(
    payment?.balancePayment ??
      booking?.balancePayment ??
      Math.max(paymentTotal - advance, 0)
  );

  const location =
    booking?.location ||
    booking?.eventLocation ||
    booking?.address ||
    "Not provided";

  const eventTime =
    booking?.eventTime ||
    booking?.functionTime ||
    booking?.time ||
    "Not specified";

  const cateringServices = [
    ...(Array.isArray(booking?.cateringServices) ? booking.cateringServices : []),
    booking?.cookingService && "Cooking Service",
    booking?.servingStaff && "Serving Staff",
  ].filter(Boolean);

  const extraRequirements =
    booking?.extraRequirements ||
    booking?.requirements ||
    booking?.notes ||
    "";

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

        <button
          type="button"
          className="booking-details-refresh-btn"
          onClick={fetchBooking}
          disabled={updating}
        >
          <RefreshCw size={16} />
          Refresh
        </button>
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

        <div className={`booking-details-status status-${validStatus}`}>
          <span className="booking-details-status-dot" />
          {validStatus.charAt(0).toUpperCase() + validStatus.slice(1)}
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
                <strong>{getEventType(booking)}</strong>
              </div>

              <div className="booking-details-info-item">
                <span>Function Date</span>
                <strong>{formatDate(getEventDate(booking))}</strong>
              </div>

              <div className="booking-details-info-item">
                <span>Function Time</span>
                <strong className="booking-details-icon-value">
                  <Clock size={15} />
                  {eventTime}
                </strong>
              </div>

              <div className="booking-details-info-item">
                <span>Number of Persons</span>
                <strong className="booking-details-icon-value">
                  <Users size={16} />
                  {getPersons(booking)}
                </strong>
              </div>

              <div className="booking-details-info-item full-width">
                <span>Event Location</span>
                <strong className="booking-details-icon-value">
                  <MapPin size={16} />
                  {location}
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
                {getCustomerName(booking).charAt(0).toUpperCase()}
              </div>

              <div className="booking-details-customer-content">
                <h3>{getCustomerName(booking)}</h3>

                <p>
                  <Phone size={15} />
                  {getPhone(booking)}
                </p>

                {customer?.email && <p>{customer.email}</p>}
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
              {cateringServices.length > 0 ? (
                cateringServices.map((service) => (
                  <span key={service} className="booking-details-service-tag">
                    <CheckCircle2 size={15} />
                    {service}
                  </span>
                ))
              ) : (
                <p className="booking-details-muted">
                  No catering services specified.
                </p>
              )}
            </div>

            {foodItems.length > 0 ? (
              <div className="booking-details-food-list">
                {foodItems.map((food, index) => {
                  const foodName =
                    typeof food === "string"
                      ? food
                      : food?.name || food?.foodName || "Food item";

                  const foodId =
                    typeof food === "object"
                      ? food?._id || food?.id || `${foodName}-${index}`
                      : `${food}-${index}`;

                  return (
                    <div className="booking-details-food-item" key={foodId}>
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

            {extraRequirements && (
              <div className="booking-details-requirements">
                <span>Extra Requirements</span>
                <p>{extraRequirements}</p>
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
              className={`booking-details-status-select status-${validStatus}`}
              value={validStatus}
              disabled={updating}
              onChange={(event) => handleStatusUpdate(event.target.value)}
            >
              {STATUSES.map((item) => (
                <option key={item} value={item}>
                  {item.charAt(0).toUpperCase() + item.slice(1)}
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
                Confirm the correct status before updating the booking.
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
              <strong>{formatCurrency(paymentTotal)}</strong>
            </div>

            <div className="booking-details-payment-row">
              <span>Advance Paid</span>
              <strong className="payment-positive">
                {formatCurrency(advance)}
              </strong>
            </div>

            <div className="booking-details-payment-row payment-balance">
              <span>Balance Amount</span>
              <strong>{formatCurrency(balance)}</strong>
            </div>

            <p className="booking-details-payment-note">
              Amounts are shown from the booking data available in the API.
            </p>
          </article>

          <Link
            to="/bookings"
            className="booking-details-back-link"
          >
            <ArrowLeft size={17} />
            Return to All Bookings
          </Link>
        </aside>
      </div>
    </section>
  );
}
