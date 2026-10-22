
import { useCallback, useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import api from "../services/api";
import "./FoodMenu.css";

const CATEGORIES = [
  "Breakfast",
  "Lunch",
  "Dinner",
  "Snacks",
  "Desserts",
  "Drinks",
];

const getFoodList = (response) => {
  const data = response?.data;

  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.foods)) return data.foods;
  if (Array.isArray(data?.data)) return data.data;
  if (Array.isArray(data?.data?.foods)) return data.data.foods;

  return [];
};

const getFoodId = (food) => food?._id || food?.id;

const getFoodType = (food) => {
  const value = String(food?.type || food?.foodType || "Veg").toLowerCase();
  return value === "non-veg" || value === "nonveg" ? "Non-Veg" : "Veg";
};

export default function FoodMenu() {
  const navigate = useNavigate();

  const [foods, setFoods] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [search, setSearch] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("All");
  const [typeFilter, setTypeFilter] = useState("All");
  const [availabilityFilter, setAvailabilityFilter] = useState("All");
  const [busyId, setBusyId] = useState("");

  const loadFoods = useCallback(async () => {
    try {
      setLoading(true);
      setError("");

      const response = await api.get("/foods");
      setFoods(getFoodList(response));
    } catch (err) {
      setError(
        err.response?.data?.message ||
          "Unable to load foods. Check owner login and backend connection."
      );
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadFoods();
  }, [loadFoods]);

  const toggleAvailability = async (food) => {
    const id = getFoodId(food);
    if (!id || busyId) return;

    const currentAvailability = food.available ?? food.isAvailable ?? true;

    try {
      setBusyId(String(id));
      setError("");
      setNotice("");

      await api.patch(`/foods/${id}/availability`);

      setFoods((current) =>
        current.map((item) =>
          String(getFoodId(item)) === String(id)
            ? { ...item, available: !currentAvailability }
            : item
        )
      );

      setNotice(
        currentAvailability
          ? "Food is now unavailable."
          : "Food is now available."
      );
    } catch (err) {
      setError(
        err.response?.data?.message ||
          "Could not update food availability."
      );
    } finally {
      setBusyId("");
    }
  };

  const deleteFood = async (food) => {
    const id = getFoodId(food);
    if (!id || busyId) return;

    if (!window.confirm(`Delete "${food.name}" from the food menu?`)) {
      return;
    }

    try {
      setBusyId(String(id));
      setError("");
      setNotice("");

      await api.delete(`/foods/${id}`);

      setFoods((current) =>
        current.filter((item) => String(getFoodId(item)) !== String(id))
      );

      setNotice("Food deleted successfully.");
    } catch (err) {
      setError(
        err.response?.data?.message ||
          "Could not delete food. Please try again."
      );
    } finally {
      setBusyId("");
    }
  };

  const filteredFoods = useMemo(() => {
    const query = search.trim().toLowerCase();

    return foods.filter((food) => {
      const nameMatches =
        !query ||
        [food.name, food.tamilName, food.description]
          .filter(Boolean)
          .some((value) =>
            String(value).toLowerCase().includes(query)
          );

      const category = food.category || food.meal || "Other";
      const type = getFoodType(food);
      const available = food.available ?? food.isAvailable ?? true;

      return (
        nameMatches &&
        (categoryFilter === "All" || category === categoryFilter) &&
        (typeFilter === "All" || type === typeFilter) &&
        (availabilityFilter === "All" ||
          (availabilityFilter === "Available" && available) ||
          (availabilityFilter === "Unavailable" && !available))
      );
    });
  }, [
    foods,
    search,
    categoryFilter,
    typeFilter,
    availabilityFilter,
  ]);

  const availableCount = foods.filter(
    (food) => food.available ?? food.isAvailable ?? true
  ).length;

  const openAddFood = () => navigate("/add-food");

  return (
    <main className="food-menu-page">
      <section className="food-menu-hero">
        <div className="food-hero-copy">
          <span className="food-menu-eyebrow">
            ✦ NIVETHA CATERING SERVICE
          </span>
          <h1>Food Menu</h1>
          <p>Manage your dishes and control what customers can order.</p>
        </div>

        <div className="food-hero-emblem" aria-hidden="true">
          <span>✦</span>
          <strong>N</strong>
          <small>EST. NIVETHA</small>
        </div>
      </section>

      <section className="food-menu-summary">
        <article className="food-summary-card">
          <span className="summary-icon">▤</span>
          <div>
            <p>Total Dishes</p>
            <strong>{loading ? "—" : foods.length}</strong>
          </div>
        </article>

        <article className="food-summary-card">
          <span className="summary-icon summary-icon-green">✓</span>
          <div>
            <p>Available</p>
            <strong>{loading ? "—" : availableCount}</strong>
          </div>
        </article>

        <article className="food-summary-card">
          <span className="summary-icon summary-icon-gold">◈</span>
          <div>
            <p>Categories</p>
            <strong>{CATEGORIES.length}</strong>
          </div>
        </article>
      </section>

      <section className="food-menu-toolbar">
        <div className="food-toolbar-heading">
          <div>
            <span className="food-menu-section-label">
              YOUR COLLECTION
            </span>
            <h2>Manage Dishes</h2>
            <p>Organise your catering menu in one place.</p>
          </div>

          <button
            type="button"
            className="food-add-button"
            onClick={openAddFood}
          >
            <span>＋</span> Add New Food
          </button>
        </div>

        <div className="food-filter-row">
          <label className="food-search-box">
            <span aria-hidden="true">⌕</span>
            <input
              type="search"
              placeholder="Search English or Tamil name..."
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              aria-label="Search food menu"
            />
          </label>

          <select
            value={categoryFilter}
            onChange={(event) => setCategoryFilter(event.target.value)}
            aria-label="Filter category"
          >
            <option value="All">All Categories</option>
            {CATEGORIES.map((category) => (
              <option value={category} key={category}>
                {category}
              </option>
            ))}
          </select>

          <select
            value={typeFilter}
            onChange={(event) => setTypeFilter(event.target.value)}
            aria-label="Filter food type"
          >
            <option value="All">Veg & Non-Veg</option>
            <option value="Veg">Veg</option>
            <option value="Non-Veg">Non-Veg</option>
          </select>

          <select
            value={availabilityFilter}
            onChange={(event) =>
              setAvailabilityFilter(event.target.value)
            }
            aria-label="Filter availability"
          >
            <option value="All">All Status</option>
            <option value="Available">Available</option>
            <option value="Unavailable">Unavailable</option>
          </select>
        </div>
      </section>

      {notice && (
        <div className="food-menu-notice" role="status">
          <span>✓</span>
          <p>{notice}</p>
          <button
            type="button"
            onClick={() => setNotice("")}
            aria-label="Dismiss message"
          >
            ×
          </button>
        </div>
      )}

      {error && (
        <div className="food-menu-error" role="alert">
          <span>!</span>
          <p>{error}</p>
          <button type="button" onClick={loadFoods} disabled={loading}>
            {loading ? "Loading..." : "Retry"}
          </button>
        </div>
      )}

      <section className="food-menu-results">
        <div className="food-results-heading">
          <div>
            <span className="food-menu-section-label">
              MENU OVERVIEW
            </span>
            <h2>Food Collection</h2>
          </div>

          <span className="food-results-count">
            {loading ? "Loading..." : `${filteredFoods.length} dishes`}
          </span>
        </div>

        {loading ? (
          <div className="food-menu-loading">
            <span className="food-loading-spinner" />
            <p>Loading food menu...</p>
          </div>
        ) : filteredFoods.length === 0 ? (
          <div className="food-menu-empty">
            <div className="food-empty-icon">♨</div>
            <h3>
              {foods.length ? "No matching dishes" : "Your menu is empty"}
            </h3>
            <p>
              {foods.length
                ? "Try another search term or change the filters."
                : "Add your first dish to start building the menu."}
            </p>

            {foods.length === 0 && (
              <button
                type="button"
                className="food-add-button"
                onClick={openAddFood}
              >
                <span>＋</span> Add First Food
              </button>
            )}
          </div>
        ) : (
          <div className="food-menu-grid">
            {filteredFoods.map((food, index) => {
              const id = getFoodId(food);
              const available = food.available ?? food.isAvailable ?? true;
              const category = food.category || food.meal || "Other";
              const type = getFoodType(food);
              const busy = String(id) === busyId;

              return (
                <article
                  className={`food-menu-card ${
                    !available ? "food-unavailable" : ""
                  }`}
                  key={id || `${food.name}-${index}`}
                >
                  <div className="food-card-image-wrap">
                    {food.image ? (
                      <img
                        src={food.image}
                        alt={food.name || "Food"}
                        className="food-card-image"
                        loading="lazy"
                      />
                    ) : (
                      <div className="food-image-placeholder">
                        <span>♨</span>
                        <small>NIVETHA</small>
                      </div>
                    )}

                    <span
                      className={`food-type-badge ${
                        type === "Non-Veg" ? "non-veg" : "veg"
                      }`}
                    >
                      <span />
                      {type}
                    </span>

                    {!available && (
                      <span className="food-unavailable-overlay">
                        Unavailable
                      </span>
                    )}
                  </div>

                  <div className="food-card-content">
                    <span className="food-meal-label">{category}</span>
                    <h3>{food.name || "Untitled Dish"}</h3>

                    {food.tamilName && (
                      <p className="food-tamil-name">{food.tamilName}</p>
                    )}

                    {food.description && (
                      <p className="food-description">
                        {food.description}
                      </p>
                    )}

                    <div className="food-card-status-row">
                      <span
                        className={`food-availability ${
                          available ? "is-available" : "is-unavailable"
                        }`}
                      >
                        <span />
                        {available ? "Available" : "Unavailable"}
                      </span>
                    </div>

                    <div className="food-card-actions">
                      <button
                        type="button"
                        className="food-edit-button"
                        onClick={() => navigate(`/foods/edit/${id}`)}
                        disabled={busy || Boolean(busyId)}
                      >
                        ✎ Edit
                      </button>

                      <button
                        type="button"
                        className={`food-toggle-button ${
                          available ? "toggle-disable" : "toggle-enable"
                        }`}
                        onClick={() => toggleAvailability(food)}
                        disabled={busy || Boolean(busyId)}
                      >
                        {busy
                          ? "Please wait..."
                          : available
                            ? "Disable"
                            : "Enable"}
                      </button>

                      <button
                        type="button"
                        className="food-delete-button"
                        onClick={() => deleteFood(food)}
                        disabled={busy || Boolean(busyId)}
                        aria-label={`Delete ${food.name}`}
                        title="Delete food"
                      >
                        ×
                      </button>
                    </div>
                  </div>
                </article>
              );
            })}
          </div>
        )}
      </section>
    </main>
  );
}
