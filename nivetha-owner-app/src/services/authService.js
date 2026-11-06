
import api from "./api";

const authService = {
  async login(email, password, role = "owner") {
    if (!["owner", "admin"].includes(role)) {
      throw new Error("Invalid login role.");
    }

    const endpoint =
      role === "admin"
        ? "/auth/admin-login"
        : "/auth/owner-login";

    const response = await api.post(endpoint, {
      email: email.trim().toLowerCase(),
      password,
    });

    const data = response.data;

    if (
      !data?.access_token ||
      data.role !== role ||
      !data.user ||
      data.user.role !== role
    ) {
      throw new Error("Invalid login response.");
    }

    localStorage.setItem("ownerToken", data.access_token);
    localStorage.setItem("ownerUser", JSON.stringify(data.user));

    return {
      token: data.access_token,
      user: data.user,
    };
  },

  getToken() {
    return localStorage.getItem("ownerToken");
  },

  getUser() {
    try {
      return JSON.parse(
        localStorage.getItem("ownerUser") || "null"
      );
    } catch {
      return null;
    }
  },

  logout() {
    localStorage.removeItem("ownerToken");
    localStorage.removeItem("ownerUser");
  },
};

export default authService;
