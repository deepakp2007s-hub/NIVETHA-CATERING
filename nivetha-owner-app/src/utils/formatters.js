
/* ==========================================
   NIVETHA CATERING - FORMATTERS
   Date, Time, Currency, Status and Text
========================================== */

/**
 * Format date into a readable Indian date.
 * Example: 10 Oct 2026
 */
export function formatDate(value) {
  if (!value) return "—";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return "—";
  }

  return new Intl.DateTimeFormat("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  }).format(date);
}

/**
 * Format date and time.
 * Example: 10 Oct 2026, 10:30 AM
 */
export function formatDateTime(value) {
  if (!value) return "—";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return "—";
  }

  return new Intl.DateTimeFormat("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  }).format(date);
}

/**
 * Format time.
 * Example: 10:30 AM
 */
export function formatTime(value) {
  if (!value) return "—";

  // Support time strings such as "10:30" or "14:45".
  if (typeof value === "string") {
    const match = value.match(/^(\d{1,2}):(\d{2})(?:\s*(AM|PM))?$/i);

    if (match) {
      let hours = Number(match[1]);
      const minutes = Number(match[2]);
      const period = match[3]?.toUpperCase();

      if (
        hours > 23 ||
        minutes > 59 ||
        (period && (hours < 1 || hours > 12))
      ) {
        return "—";
      }

      if (period) {
        return `${hours}:${String(minutes).padStart(2, "0")} ${period}`;
      }

      const suffix = hours >= 12 ? "PM" : "AM";
      hours = hours % 12 || 12;

      return `${hours}:${String(minutes).padStart(2, "0")} ${suffix}`;
    }
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return "—";
  }

  return new Intl.DateTimeFormat("en-IN", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  }).format(date);
}

/**
 * Format amount in Indian Rupees.
 * Example: ₹1,25,000.00
 */
export function formatCurrency(value) {
  if (value === null || value === undefined || value === "") {
    return "₹0.00";
  }

  const amount = Number(value);

  if (!Number.isFinite(amount)) {
    return "₹0.00";
  }

  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount);
}

/**
 * Format a number using Indian number grouping.
 * Example: 1,25,000
 */
export function formatNumber(value) {
  const number = Number(value);

  if (value === null || value === undefined || value === "" ||
      !Number.isFinite(number)) {
    return "0";
  }

  return new Intl.NumberFormat("en-IN", {
    maximumFractionDigits: 2,
  }).format(number);
}

/**
 * Format booking status for display.
 * Example: "pending" becomes "Pending"
 */
export function formatStatus(value) {
  if (!value || typeof value !== "string") {
    return "Unknown";
  }

  return value
    .trim()
    .replace(/[_-]+/g, " ")
    .replace(/\s+/g, " ")
    .replace(/\b\w/g, (character) => character.toUpperCase());
}

/**
 * Return a CSS class for booking or payment status.
 * Use with App.css status badge classes.
 */
export function getStatusClass(value) {
  const status = String(value || "")
    .trim()
    .toLowerCase()
    .replace(/[_\s]+/g, "-");

  const statusClasses = {
    pending: "status-pending",
    confirmed: "status-confirmed",
    completed: "status-completed",
    active: "status-active",
    rejected: "status-rejected",
    cancelled: "status-cancelled",
    canceled: "status-cancelled",
    inactive: "status-inactive",
    processing: "status-processing",
    paid: "status-confirmed",
    unpaid: "status-pending",
    "partially-paid": "status-processing",
    "partially-paid-": "status-processing",
  };

  return statusClasses[status] || "status-default";
}

/**
 * Safely display a person's name.
 */
export function formatName(value) {
  if (typeof value !== "string" || !value.trim()) {
    return "Unknown";
  }

  return value
    .trim()
    .replace(/\s+/g, " ")
    .replace(/\b\w/g, (character) => character.toUpperCase());
}

/**
 * Safely display a phone number.
 */
export function formatPhone(value) {
  if (value === null || value === undefined || value === "") {
    return "—";
  }

  return String(value).trim() || "—";
}

/**
 * Display an optional value or fallback.
 */
export function formatValue(value, fallback = "—") {
  if (value === null || value === undefined || value === "") {
    return fallback;
  }

  if (typeof value === "string" && !value.trim()) {
    return fallback;
  }

  return value;
}

/**
 * Shorten long text.
 */
export function truncateText(value, maxLength = 60) {
  if (typeof value !== "string" || !value.trim()) {
    return "—";
  }

  if (value.length <= maxLength) {
    return value;
  }

  return `${value.slice(0, Math.max(0, maxLength)).trimEnd()}...`;
}

/**
 * Format a person's name into initials.
 * Example: "Deepak Kumar" becomes "DK"
 */
export function getInitials(value) {
  if (typeof value !== "string" || !value.trim()) {
    return "NA";
  }

  return value
    .trim()
    .split(/\s+/)
    .slice(0, 2)
    .map((part) => part.charAt(0).toUpperCase())
    .join("");
}

/**
 * Format a count with singular or plural label.
 * Example: 1 booking, 5 bookings
 */
export function formatCount(value, singular, plural) {
  const count = Number(value);

  if (!Number.isFinite(count)) {
    return `0 ${plural}`;
  }

  const formattedCount = formatNumber(count);

  return `${formattedCount} ${count === 1 ? singular : plural}`;
}
