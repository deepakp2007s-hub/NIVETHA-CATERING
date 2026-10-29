import api from "./api";

const bookingService = {
  // Get all bookings (requires a matching backend endpoint)
  getAll: async (params = {}) => {
    const response = await api.get("/bookings", { params });
    return response.data;
  },

  // Get booking details
  getById: async (id) => {
    const response = await api.get(`/bookings/${id}`);
    return response.data;
  },

  // Update booking details
  update: async (id, data) => {
    const response = await api.patch(`/bookings/${id}`, data);
    return response.data;
  },

  // Update booking status
  updateStatus: async (id, status) => {
    const response = await api.patch(`/bookings/${id}/status`, {
      status,
    });
    return response.data;
  },
};

export default bookingService;