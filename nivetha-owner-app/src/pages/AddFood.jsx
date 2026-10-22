
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

export default function AddFood() {
  const navigate = useNavigate();

  const [form, setForm] = useState(INITIAL_FORM);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

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
    setSuccess("");

    if (!form.name.trim()) {
      setError("Food name is required.");
      return;
    }

    try {
      setLoading(true);

      await api.post("/foods", {
        name: form.name.trim(),
        tamilName: form.tamilName.trim(),
        category: form.category,
        type: form.type,
        description: form.description.trim(),
        image: form.image.trim(),
        available: form.available,
      });

      setSuccess("Food added successfully!");

      // Redirect to the correct Food Menu route.
      navigate("/food-menu", {
        replace: true,
        state: { foodAdded: true },
      });
    } catch (err) {
      setError(
        err.response?.data?.message ||
          err.response?.data?.error ||
          "Unable to add food. Check owner login and backend connection."
      );
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

      {success && (
        <p role="status" className="food-success">
          {success}
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
            <option value="Breakfast">Breakfast</option>
            <option value="Lunch">Lunch</option>
            <option value="Dinner">Dinner</option>
            <option value="Snacks">Snacks</option>
            <option value="Desserts">Desserts</option>
            <option value="Drinks">Drinks</option>
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
