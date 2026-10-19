
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

  const refreshProfile = useCallback(async () => {
    const data = await authService.getProfile();
    const currentCustomer = data?.customer || data?.data?.customer || null;

    if (!currentCustomer) {
      throw new Error("Customer profile was not returned.");
    }

    setCustomer(currentCustomer);
    return currentCustomer;
  }, []);

  const updateProfile = useCallback(async (profileData) => {
    const data = await authService.updateProfile(profileData);
    const updatedCustomer =
      data?.customer || data?.data?.customer || data?.data || null;

    if (!updatedCustomer || !updatedCustomer.id && !updatedCustomer._id) {
      throw new Error("Updated customer profile was not returned.");
    }

    setCustomer(updatedCustomer);
    return updatedCustomer;
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
        const currentCustomer =
          data?.customer || data?.data?.customer || null;

        if (active) {
          setCustomer(currentCustomer);
        }
      } catch (error) {
        if (
          error.response?.status === 401 ||
          error.response?.status === 403
        ) {
          authService.logout();

          if (active) setCustomer(null);
        } else if (active) {
          // Do not discard a valid token for temporary server/network errors.
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

  const login = useCallback(async (credentials) => {
    const data = await authService.login(credentials);

    if (!data?.token || !data?.customer) {
      throw new Error(data?.message || "Login response is incomplete.");
    }

    localStorage.setItem("customerToken", data.token);
    setCustomer(data.customer);

    return data;
  }, []);

  const register = useCallback(async (details) => {
    const data = await authService.register(details);

    if (!data?.token || !data?.customer) {
      throw new Error(data?.message || "Registration response is incomplete.");
    }

    localStorage.setItem("customerToken", data.token);
    setCustomer(data.customer);

    return data;
  }, []);

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
    refreshProfile,
    updateProfile,
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
