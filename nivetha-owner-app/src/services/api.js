
import axios from "axios";

const API_BASE_URL = (
  import.meta.env.VITE_API_BASE_URL ||
  "https://nivetha-catering-api.onrender.com/api"
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

// Handle API errors.
api.interceptors.response.use(
  (response) => response,
  (error) => {
    const status = error.response?.status;
    const requestUrl = error.config?.url || "";

    const isLoginRequest =
      /\/auth\/login(?:[/?]|$)/.test(requestUrl) ||
      /\/login(?:[/?]|$)/.test(requestUrl);

    if (status === 401 && !isLoginRequest) {
      localStorage.removeItem("ownerToken");

      if (window.location.pathname !== "/login") {
        window.location.replace("/login");
      }
    }

    if (!error.response) {
      error.message =
        error.code === "ECONNABORTED"
          ? "Request timed out. Please try again."
          : "Cannot connect to the server. Check your connection.";
    } else if (status >= 500) {
      error.message =
        error.response.data?.message ||
        "Server error. Please try again later.";
    }

    return Promise.reject(error);
  }
);

export default api;
