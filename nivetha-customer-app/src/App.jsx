
import { Routes, Route, Navigate, useLocation } from "react-router-dom";

import Navbar from "./components/Navbar.jsx";
import Footer from "./components/Footer.jsx";
import ProtectedRoute from "./components/ProtectedRoute.jsx";

import Splash from "./pages/Splash.jsx";
import Login from "./pages/Login.jsx";
import Register from "./pages/Register.jsx";
import Home from "./pages/Home.jsx";
import CustomerType from "./pages/CustomerType.jsx";
import EventDetails from "./pages/EventDetails.jsx";
import Catering from "./pages/Catering.jsx";
import FoodMenu from "./pages/FoodMenu.jsx";
import Booking from "./pages/Booking.jsx";
import BookingConfirmation from "./pages/BookingConfirmation.jsx";
import MyBookings from "./pages/MyBookings.jsx";
import BookingDetails from "./pages/BookingDetails.jsx";
import EditBooking from "./pages/EditBooking.jsx";
import Notifications from "./pages/Notifications.jsx";
import Profile from "./pages/Profile.jsx";
import Review from "./pages/Review.jsx";
import NotFound from "./pages/NotFound.jsx";

import { useAuth } from "./context/AuthContext.jsx";
import "./App.css";

function GuestRoute({ children }) {
  const { isAuthenticated, loading } = useAuth();

  if (loading) return null;

  return isAuthenticated ? <Navigate to="/" replace /> : children;
}

function AppLayout() {
  const location = useLocation();
  const isSplash = location.pathname === "/splash";

  return (
    <>
      {!isSplash && <Navbar />}

      <main className="app-main">
        <Routes>
          <Route path="/splash" element={<Splash />} />

          <Route
            path="/login"
            element={
              <GuestRoute>
                <Login />
              </GuestRoute>
            }
          />

          <Route
            path="/register"
            element={
              <GuestRoute>
                <Register />
              </GuestRoute>
            }
          />

          <Route path="/" element={<Home />} />
          <Route path="/home" element={<Navigate to="/" replace />} />

          <Route element={<ProtectedRoute />}>
            <Route path="/customer-type" element={<CustomerType />} />
            <Route path="/event-details" element={<EventDetails />} />
            <Route path="/catering" element={<Catering />} />
            <Route path="/food-menu" element={<FoodMenu />} />
            <Route path="/booking" element={<Booking />} />
            <Route path="/booking-confirmation" element={<BookingConfirmation />} />
            <Route path="/my-bookings" element={<MyBookings />} />
            <Route path="/my-bookings/:id" element={<BookingDetails />} />
            <Route path="/my-bookings/:id/edit" element={<EditBooking />} />
            <Route path="/profile" element={<Profile />} />
            <Route path="/notifications" element={<Notifications />} />
            <Route path="/review" element={<Review />} />
          </Route>

          <Route path="*" element={<NotFound />} />
        </Routes>
      </main>

      {!isSplash && <Footer />}
    </>
  );
}

export default function App() {
  return <AppLayout />;
}
