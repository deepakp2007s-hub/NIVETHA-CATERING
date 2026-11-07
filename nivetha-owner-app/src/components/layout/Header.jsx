import { useEffect, useRef, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import {
  Menu,
  Bell,
  LogOut,
  UserRound,
  ChevronDown,
  LayoutDashboard,
  CalendarDays,
  Users,
  UtensilsCrossed,
  BarChart3,
  Star,
  Settings,
  X,
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

const pageIcons = {
  "/dashboard": LayoutDashboard,
  "/bookings": CalendarDays,
  "/customers": Users,
  "/food-menu": UtensilsCrossed,
  "/reports": BarChart3,
  "/reviews": Star,
  "/settings": Settings,
};

export default function Header({ onMenuClick }) {
  const { user, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();

  const [menuOpen, setMenuOpen] = useState(false);
  const dropdownRef = useRef(null);

  const currentPath = location.pathname;

  const title = currentPath.startsWith("/bookings/")
    ? "Booking Details"
    : pageTitles[currentPath] || "Nivetha Owner";

  const PageIcon =
    pageIcons[currentPath] ||
    (currentPath.startsWith("/bookings/")
      ? CalendarDays
      : LayoutDashboard);

  const userName = user?.name || user?.full_name || user?.email || "Owner";
  const userRole = user?.role === "admin" ? "Admin" : "Owner";

  useEffect(() => {
    setMenuOpen(false);
  }, [currentPath]);

  useEffect(() => {
    const handleOutsideClick = (event) => {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(event.target)
      ) {
        setMenuOpen(false);
      }
    };

    const handleEscape = (event) => {
      if (event.key === "Escape") {
        setMenuOpen(false);
      }
    };

    document.addEventListener("mousedown", handleOutsideClick);
    document.addEventListener("keydown", handleEscape);

    return () => {
      document.removeEventListener("mousedown", handleOutsideClick);
      document.removeEventListener("keydown", handleEscape);
    };
  }, []);

  const handleNotifications = () => {
    setMenuOpen(false);
    navigate("/notifications");
  };

  const handleLogout = async () => {
    setMenuOpen(false);

    try {
      await logout();
      navigate("/login", { replace: true });
    } catch (error) {
      console.error("Logout failed:", error);
    }
  };

  return (
    <header className="owner-header">
      <div className="header-left">
        <button
          type="button"
          className="header-menu-button"
          aria-label="Open navigation menu"
          onClick={onMenuClick}
        >
          <Menu size={22} />
        </button>

        <div className="header-page-info">
          <div className="header-title-row">
            <div className="header-page-icon">
              <PageIcon size={19} />
            </div>

            <h1>{title}</h1>
          </div>

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

        <div className="header-profile" ref={dropdownRef}>
          <div className="owner-avatar">
            <UserRound size={21} />
          </div>

          <div className="owner-info">
            <strong title={userName}>{userName}</strong>
            <span>{userRole}</span>
          </div>

          <button
            type="button"
            className={`profile-menu-button ${
              menuOpen ? "profile-menu-active" : ""
            }`}
            aria-label="Toggle user menu"
            aria-expanded={menuOpen}
            aria-haspopup="true"
            onClick={() => setMenuOpen((value) => !value)}
          >
            <ChevronDown size={18} />
          </button>

          {menuOpen && (
            <div className="profile-dropdown">
              <div className="profile-dropdown-heading">
                <div className="dropdown-avatar">
                  <UserRound size={20} />
                </div>

                <div className="dropdown-user-details">
                  <strong>{userName}</strong>
                  <span>{user?.email || `${userRole} account`}</span>
                </div>
              </div>

              <div className="dropdown-divider" />

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
