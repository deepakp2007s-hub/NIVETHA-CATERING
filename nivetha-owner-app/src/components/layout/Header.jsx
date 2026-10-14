import { useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import {
  Menu,
  Bell,
  LogOut,
  UserRound,
  ChevronDown,
} from "lucide-react";

import { useAuth } from "../../context/AuthContext";
import "./Header.css";

const pageTitles = {
  "/dashboard": "Dashboard",
  "/bookings": "Bookings",
  "/customers": "Customers",
  "/food-menu": "Food Menu",
  "/reports": "Reports",
  "/reviews": "Customer Reviews",
  "/settings": "Settings",
  "/notifications": "Notifications",
};

export default function Header({ onMenuClick }) {
  const { user, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();

  const [menuOpen, setMenuOpen] = useState(false);

  const title = location.pathname.startsWith("/bookings/")
    ? "Booking Details"
    : pageTitles[location.pathname] || "Nivetha Owner";

  const ownerName = user?.name || "Owner";

  const handleNotifications = () => {
    setMenuOpen(false);
    navigate("/notifications");
  };

  const handleLogout = async () => {
    setMenuOpen(false);

    try {
      await logout();
    } finally {
      navigate("/login", { replace: true });
    }
  };

  return (
    <header className="owner-header">
      <div className="header-left">
        <button
          type="button"
          className="header-menu-button"
          aria-label="Open navigation"
          onClick={onMenuClick}
        >
          <Menu size={23} />
        </button>

        <div>
          <h1>{title}</h1>
          <p>Welcome to Nivetha Catering Service</p>
        </div>
      </div>

      <div className="header-actions">
        <button
          type="button"
          className="header-icon-button"
          aria-label="Notifications"
          title="Notifications"
          onClick={handleNotifications}
        >
          <Bell size={20} />
        </button>

        <div className="header-profile">
          <div className="owner-avatar">
            <UserRound size={21} />
          </div>

          <div className="owner-info">
            <strong>{ownerName}</strong>
            <span>Administrator</span>
          </div>

          <button
            type="button"
            className="profile-menu-button"
            aria-label="Owner menu"
            aria-expanded={menuOpen}
            aria-haspopup="true"
            onClick={() => setMenuOpen((value) => !value)}
          >
            <ChevronDown
              size={18}
              style={{
                transform: menuOpen ? "rotate(180deg)" : "rotate(0deg)",
                transition: "transform 0.2s ease",
              }}
            />
          </button>

          {menuOpen && (
            <div className="profile-dropdown">
              <div className="profile-dropdown-heading">
                <strong>{ownerName}</strong>
                <span>Owner account</span>
              </div>

              <button
                type="button"
                className="logout-button"
                onClick={handleLogout}
              >
                <LogOut size={18} />
                <span>Logout</span>
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}