
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
  Sparkles,
  ChevronRight,
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
  const handleClose = () => {
    if (typeof onClose === "function") {
      onClose();
    }
  };

  return (
    <>
      <button
        type="button"
        className={`sidebar-overlay ${open ? "sidebar-overlay-visible" : ""}`}
        aria-label="Close navigation menu"
        aria-hidden={!open}
        tabIndex={open ? 0 : -1}
        onClick={handleClose}
      />

      <aside
        className={`owner-sidebar ${open ? "sidebar-open" : ""}`}
        aria-label="Owner navigation"
      >
        <div className="sidebar-brand">
          <div className="brand-icon">
            <ChefHat size={27} strokeWidth={1.9} />
            <span className="brand-icon-glow" />
          </div>

          <div className="brand-text">
            <h2>NIVETHA</h2>
            <p>CATERING SERVICE</p>
          </div>

          <button
            type="button"
            className="sidebar-close"
            aria-label="Close sidebar"
            onClick={handleClose}
          >
            <X size={20} />
          </button>
        </div>

        <div className="sidebar-brand-divider" />

        <div className="sidebar-section-label">
          <span>MAIN MENU</span>
          <Sparkles size={13} />
        </div>

        <nav className="sidebar-nav">
          {menuItems.map(({ label, path, icon: Icon }, index) => (
            <NavLink
              key={path}
              to={path}
              end={path === "/dashboard"}
              className={({ isActive }) =>
                `sidebar-link ${isActive ? "active" : ""}`
              }
              onClick={handleClose}
              style={{ "--sidebar-item-index": index }}
            >
              <span className="sidebar-link-icon">
                <Icon size={19} strokeWidth={1.9} />
              </span>

              <span className="sidebar-link-label">{label}</span>

              <ChevronRight
                size={15}
                className="sidebar-link-arrow"
                aria-hidden="true"
              />
            </NavLink>
          ))}
        </nav>

        <div className="sidebar-bottom">
          <div className="sidebar-premium-card">
            <div className="sidebar-premium-icon">
              <Sparkles size={17} />
            </div>
            <div>
              <strong>Manage with ease</strong>
              <p>Your catering business, one place.</p>
            </div>
          </div>

          <div className="sidebar-footer">
            <div className="sidebar-footer-icon">
              <ChefHat size={20} />
            </div>

            <div className="sidebar-footer-text">
              <strong>Owner Panel</strong>
              <p>Nivetha Catering</p>
            </div>

            <span className="sidebar-footer-status" title="Owner panel" />
          </div>
        </div>
      </aside>
    </>
  );
}
