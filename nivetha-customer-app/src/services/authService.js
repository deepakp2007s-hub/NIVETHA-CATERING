
import api from "./api";

const authService = {
  // Customer registration
  register: async (customerData) => {
    const response = await api.post(
      "/customer-auth/register",
      customerData
    );

    return response.data;
  },

  // Customer login
  login: async (credentials) => {
    const response = await api.post(
      "/customer-auth/login",
      credentials
    );

    return response.data;
  },

  // Get logged-in customer profile
  getProfile: async () => {
    const response = await api.get("/customer-auth/me");
    return response.data?.data?.customer ?? response.data?.data ?? response.data;
  },

  // Update logged-in customer's own profile
  updateProfile: async (profileData) => {
    const response = await api.patch(
      "/customers/profile",
      profileData
    );

    return response.data?.data?.customer ?? response.data?.data ?? response.data;
  },

  // Customer logout
  logout: () => {
    localStorage.removeItem("customerToken");
  },
};

export default authService;
