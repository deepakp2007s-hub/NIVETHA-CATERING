import {
  createContext,
  useContext,
  useEffect,
  useState,
} from "react";

import authService from "../services/authService";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(
    () => localStorage.getItem("ownerToken")
  );
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    const restoreSession = async () => {
      const savedToken = localStorage.getItem("ownerToken");

      if (!savedToken) {
        if (!cancelled) {
          setUser(null);
          setToken(null);
          setLoading(false);
        }
        return;
      }

      try {
        const response = await authService.getProfile();
        const owner = response?.owner || response?.user;

        if (response?.success === false || !owner) {
          throw new Error("Invalid owner session");
        }

        if (!cancelled) {
          setUser({
            ...owner,
            role: owner.role || "owner",
          });
          setToken(savedToken);
        }
      } catch (error) {
        localStorage.removeItem("ownerToken");

        if (!cancelled) {
          setUser(null);
          setToken(null);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    restoreSession();

    return () => {
      cancelled = true;
    };
  }, []);

  const login = async ({ phone, password }) => {
    const response = await authService.login(
      phone.trim(),
      password
    );

    const owner = response?.owner || response?.user;

    if (!response?.success || !response?.token || !owner) {
      throw new Error(response?.message || "Login failed");
    }

    const loggedInOwner = {
      ...owner,
      role: owner.role || "owner",
    };

    localStorage.setItem("ownerToken", response.token);

    setToken(response.token);
    setUser(loggedInOwner);

    return {
      ...response,
      owner: loggedInOwner,
      user: loggedInOwner,
    };
  };

  const logout = () => {
    // Clear the local session immediately.
    localStorage.removeItem("ownerToken");
    setToken(null);
    setUser(null);

    // Server-side logout is optional; local logout must still work.
    try {
      const result = authService.logout?.();

      if (result && typeof result.catch === "function") {
        result.catch((error) => {
          console.error("Server logout failed:", error);
        });
      }
    } catch (error) {
      console.error("Server logout failed:", error);
    }
  };

  const value = {
    user,
    owner: user,
    token,
    loading,
    isAuthenticated: Boolean(token && user?.role === "owner"),
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
    throw new Error("useAuth must be used inside AuthProvider");
  }

  return context;
}