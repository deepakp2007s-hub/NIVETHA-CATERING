
import api from "./api";

const ALLOWED_STATUSES = [
  "confirmed",
  "rejected",
  "completed",
];

const validateBookingId = (id) => {
  if (!id || typeof id !== "string" || !id.trim()) {
    throw new Error("Valid booking ID is required.");
  }

  return encodeURIComponent(id.trim());
};

const bookingService = {
  // GET ALL BOOKINGS
  async getAll(params = {}) {
    if (
      !params ||
      typeof params !== "object" ||
      Array.isArray(params)
    ) {
      throw new Error("Invalid booking filters.");
    }

    const response = await api.get("/bookings/", { params });
    return response.data;
  },

  // GET BOOKING BY ID
  async getById(id) {
    const bookingId = validateBookingId(id);

    const response = await api.get(
      `/bookings/owner/${bookingId}`
    );

    return response.data;
  },

  // UPDATE BOOKING
  async update(id, data) {
    const bookingId = validateBookingId(id);

    if (!data || typeof data !== "object" || Array.isArray(data)) {
      throw new Error("Valid booking update data is required.");
    }

    const response = await api.put(
      `/bookings/${bookingId}`,
      data
    );

    return response.data;
  },

  // UPDATE BOOKING STATUS
  async updateStatus(id, status, ownerNote = null) {
    const bookingId = validateBookingId(id);

    if (
      typeof status !== "string" ||
      !ALLOWED_STATUSES.includes(status)
    ) {
      throw new Error(
        `Invalid booking status. Allowed: ${ALLOWED_STATUSES.join(", ")}.`
      );
    }

    if (
      ownerNote !== null &&
      typeof ownerNote !== "string"
    ) {
      throw new Error("Owner note must be a string.");
    }

    const response = await api.patch(
      `/bookings/owner/${bookingId}/status`,
      {
        status,
        owner_note: ownerNote?.trim() || null,
      }
    );

    return response.data;
  },

  // CANCEL BOOKING
  async cancel(id) {
    const bookingId = validateBookingId(id);

    const response = await api.patch(
      `/bookings/${bookingId}/cancel`
    );

    return response.data;
  },
};

export default bookingService;
