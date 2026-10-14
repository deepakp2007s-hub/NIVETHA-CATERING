import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, ArrowRight, Utensils } from "lucide-react";
import foodService from "../services/foodService";
import { useBooking } from "../context/BookingContext";
import "./PageStyles.css";

const fallbackFoods = [
  { _id: "veg-meals", name: "Traditional Veg Meals", category: "Lunch", type: "Veg" },
  { _id: "breakfast", name: "South Indian Breakfast", category: "Breakfast", type: "Veg" },
  { _id: "biryani", name: "Biryani Menu", category: "Lunch / Dinner", type: "Non-Veg" },
  { _id: "snacks", name: "Snacks & Refreshments", category: "Snacks", type: "Veg" },
];

export default function FoodMenu() {
  const navigate = useNavigate();
  const { booking, updateBooking } = useBooking();
  const [mealType, setMealType] = useState(booking.mealType || "Lunch");
  const [foodType, setFoodType] = useState(booking.foodType || "Veg");
  const [foods, setFoods] = useState([]);
  const [selectedFoods, setSelectedFoods] = useState(booking.selectedFoods || []);
  const [message, setMessage] = useState("");

  useEffect(() => {
    let active = true;

    foodService.getAll()
      .then((response) => {
        const data = response.data?.foods || response.data || [];
        if (active && Array.isArray(data) && data.length) setFoods(data);
        else if (active) setFoods(fallbackFoods);
      })
      .catch(() => {
        if (active) {
          setFoods(fallbackFoods);
          setMessage("Showing sample menu options. Live menu could not be loaded.");
        }
      });

    return () => { active = false; };
  }, []);

  const filteredFoods = foods.filter((food) => {
    const type = String(food.type || "Veg").toLowerCase();
    return type.includes(foodType.toLowerCase()) || type === "both" || type === "all";
  });

  function toggleFood(food) {
    const id = food._id || food.id || food.name;
    setSelectedFoods((current) =>
      current.some((item) => (item._id || item.id || item.name) === id)
        ? current.filter((item) => (item._id || item.id || item.name) !== id)
        : [...current, food]
    );
  }

  function continueNext() {
    updateBooking({ mealType, foodType, selectedFoods });
    navigate("/booking");
  }

  return (
    <section className="page-container">
      <div className="page-heading">
        <span className="page-kicker">STEP 4 OF 5</span>
        <h1>Choose your food menu</h1>
        <p>Choose meal preferences and select the foods you would like.</p>
      </div>

      <div className="page-form">
        <label>Meal</label>
        <div className="choice-row">
          {["Breakfast", "Lunch", "Dinner"].map((meal) => (
            <button key={meal} type="button" className={`choice-chip ${mealType === meal ? "active" : ""}`} onClick={() => setMealType(meal)}>
              {meal}
            </button>
          ))}
        </div>

        <label>Food preference</label>
        <div className="choice-row">
          {["Veg", "Non-Veg"].map((type) => (
            <button key={type} type="button" className={`choice-chip ${foodType === type ? "active" : ""}`} onClick={() => setFoodType(type)}>
              {type}
            </button>
          ))}
        </div>

        {message && <p className="page-notice">{message}</p>}

        <div className="food-selection-grid">
          {filteredFoods.map((food) => {
            const id = food._id || food.id || food.name;
            const isSelected = selectedFoods.some((item) => (item._id || item.id || item.name) === id);

            return (
              <button
                type="button"
                key={id}
                className={`food-option ${isSelected ? "selected" : ""}`}
                onClick={() => toggleFood(food)}
              >
                <Utensils size={23} />
                <strong>{food.name}</strong>
                <span>{food.category || food.type || "Menu item"}</span>
                <small>{isSelected ? "✓ Selected" : "Add to menu"}</small>
              </button>
            );
          })}
        </div>

        <p className="page-muted">Selected items: {selectedFoods.length}</p>

        <div className="page-actions">
          <button className="page-btn page-btn-light" onClick={() => navigate("/catering")}>
            <ArrowLeft size={18} /> Back
          </button>
          <button className="page-btn" onClick={continueNext}>
            Continue <ArrowRight size={18} />
          </button>
        </div>
      </div>
    </section>
  );
}