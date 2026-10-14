import { useEffect, useState } from "react";
import { UserRound, Mail, Phone, LogOut } from "lucide-react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import authService from "../services/authService";
import "./PageStyles.css";

export default function Profile() {
  const navigate = useNavigate();
  const { customer, user, setCustomer, logout } = useAuth();
  const currentUser = customer || user || {};

  const [form, setForm] = useState({
    name: currentUser.name || "",
    email: currentUser.email || "",
    phone: currentUser.phone || currentUser.mobile || "",
    address: currentUser.address || "",
  });
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    setForm({
      name: currentUser.name || "",
      email: currentUser.email || "",
      phone: currentUser.phone || currentUser.mobile || "",
      address: currentUser.address || "",
    });
  }, [currentUser.name, currentUser.email, currentUser.phone, currentUser.mobile, currentUser.address]);

  function change(event) {
    setForm({ ...form, [event.target.name]: event.target.value });
  }

  async function submit(event) {
    event.preventDefault();
    setError("");
    setMessage("");

    try {
      setSaving(true);
      const response = await authService.updateProfile(form);
      const updated = response.data?.customer || response.data?.user || response.data;
      if (updated && typeof updated === "object") setCustomer(updated);
      setMessage("Profile updated successfully.");
    } catch (err) {
      setError(err.message || "Unable to update profile. Check your backend route.");
    } finally {
      setSaving(false);
    }
  }

  function handleLogout() {
    logout();
    navigate("/login", { replace: true });
  }

  return (
    <section className="page-container page-narrow">
      <div className="page-heading">
        <span className="page-kicker">YOUR ACCOUNT</span>
        <h1>My Profile</h1>
        <p>Manage your personal information.</p>
      </div>

      <div className="profile-header">
        <div className="profile-avatar"><UserRound size={35} /></div>
        <div>
          <h2>{form.name || "Customer"}</h2>
          <p>{form.email || "Your account"}</p>
        </div>
      </div>

      <form className="page-form" onSubmit={submit}>
        <label>Full name</label>
        <div className="page-input-icon"><UserRound size={17} /><input name="name" value={form.name} onChange={change} required /></div>

        <label>Email address</label>
        <div className="page-input-icon"><Mail size={17} /><input type="email" name="email" value={form.email} onChange={change} required /></div>

        <label>Mobile number</label>
        <div className="page-input-icon"><Phone size={17} /><input type="tel" name="phone" value={form.phone} onChange={change} /></div>

        <label>Address</label>
        <textarea rows="3" name="address" value={form.address} onChange={change} placeholder="Enter your address" />

        {message && <p className="page-success">{message}</p>}
        {error && <p className="page-error">{error}</p>}

        <button type="submit" className="page-btn" disabled={saving}>
          {saving ? "Saving..." : "Save Profile"}
        </button>
      </form>

      <div className="profile-links">
        <Link to="/my-bookings">My Bookings</Link>
        <Link to="/notifications">Notifications</Link>
        <button className="page-btn page-btn-danger" onClick={handleLogout}><LogOut size={17} /> Logout</button>
      </div>
    </section>
  );
}