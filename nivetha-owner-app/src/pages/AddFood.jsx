
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import api from "../services/api";
import "./AddFood.css";

const INITIAL_FORM = {
  name: "",
  tamilName: "",
  category: "Lunch",
  type: "Veg",
  description: "",
  image: "",
  available: true,
};

const CATEGORIES = ["Breakfast", "Lunch", "Dinner", "Sweets"];

export default function AddFood() {
  const navigate = useNavigate();

  const [form, setForm] = useState(INITIAL_FORM);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleChange = (event) => {
    const { name, value, type, checked } = event.target;

    setForm((previous) => ({
      ...previous,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError("");

    const name = form.name.trim();
    const description = form.description.trim();
    const imageUrl = form.image.trim();

    if (!name) {
      setError("Food name is required.");
      return;
    }

    if (imageUrl) {
      try {
        new URL(imageUrl);
      } catch {
        setError("Please enter a valid image URL.");
        return;
      }
    }

    const payload = {
      name,
      category: form.category,
      description,
      image_url: imageUrl || null,
      is_available: form.available,
      is_vegetarian: form.type === "Veg",
    };

    try {
      setLoading(true);

      const response = await api.post("/foods/", payload);

      if (response.data?.success === false) {
        throw new Error(response.data?.message || "Unable to add food.");
      }

      navigate("/food-menu", {
        replace: true,
        state: { foodAdded: true },
      });
    } catch (err) {
      const detail = err.response?.data?.detail;

      const message =
        typeof detail === "string"
          ? detail
          : Array.isArray(detail)
            ? detail.map((item) => item.msg).join(", ")
            : err.response?.data?.message ||
              err.response?.data?.error ||
              err.message ||
              "Unable to add food. Check owner login and backend connection.";

      setError(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="add-food-page">
      <header className="add-food-heading">
        <span>NIVETHA CATERING SERVICE</span>
        <h1>Add New Food</h1>
        <p>Add a dish to your catering menu.</p>
      </header>

      {error && (
        <p role="alert" className="food-error">
          {error}
        </p>
      )}

      <form onSubmit={handleSubmit} className="add-food-form">
        <label>
          Food Name *
          <input
            name="name"
            value={form.name}
            onChange={handleChange}
            placeholder="Example: Vegetable Biryani"
            maxLength={150}
            required
          />
        </label>

        <label>
          Tamil Name
          <input
            name="tamilName"
            value={form.tamilName}
            onChange={handleChange}
            placeholder="உணவின் பெயர்"
            maxLength={150}
          />
        </label>

        <label>
          Category *
          <select
            name="category"
            value={form.category}
            onChange={handleChange}
            required
          >
            {CATEGORIES.map((category) => (
              <option key={category} value={category}>
                {category}
              </option>
            ))}
          </select>
        </label>

        <label>
          Food Type *
          <select
            name="type"
            value={form.type}
            onChange={handleChange}
            required
          >
            <option value="Veg">Veg</option>
            <option value="Non-Veg">Non-Veg</option>
          </select>
        </label>

        <label className="add-food-full">
          Image URL
          <input
            type="url"
            name="image"
            value={form.image}
            onChange={handleChange}
            placeholder="https://example.com/food.jpg"
          />
        </label>

        <label className="add-food-full">
          Description
          <textarea
            name="description"
            value={form.description}
            onChange={handleChange}
            placeholder="Describe the food"
            rows={4}
            maxLength={1000}
          />
        </label>

        <label className="add-food-checkbox">
          <input
            type="checkbox"
            name="available"
            checked={form.available}
            onChange={handleChange}
          />
          Available for customers
        </label>

        <div className="add-food-actions">
          <button
            type="button"
            onClick={() => navigate("/food-menu")}
            disabled={loading}
          >
            Cancel
          </button>

          <button type="submit" disabled={loading}>
            {loading ? "Saving..." : "Add Food"}
          </button>
        </div>
      </form>
    </main>
  );
}
