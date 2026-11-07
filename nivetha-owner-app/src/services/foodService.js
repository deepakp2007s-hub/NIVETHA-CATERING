
import api from "./api";

const validateFoodId = (id) => {
  if (
    !id ||
    typeof id !== "string" ||
    !id.trim()
  ) {
    throw new Error("Valid Food ID is required.");
  }

  return encodeURIComponent(id.trim());
};

const foodService = {
  // GET ALL FOODS
  async getAll(params = {}) {
    if (
      !params ||
      typeof params !== "object" ||
      Array.isArray(params)
    ) {
      throw new Error("Invalid food filters.");
    }

    const response = await api.get("/foods/", {
      params,
    });

    return response.data;
  },

  // GET FOOD BY ID
  async getById(id) {
    const foodId = validateFoodId(id);

    const response = await api.get(
      `/foods/${foodId}`
    );

    return response.data;
  },

  // CREATE FOOD
  async create(foodData) {
    if (
      !foodData ||
      typeof foodData !== "object" ||
      Array.isArray(foodData)
    ) {
      throw new Error("Valid food details are required.");
    }

    if (!foodData.name?.trim()) {
      throw new Error("Food name is required.");
    }

    if (!foodData.category) {
      throw new Error("Food category is required.");
    }

    const payload = {
      name: foodData.name.trim(),
      category: foodData.category,
      description: foodData.description?.trim() || "",
      image_url: foodData.image_url?.trim() || null,
      is_available: foodData.is_available ?? true,
      is_vegetarian: foodData.is_vegetarian ?? true,
    };

    const response = await api.post("/foods/", payload);

    return response.data;
  },

  // UPDATE FOOD
  async update(id, foodData) {
    const foodId = validateFoodId(id);

    if (
      !foodData ||
      typeof foodData !== "object" ||
      Array.isArray(foodData)
    ) {
      throw new Error("Valid food update details are required.");
    }

    const response = await api.put(
      `/foods/${foodId}`,
      foodData
    );

    return response.data;
  },

  // UPDATE FOOD AVAILABILITY
  async updateAvailability(id, isAvailable) {
    const foodId = validateFoodId(id);

    if (typeof isAvailable !== "boolean") {
      throw new Error("Availability must be true or false.");
    }

    const response = await api.patch(
      `/foods/${foodId}/availability`,
      {
        is_available: isAvailable,
      }
    );

    return response.data;
  },

  // DELETE FOOD
  async delete(id) {
    const foodId = validateFoodId(id);

    const response = await api.delete(
      `/foods/${foodId}`
    );

    return response.data;
  },
};

export default foodService;
