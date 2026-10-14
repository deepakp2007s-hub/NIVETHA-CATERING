import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { CalendarDays, MapPin, Users, ArrowRight } from "lucide-react";
import bookingService from "../services/bookingService";
import Loading from "../components/Loading";
import "./PageStyles.css";

export default function MyBookings() {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let active = true;

    bookingService.getMyBookings()
      .then((response) => {
        const data = response.data?.bookings || response.data || [];
        if (active) setBookings(Array.isArray(data) ? data : []);
      })
      .catch((err) => {
        if (active) setError(err.message || "Unable to load bookings.");
      })
      .finally(() => {
        if (active) setLoading(false);
      });

    return () => { active = false; };
  }, []);

  if (loading) return <Loading />;

  return (
    <section className="page-container">
      <div className="page-heading page-heading-row">
        <div>
          <span className="page-kicker">YOUR EVENTS</span>
          <h1>My Bookings</h1>
          <p>Track your catering requests and event details.</p>
        </div>
        <Link className="page-btn" to="/customer-type">+ New Booking</Link>
      </div>

      {error && <p className="page-error">{error}</p>}

      {!bookings.length && !error ? (
        <div className="page-empty">
          <CalendarDays size={44} />
          <h2>No bookings yet</h2>
          <p>Your submitted catering bookings will appear here.</p>
          <Link className="page-btn" to="/customer-type">Book Catering</Link>
        </div>
      ) : (
        <div className="booking-list">
          {bookings.map((item) => {
            const id = item._id || item.id || item.bookingId;
            const status = String(item.status || "pending").toLowerCase();

            return (
              <article className="booking-item" key={id}>
                <div className="booking-item-top">
                  <span className={`status-pill status-${status}`}>{status}</span>
                  <small>#{String(id || "").slice(-8) || "New"}</small>
                </div>
                <h3>{item.eventType || item.eventName || "Catering Event"}</h3>
                <p><CalendarDays size={16} /> {item.functionDate || item.eventDate || "Date pending"}</p>
                <p><MapPin size={16} /> {item.location || "Location not provided"}</p>
                <p><Users size={16} /> {item.numberOfPersons || item.guestCount || "—"} guests</p>
                <Link to={`/my-bookings/${id}`} className="booking-view-link">
                  View details <ArrowRight size={16} />
                </Link>
              </article>
            );
          })}
        </div>
      )}
    </section>
  );
}