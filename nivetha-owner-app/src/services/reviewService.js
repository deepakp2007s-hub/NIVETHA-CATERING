import api from "./api";
const reviewService = {
  getAll: async (params = {}) => {const response = await api.get("/reviews", {  params,});
  return response.data;},
  getById: async (id) => {if (!id) {throw new Error("Review ID is required."); }
  const response = await api.get(`/reviews/${encodeURIComponent(id)}`);
  return response.data;},};
export default reviewService;
