import { LoaderCircle } from "lucide-react";
import "./Button.css";

export default function Button({
  children,
  variant = "primary",
  type = "button",
  loading = false,
  disabled = false,
  fullWidth = false,
  onClick,
  className = "",
}) {
  return (
    <button
      type={type}
      className={`nv-button nv-button-${variant} ${fullWidth ? "nv-button-full" : ""} ${className}`}
      disabled={disabled || loading}
      onClick={onClick}
    >
      {loading && <LoaderCircle size={17} className="nv-button-spinner" />}
      {children}
    </button>
  );
}