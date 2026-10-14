import api from "./api";

const bookingService = {
  getAll: async (params = {}) => {
    const response = await api.get("/bookings", { params });
    return response.data;
  },

  getById: async (id) => {
    const response = await api.get(`/bookings/${id}`);
    return response.data;
  },

  update: async (id, data) => {
    const response = await api.patch(`/bookings/${id}/status`, data);
    return response.data;
  },

  updateStatus: async (id, status) => {
    const response = await api.patch(`/bookings/${id}/status`, {
      status,
    });
    return response.data;
  },
};

export default bookingService;
