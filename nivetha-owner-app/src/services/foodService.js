import api from "./api";

const foodService = {
  getAll: async (params = {}) => {
    const response = await api.get("/foods", { params });
    return response.data;
  },

  getById: async (id) => {
    const response = await api.get(`/foods/${id}`);
    return response.data;
  },

  create: async (foodData) => {
    const response = await api.post("/foods", foodData);
    return response.data;
  },

  update: async (id, foodData) => {
    const response = await api.put(`/foods/${id}`, foodData);
    return response.data;
  },

  delete: async (id) => {
    const response = await api.delete(`/foods/${id}`);
    return response.data;
  },
};

export default foodService;