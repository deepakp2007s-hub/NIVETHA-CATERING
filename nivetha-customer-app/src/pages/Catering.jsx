import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { ChefHat, Users, ArrowLeft, ArrowRight } from "lucide-react";
import { useBooking } from "../context/BookingContext";
import "./PageStyles.css";

const options = [
  { id: "cooking", title: "Cooking Service", text: "Experienced cooks prepare food at your venue.", icon: ChefHat },
  { id: "serving", title: "Serving Staff", text: "Staff help serve food to your guests.", icon: Users },
];

export default function Catering() {
  const navigate = useNavigate();
  const { booking, updateBooking } = useBooking();
  const [selected, setSelected] = useState(booking.cateringServices || []);
  const [error, setError] = useState("");

  function toggle(id) {
    setSelected((current) =>
      current.includes(id) ? current.filter((item) => item !== id) : [...current, id]
    );
  }

  function continueNext() {
    if (selected.length === 0) {
      setError("Select at least one catering service to continue.");
      return;
    }
    setError("");
    updateBooking({ cateringServices: selected });
    navigate("/food-menu");
  }

  return (
    <section className="page-container">
      <div className="page-heading">
        <span className="page-kicker">STEP 3 OF 5</span>
        <h1>Choose catering services</h1>
        <p>Select one or both services for your function.</p>
      </div>

      <div className="selection-grid">
        {options.map(({ id, title, text, icon: Icon }) => (
          <button
            type="button"
            key={id}
            className={`selection-card ${selected.includes(id) ? "selected" : ""}`}
            onClick={() => toggle(id)}
          >
            <Icon size={30} />
            <strong>{title}</strong>
            <span>{text}</span>
            <small>{selected.includes(id) ? "✓ Selected" : "Tap to select"}</small>
          </button>
        ))}
      </div>

      {error && <p className="page-error" role="alert">{error}</p>}

      <div className="page-actions">
        <button className="page-btn page-btn-light" onClick={() => navigate("/event-details")}>
          <ArrowLeft size={18} /> Back
        </button>
        <button className="page-btn" onClick={continueNext}>
          Continue <ArrowRight size={18} />
        </button>
      </div>
    </section>
  );
}
