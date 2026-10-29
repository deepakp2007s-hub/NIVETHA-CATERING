
import axios from "axios";

const API_BASE_URL = (
  import.meta.env.VITE_API_BASE_URL ||
  "https://nivetha-fastapi-backend.onrender.com/api/v1"
).replace(/\/+$/, "");

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 60000,
  headers: {
    "Content-Type": "application/json",
  },
});

// Attach the Anna Owner authentication token.
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("ownerToken");

    config.headers = config.headers || {};

    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    } else {
      delete config.headers.Authorization;
    }

    return config;
  },
  (error) => Promise.reject(error)
);

// Handle API errors without redirecting to the login page.
api.interceptors.response.use(
  (response) => response,
  (error) => {
    const status = error.response?.status;

    if (!error.response) {
      error.message =
        error.code === "ECONNABORTED"
          ? "Request timed out. Please try again."
          : "Cannot connect to the server. Check your internet connection.";
    } else if (status === 401) {
      // Remove an invalid or expired token.
      localStorage.removeItem("ownerToken");

      // Do not redirect automatically to /login.
      error.message =
        error.response.data?.detail ||
        error.response.data?.message ||
        "Authentication required. Please check the Owner API access.";
    } else if (status === 403) {
      error.message =
        error.response.data?.detail ||
        error.response.data?.message ||
        "Access denied. Owner permission is required.";
    } else if (status >= 500) {
      error.message =
        error.response.data?.detail ||
        error.response.data?.message ||
        "Server error. Please try again later.";
    } else {
      error.message =
        error.response.data?.detail ||
        error.response.data?.message ||
        error.message ||
        "Something went wrong. Please try again.";
    }

    return Promise.reject(error);
  }
);

export default api;
