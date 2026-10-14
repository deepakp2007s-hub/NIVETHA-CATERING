import api from "./api";

const foodService = {
  getAll: async (params = {}) => {
    const response = await api.get("/foods", { params });
    return response.data;
  },

  getById: async (foodId) => {
    const response = await api.get(`/foods/${foodId}`);
    return response.data;
  },
};

export default foodService;
