
import { LoaderCircle } from "lucide-react";
import "./Loader.css";

export default function Loader({
  message = "Loading...",
  fullScreen = false,
  size = 30,
}) {
  return (
    <div
      className={`page-loading ${fullScreen ? "app-loading" : ""}`}
      role="status"
      aria-live="polite"
      aria-busy="true"
    >
      <div className="loader-content">
        <div className="loader-icon-wrapper">
          <LoaderCircle
            className="loading-spinner-icon"
            size={size}
            strokeWidth={2.5}
            aria-hidden="true"
          />
        </div>

        <p className="loader-message">{message}</p>
      </div>
    </div>
  );
}