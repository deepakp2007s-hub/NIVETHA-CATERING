import { useState } from "react";
import "./Settings.css";

const initialPreferences = {
  language: "English",
  theme: "light",
  compactView: false,
  bookingNotifications: true,
  reviewNotifications: true,
};

const tabs = [
  { id: "general", icon: "⚙", label: "General" },
  { id: "notifications", icon: "♧", label: "Notifications" },
  { id: "security", icon: "◇", label: "Security" },
  { id: "about", icon: "ⓘ", label: "About" },
];

export default function Settings() {
  const [activeTab, setActiveTab] = useState("general");
  const [preferences, setPreferences] = useState(initialPreferences);
  const [notice, setNotice] = useState("");

  const updatePreference = (key, value) => {
    setPreferences((current) => ({
      ...current,
      [key]: value,
    }));
    setNotice("Preference updated for this session.");
  };

  const resetPreferences = () => {
    setPreferences({ ...initialPreferences });
    setNotice("Preferences reset.");
  };

  return (
    <div className="settings-page">
      <header className="settings-header">
        <div>
          <span className="settings-eyebrow">
            OWNER CONTROL CENTER
          </span>
          <h1>Settings</h1>
          <p>Manage your application preferences and account information.</p>
        </div>

        <div className="settings-header-mark" aria-hidden="true">
          ⚙
        </div>
      </header>

      {notice && (
        <div className="settings-notice" role="status" aria-live="polite">
          <span>ⓘ</span>
          <p>{notice}</p>
          <button
            type="button"
            aria-label="Dismiss notice"
            onClick={() => setNotice("")}
          >
            ×
          </button>
        </div>
      )}

      <div className="settings-layout">
        <aside className="settings-sidebar">
          <div className="settings-sidebar-heading">
            PREFERENCES
          </div>

          <nav className="settings-tabs" aria-label="Settings sections">
            {tabs.map((tab) => (
              <button
                type="button"
                key={tab.id}
                className={`settings-tab ${
                  activeTab === tab.id ? "active" : ""
                }`}
                aria-current={activeTab === tab.id ? "page" : undefined}
                onClick={() => {
                  setActiveTab(tab.id);
                  setNotice("");
                }}
              >
                <span className="settings-tab-icon">{tab.icon}</span>
                <span>{tab.label}</span>
                {activeTab === tab.id && (
                  <span className="settings-tab-arrow">›</span>
                )}
              </button>
            ))}
          </nav>

          <div className="settings-sidebar-note">
            <span className="settings-note-icon">✦</span>
            <strong>Nivetha Catering</strong>
            <p>Owner settings and application preferences.</p>
          </div>
        </aside>

        <main className="settings-content">
          {activeTab === "general" && (
            <section className="settings-panel">
              <div className="settings-panel-heading">
                <div>
                  <h2>General Preferences</h2>
                  <p>Choose your application preferences.</p>
                </div>
                <span className="settings-panel-icon">⚙</span>
              </div>

              <div className="settings-option">
                <div className="settings-option-copy">
                  <strong>Display Language</strong>
                  <p>Choose your preferred language.</p>
                </div>

                <select
                  className="settings-select"
                  value={preferences.language}
                  onChange={(event) =>
                    updatePreference("language", event.target.value)
                  }
                >
                  <option value="English">English</option>
                  <option value="Tamil">தமிழ் (Tamil)</option>
                </select>
              </div>

              <div className="settings-option">
                <div className="settings-option-copy">
                  <strong>Appearance</strong>
                  <p>Select your preferred appearance.</p>
                </div>

                <select
                  className="settings-select"
                  value={preferences.theme}
                  onChange={(event) =>
                    updatePreference("theme", event.target.value)
                  }
                >
                  <option value="light">Light</option>
                  <option value="dark">Dark preference</option>
                </select>
              </div>

              <div className="settings-option">
                <div className="settings-option-copy">
                  <strong>Compact View</strong>
                  <p>Choose a compact layout preference.</p>
                </div>

                <button
                  type="button"
                  role="switch"
                  aria-label="Compact View"
                  aria-checked={preferences.compactView}
                  className={`settings-switch ${
                    preferences.compactView ? "on" : ""
                  }`}
                  onClick={() =>
                    updatePreference("compactView", !preferences.compactView)
                  }
                >
                  <span />
                </button>
              </div>

              <div className="settings-panel-footer">
                <button
                  type="button"
                  className="settings-button settings-button-secondary"
                  onClick={resetPreferences}
                >
                  Reset Preferences
                </button>
              </div>
            </section>
          )}

          {activeTab === "notifications" && (
            <section className="settings-panel">
              <div className="settings-panel-heading">
                <div>
                  <h2>Notification Preferences</h2>
                  <p>Manage your notification preferences.</p>
                </div>
                <span className="settings-panel-icon">♧</span>
              </div>

              <div className="settings-option">
                <div className="settings-option-copy">
                  <strong>Booking Notifications</strong>
                  <p>Preference for new and updated booking alerts.</p>
                </div>

                <button
                  type="button"
                  role="switch"
                  aria-label="Booking Notifications"
                  aria-checked={preferences.bookingNotifications}
                  className={`settings-switch ${
                    preferences.bookingNotifications ? "on" : ""
                  }`}
                  onClick={() =>
                    updatePreference(
                      "bookingNotifications",
                      !preferences.bookingNotifications
                    )
                  }
                >
                  <span />
                </button>
              </div>

              <div className="settings-option">
                <div className="settings-option-copy">
                  <strong>Review Notifications</strong>
                  <p>Preference for customer review alerts.</p>
                </div>

                <button
                  type="button"
                  role="switch"
                  aria-label="Review Notifications"
                  aria-checked={preferences.reviewNotifications}
                  className={`settings-switch ${
                    preferences.reviewNotifications ? "on" : ""
                  }`}
                  onClick={() =>
                    updatePreference(
                      "reviewNotifications",
                      !preferences.reviewNotifications
                    )
                  }
                >
                  <span />
                </button>
              </div>

              <div className="settings-info">
                These preferences only update this page's state. Actual
                notification delivery must be configured separately.
              </div>
            </section>
          )}

          {activeTab === "security" && (
            <section className="settings-panel">
              <div className="settings-panel-heading">
                <div>
                  <h2>Account Security</h2>
                  <p>Information about protecting your owner account.</p>
                </div>
                <span className="settings-panel-icon">◇</span>
              </div>

              <div className="settings-security-card">
                <span className="settings-security-icon">✓</span>
                <div>
                  <strong>Owner-only access</strong>
                  <p>
                    Keep owner pages protected with authentication and
                    backend authorization.
                  </p>
                </div>
              </div>

              <div className="settings-option settings-option-stacked">
                <div className="settings-option-copy">
                  <strong>Password Management</strong>
                  <p>
                    Password changes require an authenticated backend
                    endpoint. This page does not change your password.
                  </p>
                </div>
              </div>

              <div className="settings-option settings-option-stacked">
                <div className="settings-option-copy">
                  <strong>Session Management</strong>
                  <p>
                    Use the application logout option to end your session.
                    This page does not modify authentication tokens.
                  </p>
                </div>
              </div>

              <div className="settings-info">
                Never share your password, JWT token, or database credentials.
              </div>
            </section>
          )}

          {activeTab === "about" && (
            <section className="settings-panel">
              <div className="settings-panel-heading">
                <div>
                  <h2>About Application</h2>
                  <p>Application details for the owner dashboard.</p>
                </div>
                <span className="settings-panel-icon">ⓘ</span>
              </div>

              <div className="settings-about-brand">
                <div className="settings-brand-logo">N</div>
                <div>
                  <h3>Nivetha Catering Service</h3>
                  <p>Anna Owner Application</p>
                </div>
              </div>

              <div className="settings-about-row">
                <span>Application</span>
                <strong>Anna Owner App</strong>
              </div>

              <div className="settings-about-row">
                <span>Purpose</span>
                <strong>Owner business management</strong>
              </div>

              <div className="settings-about-row">
                <span>Access</span>
                <strong>Restricted owner access</strong>
              </div>

              <div className="settings-about-row">
                <span>Technology</span>
                <strong>React · Vite · Node.js</strong>
              </div>

              <div className="settings-info">
                Update version information when you release a verified build.
              </div>
            </section>
          )}
        </main>
      </div>

      <footer className="settings-footer">
        <span>NIVETHA CATERING SERVICE</span>
        <span>Owner application preferences</span>
      </footer>
    </div>
  );
}