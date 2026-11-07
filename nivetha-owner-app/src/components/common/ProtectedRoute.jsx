
import { Navigate, Outlet, useLocation } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function ProtectedRoute() {
  const { user, loading, isAuthenticated } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div className="protected-loading">
        <div className="protected-spinner" />
        <p>Checking authentication...</p>
      </div>
    );
  }

  const authenticated =
    typeof isAuthenticated === "boolean"
      ? isAuthenticated
      : Boolean(user);

  if (!authenticated) {
    return (
      <Navigate
        to="/login"
        replace
        state={{ from: location }}
      />
    );
  }

  return <Outlet />;
}
