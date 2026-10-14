import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { CalendarDays, MapPin, Users, Utensils } from "lucide-react";
import bookingService from "../services/bookingService";
import Loading from "../components/Loading";
import "./PageStyles.css";

export default function BookingDetails() {
  const { id } = useParams();
  const [booking, setBooking] = useState(null);
  const [loading, setLoading] = useState(true);
  const [cancelling, setCancelling] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    let active = true;

    bookingService.getById(id)
      .then((response) => {
        if (active) setBooking(response.data?.booking || response.data);
      })
      .catch((err) => {
        if (active) setError(err.message || "Unable to load this booking.");
      })
      .finally(() => {
        if (active) setLoading(false);
      });

    return () => { active = false; };
  }, [id]);

  async function cancelBooking() {
    if (!window.confirm("Cancel this pending booking? This action cannot be undone.")) return;
    setCancelling(true);
    setError("");
    try {
      const updated = await bookingService.cancel(id);
      setBooking((previous) => ({ ...previous, ...(updated?.data || updated), status: "cancelled" }));
    } catch (err) {
      setError(err.message || "Unable to cancel this booking.");
    } finally {
      setCancelling(false);
    }
  }

  if (loading) return <Loading />;

  if (error || !booking) {
    return (
      <section className="page-container page-narrow">
        <p className="page-error">{error || "Booking not found."}</p>
        <Link to="/my-bookings" className="page-btn">Back to My Bookings</Link>
      </section>
    );
  }

  const status = String(booking.status || "pending").toLowerCase();

  return (
    <section className="page-container page-narrow">
      <div className="page-heading">
        <span className="page-kicker">BOOKING DETAILS</span>
        <h1>{booking.eventType || "Catering Event"}</h1>
        <span className={`status-pill status-${status}`}>{status}</span>
      </div>

      <div className="summary-card">
        <div className="summary-row"><span><CalendarDays size={16} /> Date</span><strong>{booking.functionDate || booking.eventDate || "—"}</strong></div>
        <div className="summary-row"><span>Time</span><strong>{booking.functionTime || "—"}</strong></div>
        <div className="summary-row"><span><MapPin size={16} /> Location</span><strong>{booking.location || "—"}</strong></div>
        <div className="summary-row"><span><Users size={16} /> Guests</span><strong>{booking.numberOfPersons || booking.guestCount || "—"}</strong></div>
        <div className="summary-row"><span><Utensils size={16} /> Meal</span><strong>{booking.mealType || "—"}</strong></div>
        <div className="summary-row"><span>Food preference</span><strong>{booking.foodType || "—"}</strong></div>
        <div className="summary-row"><span>Catering services</span><strong>{booking.cateringServices?.join(", ") || booking.cateringService || "—"}</strong></div>
        <div className="summary-row"><span>Selected foods</span><strong>{booking.selectedFoodNames?.join(", ") || booking.selectedFoods?.map((food) => typeof food === "string" ? food : food.name).join(", ") || "—"}</strong></div>
        <div className="summary-extra">
          <strong>Extra requirements</strong>
          <p>{booking.extraRequirements || "No additional requirements."}</p>
        </div>
      </div>

      {error && <p className="page-error" role="alert">{error}</p>}

      <div className="page-actions">
        <Link to="/my-bookings" className="page-btn page-btn-light">Back</Link>
        {status === "pending" && (
          <>
            <Link to={`/my-bookings/${id}/edit`} className="page-btn">Edit Booking</Link>
            <button type="button" className="page-btn page-btn-danger" onClick={cancelBooking} disabled={cancelling}>
              {cancelling ? "Cancelling..." : "Cancel Booking"}
            </button>
          </>
        )}
      </div>
    </section>
  );
}
