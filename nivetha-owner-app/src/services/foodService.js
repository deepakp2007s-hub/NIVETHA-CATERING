import api from "./api";
const foodService = {getAll: async (params = {}) => {const response = await api.get("/foods", {  params,}); return response.data;},
  getById: async (id) => {if (!id) {  throw new Error("Food ID is required.");}
  const response = await api.get( `/foods/${encodeURIComponent(id)}`  );
  return response.data;},
  create: async (foodData) => { if (!foodData || typeof foodData !== "object") {   throw new Error("Valid food details are required.");}
  const response = await api.post("/foods", foodData);
  return response.data;},
  update: async (id, foodData) => {
    if (!id) {
      throw new Error("Food ID is required.");
    }
  const response = await api.put( `/foods/${encodeURIComponent(id)}`, foodData );
  return response.data;  },
  delete: async (id) => {if (!id) {  throw new Error("Food ID is required."); }
  const response = await api.delete(`/foods/${encodeURIComponent(id)}`);
  return response.data;},};
export default foodService;