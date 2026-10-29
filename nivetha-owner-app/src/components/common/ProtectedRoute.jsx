
import { Outlet } from "react-router-dom";

export default function ProtectedRoute() {
  // No frontend login page required.
  return <Outlet />;
}