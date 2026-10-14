import api from "./api";

const reportService = {
  getDashboard: async () => {
    const response = await api.get("/dashboard");
    return response.data;
  },

  getReports: async (params = {}) => {
    const response = await api.get("/reports", { params });
    return response.data;
  },
};

export default reportService;