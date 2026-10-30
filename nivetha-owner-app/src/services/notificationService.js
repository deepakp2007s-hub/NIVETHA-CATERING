import api from "./api";
const notificationService = {getAll: async (params = {}) => { const response = await api.get("/notifications", {   params, });
  return response.data; },
  getById: async (id) => { if (!id) {   throw new Error("Notification ID is required."); }
  const response = await api.get(  `/notifications/${encodeURIComponent(id)}`);
  return response.data;},
  markAsRead: async (id) => { if (!id) {throw new Error("Notification ID is required."); }
  const response = await api.patch( `/notifications/${encodeURIComponent(id)}/read` );
  return response.data;},
  markAllAsRead: async () => {const response = await api.patch("/notifications/read-all");
  return response.data;},
  delete: async (id) => { if (!id) {  throw new Error("Notification ID is required.");  }
  const response = await api.delete(   `/notifications/${encodeURIComponent(id)}` );
  return response.data; },};
export default notificationService;
