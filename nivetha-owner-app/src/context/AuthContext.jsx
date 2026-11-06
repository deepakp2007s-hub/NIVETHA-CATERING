
import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";

import authService from "../services/authService";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [token, setToken] = useState(() => authService.getToken());
  const [user, setUser] = useState(() => authService.getUser());
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const savedToken = authService.getToken();
    const savedUser = authService.getUser();

    if (
      !savedToken ||
      !savedUser ||
      !["owner", "admin"].includes(savedUser.role)
    ) {
      authService.logout();
      setToken(null);
      setUser(null);
    } else {
      setToken(savedToken);
      setUser(savedUser);
    }

    setLoading(false);
  }, []);

  const login = async (email, password, role = "owner") => {
    const response = await authService.login(email, password, role);

    setToken(response.token);
    setUser(response.user);

    return response;
  };

  const logout = () => {
    authService.logout();
    setToken(null);
    setUser(null);
  };

  const isAuthenticated = Boolean(
    token && ["owner", "admin"].includes(user?.role)
  );

  const value = useMemo(
    () => ({
      token,
      user,
      owner: user,
      loading,
      isAuthenticated,
      login,
      logout,
    }),
    [token, user, loading, isAuthenticated]
  );

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
