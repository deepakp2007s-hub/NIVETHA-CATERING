import { useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import { ChefHat, ArrowRight } from "lucide-react";
import "./PageStyles.css";

export default function Splash() {
  const navigate = useNavigate();

  useEffect(() => {
    const timer = setTimeout(() => navigate("/", { replace: true }), 3500);
    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <section className="splash-page">
      <div className="splash-content">
        <div className="splash-logo"><ChefHat size={54} /></div>
        <span className="splash-small">WELCOME TO</span>
        <h1>Nivetha <span>Catering</span></h1>
        <p>Every occasion, served with love.</p>
        <div className="splash-loader"><span /></div>
        <Link to="/" className="page-btn">Enter Website <ArrowRight size={17} /></Link>
      </div>
    </section>
  );
}