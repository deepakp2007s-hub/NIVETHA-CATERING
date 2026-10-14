import { useEffect, useMemo, useState } from "react";
import api from "../services/api";
import "./Reviews.css";

const getReviewList = (response) => {
  const data = response?.data;

  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.reviews)) return data.reviews;
  if (Array.isArray(data?.data)) return data.data;
  if (Array.isArray(data?.data?.reviews)) return data.data.reviews;

  return [];
};

const getRating = (review) => {
  const rating = Number(review?.rating ?? review?.stars ?? 0);
  return Number.isFinite(rating) ? Math.min(5, Math.max(0, rating)) : 0;
};

const getCustomerName = (review) =>
  review?.customerName ||
  review?.customer?.name ||
  review?.customer?.fullName ||
  review?.name ||
  "Customer";

const getReviewDate = (review) => {
  const value = review?.createdAt || review?.date;
  if (!value) return null;

  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
};

const formatDate = (date) =>
  date
    ? date.toLocaleDateString("en-IN", {
        day: "2-digit",
        month: "short",
        year: "numeric",
      })
    : "Date unavailable";

export default function Reviews() {
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [ratingFilter, setRatingFilter] = useState("all");
  const [search, setSearch] = useState("");

  useEffect(() => {
    let active = true;

    const loadReviews = async () => {
      try {
        setLoading(true);
        setError("");

        // Change this path only if your existing backend uses another route.
        const response = await api.get("/reviews");

        if (active) {
          setReviews(getReviewList(response));
        }
      } catch (err) {
        if (active) {
          setError(
            err?.response?.data?.message ||
              "Unable to load reviews. Please check the backend connection."
          );
        }
      } finally {
        if (active) setLoading(false);
      }
    };

    loadReviews();

    return () => {
      active = false;
    };
  }, []);

  const filteredReviews = useMemo(() => {
    const query = search.trim().toLowerCase();

    return reviews.filter((review) => {
      const rating = getRating(review);
      const customer = getCustomerName(review).toLowerCase();
      const comment = String(
        review?.comment || review?.review || review?.feedback || ""
      ).toLowerCase();

      const matchesRating =
        ratingFilter === "all" || rating === Number(ratingFilter);

      const matchesSearch =
        !query || customer.includes(query) || comment.includes(query);

      return matchesRating && matchesSearch;
    });
  }, [reviews, ratingFilter, search]);

  const stats = useMemo(() => {
    const total = reviews.length;
    const ratingTotal = reviews.reduce(
      (sum, review) => sum + getRating(review),
      0
    );

    const distribution = [5, 4, 3, 2, 1].map((rating) => ({
      rating,
      count: reviews.filter(
        (review) => Math.round(getRating(review)) === rating
      ).length,
    }));

    return {
      total,
      average: total ? (ratingTotal / total).toFixed(1) : "0.0",
      fiveStars: distribution[0].count,
      distribution,
    };
  }, [reviews]);

  if (loading) {
    return (
      <div className="reviews-page">
        <div className="reviews-state">
          <span className="reviews-spinner" />
          <p>Loading customer reviews...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="reviews-page">
        <div className="reviews-state">
          <div className="reviews-error-icon">!</div>
          <h2>Reviews unavailable</h2>
          <p>{error}</p>
          <button
            className="reviews-btn"
            onClick={() => window.location.reload()}
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="reviews-page">
      <header className="reviews-header">
        <div>
          <span className="reviews-eyebrow">CUSTOMER EXPERIENCE</span>
          <h1>Reviews & Feedback</h1>
          <p>Understand what customers think about your catering service.</p>
        </div>

        <div className="reviews-count-chip">
          <span className="reviews-count-dot" />
          {stats.total} review{stats.total === 1 ? "" : "s"}
        </div>
      </header>

      <section className="reviews-stats-grid">
        <article className="reviews-stat-card reviews-stat-primary">
          <span className="reviews-stat-label">Average Rating</span>
          <div className="reviews-average-row">
            <strong>{stats.average}</strong>
            <span className="reviews-big-star">★</span>
          </div>
          <div className="reviews-stars" aria-label={`${stats.average} out of 5`}>
            {"★".repeat(Math.round(Number(stats.average)))}
            <span>{"★".repeat(5 - Math.round(Number(stats.average)))}</span>
          </div>
          <small>Based on available reviews</small>
        </article>

        <article className="reviews-stat-card">
          <div className="reviews-stat-icon">✦</div>
          <span className="reviews-stat-label">Total Reviews</span>
          <strong className="reviews-stat-value">{stats.total}</strong>
          <small>Customer feedback received</small>
        </article>

        <article className="reviews-stat-card">
          <div className="reviews-stat-icon">★</div>
          <span className="reviews-stat-label">5-Star Reviews</span>
          <strong className="reviews-stat-value">{stats.fiveStars}</strong>
          <small>Highest-rated feedback</small>
        </article>
      </section>

      <section className="reviews-content-grid">
        <article className="reviews-panel reviews-distribution-panel">
          <div className="reviews-panel-heading">
            <h2>Rating Distribution</h2>
            <p>Breakdown of customer ratings</p>
          </div>

          <div className="reviews-distribution">
            {stats.distribution.map((item) => {
              const percentage = stats.total
                ? (item.count / stats.total) * 100
                : 0;

              return (
                <div className="reviews-rating-row" key={item.rating}>
                  <span className="reviews-rating-label">
                    {item.rating} <span>★</span>
                  </span>

                  <div className="reviews-rating-track">
                    <div
                      className="reviews-rating-fill"
                      style={{ width: `${percentage}%` }}
                    />
                  </div>

                  <span className="reviews-rating-count">
                    {item.count}
                  </span>
                </div>
              );
            })}
          </div>
        </article>

        <article className="reviews-panel reviews-feedback-panel">
          <div className="reviews-panel-heading">
            <h2>Feedback Overview</h2>
            <p>Summary of the available customer feedback</p>
          </div>

          {stats.total === 0 ? (
            <div className="reviews-empty">
              <span>☆</span>
              <h3>No feedback yet</h3>
              <p>Customer reviews will appear here when they are submitted.</p>
            </div>
          ) : (
            <div className="reviews-feedback-summary">
              <div className="reviews-feedback-icon">✓</div>
              <div>
                <strong>{stats.average} / 5</strong>
                <p>Average customer rating</p>
                <small>
                  Calculated from {stats.total} available review
                  {stats.total === 1 ? "" : "s"}.
                </small>
              </div>
            </div>
          )}
        </article>
      </section>

      <section className="reviews-panel reviews-list-panel">
        <div className="reviews-panel-heading reviews-list-heading">
          <div>
            <h2>Customer Reviews</h2>
            <p>Read feedback submitted by your customers.</p>
          </div>

          <span className="reviews-filtered-count">
            {filteredReviews.length} shown
          </span>
        </div>

        <div className="reviews-toolbar">
          <div className="reviews-search">
            <span>⌕</span>
            <input
              type="search"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Search customer or feedback..."
              aria-label="Search customer reviews"
            />
          </div>

          <select
            className="reviews-rating-filter"
            value={ratingFilter}
            onChange={(event) => setRatingFilter(event.target.value)}
            aria-label="Filter reviews by rating"
          >
            <option value="all">All ratings</option>
            <option value="5">5 stars</option>
            <option value="4">4 stars</option>
            <option value="3">3 stars</option>
            <option value="2">2 stars</option>
            <option value="1">1 star</option>
          </select>
        </div>

        {filteredReviews.length === 0 ? (
          <div className="reviews-empty">
            <span>☆</span>
            <h3>{reviews.length ? "No matching reviews" : "No reviews found"}</h3>
            <p>
              {reviews.length
                ? "Try changing your search or rating filter."
                : "Reviews will appear here after customers submit feedback."}
            </p>
          </div>
        ) : (
          <div className="reviews-list">
            {filteredReviews.map((review, index) => {
              const id =
                review?._id || review?.id || review?.reviewId || index;
              const name = getCustomerName(review);
              const rating = getRating(review);
              const comment =
                review?.comment ||
                review?.review ||
                review?.feedback ||
                "No written comment was provided.";
              const date = getReviewDate(review);

              return (
                <article className="reviews-item" key={id}>
                  <div className="reviews-item-avatar">
                    {name.charAt(0).toUpperCase()}
                  </div>

                  <div className="reviews-item-content">
                    <div className="reviews-item-top">
                      <div>
                        <h3>{name}</h3>
                        <span className="reviews-item-date">
                          {formatDate(date)}
                        </span>
                      </div>

                      <span className="reviews-item-rating">
                        <span>★</span> {rating.toFixed(1)}
                      </span>
                    </div>

                    <div
                      className="reviews-item-stars"
                      aria-label={`${rating} out of 5 stars`}
                    >
                      {"★".repeat(Math.floor(rating))}
                      <span>
                        {"★".repeat(5 - Math.floor(rating))}
                      </span>
                    </div>

                    <p className="reviews-item-comment">{comment}</p>
                  </div>
                </article>
              );
            })}
          </div>
        )}
      </section>

      <footer className="reviews-footer">
        <span>NIVETHA CATERING SERVICE</span>
        <span>Customer feedback · Read-only view</span>
      </footer>
    </div>
  );
}
