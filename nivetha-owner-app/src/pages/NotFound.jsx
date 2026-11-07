
import { Link, useNavigate } from "react-router-dom";
import { Home, ArrowLeft, SearchX, Sparkles } from "lucide-react";
import "./NotFound.css";

export default function NotFound() {
  const navigate = useNavigate();

  const goBack = () => {
    if (window.history.length > 1) {
      navigate(-1);
    } else {
      navigate("/dashboard", { replace: true });
    }
  };

  return (
    <main className="not-found-page">
      <div className="not-found-orb not-found-orb-one" />
      <div className="not-found-orb not-found-orb-two" />

      <div className="not-found-content">
        <div className="not-found-top-label">
          <Sparkles size={15} />
          NIVETHA CATERING
          <span>•</span>
          ERROR PAGE
        </div>

        <section className="not-found-card">
          <div className="not-found-illustration">
            <div className="not-found-icon-ring">
              <SearchX size={42} strokeWidth={1.5} />
            </div>
            <span className="not-found-floating-dot dot-one" />
            <span className="not-found-floating-dot dot-two" />
            <span className="not-found-floating-dot dot-three" />
          </div>

          <div className="not-found-number">404</div>

          <span className="not-found-badge">
            <span />
            PAGE NOT FOUND
          </span>

          <h1>Oops! Lost in the kitchen?</h1>

          <p>
            The page you're looking for may have been moved, deleted,
            or doesn't exist. Let's get you back on track.
          </p>

          <div className="not-found-actions">
            <Link to="/dashboard" className="not-found-home-button">
              <Home size={17} />
              Back to Dashboard
            </Link>

            <button
              type="button"
              className="not-found-back-button"
              onClick={goBack}
            >
              <ArrowLeft size={17} />
              Go Back
            </button>
          </div>

          <div className="not-found-divider" />

          <div className="not-found-help">
            <span>Need a fresh start?</span>
            <Link to="/dashboard">Visit your dashboard →</Link>
          </div>
        </section>

        <footer className="not-found-footer">
          <span>NIVETHA CATERING SERVICE</span>
          <span>Crafted with care · Owner Dashboard</span>
        </footer>
      </div>
    </main>
  );
}
