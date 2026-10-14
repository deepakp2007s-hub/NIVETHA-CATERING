import { Link, NavLink } from "react-router-dom";
import { Menu, X, ShoppingBag, UserRound } from "lucide-react";
import { useState } from "react";
import "./Navbar.css";

export default function Navbar() {
  const [menuOpen, setMenuOpen] = useState(false);

  const closeMenu = () => setMenuOpen(false);

  return (
    <header className="nv-navbar">
      <div className="nv-nav-inner">
        <Link to="/" className="nv-brand" onClick={closeMenu}>
          <span className="nv-brand-mark">N</span>
          <span className="nv-brand-copy">
            <strong>NIVETHA</strong>
            <small>CATERING SERVICE</small>
          </span>
        </Link>

        <button
          className="nv-menu-toggle"
          type="button"
          aria-label={menuOpen ? "Close menu" : "Open menu"}
          aria-expanded={menuOpen}
          onClick={() => setMenuOpen(!menuOpen)}
        >
          {menuOpen ? <X size={23} /> : <Menu size={23} />}
        </button>

        <nav className={`nv-nav-links ${menuOpen ? "nv-nav-open" : ""}`}>
          <NavLink to="/" end onClick={closeMenu}>Home</NavLink>
          <a href="/#services" onClick={closeMenu}>Services</a>
          <a href="/#about" onClick={closeMenu}>About</a>
          <a href="/#contact" onClick={closeMenu}>Contact</a>

          <Link
            to="/booking"
            className="nv-mobile-book"
            onClick={closeMenu}
          >
            <ShoppingBag size={17} /> Book Catering
          </Link>

          <Link
            to="/login"
            className="nv-mobile-login"
            onClick={closeMenu}
          >
            <UserRound size={17} /> Customer Login
          </Link>
        </nav>

        <div className="nv-nav-actions">
          <Link to="/login" className="nv-login-link">
            <UserRound size={17} />
            Login
          </Link>
          <Link to="/booking" className="nv-book-button">
            Book Now <span>↗</span>
          </Link>
        </div>
      </div>
    </header>
  );
}