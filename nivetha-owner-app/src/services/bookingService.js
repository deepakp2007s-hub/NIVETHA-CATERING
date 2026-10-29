import api from "./api";

const bookingService = {
  // Get all bookings.
  getAll: async (params = {}) => {
    const response = await api.get("/bookings", { params });
    return response.data;
  },

  // Get booking details by ID.
  getById: async (id) => {
    if (!id) {
      throw new Error("Booking ID is required.");
    }

    const response = await api.get(
      `/bookings/${encodeURIComponent(id)}`
    );

    return response.data;
  },

  // Update booking details.
  update: async (id, data) => {
    if (!id) {
      throw new Error("Booking ID is required.");
    }

    const response = await api.patch(
      `/bookings/${encodeURIComponent(id)}`,
      data
    );

    return response.data;
  },

  // Update booking status.
  updateStatus: async (id, status) => {
    if (!id || !status) {
      throw new Error("Booking ID and status are required.");
    }

    const response = await api.patch(
      `/bookings/${encodeURIComponent(id)}/status`,
      { status }
    );

    return response.data;
  },

  // Cancel a booking.
  cancel: async (id) => {
    if (!id) {
      throw new Error("Booking ID is required.");
    }

    const response = await api.patch(
      `/bookings/${encodeURIComponent(id)}/cancel`
    );

    return response.data;
  },
};

export default bookingService;
