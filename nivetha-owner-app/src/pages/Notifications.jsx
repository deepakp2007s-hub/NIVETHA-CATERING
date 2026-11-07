import { useEffect, useMemo, useState } from "react";
import {
  Bell,
  CalendarCheck,
  Star,
  Info,
  CheckCheck,
  Trash2,
  Filter,
  Clock,
  Inbox,
  Search,
  X,
  RefreshCw,
  Check,
  BellRing,
} from "lucide-react";
import "./Notifications.css";

const STORAGE_KEY = "nivetha-owner-notifications";

const INITIAL_NOTIFICATIONS = [
  {
    id: "welcome-notification",
    type: "system",
    title: "Welcome to Nivetha Owner App",
    message: "Manage your catering business from your owner dashboard.",
    createdAt: new Date().toISOString(),
    read: true,
  },
];

const FILTERS = [
  { id: "all", label: "All" },
  { id: "unread", label: "Unread" },
  { id: "read", label: "Read" },
];

const ICON_MAP = {
  booking: CalendarCheck,
  review: Star,
  system: Info,
};

const getInitialNotifications = () => {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);

    if (!saved) return INITIAL_NOTIFICATIONS;

    const parsed = JSON.parse(saved);

    if (!Array.isArray(parsed)) return INITIAL_NOTIFICATIONS;

    return parsed.filter(
      (item) =>
        item &&
        item.id !== undefined &&
        typeof item.title === "string" &&
        typeof item.message === "string"
    );
  } catch {
    return INITIAL_NOTIFICATIONS;
  }
};

const formatNotificationTime = (value) => {
  if (!value) return "Time unavailable";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return String(value);
  }

  const now = new Date();
  const diff = Math.max(0, now.getTime() - date.getTime());
  const minutes = Math.floor(diff / 60000);

  if (minutes < 1) return "Just now";
  if (minutes < 60) return `${minutes} min ago`;

  const hours = Math.floor(minutes / 60);

  if (hours < 24) return `${hours} hr${hours === 1 ? "" : "s"} ago`;

  const days = Math.floor(hours / 24);

  if (days < 7) return `${days} day${days === 1 ? "" : "s"} ago`;

  return date.toLocaleDateString("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
};

