import api from "./api";

const authService = {
  // Owner login
  login: async (phone, password) => {
    const response = await api.post("/auth/login", {
      phone,
      password,
    });

    return response.data;
  },

  // Restore owner profile after refresh
  getProfile: async () => {
    const response = await api.get("/auth/me");
    return response.data;
  },

  // Clear local owner session
  logout: () => {
    localStorage.removeItem("ownerToken");
  },
};

export default authService;