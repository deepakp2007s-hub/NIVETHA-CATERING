import { useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import bookingService from "../services/bookingService";
import Loading from "../components/Loading";
import "./PageStyles.css";

export default function EditBooking() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [form, setForm] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    let active = true;

    bookingService.getById(id)
      .then((response) => {
        const data = response.data?.booking || response.data;
        if (active) {
          setForm({
            functionDate: String(data.functionDate || data.eventDate || "").slice(0, 10),
            functionTime: data.functionTime || "",
            location: data.location || "",
            numberOfPersons: data.numberOfPersons || data.guestCount || 1,
            extraRequirements: data.extraRequirements || "",
          });
        }
      })
      .catch((err) => {
        if (active) setError(err.message || "Unable to load booking.");
      })
      .finally(() => {
        if (active) setLoading(false);
      });

    return () => { active = false; };
  }, [id]);

  function change(event) {
    setForm({ ...form, [event.target.name]: event.target.value });
  }

  async function submit(event) {
    event.preventDefault();
    setError("");

    try {
      setSaving(true);
      await bookingService.update(id, {
        ...form,
        numberOfPersons: Number(form.numberOfPersons),
      });
      navigate(`/my-bookings/${id}`);
    } catch (err) {
      setError(err.message || "Unable to update booking.");
    } finally {
      setSaving(false);
    }
  }

  if (loading) return <Loading />;

  if (!form) {
    return (
      <section className="page-container page-narrow">
        <p className="page-error">{error || "Booking not found."}</p>
        <Link to="/my-bookings" className="page-btn">Back to bookings</Link>
      </section>
    );
  }

  return (
    <section className="page-container page-narrow">
      <div className="page-heading">
        <span className="page-kicker">UPDATE EVENT</span>
        <h1>Edit Booking</h1>
        <p>Update your event details and save your changes.</p>
      </div>

      <form className="page-form" onSubmit={submit}>
        <label>Function date</label>
        <input type="date" name="functionDate" min={new Date().toISOString().split("T")[0]} value={form.functionDate} onChange={change} required />

        <label>Function time</label>
        <input type="time" name="functionTime" value={form.functionTime} onChange={change} required />

        <label>Location</label>
        <input name="location" value={form.location} onChange={change} required />

        <label>Number of guests</label>
        <input type="number" min="1" name="numberOfPersons" value={form.numberOfPersons} onChange={change} required />

        <label>Extra requirements</label>
        <textarea rows="4" name="extraRequirements" value={form.extraRequirements} onChange={change} />

        {error && <p className="page-error">{error}</p>}

        <div className="page-actions">
          <Link to={`/my-bookings/${id}`} className="page-btn page-btn-light">Cancel</Link>
          <button type="submit" className="page-btn" disabled={saving}>
            {saving ? "Saving..." : "Save Changes"}
          </button>
        </div>
      </form>
    </section>
  );
}
