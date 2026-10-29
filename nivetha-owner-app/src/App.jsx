
import { useState } from "react";
import AppRoutes from "./routes/AppRoutes";

import Sidebar from "./components/layout/Sidebar";
import Header from "./components/layout/Header";

import "./App.css";

export default function App() {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const closeSidebar = () => setSidebarOpen(false);

  return (
    <div className="owner-layout">
      <Sidebar open={sidebarOpen} onClose={closeSidebar} />

      <div className="owner-main">
        <Header onMenuClick={() => setSidebarOpen(true)} />

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
