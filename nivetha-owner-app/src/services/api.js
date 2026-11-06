
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

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("ownerToken");

    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    } else {
      delete config.headers.Authorization;
    }

    return config;
  },
  (error) => Promise.reject(error)
);

api.interceptors.response.use(
  (response) => response,
  (error) => {
    const status = error.response?.status;
    const requestUrl = error.config?.url || "";

    if (!error.response) {
      error.message =
        error.code === "ECONNABORTED"
          ? "Request timed out. Please try again."
          : "Cannot connect to the server. Check your internet connection.";
    } else if (status === 401) {
      const isLoginRequest =
        requestUrl.includes("/auth/owner-login") ||
        requestUrl.includes("/auth/admin-login");

      if (!isLoginRequest) {
        localStorage.removeItem("ownerToken");
        localStorage.removeItem("ownerUser");
      }

      error.message =
        error.response.data?.detail ||
        "Invalid credentials or authentication expired.";
    } else if (status === 403) {
      error.message =
        error.response.data?.detail ||
        "Access denied. Your account does not have permission.";
    } else if (status >= 500) {
      error.message =
        error.response.data?.detail ||
        "Server error. Please try again later.";
    } else {
      error.message =
        error.response.data?.detail ||
        error.response.data?.message ||
        error.message ||
        "Something went wrong.";
    }

    return Promise.reject(error);
  }
);

export default api;
