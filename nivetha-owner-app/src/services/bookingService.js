
import api from "./api";

const bookingService = {
  async getAll(params = {}) {
    const response = await api.get("/bookings/", { params });
    return response.data;
  },

  async getById(id) {
    if (!id) {
      throw new Error("Booking ID is required.");
    }

    const response = await api.get(
      `/bookings/owner/${encodeURIComponent(id)}`
    );

    return response.data;
  },

  async update(id, data) {
    if (!id) {
      throw new Error("Booking ID is required.");
    }

    const response = await api.put(
      `/bookings/${encodeURIComponent(id)}`,
      data
    );

    return response.data;
  },

  async updateStatus(id, status, ownerNote = null) {
    if (!id || !status) {
      throw new Error("Booking ID and status are required.");
    }

    const allowedStatuses = ["confirmed", "rejected", "completed"];

    if (!allowedStatuses.includes(status)) {
      throw new Error("Invalid booking status.");
    }

    const response = await api.patch(
      `/bookings/owner/${encodeURIComponent(id)}/status`,
      {
        status,
        owner_note: ownerNote,
      }
    );

    return response.data;
  },

  async cancel(id) {
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
