import axios from "axios";

const api = axios.create({
  baseURL:
    import.meta.env.VITE_API_BASE_URL || "http://localhost:5000/api",
  timeout: 15000,
  headers: {
    "Content-Type": "application/json",
  },
});

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("customerToken");

    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    return config;
  },
  (error) => Promise.reject(error)
);

api.interceptors.response.use(
  (response) => response,
  (error) => {
    const status = error.response?.status;
    const backendMessage =
      error.response?.data?.message ||
      error.response?.data?.error;

    let message;

    if (!error.response) {
      message =
        error.code === "ECONNABORTED"
          ? "Request timed out. Please try again."
          : "Cannot connect to backend. Check that the server is running on port 5000.";
    } else {
      message =
        backendMessage ||
        (status === 400
          ? "Invalid request. Check the entered details."
          : status === 401
          ? "Unauthorized. Please log in again."
          : status === 404
          ? "API route not found. Check the backend route."
          : status === 409
          ? "This account may already exist."
          : status >= 500
          ? "Backend server error. Check the backend terminal."
          : "Something went wrong. Please try again.");
    }

    error.message = message;

    // Keep the original response and status for debugging.
    return Promise.reject(error);
  }
);

export default api;