
import api from "./api";

const reviewService = {
  create: async (reviewData) => {
    const response = await api.post("/reviews", reviewData);
    return response.data;
  },
};

export default reviewService;
