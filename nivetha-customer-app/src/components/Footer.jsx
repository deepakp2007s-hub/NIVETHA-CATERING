import { Link } from "react-router-dom";
import { MapPin, Phone, ArrowUpRight } from "lucide-react";
import "./Footer.css";

export default function Footer() {
  return (
    <footer className="nv-footer" id="contact">
      <div className="nv-footer-main">
        <div className="nv-footer-brand">
          <Link to="/" className="nv-footer-logo">
            <span className="nv-brand-mark">N</span>
            <span>
              <strong>NIVETHA</strong>
              <small>CATERING SERVICE</small>
            </span>
          </Link>
          <p>
            Delicious food and thoughtful service for your
            most memorable celebrations.
          </p>
        </div>

        <div className="nv-footer-column">
          <h3>Explore</h3>
          <Link to="/">Home</Link>
          <a href="/#services">Our Services</a>
          <a href="/#about">About Us</a>
        </div>

        <div className="nv-footer-column">
          <h3>Customer</h3>
          <Link to="/booking">Book Catering</Link>
          <Link to="/login">Customer Login</Link>
          <Link to="/my-bookings">My Bookings</Link>
        </div>

        <div className="nv-footer-column">
          <h3>Get in Touch</h3>
          <p><MapPin size={16} /> Contact us for your event location</p>
          <p><Phone size={16} /> Contact details coming soon</p>
          <Link to="/booking" className="nv-footer-cta">
            Plan your event <ArrowUpRight size={15} />
          </Link>
        </div>
      </div>

      <div className="nv-footer-bottom">
        <span>© {new Date().getFullYear()} Nivetha Catering Service</span>
        <span>Made for your special moments <span className="nv-footer-heart">♥</span></span>
      </div>
    </footer>
  );
}