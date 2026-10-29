
import { Routes, Route, Navigate } from "react-router-dom";

import Dashboard from "../pages/Dashboard";
import Bookings from "../pages/Bookings";
import BookingDetails from "../pages/BookingDetails";
import Customers from "../pages/Customers";
import FoodMenu from "../pages/FoodMenu";
import AddFood from "../pages/AddFood";
import Reports from "../pages/Reports";
import Reviews from "../pages/Reviews";
import Settings from "../pages/Settings";
import Notifications from "../pages/Notifications";

export default function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<Navigate to="/dashboard" replace />} />

      <Route path="/dashboard" element={<Dashboard />} />
      <Route path="/bookings" element={<Bookings />} />
      <Route path="/bookings/:id" element={<BookingDetails />} />
      <Route path="/customers" element={<Customers />} />

      <Route path="/food-menu" element={<FoodMenu />} />
      <Route path="/add-food" element={<AddFood />} />

      <Route path="/reports" element={<Reports />} />
      <Route path="/reviews" element={<Reviews />} />
      <Route path="/notifications" element={<Notifications />} />
      <Route path="/settings" element={<Settings />} />

      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
}
