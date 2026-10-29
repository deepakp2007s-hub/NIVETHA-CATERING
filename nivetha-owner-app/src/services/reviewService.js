
import api from "./api";

const reviewService = {
  // Get all customer reviews with optional filters.
  getAll: async (params = {}) => {
    const response = await api.get("/reviews", {
      params,
    });

    return response.data;
  },

  // Get review details by ID.
  getById: async (id) => {
    if (!id) {
      throw new Error("Review ID is required.");
    }

    const response = await api.get(
      `/reviews/${encodeURIComponent(id)}`
    );

    return response.data;
  },
};

export default reviewService;
