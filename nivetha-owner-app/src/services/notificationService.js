
import api from "./api";

const notificationService = {
  // Get all notifications.
  getAll: async (params = {}) => {
    const response = await api.get("/notifications", {
      params,
    });

    return response.data;
  },

  // Get notification details by ID.
  getById: async (id) => {
    if (!id) {
      throw new Error("Notification ID is required.");
    }

    const response = await api.get(
      `/notifications/${encodeURIComponent(id)}`
    );

    return response.data;
  },

  // Mark a notification as read.
  markAsRead: async (id) => {
    if (!id) {
      throw new Error("Notification ID is required.");
    }

    const response = await api.patch(
      `/notifications/${encodeURIComponent(id)}/read`
    );

    return response.data;
  },

  // Mark all notifications as read.
  markAllAsRead: async () => {
    const response = await api.patch("/notifications/read-all");
    return response.data;
  },

  // Delete a notification.
  delete: async (id) => {
    if (!id) {
      throw new Error("Notification ID is required.");
    }

    const response = await api.delete(
      `/notifications/${encodeURIComponent(id)}`
    );

    return response.data;
  },
};

export default notificationService;
