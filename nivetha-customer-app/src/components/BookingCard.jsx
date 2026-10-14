import { Link } from "react-router-dom";
import { CalendarDays, MapPin, Users, ArrowUpRight } from "lucide-react";
import "./BookingCard.css";

export default function BookingCard({ booking }) {
  if (!booking) return null;

  const id = booking._id || booking.id;
  const eventName = booking.eventType || booking.eventName || "Catering Event";
  const eventDate = booking.eventDate || booking.functionDate || booking.date;
  const persons = booking.numberOfPersons ?? booking.persons ?? booking.guestCount;
  const location = booking.location || booking.eventLocation || "Location not provided";
  const status = String(booking.status || "pending").toLowerCase();

  const formattedDate = eventDate
    ? new Date(eventDate).toLocaleDateString("en-IN", {
        day: "numeric",
        month: "short",
        year: "numeric",
      })
    : "Date not provided";

  return (
    <article className="nv-booking-card">
      <div className="nv-booking-card-top">
        <div className="nv-booking-symbol">N</div>
        <span className={`nv-booking-status nv-status-${status}`}>
          {status.replace(/[-_]/g, " ")}
        </span>
      </div>

      <h3>{eventName}</h3>
      <p className="nv-booking-id">Booking ID: {id || "Pending"}</p>

      <div className="nv-booking-info">
        <p><CalendarDays size={16} /> {formattedDate}</p>
        <p><Users size={16} /> {persons ?? "Not specified"} guests</p>
        <p><MapPin size={16} /> {location}</p>
      </div>

      {id ? (
        <Link to={`/my-bookings/${id}`} className="nv-booking-details">
          View booking <ArrowUpRight size={16} />
        </Link>
      ) : (
        <span className="nv-booking-details nv-booking-unavailable">
          Booking details unavailable
        </span>
      )}
    </article>
  );
}