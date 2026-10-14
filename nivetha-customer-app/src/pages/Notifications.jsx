import { useEffect, useState } from "react";
import { Bell, CheckCheck, Trash2 } from "lucide-react";
import notificationService from "../services/notificationService";
import Loading from "../components/Loading";
import "./PageStyles.css";

export default function Notifications() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let active = true;

    notificationService.getAll()
      .then((response) => {
        const data = response.data?.notifications || response.data || [];
        if (active) setItems(Array.isArray(data) ? data : []);
      })
      .catch((err) => {
        if (active) setError(err.message || "Unable to load notifications.");
      })
      .finally(() => {
        if (active) setLoading(false);
      });

    return () => { active = false; };
  }, []);

  async function markRead(id) {
    try {
      await notificationService.markAsRead(id);
      setItems((current) => current.map((item) =>
        (item._id || item.id) === id ? { ...item, read: true, isRead: true } : item
      ));
    } catch (err) {
      setError(err.message || "Unable to update notification.");
    }
  }

  async function markAllRead() {
    try {
      await notificationService.markAllAsRead();
      setItems((current) => current.map((item) => ({ ...item, read: true, isRead: true })));
    } catch (err) {
      setError(err.message || "Unable to mark all notifications as read.");
    }
  }

  async function removeNotification(id) {
    try {
      await notificationService.delete(id);
      setItems((current) => current.filter((item) => (item._id || item.id) !== id));
    } catch (err) {
      setError(err.message || "Unable to delete notification.");
    }
  }

  if (loading) return <Loading />;

  return (
    <section className="page-container">
      <div className="page-heading page-heading-row">
        <div>
          <span className="page-kicker">STAY UPDATED</span>
          <h1>Notifications</h1>
          <p>Booking updates and important messages.</p>
        </div>
        {items.length > 0 && (
          <button className="page-btn page-btn-light" onClick={markAllRead}>
            <CheckCheck size={18} /> Mark all read
          </button>
        )}
      </div>

      {error && <p className="page-error">{error}</p>}

      {!items.length ? (
        <div className="page-empty">
          <Bell size={42} />
          <h2>You're all caught up</h2>
          <p>New notifications will appear here.</p>
        </div>
      ) : (
        <div className="notification-list">
          {items.map((item) => {
            const id = item._id || item.id;
            const read = Boolean(item.read || item.isRead);

            return (
              <article className={`notification-item ${read ? "" : "unread"}`} key={id}>
                <div className="notification-icon"><Bell size={21} /></div>
                <div className="notification-content">
                  <h3>{item.title || "Nivetha Catering Update"}</h3>
                  <p>{item.message || item.description || "You have a new notification."}</p>
                  <small>{item.createdAt ? new Date(item.createdAt).toLocaleString() : ""}</small>
                  <div className="notification-actions">
                    {!read && <button onClick={() => markRead(id)}>Mark as read</button>}
                    <button onClick={() => removeNotification(id)} aria-label="Delete notification"><Trash2 size={15} /> Delete</button>
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