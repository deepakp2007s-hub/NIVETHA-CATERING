
import { useEffect, useState } from "react";
import { Bell, CheckCheck, Trash2 } from "lucide-react";
import notificationService from "../services/notificationService";
import Loading from "../components/Loading";
import "./PageStyles.css";

function getErrorMessage(err, fallback) {
  return (
    err.response?.data?.message ||
    err.response?.data?.error ||
    err.message ||
    fallback
  );
}

function unwrapNotifications(response) {
  return (
    response?.notifications ||
    response?.data?.notifications ||
    response?.data?.data ||
    response?.data ||
    response
  );
}

export default function Notifications() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [busyIds, setBusyIds] = useState([]);
  const [markingAll, setMarkingAll] = useState(false);

  useEffect(() => {
    let active = true;

    async function loadNotifications() {
      try {
        setLoading(true);
        setError("");

        const response = await notificationService.getAll();
        const data = unwrapNotifications(response);

        if (active) {
          setItems(Array.isArray(data) ? data : []);
        }
      } catch (err) {
        if (active) {
          setError(
            getErrorMessage(err, "Unable to load notifications.")
          );
        }
      } finally {
        if (active) setLoading(false);
      }
    }

    loadNotifications();

    return () => {
      active = false;
    };
  }, []);

  function setBusy(id, busy) {
    setBusyIds((current) =>
      busy
        ? [...new Set([...current, id])]
        : current.filter((itemId) => itemId !== id)
    );
  }

  async function markRead(id) {
    if (!id || busyIds.includes(id)) return;

    setError("");
    setBusy(id, true);

    try {
      await notificationService.markAsRead(id);

      setItems((current) =>
        current.map((item) =>
          (item._id || item.id) === id
            ? { ...item, read: true, isRead: true }
            : item
        )
      );
    } catch (err) {
      setError(
        getErrorMessage(err, "Unable to update notification.")
      );
    } finally {
      setBusy(id, false);
    }
  }

  async function markAllRead() {
    if (markingAll) return;

    setError("");
    setMarkingAll(true);

    try {
      await notificationService.markAllAsRead();

      setItems((current) =>
        current.map((item) => ({
          ...item,
          read: true,
          isRead: true,
        }))
      );
    } catch (err) {
      setError(
        getErrorMessage(
          err,
          "Unable to mark all notifications as read."
        )
      );
    } finally {
      setMarkingAll(false);
    }
  }

  async function removeNotification(id) {
    if (!id || busyIds.includes(id)) return;

    setError("");
    setBusy(id, true);

    try {
      await notificationService.delete(id);

      setItems((current) =>
        current.filter((item) => (item._id || item.id) !== id)
      );
    } catch (err) {
      setError(
        getErrorMessage(err, "Unable to delete notification.")
      );
    } finally {
      setBusy(id, false);
    }
  }

  if (loading) return <Loading />;

  const unreadCount = items.filter(
    (item) => !(item.read || item.isRead)
  ).length;

  return (
    <section className="page-container">
      <div className="page-heading page-heading-row">
        <div>
          <span className="page-kicker">STAY UPDATED</span>
          <h1>Notifications</h1>
          <p>Booking updates and important messages.</p>
        </div>

        {unreadCount > 0 && (
          <button
            type="button"
            className="page-btn page-btn-light"
            onClick={markAllRead}
            disabled={markingAll}
          >
            <CheckCheck size={18} />
            {markingAll ? "Updating..." : "Mark all read"}
          </button>
        )}
      </div>

      {error && (
        <p className="page-error" role="alert">
          {error}
        </p>
      )}

      {items.length === 0 ? (
        <div className="page-empty">
          <Bell size={42} />
          <h2>You're all caught up</h2>
          <p>New notifications will appear here.</p>
        </div>
      ) : (
        <div className="notification-list">
          {items.map((item, index) => {
            const id = item._id || item.id;
            const read = Boolean(item.read || item.isRead);
            const busy = id ? busyIds.includes(id) : false;

            return (
              <article
                className={`notification-item ${read ? "" : "unread"}`}
                key={id || `notification-${index}`}
              >
                <div className="notification-icon">
                  <Bell size={21} />
                </div>

                <div className="notification-content">
                  <h3>{item.title || "Nivetha Catering Update"}</h3>

                  <p>
                    {item.message ||
                      item.description ||
                      "You have a new notification."}
                  </p>

                  <small>
                    {item.createdAt
                      ? new Date(item.createdAt).toLocaleString("en-IN")
                      : ""}
                  </small>

                  <div className="notification-actions">
                    {!read && id && (
                      <button
                        type="button"
                        onClick={() => markRead(id)}
                        disabled={busy}
                      >
                        Mark as read
                      </button>
                    )}

                    {id && (
                      <button
                        type="button"
                        onClick={() => removeNotification(id)}
                        disabled={busy}
                        aria-label="Delete notification"
                      >
                        <Trash2 size={15} />
                        {busy ? "Please wait..." : "Delete"}
                      </button>
                    )}
                  </div>
                </div>

                {!read && <span className="notification-dot" />}
              </article>
            );
          })}
        </div>
      )}
    </section>
  );
}
