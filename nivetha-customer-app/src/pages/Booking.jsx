
import { useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { CalendarDays, MapPin, Users, Utensils } from "lucide-react";
import bookingService from "../services/bookingService";
import { useBooking } from "../context/BookingContext";
import "./PageStyles.css";

export default function Booking() {
  const navigate = useNavigate();
  const { booking, updateBooking } = useBooking();

  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");
  const submissionInProgress = useRef(false);

  async function submitBooking() {
    if (submissionInProgress.current) return;

    setError("");

    if (
      !booking.eventType ||
      !booking.functionDate ||
      !booking.functionTime ||
      !booking.location?.trim() ||
      !Number.isSafeInteger(Number(booking.numberOfPersons)) ||
      Number(booking.numberOfPersons) < 1
    ) {
      setError("Please complete all required event details.");
      navigate("/event-details");
      return;
    }

    if (
      !Array.isArray(booking.cateringServices) ||
      booking.cateringServices.length === 0
    ) {
      setError("Please select at least one catering service.");
      navigate("/catering");
      return;
    }

    const selectedFoodIds = (booking.selectedFoods || [])
      .map((food) =>
        typeof food === "string" ? food : food?._id || food?.id
      )
      .filter(Boolean);

    try {
      submissionInProgress.current = true;
      setSubmitting(true);

      const response = await bookingService.create({
        eventType: booking.eventType,
        functionDate: booking.functionDate,
        functionTime: booking.functionTime,
        location: booking.location.trim(),
        numberOfPersons: Number(booking.numberOfPersons),
        extraRequirements: booking.extraRequirements || "",
        cateringServices: booking.cateringServices,
        mealType: booking.mealType || "",
        foodType: booking.foodType || "veg",
        selectedFoods: selectedFoodIds,
      });

      const created =
        response?.booking ||
        response?.data?.booking ||
        response?.data?.data ||
        response?.data ||
        response;

      const bookingId =
        created?._id || created?.id || created?.bookingId;

      if (!bookingId) {
        throw new Error(
          "Booking response did not contain a booking ID. Please check My Bookings before trying again."
        );
      }

      updateBooking({ bookingId });

      navigate("/booking-confirmation", {
        state: { booking: created },
      });
    } catch (err) {
      const serverMessage =
        err.response?.data?.message ||
        err.response?.data?.error;

      setError(
        serverMessage ||
          err.message ||
          "Unable to submit your booking. Please try again."
      );
    } finally {
      submissionInProgress.current = false;
      setSubmitting(false);
    }
  }

  return (
    <section className="page-container page-narrow">
      <div className="page-heading">
        <span className="page-kicker">STEP 5 OF 5</span>
        <h1>Review your booking</h1>
        <p>Check your event information before sending your request.</p>
      </div>

      <div className="summary-card">
        <div className="summary-title">
          <CalendarDays size={20} />
          <strong>Event details</strong>
        </div>

        <div className="summary-row">
          <span>Occasion</span>
          <strong>{booking.eventType || "Not selected"}</strong>
        </div>

        <div className="summary-row">
          <span>Date</span>
          <strong>{booking.functionDate || "Not selected"}</strong>
        </div>

        <div className="summary-row">
          <span>Time</span>
          <strong>{booking.functionTime || "Not selected"}</strong>
        </div>

        <div className="summary-row">
          <span><MapPin size={15} /> Location</span>
          <strong>{booking.location || "Not entered"}</strong>
        </div>

        <div className="summary-row">
          <span><Users size={15} /> Guests</span>
          <strong>{booking.numberOfPersons || 0}</strong>
        </div>

        <div className="summary-row">
          <span><Utensils size={15} /> Catering</span>
          <strong>
            {booking.cateringServices?.join(", ") || "Not selected"}
          </strong>
        </div>

        <div className="summary-row">
          <span>Meal / Preference</span>
          <strong>
            {booking.mealType || "—"} / {booking.foodType || "—"}
          </strong>
        </div>

        <div className="summary-row">
          <span>Selected foods</span>
          <strong>
            {booking.selectedFoods
              ?.map((food) =>
                typeof food === "string"
                  ? food
                  : food?.name || food?.tamilName || ""
              )
              .filter(Boolean)
              .join(", ") || "Menu to be discussed"}
          </strong>
        </div>

        {booking.extraRequirements && (
          <div className="summary-extra">
            <strong>Extra requirements</strong>
            <p>{booking.extraRequirements}</p>
          </div>
        )}
      </div>

      {error && (
        <p className="page-error" role="alert">
          {error}
        </p>
      )}

      <div className="page-actions">
        <button
          type="button"
          className="page-btn page-btn-light"
          onClick={() => navigate("/food-menu")}
          disabled={submitting}
        >
          Back
        </button>

        <button
          type="button"
          className="page-btn"
          onClick={submitBooking}
          disabled={submitting}
        >
          {submitting ? "Submitting..." : "Submit Booking"}
        </button>
      </div>
    </section>
  );
}
