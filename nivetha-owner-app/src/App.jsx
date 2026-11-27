import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "./context/AuthContext";
import AppRoutes from "./routes/AppRoutes";
import Login from "./pages/Login";
import Loader from "./components/common/Loader";
import Sidebar from "./components/layout/Sidebar";
import Header from "./components/layout/Header";
import {
  requestOwnerNotificationToken,
  listenForegroundNotifications,
} from "./firebase/notifications";
import "./App.css";

// Firebase Console -> Project settings -> Cloud Messaging -> Web Push certificates-ல எடுத்த VAPID key-ஐ இங்கே போடு
const VAPID_KEY = "BJ0uqZsNTaBIHFaVWLwRj4HHSuXk8TZu4YF3ePli0hoyTLZRsuEXMxcJxKuEXJTaDKJ2uulLXm-2qYzoEP0mzOg";

export default function App() {
  const { isAuthenticated, loading } = useAuth();
  const navigate = useNavigate();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [bannerNotification, setBannerNotification] = useState(null);

  const closeSidebar = () => setSidebarOpen(false);

  useEffect(() => {
    if (!isAuthenticated) return;

    requestOwnerNotificationToken(VAPID_KEY);

    const unsubscribe = listenForegroundNotifications((payload) => {
      const title = payload?.notification?.title || "Nivetha Catering";
      const body = payload?.notification?.body || "புதிய அப்டேட் வந்துள்ளது";
      const targetPath =
        payload?.data?.url ||
        (payload?.data?.bookingId
          ? `/bookings/${payload.data.bookingId}`
          : payload?.data?.screen === "bookings"
          ? "/bookings"
          : "/notifications");

      setBannerNotification({
        id: Date.now(),
        title,
        body,
        targetPath,
      });
    });

    return () => {
      if (typeof unsubscribe === "function") {
        unsubscribe();
      }
    };
  }, [isAuthenticated]);

  const handleBannerClick = () => {
    if (!bannerNotification) return;
    const path = bannerNotification.targetPath || "/notifications";
    setBannerNotification(null);
    navigate(path);
  };

  if (loading) {
    return <Loader />;
  }

  if (!isAuthenticated) {
    return <Login />;
  }

  return (
    <div className="owner-layout">
      {bannerNotification && (
        <div
          onClick={handleBannerClick}
          role="button"
          tabIndex={0}
          onKeyDown={(e) => {
            if (e.key === "Enter" || e.key === " ") handleBannerClick();
          }}
          style={{
            position: "fixed",
            top: "16px",
            right: "16px",
            zIndex: 9999,
            maxWidth: "380px",
            backgroundColor: "#144536",
            color: "#ffffff",
            borderLeft: "4px solid #d9a441",
            borderRadius: "10px",
            padding: "14px 16px",
            boxShadow: "0 10px 25px rgba(0, 0, 0, 0.25)",
            cursor: "pointer",
          }}
        >
          <div style={{ display: "flex", justifyContent: "space-between", gap: "12px" }}>
            <strong style={{ fontSize: "14px", color: "#f6e7c1" }}>
              {bannerNotification.title}
            </strong>
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                setBannerNotification(null);
              }}
              style={{
                background: "transparent",
                border: "none",
                color: "#ffffff",
                fontSize: "16px",
                cursor: "pointer",
                lineHeight: 1,
              }}
              aria-label="Close notification"
            >
              ×
            </button>
          </div>
          <p style={{ margin: "6px 0 4px", fontSize: "13px", lineHeight: 1.4 }}>
            {bannerNotification.body}
          </p>
          <span style={{ fontSize: "11px", color: "#d9a441" }}>
            திறக்க இங்கே கிளிக் செய்யவும் →
          </span>
        </div>
      )}

      <Sidebar
        open={sidebarOpen}
        onClose={closeSidebar}
      />

      <div className="owner-main">
        <Header
          onMenuClick={() => setSidebarOpen(true)}
        />

        <main className="owner-content">
          <div className="page-container">
            <AppRoutes />
          </div>
        </main>
      </div>
    </div>
  );
}