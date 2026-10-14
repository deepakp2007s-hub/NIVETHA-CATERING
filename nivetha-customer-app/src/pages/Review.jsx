import { useState } from "react";
import { Star } from "lucide-react";
import reviewService from "../services/reviewService";
import "./PageStyles.css";

export default function Review() {
  const [rating, setRating] = useState(5);
  const [review, setReview] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  async function submit(event) {
    event.preventDefault();
    setError("");
    setMessage("");

    if (!review.trim()) {
      setError("Please enter your feedback.");
      return;
    }

    try {
      setSubmitting(true);
      await reviewService.create({ rating, review: review.trim(), comment: review.trim() });
      setMessage("Thank you! Your feedback has been submitted.");
      setReview("");
      setRating(5);
    } catch (err) {
      setError(err.message || "Unable to submit feedback. Please try again.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <section className="page-container page-narrow">
      <div className="page-heading">
        <span className="page-kicker">YOUR FEEDBACK MATTERS</span>
        <h1>Review & Feedback</h1>
        <p>Tell us about your experience with Nivetha Catering Service.</p>
      </div>

      <form className="page-form review-form" onSubmit={submit}>
        <label>How would you rate our service?</label>
        <div className="rating-stars" role="group" aria-label="Choose rating">
          {[1, 2, 3, 4, 5].map((value) => (
            <button
              type="button"
              key={value}
              onClick={() => setRating(value)}
              aria-label={`${value} star${value > 1 ? "s" : ""}`}
              className={value <= rating ? "star-active" : ""}
            >
              <Star size={34} fill={value <= rating ? "currentColor" : "none"} />
            </button>
          ))}
        </div>
        <p className="rating-label">{rating} out of 5 stars</p>

        <label htmlFor="review-message">Your feedback</label>
        <textarea
          id="review-message"
          rows="6"
          value={review}
          onChange={(event) => setReview(event.target.value)}
          placeholder="Share your experience..."
          maxLength={1000}
          required
        />
        <small className="page-muted">{review.length}/1000 characters</small>

        {message && <p className="page-success">{message}</p>}
        {error && <p className="page-error">{error}</p>}

        <button type="submit" className="page-btn" disabled={submitting}>
          {submitting ? "Submitting..." : "Submit Feedback"}
        </button>
      </form>
    </section>
  );
}