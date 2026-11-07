
import { useCallback, useEffect, useState } from "react";
import {
  Settings as SettingsIcon,
  Bell,
  ShieldCheck,
  Info,
  Globe,
  Sun,
  Moon,
  RotateCcw,
  CheckCircle2,
  X,
  Sparkles,
  LockKeyhole,
  Monitor,
} from "lucide-react";
import "./Settings.css";

const STORAGE_KEY = "nivetha-owner-settings";

const initialPreferences = {
  language: "English",
  theme: "light",
  compactView: false,
  bookingNotifications: true,
  reviewNotifications: true,
};

const translations = {
  English: {
    eyebrow: "OWNER CONTROL CENTER",
    title: "Settings",
    subtitle: "Manage your application preferences and account information.",
    preferences: "PREFERENCES",
    general: "General",
    notifications: "Notifications",
    security: "Security",
    about: "About",
    brandDescription: "Owner settings and application preferences.",
    generalTitle: "General Preferences",
    generalSubtitle: "Customize your application experience.",
    language: "Display Language",
    languageDescription: "Choose your preferred language.",
    appearance: "Appearance",
    appearanceDescription: "Select your preferred appearance.",
    light: "Light",
    dark: "Dark",
    compact: "Compact View",
    compactDescription: "Use a more compact page layout.",
    reset: "Reset Preferences",
    notificationTitle: "Notification Preferences",
    notificationSubtitle: "Manage your notification preferences.",
    booking: "Booking Notifications",
    bookingDescription: "Alerts for new and updated bookings.",
    reviews: "Review Notifications",
    reviewsDescription: "Alerts when customers submit reviews.",
    localNotice: "These settings control your local preferences only. Actual notification delivery must be configured separately.",
    securityTitle: "Account Security",
    securitySubtitle: "Protect your owner account.",
    ownerAccess: "Owner-only access",
    ownerDescription: "Owner pages should remain protected by authentication and backend authorization.",
    password: "Password Management",
    passwordDescription: "Password changes require an authenticated backend endpoint.",
    session: "Session Management",
    sessionDescription: "Use the application logout option to securely end your session.",
    securityNotice: "Never share your password, JWT token, or database credentials.",
    aboutTitle: "About Application",
    aboutSubtitle: "Application information.",
    appName: "Nivetha Catering Service",
    appSubtitle: "Owner Management Application",
    application: "Application",
    purpose: "Purpose",
    purposeValue: "Owner business management",
    access: "Access",
    accessValue: "Restricted owner access",
    technology: "Technology",
    technologyValue: "React · Vite · FastAPI · MongoDB",
    footer: "Owner application preferences",
    saved: "Settings saved successfully.",
    resetSuccess: "Preferences restored to defaults.",
    languageChanged: "Language preference saved.",
    themeChanged: "Appearance preference saved.",
    notificationChanged: "Notification preference saved.",
    resetConfirm: "Reset all settings to their default values?",
  },
  Tamil: {
    eyebrow: "நிர்வாகக் கட்டுப்பாட்டு மையம்",
    title: "அமைப்புகள்",
    subtitle: "உங்கள் பயன்பாட்டு அமைப்புகள் மற்றும் கணக்கை நிர்வகிக்கவும்.",
    preferences: "விருப்பங்கள்",
    general: "பொது",
    notifications: "அறிவிப்புகள்",
    security: "பாதுகாப்பு",
    about: "பற்றி",
    brandDescription: "நிர்வாக அமைப்புகள் மற்றும் பயன்பாட்டு விருப்பங்கள்.",
    generalTitle: "பொது அமைப்புகள்",
    generalSubtitle: "உங்கள் பயன்பாட்டு அனுபவத்தை மாற்றவும்.",
    language: "மொழி",
    languageDescription: "உங்களுக்கு விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்.",
    appearance: "தோற்றம்",
    appearanceDescription: "உங்களுக்கு விருப்பமான தோற்றத்தைத் தேர்ந்தெடுக்கவும்.",
    light: "வெளிச்சம்",
    dark: "இருள்",
    compact: "சுருக்கமான காட்சி",
    compactDescription: "குறைந்த இடத்தில் உள்ளடக்கத்தைக் காட்டவும்.",
    reset: "அமைப்புகளை மீட்டமை",
    notificationTitle: "அறிவிப்பு அமைப்புகள்",
    notificationSubtitle: "அறிவிப்பு விருப்பங்களை நிர்வகிக்கவும்.",
    booking: "முன்பதிவு அறிவிப்புகள்",
    bookingDescription: "புதிய மற்றும் மாற்றப்பட்ட முன்பதிவுகளுக்கான அறிவிப்புகள்.",
    reviews: "மதிப்பாய்வு அறிவிப்புகள்",
    reviewsDescription: "வாடிக்கையாளர் மதிப்பாய்வுகளுக்கான அறிவிப்புகள்.",
    localNotice: "இந்த அமைப்புகள் உங்கள் உள்ளூர் விருப்பங்களை மட்டுமே சேமிக்கின்றன. உண்மையான அறிவிப்பு அனுப்புதல் தனியாக அமைக்கப்பட வேண்டும்.",
    securityTitle: "கணக்கு பாதுகாப்பு",
    securitySubtitle: "உங்கள் நிர்வாகக் கணக்கைப் பாதுகாக்கவும்.",
    ownerAccess: "நிர்வாகி அணுகல் மட்டும்",
    ownerDescription: "நிர்வாகப் பக்கங்கள் அங்கீகாரம் மற்றும் backend பாதுகாப்புடன் இருக்க வேண்டும்.",
    password: "கடவுச்சொல் மேலாண்மை",
    passwordDescription: "கடவுச்சொல்லை மாற்ற அங்கீகரிக்கப்பட்ட backend API தேவை.",
    session: "Session மேலாண்மை",
    sessionDescription: "வெளியேறு வசதியைப் பயன்படுத்தி பாதுகாப்பாக வெளியேறவும்.",
    securityNotice: "உங்கள் கடவுச்சொல், JWT token அல்லது database credentials-ஐ யாரிடமும் பகிர வேண்டாம்.",
    aboutTitle: "பயன்பாட்டைப் பற்றி",
    aboutSubtitle: "பயன்பாட்டு விவரங்கள்.",
    appName: "நிவேதா கேட்டரிங் சர்வீஸ்",
    appSubtitle: "நிர்வாக மேலாண்மை பயன்பாடு",
    application: "பயன்பாடு",
    purpose: "நோக்கம்",
    purposeValue: "வணிக நிர்வாகம்",
    access: "அணுகல்",
    accessValue: "கட்டுப்படுத்தப்பட்ட நிர்வாக அணுகல்",
    technology: "தொழில்நுட்பம்",
    technologyValue: "React · Vite · FastAPI · MongoDB",
    footer: "நிர்வாக பயன்பாட்டு அமைப்புகள்",
    saved: "அமைப்புகள் வெற்றிகரமாக சேமிக்கப்பட்டன.",
    resetSuccess: "இயல்புநிலை அமைப்புகள் மீட்டமைக்கப்பட்டன.",
    languageChanged: "மொழி அமைப்பு சேமிக்கப்பட்டது.",
    themeChanged: "தோற்ற அமைப்பு சேமிக்கப்பட்டது.",
    notificationChanged: "அறிவிப்பு அமைப்பு சேமிக்கப்பட்டது.",
    resetConfirm: "அனைத்து அமைப்புகளையும் இயல்புநிலைக்கு மாற்ற வேண்டுமா?",
  },
};

