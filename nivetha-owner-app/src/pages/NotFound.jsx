import { Link } from "react-router-dom";
import { Home } from "lucide-react";
import "./NotFound.css";

export default function NotFound() {
  return (
    <section className="not-found-page">
      <div className="not-found-card">
        <div className="not-found-icon">!</div>

        <h1>404</h1>
        <h3>Page not found</h3>
        <p>The page you requested does not exist.</p>

        <Link to="/dashboard" className="not-found-button">
          <Home size={17} />
          Back to Dashboard
        </Link>
      </div>
    </section>
  );
}