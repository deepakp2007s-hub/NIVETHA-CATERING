import api from "./api";

const reviewService = {
  getAll: async (params = {}) => {
    const response = await api.get("/reviews", { params });
    return response.data;
  },

  getById: async (id) => {
    const response = await api.get(`/reviews/${id}`);
    return response.data;
  },
};

export default reviewService;