import api from "./api";

const validateCustomerId = (id) => {
  if (typeof id !== "string" || !id.trim()) {
    throw new Error("Valid Customer ID is required.");
  }

  return encodeURIComponent(id.trim());
};

const customerService = {
  async getAll(params = {}) {
    const response = await api.get("/customers/", { params });
    return response.data;
  },

  async getById(id) {
    const customerId = validateCustomerId(id);
    const response = await api.get(`/customers/${customerId}`);
    return response.data;
  },

  async update(id, data) {
    const customerId = validateCustomerId(id);
    const response = await api.patch(`/customers/${customerId}`, data);
    return response.data;
  },

  async delete(id) {
    const customerId = validateCustomerId(id);
    const response = await api.delete(`/customers/${customerId}`);
    return response.data;
  },
};

export default customerService;