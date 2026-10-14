import { useState } from "react";
import { useLocation } from "react-router-dom";

import { useAuth } from "./context/AuthContext";
import AppRoutes from "./routes/AppRoutes";

import Sidebar from "./components/layout/Sidebar";
import Header from "./components/layout/Header";

import "./App.css";

function OwnerLayout() {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const closeSidebar = () => {
    setSidebarOpen(false);
  };

  return (
    <div className="owner-layout">
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

      {sidebarOpen && (
        <button
          type="button"
          className="sidebar-overlay"
          aria-label="Close sidebar"
          onClick={closeSidebar}
        />
      )}
    </div>
  );
}

export default function App() {
  const { user, loading } = useAuth();
  const location = useLocation();

  const isLoginPage = location.pathname === "/login";

  if (loading) {
    return (
      <div className="app-loading">
        <p>Loading Nivetha Owner App...</p>
      </div>
    );
  }

  if (!user || user.role !== "owner" || isLoginPage) {
    return <AppRoutes />;
  }

  return <OwnerLayout />;
}