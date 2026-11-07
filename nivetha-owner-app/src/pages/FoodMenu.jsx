import { useCallback, useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  Plus,
  Search,
  RefreshCw,
  Pencil,
  Trash2,
  UtensilsCrossed,
  CheckCircle2,
  XCircle,
  Leaf,
  Drumstick,
  ImageOff,
  Filter,
  X,
} from "lucide-react";
import api from "../services/api";
import "./FoodMenu.css";

const CATEGORIES = ["Breakfast", "Lunch", "Dinner", "Sweets"];

const getFoodList = (response) => {
  const data = response?.data ?? response;

  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.foods)) return data.foods;
  if (Array.isArray(data?.data)) return data.data;
  if (Array.isArray(data?.data?.foods)) return data.data.foods;

  return [];
};

const getFoodId = (food) => food?.id || food?._id;

const isFoodAvailable = (food) =>
  food?.is_available ?? food?.available ?? food?.isAvailable ?? true;

const isVegetarian = (food) =>
  food?.is_vegetarian ?? food?.isVegetarian ?? true;

const getFoodImage = (food) =>
  food?.image_url || food?.imageUrl || food?.image || "";

const getFoodCategory = (food) =>
  food?.category || food?.meal || "Other";

const getErrorMessage = (error, fallback) =>
  error?.response?.data?.detail ||
  error?.response?.data?.message ||
  error?.message ||
  fallback;

