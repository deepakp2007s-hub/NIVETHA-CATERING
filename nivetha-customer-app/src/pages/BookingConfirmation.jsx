
import { Link, useLocation } from "react-router-dom";
import {
  CheckCircle2,
  CalendarDays,
  MapPin,
  Users,
} from "lucide-react";
import { useBooking } from "../context/BookingContext";
import "./PageStyles.css";

export default function BookingConfirmation() {
  const { booking } = useBooking();
  const location = useLocation();

  const responseBooking = location.state?.booking || {};
  const saved =
    responseBooking.booking ||
    responseBooking.data?.booking ||
    responseBooking.data ||
    responseBooking;

  const bookingId =
    saved.bookingId ||
    saved._id ||
    saved.id ||
    booking.bookingId;

  const functionDate =
    saved.functionDate || booking.functionDate;

  const eventLocation =
    saved.location || booking.location;

  const numberOfPersons =
    saved.numberOfPersons ?? booking.numberOfPersons;

  const formattedDate = functionDate
    ? (() => {
        const date = new Date(functionDate);

        return Number.isNaN(date.getTime())
          ? functionDate
          : date.toLocaleDateString("en-IN", {
              day: "2-digit",
              month: "short",
              year: "numeric",
            });
      })()
    : "Date not available";

  return (
    <section className="page-container page-narrow">
      <div className="confirmation-card">
        <div className="confirmation-icon">
          <CheckCircle2 size={54} />
        </div>

        <span className="page-kicker">REQUEST SUBMITTED</span>

        <h1>Thank you for your booking!</h1>

        <p>
          Your catering request has been submitted. The team can
          review it and confirm availability.
        </p>

        {bookingId && (
          <div className="booking-reference">
            <span>Booking reference</span>
            <strong>{bookingId}</strong>
          </div>
        )}

        <div className="confirmation-details">
          <p>
            <CalendarDays size={18} />
            <span>{formattedDate}</span>
          </p>

          <p>
            <MapPin size={18} />
            <span>{eventLocation || "Location not available"}</span>
          </p>

          <p>
            <Users size={18} />
            <span>{numberOfPersons || "—"} guests</span>
          </p>
        </div>

        <div className="page-actions page-actions-center">
          <Link to="/my-bookings" className="page-btn">
            View My Bookings
          </Link>

          <Link to="/" className="page-btn page-btn-light">
            Back to Home
          </Link>
        </div>
      </div>
    </section>
  );
}
