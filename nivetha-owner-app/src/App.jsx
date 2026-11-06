
import { useState } from "react";
import { useAuth } from "./context/AuthContext";
import AppRoutes from "./routes/AppRoutes";
import Login from "./pages/Login";
import Loader from "./components/common/Loader";
import Sidebar from "./components/layout/Sidebar";
import Header from "./components/layout/Header";
import "./App.css";

export default function App() {
  const { isAuthenticated, loading } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const closeSidebar = () => setSidebarOpen(false);

  if (loading) {
    return <Loader />;
  }

  if (!isAuthenticated) {
    return <Login />;
  }

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
    </div>
  );
}
