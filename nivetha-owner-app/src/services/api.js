import axios from "axios";

const api = axios.create({
  baseURL:
    import.meta.env.VITE_API_BASE_URL ||
    "http://localhost:5000/api",
  timeout: 20000,
  headers: {
    "Content-Type": "application/json",
  },
});

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("ownerToken");

    if (token) {
      config.headers = config.headers || {};
      config.headers.Authorization = `Bearer ${token}`;
    } else if (config.headers) {
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

    const isLoginRequest =
      requestUrl.includes("/auth/login") ||
      requestUrl.includes("/login");

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
          : "Cannot connect to the server. Check your internet connection.";
    } else if (status >= 500) {
      error.message =
        error.response.data?.message ||
        "Server error. Please try again later.";
    }

    return Promise.reject(error);
  }
);

export default api;