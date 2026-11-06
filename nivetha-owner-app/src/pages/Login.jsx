
import { useState } from "react";
import { Navigate, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import "./Login.css";

export default function Login() {
  const { login, isAuthenticated } = useAuth();
  const navigate = useNavigate();

  const [role, setRole] = useState("owner");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  if (isAuthenticated) {
    return <Navigate to="/dashboard" replace />;
  }

  const changeRole = (selectedRole) => {
    if (loading) return;

    setRole(selectedRole);
    setEmail("");
    setPassword("");
    setError("");
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError("");

    if (!email.trim() || !password) {
      setError("Please enter your email and password.");
      return;
    }

    try {
      setLoading(true);

      await login(email, password, role);

      navigate("/dashboard", { replace: true });
    } catch (err) {
      setError(
        err.response?.data?.detail ||
        err.message ||
        "Login failed. Please try again."
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="owner-login-page">
      <section className="owner-login-card">
        <div className="owner-login-brand">
          <div className="owner-login-logo">N</div>
          <div>
            <h2>NIVETHA</h2>
            <span>CATERING SERVICES</span>
          </div>
        </div>

        <div className="owner-login-heading">
          <span className="owner-login-eyebrow">STAFF PORTAL</span>
          <h1>Welcome Back</h1>
          <p>Sign in to manage your catering business.</p>
        </div>

        <div className="owner-login-role-selector">
          <button
            type="button"
            className={role === "owner" ? "active" : ""}
            onClick={() => changeRole("owner")}
            disabled={loading}
          >
            <span>♛</span>
            Owner
          </button>

          <button
            type="button"
            className={role === "admin" ? "active" : ""}
            onClick={() => changeRole("admin")}
            disabled={loading}
          >
            <span>✦</span>
            Admin
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <label htmlFor="login-email">Email Address</label>

          <input
            id="login-email"
            type="email"
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            placeholder="Enter your email address"
            autoComplete="username"
            required
            disabled={loading}
          />

          <label htmlFor="login-password">Password</label>

          <div className="owner-password-field">
            <input
              id="login-password"
              type={showPassword ? "text" : "password"}
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              placeholder="Enter your password"
              autoComplete="current-password"
              required
              disabled={loading}
            />

            <button
              type="button"
              onClick={() => setShowPassword((value) => !value)}
              disabled={loading}
              aria-label={showPassword ? "Hide password" : "Show password"}
            >
              {showPassword ? "Hide" : "Show"}
            </button>
          </div>

          {error && (
            <div className="owner-login-error" role="alert">
              {error}
            </div>
          )}

          <button
            type="submit"
            className="owner-login-submit"
            disabled={loading}
          >
            {loading
              ? "Authenticating..."
              : `Sign In as ${role === "owner" ? "Owner" : "Admin"}`}
            {!loading && <span> →</span>}
          </button>
        </form>

        <div className="owner-login-security">
          <span>🔒</span>
          Secure Staff Authentication
        </div>

        <p className="owner-login-footer">
          © {new Date().getFullYear()} Nivetha Catering. All rights reserved.
        </p>
      </section>
    </main>
  );
}
