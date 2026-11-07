
import api from "./api";

const reportService = {
  // GET DASHBOARD SUMMARY
  async getDashboard() {
    const response = await api.get(
      "/reports/owner/summary"
    );

    return response.data;
  },

  // GET REPORTS WITH FILTERS
  async getReports(params = {}) {
    if (
      !params ||
      typeof params !== "object" ||
      Array.isArray(params)
    ) {
      throw new Error("Invalid report filters.");
    }

    const response = await api.get("/reports/", {
      params,
    });

    return response.data;
  },
};

export default reportService;
