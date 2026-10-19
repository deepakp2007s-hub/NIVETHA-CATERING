
import { useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import { ChefHat, ArrowRight } from "lucide-react";
import { useAuth } from "../context/AuthContext";
import "./PageStyles.css";

export default function Splash() {
  const navigate = useNavigate();
  const { isAuthenticated, loading } = useAuth();

  useEffect(() => {
    if (loading) return;

    const timer = setTimeout(() => {
      navigate(isAuthenticated ? "/" : "/login", {
        replace: true,
      });
    }, 3500);

    return () => clearTimeout(timer);
  }, [navigate, isAuthenticated, loading]);

  return (
    <section className="splash-page">
      <div className="splash-content">
        <div className="splash-logo">
          <ChefHat size={54} />
        </div>

        <span className="splash-small">WELCOME TO</span>
        <h1>
          Nivetha <span>Catering</span>
        </h1>

        <p>Every occasion, served with love.</p>

        <div className="splash-loader">
          <span />
        </div>

        <Link
          to={loading ? "/splash" : isAuthenticated ? "/" : "/login"}
          className="page-btn"
        >
          {loading
            ? "Loading..."
            : isAuthenticated
              ? "Enter Website"
              : "Customer Login"}
          <ArrowRight size={17} />
        </Link>
      </div>
    </section>
  );
}
