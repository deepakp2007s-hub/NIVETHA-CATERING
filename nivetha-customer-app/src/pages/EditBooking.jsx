
import { useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import bookingService from "../services/bookingService";
import Loading from "../components/Loading";
import "./PageStyles.css";

function unwrapBooking(response) {
  return (
    response?.booking ||
    response?.data?.booking ||
    response?.data?.data ||
    response?.data ||
    response
  );
}

function getErrorMessage(err, fallback) {
  return (
    err.response?.data?.message ||
    err.response?.data?.error ||
    err.message ||
    fallback
  );
}

function getToday() {
  const date = new Date();
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

export default function EditBooking() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [form, setForm] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    let active = true;

    async function loadBooking() {
      try {
        setLoading(true);
        setError("");

        const response = await bookingService.getById(id);
        const data = unwrapBooking(response);

        if (!data || typeof data !== "object" || !data._id && !data.id) {
          throw new Error("Booking not found.");
        }

        if (active) {
          setForm({
            functionDate: String(
              data.functionDate || data.eventDate || ""
            ).slice(0, 10),
            functionTime: data.functionTime || "",
            location: data.location || "",
            numberOfPersons:
              data.numberOfPersons ?? data.guestCount ?? 1,
            extraRequirements: data.extraRequirements || "",
            status: data.status || "pending",
          });
        }
      } catch (err) {
        if (active) {
          setError(getErrorMessage(err, "Unable to load booking."));
        }
      } finally {
        if (active) setLoading(false);
      }
    }

    loadBooking();

    return () => {
      active = false;
    };
  }, [id]);

  function change(event) {
    const { name, value } = event.target;

    setForm((previous) => ({
      ...previous,
      [name]: value,
    }));
  }

  async function submit(event) {
    event.preventDefault();
    setError("");

    if (form.status !== "pending") {
      setError("Only pending bookings can be edited.");
      return;
    }

    if (!form.functionDate || form.functionDate < getToday()) {
      setError("Please select today or a future date.");
      return;
    }

    if (!form.functionTime) {
      setError("Please select the function time.");
      return;
    }

    if (!form.location.trim()) {
      setError("Please enter the event location.");
      return;
    }

    const persons = Number(form.numberOfPersons);

    if (!Number.isSafeInteger(persons) || persons < 1 || persons > 1000000) {
      setError("Enter a valid whole number of guests.");
      return;
    }

    try {
      setSaving(true);

      await bookingService.update(id, {
        functionDate: form.functionDate,
        functionTime: form.functionTime,
        location: form.location.trim(),
        numberOfPersons: persons,
        extraRequirements: form.extraRequirements.trim(),
      });

      navigate(`/my-bookings/${id}`, { replace: true });
    } catch (err) {
      setError(getErrorMessage(err, "Unable to update booking."));
    } finally {
      setSaving(false);
    }
  }

  if (loading) return <Loading />;

  if (!form) {
    return (
      <section className="page-container page-narrow">
        <p className="page-error" role="alert">
          {error || "Booking not found."}
        </p>
        <Link to="/my-bookings" className="page-btn">
          Back to bookings
        </Link>
      </section>
    );
  }

  if (form.status !== "pending") {
    return (
      <section className="page-container page-narrow">
        <p className="page-error">
          This booking can no longer be edited because its status is
          {` ${form.status}.`}
        </p>
        <Link to={`/my-bookings/${id}`} className="page-btn">
          Back to booking
        </Link>
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
        <label htmlFor="functionDate">Function date</label>
        <input
          id="functionDate"
          type="date"
          name="functionDate"
          min={getToday()}
          value={form.functionDate}
          onChange={change}
          required
        />

        <label htmlFor="functionTime">Function time</label>
        <input
          id="functionTime"
          type="time"
          name="functionTime"
          value={form.functionTime}
          onChange={change}
          required
        />

        <label htmlFor="location">Location</label>
        <input
          id="location"
          name="location"
          maxLength={500}
          value={form.location}
          onChange={change}
          required
        />

        <label htmlFor="numberOfPersons">Number of guests</label>
        <input
          id="numberOfPersons"
          type="number"
          min="1"
          max="1000000"
          step="1"
          name="numberOfPersons"
          value={form.numberOfPersons}
          onChange={change}
          required
        />

        <label htmlFor="extraRequirements">Extra requirements</label>
        <textarea
          id="extraRequirements"
          rows="4"
          maxLength={2000}
          name="extraRequirements"
          value={form.extraRequirements}
          onChange={change}
        />

        {error && (
          <p className="page-error" role="alert">{error}</p>
        )}

        <div className="page-actions">
          <Link
            to={`/my-bookings/${id}`}
            className="page-btn page-btn-light"
          >
            Cancel
          </Link>

          <button
            type="submit"
            className="page-btn"
            disabled={saving}
          >
            {saving ? "Saving..." : "Save Changes"}
          </button>
        </div>
      </form>
    </section>
  );
}
