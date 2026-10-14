import api from "./api";

const authService = {
  register: async (customerData) => {
    const response = await api.post(
      "/customer-auth/register",
      customerData
    );

    return response.data;
  },

  login: async (credentials) => {
    const response = await api.post(
      "/customer-auth/login",
      credentials
    );

    return response.data;
  },

  getProfile: async () => {
    const response = await api.get("/customer-auth/me");
    return response.data;
  },

  updateProfile: async (profileData) => {
    const response = await api.put(
      "/customers/profile",
      profileData
    );

    return response.data;
  },

  logout: () => {
    localStorage.removeItem("customerToken");
  },
};

export default authService;