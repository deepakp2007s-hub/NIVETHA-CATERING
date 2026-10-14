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

    if (!booking.eventType || !booking.functionDate || !booking.location || !booking.numberOfPersons) {
      setError("Please complete the event details before submitting.");
      navigate("/customer-type");
      return;
    }

    try {
      submissionInProgress.current = true;
      setSubmitting(true);
      const response = await bookingService.create({
        eventType: booking.eventType,
        functionDate: booking.functionDate,
        functionTime: booking.functionTime,
        location: booking.location,
        numberOfPersons: Number(booking.numberOfPersons),
        extraRequirements: booking.extraRequirements,
        cateringServices: booking.cateringServices,
        mealType: booking.mealType,
        foodType: booking.foodType,
        selectedFoods: booking.selectedFoods,
      });

      const created = response.data?.booking || response.data?.data || response.data;
      updateBooking({ bookingId: created?._id || created?.id || created?.bookingId || "" });
      navigate("/booking-confirmation", {
        state: { booking: created },
      });
    } catch (err) {
      setError(err.message || "Unable to submit your booking. Please try again.");
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
        <div className="summary-title"><CalendarDays size={20} /><strong>Event details</strong></div>
        <div className="summary-row"><span>Occasion</span><strong>{booking.eventType || "Not selected"}</strong></div>
        <div className="summary-row"><span>Date</span><strong>{booking.functionDate || "Not selected"}</strong></div>
        <div className="summary-row"><span>Time</span><strong>{booking.functionTime || "Not selected"}</strong></div>
        <div className="summary-row"><span><MapPin size={15} /> Location</span><strong>{booking.location || "Not entered"}</strong></div>
        <div className="summary-row"><span><Users size={15} /> Guests</span><strong>{booking.numberOfPersons || 0}</strong></div>
        <div className="summary-row"><span><Utensils size={15} /> Catering</span><strong>{booking.cateringServices?.join(", ") || "Not selected"}</strong></div>
        <div className="summary-row"><span>Meal / Preference</span><strong>{booking.mealType || "—"} / {booking.foodType || "—"}</strong></div>
        <div className="summary-row"><span>Selected foods</span><strong>{booking.selectedFoods?.map((food) => food.name).join(", ") || "Menu to be discussed"}</strong></div>
        {booking.extraRequirements && (
          <div className="summary-extra">
            <strong>Extra requirements</strong>
            <p>{booking.extraRequirements}</p>
          </div>
        )}
      </div>

      {error && <p className="page-error">{error}</p>}

      <div className="page-actions">
        <button className="page-btn page-btn-light" onClick={() => navigate("/food-menu")}>Back</button>
        <button className="page-btn" onClick={submitBooking} disabled={submitting}>
          {submitting ? "Submitting..." : "Submit Booking"}
        </button>
      </div>
    </section>
  );
}
