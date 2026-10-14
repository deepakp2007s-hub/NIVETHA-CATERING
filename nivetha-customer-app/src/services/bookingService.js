import api from "./api";

const bookingService = {
  create: async (bookingData) => {
    const response = await api.post("/bookings", bookingData);
    return response.data;
  },

  getMyBookings: async () => {
    const response = await api.get("/bookings/my-bookings");
    return response.data?.data || response.data;
  },

  getById: async (bookingId) => {
    const response = await api.get(`/bookings/${bookingId}`);
    return response.data?.data || response.data;
  },

  update: async (bookingId, bookingData) => {
    const response = await api.patch(
      `/bookings/${bookingId}`,
      bookingData
    );
    return response.data?.data || response.data;
  },

  cancel: async (bookingId) => {
    const response = await api.patch(
      `/bookings/${bookingId}/cancel`
    );
    return response.data;
  },
};

export default bookingService;
