
import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import {
  CalendarDays,
  MapPin,
  Users,
  Utensils,
} from "lucide-react";
import bookingService from "../services/bookingService";
import Loading from "../components/Loading";
import "./PageStyles.css";

function formatDate(value) {
  if (!value) return "—";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) return value;

  return date.toLocaleDateString("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

function getErrorMessage(err, fallback) {
  return (
    err.response?.data?.message ||
    err.response?.data?.error ||
    err.message ||
    fallback
  );
}

function unwrapBooking(response) {
  return (
    response?.booking ||
    response?.data?.booking ||
    response?.data?.data ||
    response?.data ||
    response
  );
}

export default function BookingDetails() {
  const { id } = useParams();

  const [booking, setBooking] = useState(null);
  const [loading, setLoading] = useState(true);
  const [cancelling, setCancelling] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    let active = true;

    async function loadBooking() {
      setLoading(true);
      setError("");

      try {
        const response = await bookingService.getById(id);

        if (active) {
          setBooking(unwrapBooking(response));
        }
      } catch (err) {
        if (active) {
          setError(getErrorMessage(err, "Unable to load this booking."));
        }
      } finally {
        if (active) setLoading(false);
      }
    }

    loadBooking();

    return () => {
      active = false;
    };
  }, [id]);

  async function cancelBooking() {
    if (cancelling || booking?.status !== "pending") return;

    const confirmed = window.confirm(
      "Cancel this pending booking? This action cannot be undone."
    );

    if (!confirmed) return;

    setCancelling(true);
    setError("");

    try {
      const response = await bookingService.cancel(id);
      const updated = unwrapBooking(response);

      setBooking((previous) => ({
        ...previous,
        ...updated,
        status: updated?.status || "cancelled",
      }));
    } catch (err) {
      setError(getErrorMessage(err, "Unable to cancel this booking."));
    } finally {
      setCancelling(false);
    }
  }

  if (loading) return <Loading />;

  if (error && !booking) {
    return (
      <section className="page-container page-narrow">
        <p className="page-error" role="alert">{error}</p>
        <Link to="/my-bookings" className="page-btn">
          Back to My Bookings
        </Link>
      </section>
    );
  }

  if (!booking) {
    return (
      <section className="page-container page-narrow">
        <p className="page-error">Booking not found.</p>
        <Link to="/my-bookings" className="page-btn">
          Back to My Bookings
        </Link>
      </section>
    );
  }

  const status = String(booking.status || "pending").toLowerCase();

  const selectedFoods = (
    booking.selectedFoodNames?.length
      ? booking.selectedFoodNames
      : booking.selectedFoods || []
  )
    .map((food) => {
      if (typeof food === "string") return food;
      return food?.name || food?.tamilName || "";
    })
    .filter(Boolean)
    .join(", ");

  const cateringServices = Array.isArray(booking.cateringServices)
    ? booking.cateringServices.join(", ")
    : booking.cateringService || "—";

  return (
    <section className="page-container page-narrow">
      <div className="page-heading">
        <span className="page-kicker">BOOKING DETAILS</span>
        <h1>{booking.eventType || "Catering Event"}</h1>
        <span className={`status-pill status-${status}`}>
          {status}
        </span>
      </div>

      <div className="summary-card">
        <div className="summary-row">
          <span><CalendarDays size={16} /> Date</span>
          <strong>{formatDate(booking.functionDate || booking.eventDate)}</strong>
        </div>

        <div className="summary-row">
          <span>Time</span>
          <strong>{booking.functionTime || "—"}</strong>
        </div>

        <div className="summary-row">
          <span><MapPin size={16} /> Location</span>
          <strong>{booking.location || "—"}</strong>
        </div>

        <div className="summary-row">
          <span><Users size={16} /> Guests</span>
          <strong>
            {booking.numberOfPersons ?? booking.guestCount ?? "—"}
          </strong>
        </div>

        <div className="summary-row">
          <span><Utensils size={16} /> Meal</span>
          <strong>{booking.mealType || "—"}</strong>
        </div>

        <div className="summary-row">
          <span>Food preference</span>
          <strong>{booking.foodType || "—"}</strong>
        </div>

        <div className="summary-row">
          <span>Catering services</span>
          <strong>{cateringServices}</strong>
        </div>

        <div className="summary-row">
          <span>Selected foods</span>
          <strong>{selectedFoods || "—"}</strong>
        </div>

        <div className="summary-extra">
          <strong>Extra requirements</strong>
          <p>{booking.extraRequirements || "No additional requirements."}</p>
        </div>
      </div>

      {error && (
        <p className="page-error" role="alert">{error}</p>
      )}

      <div className="page-actions">
        <Link to="/my-bookings" className="page-btn page-btn-light">
          Back
        </Link>

        {status === "pending" && (
          <>
            <Link to={`/my-bookings/${id}/edit`} className="page-btn">
              Edit Booking
            </Link>

            <button
              type="button"
              className="page-btn page-btn-danger"
              onClick={cancelBooking}
              disabled={cancelling}
            >
              {cancelling ? "Cancelling..." : "Cancel Booking"}
            </button>
          </>
        )}
      </div>
    </section>
  );
}
