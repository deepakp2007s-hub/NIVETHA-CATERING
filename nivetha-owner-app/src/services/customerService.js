import api from "./api";
const customerService = {
  getAll: async (params = {}) => { const response = await api.get("/customers", { params,});
  return response.data; },
  getById: async (id) => {if (!id) {  throw new Error("Customer ID is required.");}
  const response = await api.get(`/customers/${encodeURIComponent(id)}`);
  return response.data;},};
export default customerService;