export default function FoodMenu() {
  const navigate = useNavigate();

  const [foods, setFoods] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [search, setSearch] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("All");
  const [typeFilter, setTypeFilter] = useState("All");
  const [availabilityFilter, setAvailabilityFilter] = useState("All");
  const [busyId, setBusyId] = useState("");

  const loadFoods = useCallback(async (isRefresh = false) => {
    try {
      if (isRefresh) {
        setRefreshing(true);
      } else {
        setLoading(true);
      }

      setError("");

      const response = await api.get("/foods/");
      setFoods(getFoodList(response));
    } catch (err) {
      setError(
        getErrorMessage(
          err,
          "Unable to load foods. Check owner login and backend connection."
        )
      );
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    loadFoods();
  }, [loadFoods]);

  useEffect(() => {
    if (!notice) return undefined;

    const timer = window.setTimeout(() => setNotice(""), 3500);
    return () => window.clearTimeout(timer);
  }, [notice]);

  const toggleAvailability = async (food) => {
    const id = getFoodId(food);

    if (!id || busyId) return;

    const currentAvailability = isFoodAvailable(food);
    const nextAvailability = !currentAvailability;

    try {
      setBusyId(String(id));
      setError("");
      setNotice("");

      const response = await api.patch(
        `/foods/${encodeURIComponent(id)}/availability`,
        { is_available: nextAvailability }
      );

      const updatedFood = response?.data?.food;

      setFoods((current) =>
        current.map((item) =>
          String(getFoodId(item)) === String(id)
            ? {
                ...item,
                ...(updatedFood || {}),
                is_available: nextAvailability,
              }
            : item
        )
      );

      setNotice(
        nextAvailability
          ? "Food is now available."
          : "Food is now unavailable."
      );
    } catch (err) {
      setError(
        getErrorMessage(err, "Could not update food availability.")
      );
    } finally {
      setBusyId("");
    }
  };

  const disableFood = async (food) => {
    const id = getFoodId(food);

    if (!id || busyId || !isFoodAvailable(food)) return;

    const confirmed = window.confirm(
      `Disable "${food.name}"? It will no longer be available to customers.`
    );

    if (!confirmed) return;

    try {
      setBusyId(String(id));
      setError("");
      setNotice("");

      await api.delete(`/foods/${encodeURIComponent(id)}`);

      setFoods((current) =>
        current.map((item) =>
          String(getFoodId(item)) === String(id)
            ? { ...item, is_available: false }
            : item
        )
      );

      setNotice("Food disabled successfully.");
    } catch (err) {
      setError(
        getErrorMessage(err, "Could not disable food. Please try again.")
      );
    } finally {
      setBusyId("");
    }
  };

  const filteredFoods = useMemo(() => {
    const query = search.trim().toLowerCase();

    return foods.filter((food) => {
      const searchableText = [
        food?.name,
        food?.description,
        food?.tamil_name,
        food?.tamilName,
      ]
        .filter(Boolean)
        .join(" ")
        .toLowerCase();

      const nameMatches = !query || searchableText.includes(query);
      const categoryMatches =
        categoryFilter === "All" ||
        getFoodCategory(food).toLowerCase() === categoryFilter.toLowerCase();

      const vegetarian = isVegetarian(food);
      const typeMatches =
        typeFilter === "All" ||
        (typeFilter === "Veg" && vegetarian) ||
        (typeFilter === "Non-Veg" && !vegetarian);

      const available = isFoodAvailable(food);
      const availabilityMatches =
        availabilityFilter === "All" ||
        (availabilityFilter === "Available" && available) ||
        (availabilityFilter === "Unavailable" && !available);

      return (
        nameMatches &&
        categoryMatches &&
        typeMatches &&
        availabilityMatches
      );
    });
  }, [foods, search, categoryFilter, typeFilter, availabilityFilter]);

  const availableCount = foods.filter(isFoodAvailable).length;
  const unavailableCount = foods.length - availableCount;

  const openAddFood = () => navigate("/add-food");

  const openEditFood = (food) => {
    const id = getFoodId(food);
    if (id) navigate(`/foods/edit/${encodeURIComponent(id)}`);
  };

  return (
    <main className="food-menu-page">
      <header className="food-menu-hero">
        <div className="food-hero-copy">
          <span className="food-menu-eyebrow">
            <span className="food-eyebrow-dot" />
            NIVETHA CATERING SERVICE
          </span>

          <h1>Food Menu</h1>

          <p>
            Manage your dishes, update availability and organise your catering
            collection.
          </p>

          <button
            type="button"
            className="food-add-button hero-add-button"
            onClick={openAddFood}
          >
            <Plus size={18} />
            Add New Food
          </button>
        </div>

        <div className="food-hero-emblem" aria-hidden="true">
          <div className="food-emblem-circle">
            <UtensilsCrossed size={38} />
          </div>
          <span>✦ NIVETHA ✦</span>
          <small>QUALITY · TASTE · SERVICE</small>
        </div>
      </header>

      <section className="food-menu-summary">
        <article className="food-summary-card">
          <span className="summary-icon">
            <UtensilsCrossed size={21} />
          </span>
          <div>
            <p>Total Dishes</p>
            <strong>{loading ? "—" : foods.length}</strong>
            <small>In your menu</small>
          </div>
        </article>

        <article className="food-summary-card">
          <span className="summary-icon summary-icon-green">
            <CheckCircle2 size={21} />
          </span>
          <div>
            <p>Available</p>
            <strong>{loading ? "—" : availableCount}</strong>
            <small>Ready for customers</small>
          </div>
        </article>

        <article className="food-summary-card">
          <span className="summary-icon summary-icon-gold">
            <XCircle size={21} />
          </span>
          <div>
            <p>Unavailable</p>
            <strong>{loading ? "—" : unavailableCount}</strong>
            <small>Currently disabled</small>
          </div>
        </article>
      </section>

      <section className="food-menu-toolbar">
        <div className="food-toolbar-heading">
          <div>
            <span className="food-menu-section-label">YOUR COLLECTION</span>
            <h2>Manage Dishes</h2>
            <p>Search, filter and manage your catering menu.</p>
          </div>

          <button
            type="button"
            className="food-refresh-button"
            onClick={() => loadFoods(true)}
            disabled={refreshing}
          >
            <RefreshCw
              size={16}
              className={refreshing ? "food-refresh-spinning" : ""}
            />
            {refreshing ? "Refreshing..." : "Refresh"}
          </button>
        </div>

        <div className="food-filter-row">
          <label className="food-search-box">
            <Search size={17} />
            <input
              type="search"
              placeholder="Search food name or description..."
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              aria-label="Search food menu"
            />
            {search && (
              <button
                type="button"
                onClick={() => setSearch("")}
                aria-label="Clear search"
              >
                <X size={15} />
              </button>
            )}
          </label>

          <label className="food-select-wrap">
            <Filter size={15} />
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
          </label>

          <select
            className="food-filter-select"
            value={typeFilter}
            onChange={(event) => setTypeFilter(event.target.value)}
            aria-label="Filter food type"
          >
            <option value="All">Veg & Non-Veg</option>
            <option value="Veg">Veg</option>
            <option value="Non-Veg">Non-Veg</option>
          </select>

          <select
            className="food-filter-select"
            value={availabilityFilter}
            onChange={(event) => setAvailabilityFilter(event.target.value)}
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
          <CheckCircle2 size={17} />
          <p>{notice}</p>
          <button
            type="button"
            onClick={() => setNotice("")}
            aria-label="Dismiss message"
          >
            <X size={16} />
          </button>
        </div>
      )}

      {error && (
        <div className="food-menu-error" role="alert">
          <XCircle size={18} />
          <p>{error}</p>
          <button
            type="button"
            onClick={() => loadFoods()}
            disabled={loading}
          >
            Retry
          </button>
        </div>
      )}

      <section className="food-menu-results">
        <div className="food-results-heading">
          <div>
            <span className="food-menu-section-label">MENU OVERVIEW</span>
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
            <div className="food-empty-icon">
              <UtensilsCrossed size={30} />
            </div>

            <h3>
              {foods.length ? "No matching dishes" : "Your menu is empty"}
            </h3>

            <p>
              {foods.length
                ? "Try another search term or change the filters."
                : "Add your first dish to start building your menu."}
            </p>

            {foods.length === 0 ? (
              <button
                type="button"
                className="food-add-button"
                onClick={openAddFood}
              >
                <Plus size={17} />
                Add First Food
              </button>
            ) : (
              <button
                type="button"
                className="food-reset-filter"
                onClick={() => {
                  setSearch("");
                  setCategoryFilter("All");
                  setTypeFilter("All");
                  setAvailabilityFilter("All");
                }}
              >
                Reset filters
              </button>
            )}
          </div>
        ) : (
          <div className="food-menu-grid">
            {filteredFoods.map((food, index) => {
              const id = getFoodId(food);
              const available = isFoodAvailable(food);
              const vegetarian = isVegetarian(food);
              const category = getFoodCategory(food);
              const image = getFoodImage(food);
              const busy = String(id) === busyId;

              return (
                <article
                  className={`food-menu-card ${
                    !available ? "food-unavailable" : ""
                  }`}
                  key={id || `${food.name}-${index}`}
                >
                  <div className="food-card-image-wrap">
                    {image ? (
                      <img
                        src={image}
                        alt={food.name || "Food"}
                        className="food-card-image"
                        loading="lazy"
                        onError={(event) => {
                          event.currentTarget.style.display = "none";
                          event.currentTarget.nextElementSibling?.removeAttribute(
                            "hidden"
                          );
                        }}
                      />
                    ) : null}

                    <div
                      className="food-image-placeholder"
                      hidden={Boolean(image)}
                    >
                      <ImageOff size={28} />
                      <small>NIVETHA CATERING</small>
                    </div>

                    <span
                      className={`food-type-badge ${
                        vegetarian ? "veg" : "non-veg"
                      }`}
                    >
                      {vegetarian ? <Leaf size={12} /> : <Drumstick size={12} />}
                      {vegetarian ? "Veg" : "Non-Veg"}
                    </span>

                    {!available && (
                      <span className="food-unavailable-overlay">
                        Unavailable
                      </span>
                    )}
                  </div>

                  <div className="food-card-content">
                    <div className="food-card-title-row">
                      <span className="food-meal-label">{category}</span>
                      <span
                        className={`food-availability ${
                          available ? "is-available" : "is-unavailable"
                        }`}
                      >
                        <span />
                        {available ? "Available" : "Unavailable"}
                      </span>
                    </div>

                    <h3>{food.name || "Untitled Dish"}</h3>

                    {food.description && (
                      <p className="food-description">{food.description}</p>
                    )}

                    <div className="food-card-actions">
                      <button
                        type="button"
                        className="food-edit-button"
                        onClick={() => openEditFood(food)}
                        disabled={busy || Boolean(busyId) || !id}
                      >
                        <Pencil size={14} />
                        Edit
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
                        onClick={() => disableFood(food)}
                        disabled={busy || Boolean(busyId) || !available}
                        aria-label={`Disable ${food.name}`}
                        title="Disable food"
                      >
                        <Trash2 size={16} />
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