export default function Notifications() {
  const [notifications, setNotifications] = useState(getInitialNotifications);
  const [filter, setFilter] = useState("all");
  const [search, setSearch] = useState("");
  const [notice, setNotice] = useState("");
  const [confirmClear, setConfirmClear] = useState(false);

  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(notifications));
    } catch (error) {
      console.error("Unable to save notifications:", error);
      setNotice("Unable to save notification changes in this browser.");
    }
  }, [notifications]);

  useEffect(() => {
    if (!notice) return undefined;

    const timeout = window.setTimeout(() => {
      setNotice("");
    }, 3000);

    return () => window.clearTimeout(timeout);
  }, [notice]);

  const unreadCount = useMemo(
    () => notifications.filter((item) => !item.read).length,
    [notifications]
  );

  const readCount = notifications.length - unreadCount;

  const filteredNotifications = useMemo(() => {
    const query = search.trim().toLowerCase();

    return [...notifications]
      .filter((item) => {
        if (filter === "unread" && item.read) return false;
        if (filter === "read" && !item.read) return false;

        if (!query) return true;

        return [item.title, item.message, item.type]
          .filter(Boolean)
          .some((value) => String(value).toLowerCase().includes(query));
      })
      .sort((a, b) => {
        const dateA = new Date(a.createdAt || 0).getTime();
        const dateB = new Date(b.createdAt || 0).getTime();

        return dateB - dateA;
      });
  }, [notifications, filter, search]);

  const updateNotification = (id, changes) => {
    setNotifications((current) =>
      current.map((item) =>
        String(item.id) === String(id) ? { ...item, ...changes } : item
      )
    );
  };

  const markAsRead = (id) => {
    updateNotification(id, { read: true });
    setNotice("Notification marked as read.");
  };

  const markAllAsRead = () => {
    if (unreadCount === 0) return;

    setNotifications((current) =>
      current.map((item) => ({ ...item, read: true }))
    );

    setNotice("All notifications marked as read.");
  };

  const deleteNotification = (id) => {
    setNotifications((current) =>
      current.filter((item) => String(item.id) !== String(id))
    );

    setNotice("Notification removed.");
  };

  const clearAll = () => {
    setNotifications([]);
    setConfirmClear(false);
    setNotice("All notifications cleared.");
  };

  const clearSearch = () => setSearch("");

  const getNotificationIcon = (type) => ICON_MAP[type] || Info;

  return (
    <main className="notifications-page">
      <header className="notifications-header">
        <div className="notifications-heading-content">
          <span className="notifications-eyebrow">
            <span className="notifications-live-dot" />
            OWNER CONTROL CENTER
          </span>

          <h1>Notifications</h1>

          <p>
            Stay updated with bookings, customer reviews and business activity.
          </p>
        </div>

        <div className="notifications-header-icon">
          <BellRing size={27} strokeWidth={1.8} />
          {unreadCount > 0 && (
            <span className="notifications-count">{unreadCount}</span>
          )}
        </div>
      </header>

      {notice && (
        <div className="notifications-notice" role="status">
          <Check size={17} />
          <span>{notice}</span>
          <button
            type="button"
            aria-label="Dismiss notice"
            onClick={() => setNotice("")}
          >
            <X size={16} />
          </button>
        </div>
      )}

      <section className="notifications-summary-grid">
        <article className="notifications-summary-card notifications-summary-primary">
          <div className="notifications-summary-icon">
            <Inbox size={22} />
          </div>
          <div className="notifications-summary-info">
            <span>Total notifications</span>
            <strong>{notifications.length}</strong>
            <small>All received notifications</small>
          </div>
        </article>

        <article className="notifications-summary-card">
          <div className="notifications-summary-icon unread-summary-icon">
            <Bell size={22} />
          </div>
          <div className="notifications-summary-info">
            <span>Unread notifications</span>
            <strong>{unreadCount}</strong>
            <small>Need your attention</small>
          </div>
        </article>

        <article className="notifications-summary-card">
          <div className="notifications-summary-icon read-summary-icon">
            <CheckCheck size={22} />
          </div>
          <div className="notifications-summary-info">
            <span>Read notifications</span>
            <strong>{readCount}</strong>
            <small>Already viewed</small>
          </div>
        </article>
      </section>

      <section className="notifications-card">
        <div className="notifications-toolbar">
          <div className="notifications-toolbar-title">
            <div>
              <span className="notifications-section-label">
                ACTIVITY CENTER
              </span>
              <h2>All Notifications</h2>
              <p>Manage your latest updates in one place.</p>
            </div>

            <span className="notifications-result-count">
              {filteredNotifications.length}
            </span>
          </div>

          <div className="notifications-actions">
            <button
              type="button"
              className="notifications-action-button"
              onClick={markAllAsRead}
              disabled={unreadCount === 0}
            >
              <CheckCheck size={16} />
              <span>Mark all read</span>
            </button>

            <button
              type="button"
              className="notifications-action-button notifications-clear-button"
              onClick={() => setConfirmClear(true)}
              disabled={notifications.length === 0}
            >
              <Trash2 size={16} />
              <span>Clear all</span>
            </button>
          </div>
        </div>

        <div className="notifications-controls">
          <div className="notifications-filters" aria-label="Notification filters">
            <Filter size={16} />

            {FILTERS.map((item) => (
              <button
                type="button"
                key={item.id}
                className={`notifications-filter ${
                  filter === item.id ? "active" : ""
                }`}
                onClick={() => setFilter(item.id)}
                aria-pressed={filter === item.id}
              >
                {item.label}

                {item.id === "unread" && unreadCount > 0 && (
                  <span className="notifications-filter-count">
                    {unreadCount}
                  </span>
                )}
              </button>
            ))}
          </div>

          <label className="notifications-search">
            <Search size={17} />
            <input
              type="search"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Search notifications..."
              aria-label="Search notifications"
            />

            {search && (
              <button
                type="button"
                onClick={clearSearch}
                aria-label="Clear search"
              >
                <X size={15} />
              </button>
            )}
          </label>
        </div>

        <div className="notifications-list">
          {filteredNotifications.length > 0 ? (
            filteredNotifications.map((notification) => {
              const Icon = getNotificationIcon(notification.type);

              return (
                <article
                  key={notification.id}
                  className={`notification-item ${
                    notification.read ? "is-read" : "is-unread"
                  }`}
                >
                  <div
                    className={`notification-item-icon notification-icon-${notification.type}`}
                  >
                    <Icon size={21} />
                  </div>

                  <div className="notification-item-content">
                    <div className="notification-item-heading">
                      <h3>{notification.title}</h3>

                      {!notification.read && (
                        <span className="notification-unread-label">
                          NEW
                        </span>
                      )}
                    </div>

                    <p>{notification.message}</p>

                    <span className="notification-time">
                      <Clock size={13} />
                      {formatNotificationTime(notification.createdAt)}
                    </span>
                  </div>

                  <div className="notification-item-actions">
                    {!notification.read && (
                      <button
                        type="button"
                        className="notification-read-button"
                        onClick={() => markAsRead(notification.id)}
                        title="Mark as read"
                      >
                        <Check size={15} />
                        <span>Mark read</span>
                      </button>
                    )}

                    <button
                      type="button"
                      className="notification-delete-button"
                      aria-label={`Delete ${notification.title}`}
                      title="Delete notification"
                      onClick={() => deleteNotification(notification.id)}
                    >
                      <Trash2 size={17} />
                    </button>
                  </div>
                </article>
              );
            })
          ) : (
            <div className="notifications-empty">
              <div className="notifications-empty-icon">
                <Inbox size={30} />
              </div>

              <h3>
                {search ? "No matching notifications" : "You're all caught up"}
              </h3>

              <p>
                {search
                  ? "Try another search term."
                  : filter === "unread"
                    ? "You don't have any unread notifications."
                    : filter === "read"
                      ? "There are no read notifications."
                      : "New notifications will appear here when available."}
              </p>

              {(filter !== "all" || search) && (
                <button
                  type="button"
                  className="notifications-empty-button"
                  onClick={() => {
                    setFilter("all");
                    setSearch("");
                  }}
                >
                  <RefreshCw size={14} />
                  View all notifications
                </button>
              )}
            </div>
          )}
        </div>
      </section>

      <footer className="notifications-footer">
        <span>NIVETHA CATERING SERVICE</span>
        <span>Owner notification center</span>
      </footer>

      {confirmClear && (
        <div
          className="notifications-modal-backdrop"
          role="presentation"
          onMouseDown={(event) => {
            if (event.target === event.currentTarget) {
              setConfirmClear(false);
            }
          }}
        >
          <section
            className="notifications-confirm-modal"
            role="dialog"
            aria-modal="true"
            aria-labelledby="notifications-confirm-title"
          >
            <div className="notifications-confirm-icon">
              <Trash2 size={23} />
            </div>

            <h2 id="notifications-confirm-title">Clear all notifications?</h2>

            <p>
              This will remove all {notifications.length} notifications stored
              in this browser. This action cannot be undone.
            </p>

            <div className="notifications-confirm-actions">
              <button
                type="button"
                className="notifications-cancel-button"
                onClick={() => setConfirmClear(false)}
              >
                Cancel
              </button>

              <button
                type="button"
                className="notifications-confirm-delete"
                onClick={clearAll}
              >
                <Trash2 size={15} />
                Clear all
              </button>
            </div>
          </section>
        </div>
      )}
    </main>
  );
}