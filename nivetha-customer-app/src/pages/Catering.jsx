
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  ChefHat,
  Users,
  ArrowLeft,
  ArrowRight,
} from "lucide-react";
import { useBooking } from "../context/BookingContext";
import "./PageStyles.css";

const options = [
  {
    id: "cooking",
    title: "Cooking Service",
    text: "Experienced cooks prepare food at your venue.",
    icon: ChefHat,
  },
  {
    id: "serving",
    title: "Serving Staff",
    text: "Staff help serve food to your guests.",
    icon: Users,
  },
];

export default function Catering() {
  const navigate = useNavigate();
  const { booking, updateBooking } = useBooking();

  const [selected, setSelected] = useState(
    booking.cateringServices || []
  );
  const [error, setError] = useState("");

  function toggle(id) {
    setSelected((current) =>
      current.includes(id)
        ? current.filter((item) => item !== id)
        : [...current, id]
    );

    setError("");
  }

  function continueNext() {
    if (selected.length === 0) {
      setError("Select at least one catering service to continue.");
      return;
    }

    updateBooking({
      cateringServices: selected,
    });

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
        {options.map(({ id, title, text, icon: Icon }) => {
          const isSelected = selected.includes(id);

          return (
            <button
              type="button"
              key={id}
              className={`selection-card ${
                isSelected ? "selected" : ""
              }`}
              onClick={() => toggle(id)}
              aria-pressed={isSelected}
            >
              <Icon size={30} />
              <strong>{title}</strong>
              <span>{text}</span>
              <small>
                {isSelected ? "✓ Selected" : "Tap to select"}
              </small>
            </button>
          );
        })}
      </div>

      {error && (
        <p className="page-error" role="alert">
          {error}
        </p>
      )}

      <div className="page-actions">
        <button
          type="button"
          className="page-btn page-btn-light"
          onClick={() => navigate("/event-details")}
        >
          <ArrowLeft size={18} /> Back
        </button>

        <button
          type="button"
          className="page-btn"
          onClick={continueNext}
        >
          Continue <ArrowRight size={18} />
        </button>
      </div>
    </section>
  );
}
