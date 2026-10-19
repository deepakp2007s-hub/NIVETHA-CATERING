
import { Link, useNavigate } from "react-router-dom";
import { ArrowLeft, House } from "lucide-react";
import "./PageStyles.css";

export default function NotFound() {
  const navigate = useNavigate();

  function goBack() {
    if (window.history.length > 1) {
      navigate(-1);
    } else {
      navigate("/", { replace: true });
    }
  }

  return (
    <section className="page-container page-narrow not-found-page">
      <span className="not-found-number">404</span>

      <h1>Page not found</h1>

      <p>
        The page you are looking for may have moved or does not exist.
      </p>

      <div className="page-actions page-actions-center">
        <Link to="/" className="page-btn">
          <House size={17} />
          Go Home
        </Link>

        <button
          type="button"
          className="page-btn page-btn-light"
          onClick={goBack}
        >
          <ArrowLeft size={17} />
          Go Back
        </button>
      </div>
    </section>
  );
}
