import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, ArrowRight, CalendarDays, MapPin, Users } from "lucide-react";
import { useBooking } from "../context/BookingContext";
import "./PageStyles.css";

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
    setForm({ ...form, [event.target.name]: event.target.value });
  }

  function submit(event) {
    event.preventDefault();
    if (Number(form.numberOfPersons) < 1) {
      setError("Please enter at least one guest.");
      return;
    }

    updateBooking({ ...form, numberOfPersons: Number(form.numberOfPersons) });
    navigate("/catering");
  }

  return (
    <section className="page-container page-narrow">
      <div className="page-heading">
        <span className="page-kicker">STEP 2 OF 5</span>
        <h1>Tell us about your event</h1>
        <p>Share the date, venue and expected number of guests.</p>
      </div>

      <form className="page-form" onSubmit={submit}>
        <label>Function date <CalendarDays size={16} /></label>
        <input
          type="date"
          name="functionDate"
          min={new Date().toISOString().split("T")[0]}
          value={form.functionDate}
          onChange={change}
          required
        />

        <label>Function time</label>
        <input type="time" name="functionTime" value={form.functionTime} onChange={change} required />

        <label>Event location <MapPin size={16} /></label>
        <input
          name="location"
          value={form.location}
          onChange={change}
          placeholder="Enter venue address"
          required
        />

        <label>Number of guests <Users size={16} /></label>
        <input
          type="number"
          name="numberOfPersons"
          min="1"
          value={form.numberOfPersons}
          onChange={change}
          placeholder="e.g. 150"
          required
        />

        <label>Extra requirements (optional)</label>
        <textarea
          name="extraRequirements"
          rows="4"
          value={form.extraRequirements}
          onChange={change}
          placeholder="Any special requests?"
        />

        {error && <p className="page-error">{error}</p>}

        <div className="page-actions">
          <button type="button" className="page-btn page-btn-light" onClick={() => navigate("/customer-type")}>
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