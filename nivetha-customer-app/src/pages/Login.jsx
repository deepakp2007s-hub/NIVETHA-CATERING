
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Phone, LockKeyhole, Eye, EyeOff } from "lucide-react";
import { useAuth } from "../context/AuthContext";
import "./PageStyles.css";

export default function Login() {
  const navigate = useNavigate();
  const { login } = useAuth();

  const [form, setForm] = useState({
    phone: "",
    password: "",
  });

  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  function handleChange(event) {
    const { name, value } = event.target;

    setForm((previous) => ({
      ...previous,
      [name]: value,
    }));
  }

  async function handleSubmit(event) {
    event.preventDefault();
    if (loading) return;

    setError("");

    const phone = form.phone.trim();

    if (!/^[6-9]\d{9}$/.test(phone)) {
      setError("Enter a valid 10-digit mobile number.");
      return;
    }

    if (!form.password) {
      setError("Please enter your password.");
      return;
    }

    try {
      setLoading(true);

      await login({
        phone,
        password: form.password,
      });

      // Login successful → Customer Home Page
      navigate("/", { replace: true });
    } catch (err) {
      setError(
        err.response?.data?.message ||
          err.response?.data?.error ||
          err.message ||
          "Login failed. Check your phone number and password."
      );
    } finally {
      setLoading(false);
    }
  }

  return (
    <section className="auth-page">
      <div className="auth-decoration">
        <span className="auth-decoration-icon">🍽️</span>
        <p>Good food brings people together.</p>
        <small>Nivetha Catering Service</small>
      </div>

      <div className="auth-panel">
        <span className="auth-kicker">WELCOME BACK</span>
        <h1>Customer Login</h1>

        <p className="auth-subtitle">
          Login using your registered mobile number and password.
        </p>

        <form className="auth-form" onSubmit={handleSubmit}>
          <label htmlFor="login-phone">Phone Number</label>

          <div className="auth-input-wrap">
            <Phone size={18} />
            <span className="login-country-code">+91</span>

            <input
              id="login-phone"
              type="tel"
              name="phone"
              value={form.phone}
              onChange={handleChange}
              placeholder="Enter 10-digit number"
              inputMode="numeric"
              autoComplete="tel-national"
              maxLength={10}
              required
            />
          </div>

          <label htmlFor="login-password">Password</label>

          <div className="auth-input-wrap">
            <LockKeyhole size={18} />

            <input
              id="login-password"
              type={showPassword ? "text" : "password"}
              name="password"
              value={form.password}
              onChange={handleChange}
              placeholder="Enter your password"
              autoComplete="current-password"
              required
            />

            <button
              type="button"
              className="auth-icon-button"
              onClick={() =>
                setShowPassword((previous) => !previous)
              }
              aria-label={
                showPassword ? "Hide password" : "Show password"
              }
            >
              {showPassword ? (
                <EyeOff size={18} />
              ) : (
                <Eye size={18} />
              )}
            </button>
          </div>

          {error && (
            <p className="auth-error" role="alert">
              {error}
            </p>
          )}

          <button
            className="auth-submit"
            type="submit"
            disabled={loading}
          >
            {loading ? "Signing in..." : "Sign In"}
          </button>
        </form>

        <p className="auth-switch">
          Don't have an account?{" "}
          <Link to="/register">Create account</Link>
        </p>
      </div>
    </section>
  );
}
