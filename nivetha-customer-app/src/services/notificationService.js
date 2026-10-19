
import api from "./api";

const notificationService = {
  getAll: async () => {
    const response = await api.get("/notifications");
    const result = response.data;

    if (Array.isArray(result)) return result;
    if (Array.isArray(result?.notifications)) return result.notifications;
    if (Array.isArray(result?.data)) return result.data;
    if (Array.isArray(result?.data?.notifications)) {
      return result.data.notifications;
    }

    return [];
  },

  markAsRead: async (notificationId) => {
    if (!notificationId) {
      throw new Error("Notification ID is required.");
    }

    const response = await api.patch(
      `/notifications/${encodeURIComponent(notificationId)}/read`
    );

    return response.data;
  },

  markAllAsRead: async () => {
    const response = await api.patch("/notifications/read-all");
    return response.data;
  },

  delete: async (notificationId) => {
    if (!notificationId) {
      throw new Error("Notification ID is required.");
    }

    const response = await api.delete(
      `/notifications/${encodeURIComponent(notificationId)}`
    );

    return response.data;
  },
};

export default notificationService;
