
import { NavLink } from "react-router-dom";
import {
  LayoutDashboard,
  CalendarDays,
  Users,
  UtensilsCrossed,
  BarChart3,
  Star,
  Settings,
  ChefHat,
  X,
} from "lucide-react";
import "./Sidebar.css";
const menuItems = [
  { label: "Dashboard", path: "/dashboard", icon: LayoutDashboard },
  { label: "Bookings", path: "/bookings", icon: CalendarDays },
  { label: "Customers", path: "/customers", icon: Users },
  { label: "Food Menu", path: "/food-menu", icon: UtensilsCrossed },
  { label: "Reports", path: "/reports", icon: BarChart3 },
  { label: "Reviews", path: "/reviews", icon: Star },
  { label: "Settings", path: "/settings", icon: Settings },
];

export default function Sidebar({ open = false, onClose }) {
  return (
    <>
      {open && (
        <button
          type="button"
          className="sidebar-overlay"
          aria-label="Close navigation"
          onClick={onClose}
        />
      )}

      <aside className={`owner-sidebar ${open ? "sidebar-open" : ""}`}>
        <div className="sidebar-brand">
          <div className="brand-icon">
            <ChefHat size={27} />
          </div>

          <div className="brand-text">
            <h2>NIVETHA</h2>
            <p>CATERING SERVICE</p>
          </div>

          <button
            type="button"
            className="sidebar-close"
            aria-label="Close sidebar"
            onClick={onClose}
          >
            <X size={21} />
          </button>
        </div>

        <div className="sidebar-section-label">MAIN MENU</div>

        <nav className="sidebar-nav">
          {menuItems.map(({ label, path, icon: Icon }) => (
            <NavLink
              key={path}
              to={path}
              end={path === "/dashboard"}
              className={({ isActive }) =>
                `sidebar-link ${isActive ? "active" : ""}`
              }
              onClick={onClose}
            >
              <Icon size={20} />
              <span>{label}</span>
            </NavLink>
          ))}
        </nav>

        <div className="sidebar-footer">
          <div className="sidebar-footer-icon">
            <ChefHat size={20} />
          </div>
          <div>
            <strong>Owner Panel</strong>
            <p>Manage your catering</p>
          </div>
        </div>
      </aside>
    </>
  );
}
