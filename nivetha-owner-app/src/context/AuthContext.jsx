import {
  createContext,
  useContext,
  useState,
} from "react";

import authService from "../services/authService";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [token, setToken] = useState(
    () => localStorage.getItem("ownerToken")
  );

  // Login page is not required.
  // The dashboard can open without a local user session.
  const [user, setUser] = useState({
    role: "owner",
    name: "Anna",
  });

  const [loading] = useState(false);

  // Optional login function for future use.
  const login = async ({ phone, password }) => {
    if (typeof authService.login !== "function") {
      throw new Error(
        "Owner login is not configured in authService."
      );
    }

    const response = await authService.login(
      phone.trim(),
      password
    );

    const owner = response?.owner || response?.user;

    if (!response?.token || !owner) {
      throw new Error(
        response?.message || "Owner login failed."
      );
    }

    localStorage.setItem("ownerToken", response.token);

    setToken(response.token);
    setUser({
      ...owner,
      role: owner.role || "owner",
    });

    return response;
  };

  const logout = () => {
    authService.logout?.();
    localStorage.removeItem("ownerToken");

    setToken(null);

    // Keep the dashboard accessible without a login page.
    setUser({
      role: "owner",
      name: "Anna",
    });
  };

  const value = {
    user,
    owner: user,
    token,
    loading,
    isAuthenticated: true,
    login,
    logout,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);

  if (!context) {
    throw new Error(
      "useAuth must be used inside AuthProvider"
    );
  }

  return context;
}
