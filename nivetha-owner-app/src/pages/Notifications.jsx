import { useState } from "react";
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
} from "lucide-react";
import "./Notifications.css";

const initialNotifications = [
  {
    id: 1,
    type: "booking",
    title: "New Booking Received",
    message: "A new catering booking requires your attention.",
    time: "New",
    read: false,
  },
  {
    id: 2,
    type: "review",
    title: "Customer Review",
    message: "A customer has submitted a review for your service.",
    time: "Recent",
    read: false,
  },
  {
    id: 3,
    type: "booking",
    title: "Booking Update",
    message: "Check your booking list for recent updates.",
    time: "Recent",
    read: true,
  },
  {
    id: 4,
    type: "system",
    title: "Welcome to Nivetha Owner App",
    message: "Manage your catering business from your owner dashboard.",
    time: "Earlier",
    read: true,
  },
];

const iconMap = {
  booking: CalendarCheck,
  review: Star,
  system: Info,
};

export default function Notifications() {
  const [notifications, setNotifications] = useState(initialNotifications);
  const [filter, setFilter] = useState("all");
  const [notice, setNotice] = useState("");

  const unreadCount = notifications.filter(
    (notification) => !notification.read
  ).length;

  const filteredNotifications = notifications.filter((notification) => {
    if (filter === "unread") return !notification.read;
    if (filter === "read") return notification.read;
    return true;
  });

  const markAsRead = (id) => {
    setNotifications((current) =>
      current.map((notification) =>
        notification.id === id
          ? { ...notification, read: true }
          : notification
      )
    );
    setNotice("Notification marked as read.");
  };

  const markAllAsRead = () => {
    setNotifications((current) =>
      current.map((notification) => ({
        ...notification,
        read: true,
      }))
    );
    setNotice("All notifications marked as read.");
  };

  const deleteNotification = (id) => {
    setNotifications((current) =>
      current.filter((notification) => notification.id !== id)
    );
    setNotice("Notification removed.");
  };

  const clearAll = () => {
    setNotifications([]);
    setNotice("All notifications cleared.");
  };

  return (
    <div className="notifications-page">
      <header className="notifications-header">
        <div>
          <span className="notifications-eyebrow">
            OWNER CONTROL CENTER
          </span>
          <h1>Notifications</h1>
          <p>Keep track of booking updates and customer activity.</p>
        </div>

        <div className="notifications-header-icon">
          <Bell size={27} />
          {unreadCount > 0 && (
            <span className="notifications-count">{unreadCount}</span>
          )}
        </div>
      </header>

      {notice && (
        <div className="notifications-notice" role="status">
          <span>{notice}</span>
          <button
            type="button"
            aria-label="Dismiss notice"
            onClick={() => setNotice("")}
          >
            ×
          </button>
        </div>
      )}

      <section className="notifications-summary">
        <div className="notifications-summary-icon">
          <Inbox size={23} />
        </div>
        <div>
          <span className="notifications-summary-label">
            Unread notifications
          </span>
          <strong>{unreadCount}</strong>
        </div>
        <span className="notifications-summary-total">
          {notifications.length} total
        </span>
      </section>

      <section className="notifications-card">
        <div className="notifications-toolbar">
          <div className="notifications-toolbar-title">
            <h2>All Notifications</h2>
            <span>{filteredNotifications.length}</span>
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
              onClick={clearAll}
              disabled={notifications.length === 0}
            >
              <Trash2 size={16} />
              <span>Clear all</span>
            </button>
          </div>
        </div>

        <div className="notifications-filters">
          <Filter size={16} />
          {[
            { id: "all", label: "All" },
            { id: "unread", label: "Unread" },
            { id: "read", label: "Read" },
          ].map((item) => (
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
            </button>
          ))}
        </div>

        <div className="notifications-list">
          {filteredNotifications.length > 0 ? (
            filteredNotifications.map((notification) => {
              const Icon = iconMap[notification.type] || Info;

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
                        <span className="notification-unread-dot" />
                      )}
                    </div>

                    <p>{notification.message}</p>

                    <span className="notification-time">
                      <Clock size={13} />
                      {notification.time}
                    </span>
                  </div>

                  <div className="notification-item-actions">
                    {!notification.read && (
                      <button
                        type="button"
                        className="notification-read-button"
                        onClick={() => markAsRead(notification.id)}
                      >
                        Mark read
                      </button>
                    )}

                    <button
                      type="button"
                      className="notification-delete-button"
                      aria-label={`Delete ${notification.title}`}
                      onClick={() =>
                        deleteNotification(notification.id)
                      }
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
              <h3>No notifications found</h3>
              <p>
                {filter === "unread"
                  ? "You are all caught up."
                  : "Notifications matching this filter will appear here."}
              </p>
              {filter !== "all" && (
                <button
                  type="button"
                  className="notifications-empty-button"
                  onClick={() => setFilter("all")}
                >
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
    </div>
  );
}