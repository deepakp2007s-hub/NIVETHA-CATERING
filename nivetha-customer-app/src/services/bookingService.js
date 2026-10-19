
import api from "./api";

const bookingService = {
  create: async (bookingData) => {
    const response = await api.post("/bookings", bookingData);
    return response.data;
  },

  getMyBookings: async () => {
    const response = await api.get("/bookings/my-bookings");
    const result = response.data;

    if (Array.isArray(result)) return result;
    if (Array.isArray(result?.bookings)) return result.bookings;
    if (Array.isArray(result?.data)) return result.data;
    if (Array.isArray(result?.data?.bookings)) {
      return result.data.bookings;
    }

    return [];
  },

  getById: async (bookingId) => {
    if (!bookingId) {
      throw new Error("Booking ID is required.");
    }

    const response = await api.get(
      `/bookings/${encodeURIComponent(bookingId)}`
    );

    return response.data;
  },

  update: async (bookingId, bookingData) => {
    if (!bookingId) {
      throw new Error("Booking ID is required.");
    }

    const response = await api.patch(
      `/bookings/${encodeURIComponent(bookingId)}`,
      bookingData
    );

    return response.data;
  },

  cancel: async (bookingId) => {
    if (!bookingId) {
      throw new Error("Booking ID is required.");
    }

    const response = await api.patch(
      `/bookings/${encodeURIComponent(bookingId)}/cancel`
    );

    return response.data;
  },
};

export default bookingService;
