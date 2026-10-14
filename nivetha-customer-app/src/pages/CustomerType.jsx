import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowRight, Heart, Cake, Users, Building2, GraduationCap, Church } from "lucide-react";
import { useBooking } from "../context/BookingContext";
import "./PageStyles.css";

const events = [
  { name: "Wedding", icon: Heart },
  { name: "Engagement", icon: Heart },
  { name: "Birthday", icon: Cake },
  { name: "House Function", icon: Users },
  { name: "Corporate Event", icon: Building2 },
  { name: "College / School Event", icon: GraduationCap },
  { name: "Temple Function", icon: Church },
  { name: "Other", icon: Users },
];

export default function CustomerType() {
  const navigate = useNavigate();
  const { booking, updateBooking } = useBooking();
  const [selected, setSelected] = useState(booking.eventType || "");

  function continueBooking() {
    if (!selected) return;
    updateBooking({ eventType: selected });
    navigate("/event-details");
  }

  return (
    <section className="page-container">
      <div className="page-heading">
        <span className="page-kicker">STEP 1 OF 5</span>
        <h1>What is your occasion?</h1>
        <p>Select the type of function you are planning.</p>
      </div>

      <div className="selection-grid">
        {events.map(({ name, icon: Icon }) => (
          <button
            type="button"
            key={name}
            className={`selection-card ${selected === name ? "selected" : ""}`}
            onClick={() => setSelected(name)}
          >
            <Icon size={28} />
            <strong>{name}</strong>
            <span>{selected === name ? "Selected ✓" : "Choose event"}</span>
          </button>
        ))}
      </div>

      <div className="page-actions">
        <button className="page-btn" onClick={continueBooking} disabled={!selected}>
          Continue <ArrowRight size={18} />
        </button>
      </div>
    </section>
  );
}