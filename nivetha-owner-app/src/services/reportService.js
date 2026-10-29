
import api from "./api";

const reportService = {
  // Get owner dashboard summary.
  getDashboard: async () => {
    const response = await api.get("/reports/owner/summary");
    return response.data;
  },

  // Get reports with optional filters.
  getReports: async (params = {}) => {
    const response = await api.get("/reports", {
      params,
    });

    return response.data;
  },
};

export default reportService;
