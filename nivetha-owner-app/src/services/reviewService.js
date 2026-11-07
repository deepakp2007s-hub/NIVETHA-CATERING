
import api from "./api";

const validateReviewId = (id) => {
  if (
    !id ||
    typeof id !== "string" ||
    !id.trim()
  ) {
    throw new Error("Valid Review ID is required.");
  }

  return encodeURIComponent(id.trim());
};

const reviewService = {
  // GET ALL REVIEWS
  async getAll(params = {}) {
    if (
      !params ||
      typeof params !== "object" ||
      Array.isArray(params)
    ) {
      throw new Error("Invalid review filters.");
    }

    const response = await api.get("/reviews/", {
      params,
    });

    return response.data;
  },

  // GET REVIEW BY ID
  async getById(id) {
    const reviewId = validateReviewId(id);

    const response = await api.get(
      `/reviews/${reviewId}`
    );

    return response.data;
  },
};

export default reviewService;
