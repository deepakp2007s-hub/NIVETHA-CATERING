
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  ArrowLeft,
  ArrowRight,
  CalendarDays,
  MapPin,
  Users,
} from "lucide-react";
import { useBooking } from "../context/BookingContext";
import "./PageStyles.css";

function getLocalDate() {
  const date = new Date();
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");

  return `${year}-${month}-${day}`;
}

export default function EventDetails() {
  const navigate = useNavigate();
  const { booking, updateBooking } = useBooking();

  const [form, setForm] = useState({
    functionDate: booking.functionDate || "",
    functionTime: booking.functionTime || "",
    location: booking.location || "",
    numberOfPersons: booking.numberOfPersons || "",
    extraRequirements: booking.extraRequirements || "",
  });

  const [error, setError] = useState("");

  function change(event) {
    const { name, value } = event.target;

    setForm((previous) => ({
      ...previous,
      [name]: value,
    }));

    setError("");
  }

  function submit(event) {
    event.preventDefault();
    setError("");

    const today = getLocalDate();
    const location = form.location.trim();
    const guestCount = Number(form.numberOfPersons);
    const extraRequirements = form.extraRequirements.trim();

    if (!form.functionDate || form.functionDate < today) {
      setError("Please choose today or a future event date.");
      return;
    }

    if (!form.functionTime) {
      setError("Please select the function time.");
      return;
    }

    if (!location) {
      setError("Please enter the event location.");
      return;
    }

    if (
      !Number.isSafeInteger(guestCount) ||
      guestCount < 1 ||
      guestCount > 1000000
    ) {
      setError("Enter a valid whole number of guests.");
      return;
    }

    if (extraRequirements.length > 1000) {
      setError("Extra requirements must be 1000 characters or less.");
      return;
    }

    updateBooking({
      ...form,
      location,
      numberOfPersons: guestCount,
      extraRequirements,
    });

    navigate("/catering");
  }

  return (
    <section className="page-container page-narrow">
      <div className="page-heading">
        <span className="page-kicker">STEP 2 OF 5</span>
        <h1>Tell us about your event</h1>
        <p>
          Share the date, venue and expected number of guests.
        </p>
      </div>

      <form className="page-form" onSubmit={submit}>
        <label htmlFor="functionDate">
          Function date <CalendarDays size={16} />
        </label>

        <input
          id="functionDate"
          type="date"
          name="functionDate"
          min={getLocalDate()}
          value={form.functionDate}
          onChange={change}
          required
        />

        <label htmlFor="functionTime">Function time</label>

        <input
          id="functionTime"
          type="time"
          name="functionTime"
          value={form.functionTime}
          onChange={change}
          required
        />

        <label htmlFor="location">
          Event location <MapPin size={16} />
        </label>

        <input
          id="location"
          name="location"
          value={form.location}
          onChange={change}
          placeholder="Enter venue address"
          maxLength={300}
          autoComplete="street-address"
          required
        />

        <label htmlFor="numberOfPersons">
          Number of guests <Users size={16} />
        </label>

        <input
          id="numberOfPersons"
          type="number"
          name="numberOfPersons"
          min="1"
          max="1000000"
          step="1"
          value={form.numberOfPersons}
          onChange={change}
          placeholder="e.g. 150"
          required
        />

        <label htmlFor="extraRequirements">
          Extra requirements (optional)
        </label>

        <textarea
          id="extraRequirements"
          name="extraRequirements"
          rows={4}
          value={form.extraRequirements}
          onChange={change}
          placeholder="Any special requests?"
          maxLength={1000}
        />

        <small className="page-muted">
          {form.extraRequirements.length}/1000 characters
        </small>

        {error && (
          <p className="page-error" role="alert">
            {error}
          </p>
        )}

        <div className="page-actions">
          <button
            type="button"
            className="page-btn page-btn-light"
            onClick={() => navigate("/customer-type")}
          >
            <ArrowLeft size={18} /> Back
          </button>

          <button type="submit" className="page-btn">
            Continue <ArrowRight size={18} />
          </button>
        </div>
      </form>
    </section>
  );
}
