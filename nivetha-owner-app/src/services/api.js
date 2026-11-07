import axios from "axios";

const API_BASE_URL = (
  import.meta.env.VITE_API_BASE_URL ||
  "http://127.0.0.1:8000/api/v1"
).replace(/\/+$/, "");

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 60000,
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
  },
});

// Attach JWT token to every request
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

const getErrorMessage = (data, fallback) => {
  if (typeof data?.detail === "string") {
    return data.detail;
  }

  if (Array.isArray(data?.detail)) {
    return data.detail
      .map((item) => item.msg || "Validation error")
      .join(", ");
  }

  return data?.message || fallback;
};

api.interceptors.response.use(
  (response) => response,
  (error) => {
    const status = error.response?.status;
    const requestUrl = error.config?.url || "";
    const data = error.response?.data;

    if (!error.response) {
      error.message =
        error.code === "ECONNABORTED"
          ? "Request timed out. Please try again."
          : "Cannot connect to the server.";
    } else if (status === 401) {
      const isLoginRequest = requestUrl.includes("/auth/");

      if (!isLoginRequest) {
        localStorage.removeItem("ownerToken");
        localStorage.removeItem("ownerUser");

        if (window.location.pathname !== "/login") {
          window.location.replace("/login");
        }
      }

      error.message = getErrorMessage(
        data,
        "Authentication failed. Please login again."
      );
    } else if (status === 403) {
      error.message = getErrorMessage(data, "Access denied.");
    } else if (status === 404) {
      error.message = getErrorMessage(data, "Resource not found.");
    } else if (status === 405) {
      error.message = getErrorMessage(data, "HTTP method not allowed.");
    } else if (status === 422) {
      error.message = getErrorMessage(data, "Invalid request data.");
    } else if (status >= 500) {
      error.message = getErrorMessage(data, "Server error.");
    } else {
      error.message = getErrorMessage(
        data,
        error.message || "Something went wrong."
      );
    }

    return Promise.reject(error);
  }
);

export default api;