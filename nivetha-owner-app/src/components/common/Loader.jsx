
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
    >
      <div style={{ textAlign: "center" }}>
        <LoaderCircle
          className="loading-spinner-icon"
          size={size}
          aria-hidden="true"
        />

        <p style={{ marginTop: 12, marginBottom: 0 }}>
          {message}
        </p>
      </div>
    </div>
  );
}
