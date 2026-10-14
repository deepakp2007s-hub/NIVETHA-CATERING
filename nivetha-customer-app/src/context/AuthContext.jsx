import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
} from "react";

import authService from "../services/authService";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [customer, setCustomer] = useState(null);
  const [loading, setLoading] = useState(true);

  const logout = useCallback(() => {
    authService.logout();
    setCustomer(null);
  }, []);

  useEffect(() => {
    let active = true;

    async function loadCustomer() {
      const token = localStorage.getItem("customerToken");

      if (!token) {
        if (active) setLoading(false);
        return;
      }

      try {
        const data = await authService.getProfile();

        if (active) {
          setCustomer(data.customer || data.user || null);
        }
      } catch (error) {
        if (error.response?.status === 401 || error.response?.status === 403) {
          authService.logout();
        }

        if (active) {
          setCustomer(null);
        }
      } finally {
        if (active) setLoading(false);
      }
    }

    loadCustomer();

    return () => {
      active = false;
    };
  }, []);

  const login = async (credentials) => {
    const data = await authService.login(credentials);

    if (!data.token) {
      throw new Error(data.message || "Login token was not returned.");
    }

    localStorage.setItem("customerToken", data.token);
    setCustomer(data.customer || data.user || null);

    return data;
  };

  const register = async (details) => {
    const data = await authService.register(details);

    if (!data.token) {
      throw new Error(data.message || "Registration token was not returned.");
    }

    localStorage.setItem("customerToken", data.token);
    setCustomer(data.customer || data.user || null);

    return data;
  };

  const value = {
    customer,
    user: customer,
    loading,
    isAuthenticated: Boolean(
      customer && localStorage.getItem("customerToken")
    ),
    login,
    register,
    logout,
    setCustomer,
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
    throw new Error("useAuth must be used inside AuthProvider");
  }

  return context;
}