const tabs = [
  { id: "general", icon: SettingsIcon },
  { id: "notifications", icon: Bell },
  { id: "security", icon: ShieldCheck },
  { id: "about", icon: Info },
];

const readPreferences = () => {
  try {
    const stored = localStorage.getItem(STORAGE_KEY);

    if (!stored) return { ...initialPreferences };

    const parsed = JSON.parse(stored);

    return {
      ...initialPreferences,
      ...parsed,
      language: ["English", "Tamil"].includes(parsed.language)
        ? parsed.language
        : initialPreferences.language,
      theme: ["light", "dark"].includes(parsed.theme)
        ? parsed.theme
        : initialPreferences.theme,
    };
  } catch {
    return { ...initialPreferences };
  }
};

export default function Settings() {
  const [activeTab, setActiveTab] = useState("general");
  const [preferences, setPreferences] = useState(readPreferences);
  const [notice, setNotice] = useState("");
  const [noticeType, setNoticeType] = useState("success");

  const t = translations[preferences.language];

  useEffect(() => {
    document.documentElement.dataset.theme = preferences.theme;
    document.documentElement.dataset.compact = String(
      preferences.compactView
    );

    document.body.dataset.theme = preferences.theme;

    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(preferences));
    } catch (error) {
      console.error("Unable to save settings:", error);
    }

    return () => {
      delete document.documentElement.dataset.compact;
    };
  }, [preferences]);

  const showNotice = useCallback((message, type = "success") => {
    setNotice(message);
    setNoticeType(type);
  }, []);

  const updatePreference = (key, value) => {
    setPreferences((current) => ({
      ...current,
      [key]: value,
    }));

    const message =
      key === "language"
        ? translations[value].languageChanged
        : key === "theme"
          ? translations[preferences.language].themeChanged
          : key === "bookingNotifications" ||
              key === "reviewNotifications"
            ? translations[preferences.language].notificationChanged
            : translations[preferences.language].saved;

    showNotice(message);
  };

  const resetPreferences = () => {
    if (!window.confirm(t.resetConfirm)) return;

    setPreferences({ ...initialPreferences });
    setActiveTab("general");
    showNotice(translations.English.resetSuccess);
  };

  const renderSwitch = (key, label) => (
    <button
      type="button"
      role="switch"
      aria-label={label}
      aria-checked={preferences[key]}
      className={`settings-switch ${preferences[key] ? "on" : ""}`}
      onClick={() => updatePreference(key, !preferences[key])}
    >
      <span />
    </button>
  );

  return (
    <div
      className={`settings-page ${preferences.theme === "dark" ? "settings-dark" : ""} ${preferences.compactView ? "settings-compact" : ""}`}
    >
      <header className="settings-header">
        <div>
          <span className="settings-eyebrow">
            <Sparkles size={13} />
            {t.eyebrow}
          </span>
          <h1>{t.title}</h1>
          <p>{t.subtitle}</p>
        </div>

        <div className="settings-header-mark">
          <SettingsIcon size={32} />
        </div>
      </header>

      {notice && (
        <div
          className={`settings-notice ${noticeType}`}
          role="status"
          aria-live="polite"
        >
          <CheckCircle2 size={19} />
          <p>{notice}</p>
          <button
            type="button"
            aria-label="Dismiss notice"
            onClick={() => setNotice("")}
          >
            <X size={17} />
          </button>
        </div>
      )}

      <div className="settings-layout">
        <aside className="settings-sidebar">
          <div className="settings-sidebar-heading">
            {t.preferences}
          </div>

          <nav className="settings-tabs" aria-label="Settings sections">
            {tabs.map(({ id, icon: Icon }) => (
              <button
                type="button"
                key={id}
                className={`settings-tab ${activeTab === id ? "active" : ""}`}
                aria-current={activeTab === id ? "page" : undefined}
                onClick={() => {
                  setActiveTab(id);
                  setNotice("");
                }}
              >
                <span className="settings-tab-icon">
                  <Icon size={19} />
                </span>
                <span>{t[id]}</span>
                {activeTab === id && (
                  <span className="settings-tab-arrow">›</span>
                )}
              </button>
            ))}
          </nav>

          <div className="settings-sidebar-note">
            <span className="settings-note-icon">
              <Sparkles size={18} />
            </span>
            <strong>Nivetha Catering</strong>
            <p>{t.brandDescription}</p>
          </div>
        </aside>

        <main className="settings-content">
          {activeTab === "general" && (
            <section className="settings-panel">
              <div className="settings-panel-heading">
                <div>
                  <h2>{t.generalTitle}</h2>
                  <p>{t.generalSubtitle}</p>
                </div>
                <span className="settings-panel-icon">
                  <SettingsIcon size={23} />
                </span>
              </div>

              <div className="settings-option">
                <div className="settings-option-copy">
                  <strong>
                    <Globe size={17} /> {t.language}
                  </strong>
                  <p>{t.languageDescription}</p>
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
                  <strong>
                    {preferences.theme === "dark" ? (
                      <Moon size={17} />
                    ) : (
                      <Sun size={17} />
                    )}
                    {t.appearance}
                  </strong>
                  <p>{t.appearanceDescription}</p>
                </div>

                <select
                  className="settings-select"
                  value={preferences.theme}
                  onChange={(event) =>
                    updatePreference("theme", event.target.value)
                  }
                >
                  <option value="light">{t.light}</option>
                  <option value="dark">{t.dark}</option>
                </select>
              </div>

              <div className="settings-option">
                <div className="settings-option-copy">
                  <strong>
                    <Monitor size={17} /> {t.compact}
                  </strong>
                  <p>{t.compactDescription}</p>
                </div>

                {renderSwitch("compactView", t.compact)}
              </div>

              <div className="settings-panel-footer">
                <button
                  type="button"
                  className="settings-button settings-button-secondary"
                  onClick={resetPreferences}
                >
                  <RotateCcw size={16} />
                  {t.reset}
                </button>
              </div>
            </section>
          )}

          {activeTab === "notifications" && (
            <section className="settings-panel">
              <div className="settings-panel-heading">
                <div>
                  <h2>{t.notificationTitle}</h2>
                  <p>{t.notificationSubtitle}</p>
                </div>
                <span className="settings-panel-icon">
                  <Bell size={23} />
                </span>
              </div>

              <div className="settings-option">
                <div className="settings-option-copy">
                  <strong>{t.booking}</strong>
                  <p>{t.bookingDescription}</p>
                </div>

                {renderSwitch("bookingNotifications", t.booking)}
              </div>

              <div className="settings-option">
                <div className="settings-option-copy">
                  <strong>{t.reviews}</strong>
                  <p>{t.reviewsDescription}</p>
                </div>

                {renderSwitch("reviewNotifications", t.reviews)}
              </div>

              <div className="settings-info">
                <Bell size={17} />
                <p>{t.localNotice}</p>
              </div>
            </section>
          )}

          {activeTab === "security" && (
            <section className="settings-panel">
              <div className="settings-panel-heading">
                <div>
                  <h2>{t.securityTitle}</h2>
                  <p>{t.securitySubtitle}</p>
                </div>
                <span className="settings-panel-icon">
                  <ShieldCheck size={23} />
                </span>
              </div>

              <div className="settings-security-card">
                <span className="settings-security-icon">
                  <LockKeyhole size={23} />
                </span>
                <div>
                  <strong>{t.ownerAccess}</strong>
                  <p>{t.ownerDescription}</p>
                </div>
              </div>

              <div className="settings-option settings-option-stacked">
                <div className="settings-option-copy">
                  <strong>{t.password}</strong>
                  <p>{t.passwordDescription}</p>
                </div>
              </div>

              <div className="settings-option settings-option-stacked">
                <div className="settings-option-copy">
                  <strong>{t.session}</strong>
                  <p>{t.sessionDescription}</p>
                </div>
              </div>

              <div className="settings-info">
                <ShieldCheck size={17} />
                <p>{t.securityNotice}</p>
              </div>
            </section>
          )}

          {activeTab === "about" && (
            <section className="settings-panel">
              <div className="settings-panel-heading">
                <div>
                  <h2>{t.aboutTitle}</h2>
                  <p>{t.aboutSubtitle}</p>
                </div>
                <span className="settings-panel-icon">
                  <Info size={23} />
                </span>
              </div>

              <div className="settings-about-brand">
                <div className="settings-brand-logo">N</div>
                <div>
                  <h3>{t.appName}</h3>
                  <p>{t.appSubtitle}</p>
                </div>
              </div>

              {[
                [t.application, "Nivetha Owner App"],
                [t.purpose, t.purposeValue],
                [t.access, t.accessValue],
                [t.technology, t.technologyValue],
              ].map(([label, value]) => (
                <div className="settings-about-row" key={label}>
                  <span>{label}</span>
                  <strong>{value}</strong>
                </div>
              ))}
            </section>
          )}
        </main>
      </div>

      <footer className="settings-footer">
        <span>NIVETHA CATERING SERVICE</span>
        <span>{t.footer}</span>
      </footer>
    </div>
  );
}
