
import api from "./api";

const validateNotificationId = (id) => {
  if (
    !id ||
    typeof id !== "string" ||
    !id.trim()
  ) {
    throw new Error("Valid Notification ID is required.");
  }

  return encodeURIComponent(id.trim());
};

const notificationService = {
  // GET ALL NOTIFICATIONS
  async getAll(params = {}) {
    if (
      !params ||
      typeof params !== "object" ||
      Array.isArray(params)
    ) {
      throw new Error("Invalid notification filters.");
    }

    const response = await api.get("/notifications/", {
      params,
    });

    return response.data;
  },

  // GET NOTIFICATION BY ID
  async getById(id) {
    const notificationId = validateNotificationId(id);

    const response = await api.get(
      `/notifications/${notificationId}`
    );

    return response.data;
  },

  // MARK NOTIFICATION AS READ
  async markAsRead(id) {
    const notificationId = validateNotificationId(id);

    const response = await api.patch(
      `/notifications/${notificationId}/read`
    );

    return response.data;
  },

  // MARK ALL NOTIFICATIONS AS READ
  async markAllAsRead() {
    const response = await api.patch(
      "/notifications/read-all"
    );

    return response.data;
  },

  // DELETE NOTIFICATION
  async delete(id) {
    const notificationId = validateNotificationId(id);

    const response = await api.delete(
      `/notifications/${notificationId}`
    );

    return response.data;
  },
};

export default notificationService;
