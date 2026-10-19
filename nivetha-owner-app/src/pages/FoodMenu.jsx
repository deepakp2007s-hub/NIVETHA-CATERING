
import { useCallback, useEffect, useState } from "react";
import api from "../services/api";
import "./FoodMenu.css";

const emptyFood = {
  name: "",
  tamilName: "",
  category: "Lunch",
  type: "Veg",
  description: "",
  price: "",
  image: "",
  available: true,
};

const getFoodList = (response) => {
  const data = response?.data;

  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.foods)) return data.foods;
  if (Array.isArray(data?.data)) return data.data;
  if (Array.isArray(data?.data?.foods)) return data.data.foods;

  return [];
};

const getFoodId = (food) => food?._id || food?.id;

function FoodMenu() {
  const [foods, setFoods] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [search, setSearch] = useState("");
  const [mealFilter, setMealFilter] = useState("All");
  const [typeFilter, setTypeFilter] = useState("All");
  const [availabilityFilter, setAvailabilityFilter] = useState("All");
  const [modalOpen, setModalOpen] = useState(false);
  const [editingFood, setEditingFood] = useState(null);
  const [form, setForm] = useState({ ...emptyFood });
  const [saving, setSaving] = useState(false);
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
          "Unable to load food menu. Check your login and backend connection."
      );
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadFoods();
  }, [loadFoods]);

  const openAddModal = () => {
    setEditingFood(null);
    setForm({ ...emptyFood });
    setError("");
    setNotice("");
    setModalOpen(true);
  };

  const openEditModal = (food) => {
    setEditingFood(food);

    setForm({
      name: food.name || "",
      tamilName: food.tamilName || "",
      category: food.category || food.meal || "Lunch",
      type: food.type || food.foodType || "Veg",
      description: food.description || "",
      price: food.price === 0 ? "0" : String(food.price ?? ""),
      image: food.image || "",
      available: food.available ?? food.isAvailable ?? true,
    });

    setError("");
    setNotice("");
    setModalOpen(true);
  };

  const closeModal = () => {
    if (saving) return;
    setModalOpen(false);
    setEditingFood(null);
  };

  const handleChange = (event) => {
    const { name, value, type, checked } = event.target;

    setForm((current) => ({
      ...current,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();

    if (saving) return;

    const name = form.name.trim();
    const priceText = String(form.price).trim();
    const price = Number(priceText);

    if (!name) {
      setError("Food name is required.");
      return;
    }

    if (!form.category) {
      setError("Please select a meal category.");
      return;
    }

    if (
      priceText === "" ||
      !Number.isFinite(price) ||
      price < 0
    ) {
      setError("Enter a valid price greater than or equal to ₹0.");
      return;
    }

    const payload = {
      name,
      tamilName: form.tamilName.trim(),
      category: form.category,
      type: form.type,
      description: form.description.trim(),
      price,
      image: form.image.trim(),
      available: Boolean(form.available),
    };

    setSaving(true);
    setError("");
    setNotice("");

    try {
      if (editingFood) {
        const id = getFoodId(editingFood);

        if (!id) {
          throw new Error("Food ID is missing. Reload the menu and try again.");
        }

        await api.patch(`/foods/${id}`, payload);
      } else {
        await api.post("/foods", payload);
      }

      setModalOpen(false);
      setEditingFood(null);
      setForm({ ...emptyFood });

      await loadFoods();

      setNotice(
        editingFood
          ? "Food details updated successfully."
          : "Food added successfully."
      );
    } catch (err) {
      setError(
        err.response?.data?.message ||
          err.message ||
          "Could not save food. Please try again."
      );
    } finally {
      setSaving(false);
    }
  };

  const toggleAvailability = async (food) => {
    const id = getFoodId(food);
    if (!id || busyId) return;

    const currentAvailability =
      food.available ?? food.isAvailable ?? true;

    setBusyId(String(id));
    setError("");
    setNotice("");

    try {
      const response = await api.patch(`/foods/${id}`, {
        available: !currentAvailability,
      });

      const updatedFood =
        response?.data?.data || response?.data?.food || {};

      setFoods((current) =>
        current.map((item) =>
          String(getFoodId(item)) === String(id)
            ? {
                ...item,
                ...updatedFood,
                available: !currentAvailability,
              }
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

    const confirmed = window.confirm(
      `Delete "${food.name}" from the food menu?`
    );

    if (!confirmed) return;

    setBusyId(String(id));
    setError("");
    setNotice("");

    try {
      await api.delete(`/foods/${id}`);

      setFoods((current) =>
        current.filter(
          (item) => String(getFoodId(item)) !== String(id)
        )
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

  const filteredFoods = foods.filter((food) => {
    const query = search.trim().toLowerCase();

    const nameMatches =
      !query ||
      [food.name, food.tamilName, food.description]
        .filter(Boolean)
        .some((value) =>
          String(value).toLowerCase().includes(query)
        );

    const category = food.category || food.meal || "";
    const type = food.type || food.foodType || "";
    const available = food.available ?? food.isAvailable ?? true;

    const mealMatches =
      mealFilter === "All" || category === mealFilter;

    const typeMatches =
      typeFilter === "All" || type === typeFilter;

    const availabilityMatches =
      availabilityFilter === "All" ||
      (availabilityFilter === "Available" && available) ||
      (availabilityFilter === "Unavailable" && !available);

    return (
      nameMatches &&
      mealMatches &&
      typeMatches &&
      availabilityMatches
    );
  });

  const availableCount = foods.filter(
    (food) => food.available ?? food.isAvailable ?? true
  ).length;

  return (
    <main className="food-menu-page page-enter">
      <section className="food-menu-hero">
        <div className="food-menu-hero-copy">
          <span className="food-menu-eyebrow">
            NIVETHA CATERING SERVICE
          </span>
          <h1>Food Menu</h1>
          <p>
            Manage your dishes, organize meal categories, and control
            what customers can see in the menu.
          </p>
        </div>

        <div className="food-menu-hero-mark" aria-hidden="true">
          <span>✦</span>
          <div>N</div>
        </div>
      </section>

      <section className="food-menu-summary">
        <article className="food-summary-card">
          <span className="food-summary-icon">▤</span>
          <div>
            <p>Total Dishes</p>
            <strong>{loading ? "—" : foods.length}</strong>
          </div>
        </article>

        <article className="food-summary-card">
          <span className="food-summary-icon available-icon">✓</span>
          <div>
            <p>Available Dishes</p>
            <strong>{loading ? "—" : availableCount}</strong>
          </div>
        </article>

        <article className="food-summary-card">
          <span className="food-summary-icon category-icon">◈</span>
          <div>
            <p>Meal Categories</p>
            <strong>4</strong>
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
          </div>

          <button
            type="button"
            className="food-add-button"
            onClick={openAddModal}
          >
            <span>＋</span> Add New Food
          </button>
        </div>

        <div className="food-filter-row">
          <label className="food-search-box">
            <span aria-hidden="true">⌕</span>
            <input
              type="search"
              placeholder="Search food name..."
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              aria-label="Search food menu"
            />
          </label>

          <select
            value={mealFilter}
            onChange={(event) => setMealFilter(event.target.value)}
            aria-label="Filter by meal"
          >
            <option value="All">All Meals</option>
            <option value="Breakfast">Breakfast</option>
            <option value="Lunch">Lunch</option>
            <option value="Dinner">Dinner</option>
            <option value="Sweets">Sweets</option>
          </select>

          <select
            value={typeFilter}
            onChange={(event) => setTypeFilter(event.target.value)}
            aria-label="Filter by food type"
          >
            <option value="All">Veg & Non-Veg</option>
            <option value="Veg">Vegetarian</option>
            <option value="Non-Veg">Non-Vegetarian</option>
          </select>

          <select
            value={availabilityFilter}
            onChange={(event) =>
              setAvailabilityFilter(event.target.value)
            }
            aria-label="Filter by availability"
          >
            <option value="All">All Status</option>
            <option value="Available">Available</option>
            <option value="Unavailable">Unavailable</option>
          </select>
        </div>
      </section>

      {notice && (
        <div className="food-menu-notice" role="status">
          <span>✓</span> {notice}
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
          <button type="button" onClick={loadFoods}>
            Retry
          </button>
        </div>
      )}

      <section className="food-menu-results">
        <div className="food-results-heading">
          <h2>Food Collection</h2>
          <span>
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
                ? "Try changing your search or filters."
                : "Add your first dish to start building the menu."}
            </p>

            {foods.length === 0 && (
              <button
                type="button"
                className="food-add-button"
                onClick={openAddModal}
              >
                ＋ Add First Food
              </button>
            )}
          </div>
        ) : (
          <div className="food-menu-grid">
            {filteredFoods.map((food, index) => {
              const id = getFoodId(food);
              const available =
                food.available ?? food.isAvailable ?? true;
              const category = food.category || food.meal || "Other";
              const type = food.type || food.foodType || "Veg";
              const busy = String(id) === busyId;

              return (
                <article
                  className={`food-menu-card ${
                    !available ? "food-unavailable" : ""
                  }`}
                  key={id || `${food.name}-${index}`}
                  style={{
                    animationDelay: `${Math.min(index, 8) * 55}ms`,
                  }}
                >
                  <div className="food-card-image-wrap">
                    {food.image ? (
                      <img
                        src={food.image}
                        alt={food.name}
                        className="food-card-image"
                        loading="lazy"
                      />
                    ) : (
                      <div
                        className="food-image-placeholder"
                        aria-hidden="true"
                      >
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
                    <div className="food-card-title-row">
                      <div>
                        <span className="food-meal-label">
                          {category}
                        </span>
                        <h3>{food.name || "Untitled Dish"}</h3>

                        {food.tamilName && (
                          <p className="food-tamil-name">
                            {food.tamilName}
                          </p>
                        )}
                      </div>
                    </div>

                    {food.description && (
                      <p className="food-description">
                        {food.description}
                      </p>
                    )}

                    <div className="food-card-status-row">
                      <strong>
                        ₹{Number(food.price || 0).toLocaleString("en-IN")}
                      </strong>
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
                        onClick={() => openEditModal(food)}
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

      {modalOpen && (
        <div
          className="food-modal-backdrop"
          onMouseDown={(event) => {
            if (event.target === event.currentTarget) closeModal();
          }}
        >
          <section
            className="food-modal"
            role="dialog"
            aria-modal="true"
            aria-labelledby="food-modal-title"
          >
            <div className="food-modal-header">
              <div>
                <span className="food-menu-section-label">
                  MENU MANAGEMENT
                </span>
                <h2 id="food-modal-title">
                  {editingFood ? "Edit Food" : "Add New Food"}
                </h2>
                <p>Enter the dish details below.</p>
              </div>

              <button
                type="button"
                className="food-modal-close"
                onClick={closeModal}
                disabled={saving}
                aria-label="Close dialog"
              >
                ×
              </button>
            </div>

            <form className="food-form" onSubmit={handleSubmit}>
              <div className="food-form-grid">
                <label>
                  Food Name <span>*</span>
                  <input
                    name="name"
                    value={form.name}
                    onChange={handleChange}
                    placeholder="e.g. Vegetable Biryani"
                    required
                    maxLength={100}
                  />
                </label>

                <label>
                  Tamil Name
                  <input
                    name="tamilName"
                    value={form.tamilName}
                    onChange={handleChange}
                    placeholder="உணவின் பெயர்"
                    maxLength={100}
                  />
                </label>

                <label>
                  Meal Category <span>*</span>
                  <select
                    name="category"
                    value={form.category}
                    onChange={handleChange}
                    required
                  >
                    <option value="Breakfast">Breakfast</option>
                    <option value="Lunch">Lunch</option>
                    <option value="Dinner">Dinner</option>
                    <option value="Sweets">Sweets</option>
                  </select>
                </label>

                <label>
                  Food Type <span>*</span>
                  <select
                    name="type"
                    value={form.type}
                    onChange={handleChange}
                    required
                  >
                    <option value="Veg">Vegetarian</option>
                    <option value="Non-Veg">Non-Vegetarian</option>
                  </select>
                </label>

                <label>
                  Price (₹) <span>*</span>
                  <input
                    name="price"
                    type="number"
                    min="0"
                    step="0.01"
                    value={form.price}
                    onChange={handleChange}
                    placeholder="Enter price"
                    required
                  />
                </label>

                <label className="food-form-full">
                  Image URL
                  <input
                    name="image"
                    type="url"
                    value={form.image}
                    onChange={handleChange}
                    placeholder="https://example.com/food-image.jpg"
                  />
                </label>

                <label className="food-form-full">
                  Description
                  <textarea
                    name="description"
                    value={form.description}
                    onChange={handleChange}
                    placeholder="Describe the dish..."
                    rows={3}
                    maxLength={500}
                  />
                </label>

                <label className="food-availability-checkbox food-form-full">
                  <input
                    type="checkbox"
                    name="available"
                    checked={form.available}
                    onChange={handleChange}
                  />
                  <span>
                    <strong>Available for customers</strong>
                    <small>
                      Turn this off to hide the dish from available menu items.
                    </small>
                  </span>
                </label>
              </div>

              <div className="food-modal-actions">
                <button
                  type="button"
                  className="food-cancel-button"
                  onClick={closeModal}
                  disabled={saving}
                >
                  Cancel
                </button>

                <button
                  type="submit"
                  className="food-save-button"
                  disabled={saving}
                >
                  {saving
                    ? "Saving..."
                    : editingFood
                      ? "Save Changes"
                      : "Add Food"}
                </button>
              </div>
            </form>
          </section>
        </div>
      )}
    </main>
  );
}

export default FoodMenu;
