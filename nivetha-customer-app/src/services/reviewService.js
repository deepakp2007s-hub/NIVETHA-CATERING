import api from "./api";

const reviewService = {
  create: async (reviewData) => {
    const response = await api.post("/reviews", reviewData);
    return response.data;
  },

  getAll: async () => {
    const response = await api.get("/reviews");
    return response.data;
  },

  getMyReviews: async () => {
    const response = await api.get("/reviews/my-reviews");
    return response.data;
  },

  update: async (reviewId, reviewData) => {
    const response = await api.put(
      `/reviews/${reviewId}`,
      reviewData
    );
    return response.data;
  },

  delete: async (reviewId) => {
    const response = await api.delete(`/reviews/${reviewId}`);
    return response.data;
  },
};

export default reviewService;
