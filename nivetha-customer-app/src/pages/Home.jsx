import { Link } from "react-router-dom";
import {
  ArrowRight,
  CalendarDays,
  ChefHat,
  Utensils,
  Users,
  Clock,
  ShieldCheck,
  Sparkles,
} from "lucide-react";
import "./Home.css";

const services = [
  {
    icon: <Utensils size={28} />,
    title: "Wedding Catering",
    description: "Make your special day memorable with delicious food.",
  },
  {
    icon: <ChefHat size={28} />,
    title: "Traditional Cooking",
    description: "Authentic meals prepared by experienced cooks.",
  },
  {
    icon: <Users size={28} />,
    title: "Serving Staff",
    description: "Professional service for your guests and family.",
  },
];

const benefits = [
  "Customizable menus for every occasion",
  "Vegetarian and non-vegetarian options",
  "Flexible event and guest arrangements",
  "Booking updates in one convenient place",
];

export default function Home() {
  return (
    <div className="home-page">
      <section className="home-hero">
        <div className="home-hero-content">
          <span className="home-eyebrow">
            <Sparkles size={16} /> Nivetha Catering Service
          </span>

          <h1>
            Every Occasion,
            <br />
            <span>Served with Love.</span>
          </h1>

          <p>
            Delicious food, traditional flavours and trusted catering
            service for your most important celebrations.
          </p>

          <div className="home-hero-actions">
            <Link to="/customer-type" className="home-primary-btn">
              Book Catering <ArrowRight size={18} />
            </Link>

            <a href="#services" className="home-secondary-btn">
              Explore Services
            </a>
          </div>

          <div className="home-trust-row">
            <span><ShieldCheck size={17} /> Quality Service</span>
            <span><Clock size={17} /> Easy Booking</span>
          </div>
        </div>

        <div className="home-hero-art">
          <div className="home-food-emoji">🍛</div>
          <div className="home-art-caption">
            <span>Made for your celebrations</span>
            <strong>Fresh • Tasty • Traditional</strong>
          </div>
        </div>
      </section>

      <section className="home-services" id="services">
        <div className="home-section-heading">
          <span>WHAT WE OFFER</span>
          <h2>Catering for Every Occasion</h2>
          <p>Choose the service that suits your celebration.</p>
        </div>

        <div className="home-service-grid">
          {services.map((service) => (
            <article className="home-service-card" key={service.title}>
              <div className="home-service-icon">{service.icon}</div>
              <h3>{service.title}</h3>
              <p>{service.description}</p>
              <Link to="/customer-type">
                Book this service <ArrowRight size={16} />
              </Link>
            </article>
          ))}
        </div>
      </section>

      <section className="home-about" id="about">
        <div className="home-about-icon">
          <CalendarDays size={42} />
        </div>

        <div>
          <span className="home-about-label">YOUR EVENT, YOUR MENU</span>
          <h2>Planning your function is simple.</h2>
          <p>
            Select your event, share the date and guest count, choose
            your catering preferences and submit your booking request.
          </p>

          <ul>
            {benefits.map((benefit) => (
              <li key={benefit}>
                <span>✓</span> {benefit}
              </li>
            ))}
          </ul>

          <Link to="/customer-type" className="home-primary-btn">
            Start Your Booking <ArrowRight size={18} />
          </Link>
        </div>
      </section>

      <section className="home-contact" id="contact">
        <h2>Let's make your celebration special.</h2>
        <p>Tell us about your event and plan your catering with Nivetha.</p>
        <Link to="/customer-type" className="home-contact-btn">
          Plan Your Event
        </Link>
      </section>
    </div>
  );
}