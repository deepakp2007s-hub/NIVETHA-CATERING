
import { useEffect, useState } from "react";
import { UserRound, Mail, Phone, LogOut } from "lucide-react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import "./PageStyles.css";

export default function Profile() {
  const navigate = useNavigate();
  const { customer, user, updateProfile, logout } = useAuth();
  const currentUser = customer || user || {};

  const [form, setForm] = useState({
    name: currentUser.name || "",
    email: currentUser.email || "",
    phone: currentUser.phone || currentUser.mobile || "",
    address: currentUser.address || "",
  });

  const [saving, setSaving] = useState(false);
  const [loggingOut, setLoggingOut] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    setForm({
      name: currentUser.name || "",
      email: currentUser.email || "",
      phone: currentUser.phone || currentUser.mobile || "",
      address: currentUser.address || "",
    });
  }, [
    currentUser.name,
    currentUser.email,
    currentUser.phone,
    currentUser.mobile,
    currentUser.address,
  ]);

  function change(event) {
    const { name, value } = event.target;

    setForm((previous) => ({
      ...previous,
      [name]: value,
    }));

    setMessage("");
    setError("");
  }

  async function submit(event) {
    event.preventDefault();
    setError("");
    setMessage("");

    const name = form.name.trim();
    const email = form.email.trim().toLowerCase();
    const phone = form.phone.trim();
    const address = form.address.trim();

    if (!name) {
      setError("Please enter your full name.");
      return;
    }

    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setError("Enter a valid email address.");
      return;
    }

    if (!/^[6-9]\d{9}$/.test(phone)) {
      setError("Enter a valid 10-digit Indian mobile number.");
      return;
    }

    try {
      setSaving(true);

      await updateProfile({
        name,
        email,
        phone,
        address,
      });

      setMessage("Profile updated successfully.");
    } catch (err) {
      setError(
        err.response?.data?.message ||
          err.message ||
          "Unable to update profile. Please try again."
      );
    } finally {
      setSaving(false);
    }
  }

  async function handleLogout() {
    if (loggingOut) return;

    setLoggingOut(true);

    try {
      await logout();
    } finally {
      navigate("/login", { replace: true });
    }
  }

  return (
    <section className="page-container page-narrow">
      <div className="page-heading">
        <span className="page-kicker">YOUR ACCOUNT</span>
        <h1>My Profile</h1>
        <p>Manage your personal information.</p>
      </div>

      <div className="profile-header">
        <div className="profile-avatar">
          <UserRound size={35} />
        </div>

        <div>
          <h2>{form.name || "Customer"}</h2>
          <p>{form.email || "Your account"}</p>
        </div>
      </div>

      <form className="page-form" onSubmit={submit}>
        <label htmlFor="profile-name">Full name</label>
        <div className="page-input-icon">
          <UserRound size={17} />
          <input
            id="profile-name"
            name="name"
            value={form.name}
            onChange={change}
            maxLength={100}
            autoComplete="name"
            required
          />
        </div>

        <label htmlFor="profile-email">Email address</label>
        <div className="page-input-icon">
          <Mail size={17} />
          <input
            id="profile-email"
            type="email"
            name="email"
            value={form.email}
            onChange={change}
            autoComplete="email"
            maxLength={254}
            required
          />
        </div>

        <label htmlFor="profile-phone">Mobile number</label>
        <div className="page-input-icon">
          <Phone size={17} />
          <input
            id="profile-phone"
            type="tel"
            name="phone"
            value={form.phone}
            onChange={change}
            inputMode="numeric"
            autoComplete="tel-national"
            maxLength={10}
            required
          />
        </div>

        <label htmlFor="profile-address">Address</label>
        <textarea
          id="profile-address"
          rows={3}
          name="address"
          value={form.address}
          onChange={change}
          maxLength={500}
          autoComplete="street-address"
          placeholder="Enter your address"
        />

        {message && (
          <p className="page-success" role="status">
            {message}
          </p>
        )}

        {error && (
          <p className="page-error" role="alert">
            {error}
          </p>
        )}

        <button
          type="submit"
          className="page-btn"
          disabled={saving || loggingOut}
        >
          {saving ? "Saving..." : "Save Profile"}
        </button>
      </form>

      <div className="profile-links">
        <Link to="/my-bookings">My Bookings</Link>
        <Link to="/notifications">Notifications</Link>

        <button
          type="button"
          className="page-btn page-btn-danger"
          onClick={handleLogout}
          disabled={saving || loggingOut}
        >
          <LogOut size={17} />
          {loggingOut ? "Logging out..." : "Logout"}
        </button>
      </div>
    </section>
  );
}
