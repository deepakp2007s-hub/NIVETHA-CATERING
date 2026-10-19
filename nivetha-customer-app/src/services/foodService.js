
import api from "./api";

const foodService = {
  getAll: async (params = {}) => {
    const response = await api.get("/foods/customer", { params });
    const result = response.data;

    if (Array.isArray(result)) return result;
    if (Array.isArray(result?.foods)) return result.foods;
    if (Array.isArray(result?.data)) return result.data;
    if (Array.isArray(result?.data?.foods)) {
      return result.data.foods;
    }

    return [];
  },
};

export default foodService;
