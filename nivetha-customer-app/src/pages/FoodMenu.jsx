
import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, ArrowRight, Utensils } from "lucide-react";
import foodService from "../services/foodService";
import { useBooking } from "../context/BookingContext";
import "./PageStyles.css";

const fallbackFoods = [
  {
    _id: "veg-meals",
    name: "Traditional Veg Meals",
    category: "Lunch",
    type: "Veg",
    isSample: true,
  },
  {
    _id: "breakfast",
    name: "South Indian Breakfast",
    category: "Breakfast",
    type: "Veg",
    isSample: true,
  },
  {
    _id: "biryani",
    name: "Biryani Menu",
    category: "Lunch / Dinner",
    type: "Non-Veg",
    isSample: true,
  },
  {
    _id: "snacks",
    name: "Snacks & Refreshments",
    category: "Snacks",
    type: "Veg",
    isSample: true,
  },
];

function getFoodId(food) {
  return String(food._id || food.id || food.name || "");
}

function normalizeFoods(response) {
  let data = response?.data ?? response;

  if (Array.isArray(data?.foods)) data = data.foods;
  else if (Array.isArray(data?.data)) data = data.data;
  else if (Array.isArray(data?.items)) data = data.items;

  return Array.isArray(data) ? data : [];
}

export default function FoodMenu() {
  const navigate = useNavigate();
  const { booking, updateBooking } = useBooking();

  const [mealType, setMealType] = useState(booking.mealType || "Lunch");
  const [foodType, setFoodType] = useState(booking.foodType || "Veg");
  const [foods, setFoods] = useState([]);
  const [selectedFoods, setSelectedFoods] = useState(
    booking.selectedFoods || []
  );
  const [loading, setLoading] = useState(true);
  const [usingFallback, setUsingFallback] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    let active = true;

    async function loadFoods() {
      try {
        setLoading(true);
        setError("");

        const response = await foodService.getAll();
        const data = normalizeFoods(response);

        if (!active) return;

        const availableFoods = data.filter(
          (food) => food.available !== false && food.isAvailable !== false
        );

        setFoods(availableFoods);
        setUsingFallback(false);

        if (!availableFoods.length) {
          setMessage("No menu items are currently available.");
        }
      } catch (err) {
        if (!active) return;

        setFoods(fallbackFoods);
        setUsingFallback(true);
        setMessage(
          "Live menu could not be loaded. Sample items are shown for preview only."
        );
      } finally {
        if (active) setLoading(false);
      }
    }

    loadFoods();

    return () => {
      active = false;
    };
  }, []);

  const filteredFoods = useMemo(() => {
    return foods.filter((food) => {
      const type = String(food.type || "Veg").toLowerCase();

      return (
        type === foodType.toLowerCase() ||
        type === "both" ||
        type === "all"
      );
    });
  }, [foods, foodType]);

  function toggleFood(food) {
    if (usingFallback || food.isSample) return;

    const id = getFoodId(food);

    if (!id) return;

    setSelectedFoods((current) =>
      current.some((item) => getFoodId(item) === id)
        ? current.filter((item) => getFoodId(item) !== id)
        : [...current, food]
    );

    setError("");
  }

  function continueNext() {
    setError("");

    if (usingFallback) {
      setError(
        "The live menu is unavailable. Please try again before continuing."
      );
      return;
    }

    if (!selectedFoods.length) {
      setError("Please select at least one food item.");
      return;
    }

    updateBooking({
      mealType,
      foodType,
      selectedFoods,
    });

    navigate("/booking");
  }

  return (
    <section className="page-container">
      <div className="page-heading">
        <span className="page-kicker">STEP 4 OF 5</span>
        <h1>Choose your food menu</h1>
        <p>
          Choose your meal preferences and select the foods you would like.
        </p>
      </div>

      <div className="page-form">
        <label>Meal</label>

        <div className="choice-row">
          {["Breakfast", "Lunch", "Dinner"].map((meal) => (
            <button
              key={meal}
              type="button"
              className={`choice-chip ${
                mealType === meal ? "active" : ""
              }`}
              aria-pressed={mealType === meal}
              onClick={() => setMealType(meal)}
            >
              {meal}
            </button>
          ))}
        </div>

        <label>Food preference</label>

        <div className="choice-row">
          {["Veg", "Non-Veg"].map((type) => (
            <button
              key={type}
              type="button"
              className={`choice-chip ${
                foodType === type ? "active" : ""
              }`}
              aria-pressed={foodType === type}
              onClick={() => setFoodType(type)}
            >
              {type}
            </button>
          ))}
        </div>

        {loading && <p className="page-muted">Loading menu...</p>}

        {message && <p className="page-notice">{message}</p>}

        {error && (
          <p className="page-error" role="alert">
            {error}
          </p>
        )}

        {!loading && !filteredFoods.length && !usingFallback && (
          <p className="page-muted">
            No {foodType} menu items are available right now.
          </p>
        )}

        <div className="food-selection-grid">
          {!loading &&
            filteredFoods.map((food) => {
              const id = getFoodId(food);
              const isSelected = selectedFoods.some(
                (item) => getFoodId(item) === id
              );

              return (
                <button
                  type="button"
                  key={id}
                  className={`food-option ${
                    isSelected ? "selected" : ""
                  }`}
                  onClick={() => toggleFood(food)}
                  disabled={usingFallback || food.isSample}
                  aria-pressed={isSelected}
                >
                  <Utensils size={23} />
                  <strong>{food.name}</strong>
                  <span>{food.category || food.type || "Menu item"}</span>
                  <small>
                    {usingFallback
                      ? "Preview only"
                      : isSelected
                      ? "✓ Selected"
                      : "Add to menu"}
                  </small>
                </button>
              );
            })}
        </div>

        <p className="page-muted">
          Selected items: {selectedFoods.length}
        </p>

        <div className="page-actions">
          <button
            type="button"
            className="page-btn page-btn-light"
            onClick={() => navigate("/catering")}
          >
            <ArrowLeft size={18} /> Back
          </button>

          <button
            type="button"
            className="page-btn"
            onClick={continueNext}
            disabled={loading || usingFallback || !foods.length}
          >
            Continue <ArrowRight size={18} />
          </button>
        </div>
      </div>
    </section>
  );
}
