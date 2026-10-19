
import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import {
  CalendarDays,
  MapPin,
  Users,
  ArrowRight,
} from "lucide-react";
import bookingService from "../services/bookingService";
import Loading from "../components/Loading";
import "./PageStyles.css";

function formatDate(value) {
  if (!value) return "Date pending";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) return value;

  return date.toLocaleDateString("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

export default function MyBookings() {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let active = true;

    async function loadBookings() {
      try {
        setLoading(true);
        setError("");

        const response = await bookingService.getMyBookings();

        // bookingService may already unwrap response.data.
        const data =
          response?.bookings ||
          response?.data?.bookings ||
          response?.data?.data ||
          response?.data ||
          response;

        if (active) {
          setBookings(Array.isArray(data) ? data : []);
        }
      } catch (err) {
        if (active) {
          setError(
            err.response?.data?.message ||
              err.message ||
              "Unable to load bookings."
          );
        }
      } finally {
        if (active) setLoading(false);
      }
    }

    loadBookings();

    return () => {
      active = false;
    };
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

        <Link className="page-btn" to="/customer-type">
          + New Booking
        </Link>
      </div>

      {error && (
        <div>
          <p className="page-error" role="alert">{error}</p>
          <button
            className="page-btn"
            type="button"
            onClick={() => window.location.reload()}
          >
            Try Again
          </button>
        </div>
      )}

      {!error && bookings.length === 0 ? (
        <div className="page-empty">
          <CalendarDays size={44} />
          <h2>No bookings yet</h2>
          <p>Your submitted catering bookings will appear here.</p>
          <Link className="page-btn" to="/customer-type">
            Book Catering
          </Link>
        </div>
      ) : (
        !error && (
          <div className="booking-list">
            {bookings.map((item, index) => {
              const id = item._id || item.id || item.bookingId;
              const status = String(item.status || "pending")
                .toLowerCase();

              return (
                <article
                  className="booking-item"
                  key={id || `booking-${index}`}
                >
                  <div className="booking-item-top">
                    <span className={`status-pill status-${status}`}>
                      {status}
                    </span>
                    <small>#{String(id || "").slice(-8) || "New"}</small>
                  </div>

                  <h3>
                    {item.eventType || item.eventName || "Catering Event"}
                  </h3>

                  <p>
                    <CalendarDays size={16} />
                    {formatDate(item.functionDate || item.eventDate)}
                  </p>

                  <p>
                    <MapPin size={16} />
                    {item.location || "Location not provided"}
                  </p>

                  <p>
                    <Users size={16} />
                    {item.numberOfPersons || item.guestCount || "—"} guests
                  </p>

                  {id ? (
                    <Link
                      to={`/my-bookings/${id}`}
                      className="booking-view-link"
                    >
                      View details <ArrowRight size={16} />
                    </Link>
                  ) : (
                    <span>Booking details unavailable</span>
                  )}
                </article>
              );
            })}
          </div>
        )
      )}
    </section>
  );
}
