import api from "./api";

const notificationService = {
  getAll: async () => {
    const response = await api.get("/notifications");
    return response.data;
  },

  markAsRead: async (notificationId) => {
    const response = await api.patch(
      `/notifications/${notificationId}/read`
    );
    return response.data;
  },

  markAllAsRead: async () => {
    const response = await api.patch("/notifications/read-all");
    return response.data;
  },

  delete: async (notificationId) => {
    const response = await api.delete(
      `/notifications/${notificationId}`
    );
    return response.data;
  },
};

export default notificationService;
