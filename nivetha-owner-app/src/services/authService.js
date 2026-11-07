
import api from "./api";

const TOKEN_KEY = "ownerToken";
const USER_KEY = "ownerUser";

const authService = {
  // LOGIN
  async login(email, password, role = "owner") {
    if (!["owner", "admin"].includes(role)) {
      throw new Error("Invalid login role.");
    }

    if (!email?.trim() || !password) {
      throw new Error("Email and password are required.");
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
      throw new Error("Invalid login response from server.");
    }

    localStorage.setItem(TOKEN_KEY, data.access_token);
    localStorage.setItem(USER_KEY, JSON.stringify(data.user));

    return {
      token: data.access_token,
      user: data.user,
    };
  },

  // GET TOKEN
  getToken() {
    return localStorage.getItem(TOKEN_KEY);
  },

  // GET USER
  getUser() {
    try {
      const user = JSON.parse(
        localStorage.getItem(USER_KEY) || "null"
      );

      return user && typeof user === "object" ? user : null;
    } catch {
      localStorage.removeItem(USER_KEY);
      return null;
    }
  },

  // CHECK AUTHENTICATION
  isAuthenticated() {
    return Boolean(
      this.getToken() && this.getUser()
    );
  },

  // CHECK USER ROLE
  hasRole(role) {
    const user = this.getUser();
    return Boolean(user && user.role === role);
  },

  // UPDATE USER
  updateUser(user) {
    if (!user || typeof user !== "object") {
      throw new Error("Invalid user information.");
    }

    localStorage.setItem(USER_KEY, JSON.stringify(user));
  },

  // LOGOUT
  logout() {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
  },
};

export default authService;
