
import { useCallback, useEffect, useMemo, useState } from "react";
import {
  Star,
  Search,
  RefreshCw,
  MessageSquareText,
  TrendingUp,
  Award,
  Users,
  CalendarDays,
  X,
  AlertCircle,
  CheckCircle2,
  Sparkles,
} from "lucide-react";
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

const getErrorMessage = (error) =>
  error?.response?.data?.detail ||
  error?.response?.data?.message ||
  error?.message ||
  "Unable to load reviews. Please try again.";

const getRating = (review) => {
  const value = Number(review?.rating ?? review?.stars ?? 0);

  if (!Number.isFinite(value)) return 0;
  return Math.min(5, Math.max(0, value));
};

const getCustomerName = (review) =>
  review?.customer_name ||
  review?.customerName ||
  review?.customer?.full_name ||
  review?.customer?.fullName ||
  review?.customer?.name ||
  review?.name ||
  "Customer";

const getReviewComment = (review) =>
  review?.comment ||
  review?.review ||
  review?.feedback ||
  review?.message ||
  "";

const getReviewDate = (review) => {
  const value =
    review?.created_at ||
    review?.createdAt ||
    review?.date ||
    review?.updated_at;

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

const renderStars = (rating, className = "") => {
  const roundedRating = Math.round(rating);

  return (
    <span
      className={`reviews-stars ${className}`}
      role="img"
      aria-label={`${rating.toFixed(1)} out of 5 stars`}
    >
      {Array.from({ length: 5 }, (_, index) => (
        <Star
          key={index}
          size={15}
          fill={index < roundedRating ? "currentColor" : "none"}
        />
      ))}
    </span>
  );
};

export default function Reviews() {
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState("");
  const [search, setSearch] = useState("");
  const [ratingFilter, setRatingFilter] = useState("all");

  const fetchReviews = useCallback(async (isRefresh = false) => {
    try {
      if (isRefresh) {
        setRefreshing(true);
      } else {
        setLoading(true);
      }

      setError("");

      const response = await api.get("/reviews/");
      const reviewList = getReviewList(response);

      setReviews(reviewList);
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    fetchReviews();

  }, [fetchReviews]);

  const filteredReviews = useMemo(() => {
    const query = search.trim().toLowerCase();

    return reviews.filter((review) => {
      const rating = getRating(review);
      const customer = getCustomerName(review).toLowerCase();
      const comment = getReviewComment(review).toLowerCase();

      const matchesRating =
        ratingFilter === "all" || Math.round(rating) === Number(ratingFilter);

      const matchesSearch =
        !query ||
        customer.includes(query) ||
        comment.includes(query);

      return matchesRating && matchesSearch;
    });
  }, [reviews, search, ratingFilter]);

  const stats = useMemo(() => {
    const total = reviews.length;

    const ratingTotal = reviews.reduce(
      (sum, review) => sum + getRating(review),
      0
    );

    const average = total ? ratingTotal / total : 0;

    const distribution = [5, 4, 3, 2, 1].map((rating) => {
      const count = reviews.filter(
        (review) => Math.round(getRating(review)) === rating
      ).length;

      return {
        rating,
        count,
        percentage: total ? (count / total) * 100 : 0,
      };
    });

    return {
      total,
      average: average.toFixed(1),
      fiveStars: distribution.find((item) => item.rating === 5)?.count || 0,
      distribution,
    };
  }, [reviews]);

  const clearFilters = () => {
    setSearch("");
    setRatingFilter("all");
  };

  if (loading) {
    return (
      <div className="reviews-page">
        <div className="reviews-state">
          <span className="reviews-spinner" />
          <h2>Loading Reviews</h2>
          <p>Fetching customer feedback...</p>
        </div>
      </div>
    );
  }

  if (error && reviews.length === 0) {
    return (
      <div className="reviews-page">
        <div className="reviews-state reviews-error-state">
          <div className="reviews-state-icon">
            <AlertCircle size={30} />
          </div>
          <h2>Reviews Unavailable</h2>
          <p>{error}</p>
          <button
            type="button"
            className="reviews-primary-btn"
            onClick={() => fetchReviews()}
          >
            <RefreshCw size={16} />
            Try Again
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="reviews-page">
      <header className="reviews-header">
        <div className="reviews-header-content">
          <span className="reviews-eyebrow">
            <Sparkles size={14} />
            CUSTOMER EXPERIENCE
          </span>

          <h1>Reviews & Feedback</h1>

          <p>
            Discover customer opinions and monitor your catering service
            performance.
          </p>
        </div>

        <div className="reviews-header-actions">
          <div className="reviews-count-chip">
            <span className="reviews-count-dot" />
            {stats.total} {stats.total === 1 ? "Review" : "Reviews"}
          </div>

          <button
            type="button"
            className="reviews-refresh-btn"
            onClick={() => fetchReviews(true)}
            disabled={refreshing}
          >
            <RefreshCw
              size={16}
              className={refreshing ? "reviews-refresh-spin" : ""}
            />
            {refreshing ? "Refreshing" : "Refresh"}
          </button>
        </div>
      </header>

      {error && (
        <div className="reviews-inline-error" role="alert">
          <AlertCircle size={17} />
          <span>{error}</span>
          <button type="button" onClick={() => setError("")}>
            <X size={16} />
          </button>
        </div>
      )}

      <section className="reviews-stats-grid">
        <article className="reviews-stat-card reviews-stat-primary">
          <div className="reviews-stat-top">
            <span className="reviews-stat-label">Average Rating</span>
            <span className="reviews-stat-icon">
              <Star size={20} fill="currentColor" />
            </span>
          </div>

          <div className="reviews-average-row">
            <strong>{stats.average}</strong>
            <span className="reviews-out-of">/ 5.0</span>
          </div>

          {renderStars(Number(stats.average), "reviews-average-stars")}

          <small>Based on customer reviews</small>
        </article>

        <article className="reviews-stat-card">
          <div className="reviews-stat-top">
            <span className="reviews-stat-label">Total Reviews</span>
            <span className="reviews-stat-icon purple">
              <MessageSquareText size={20} />
            </span>
          </div>

          <strong className="reviews-stat-value">{stats.total}</strong>
          <small>Customer feedback received</small>
          <div className="reviews-stat-decoration">
            <Users size={46} />
          </div>
        </article>

        <article className="reviews-stat-card">
          <div className="reviews-stat-top">
            <span className="reviews-stat-label">5-Star Reviews</span>
            <span className="reviews-stat-icon cyan">
              <Award size={20} />
            </span>
          </div>

          <strong className="reviews-stat-value">{stats.fiveStars}</strong>
          <small>Highest-rated feedback</small>
          <div className="reviews-stat-decoration cyan-decoration">
            <TrendingUp size={46} />
          </div>
        </article>
      </section>

      <section className="reviews-content-grid">
        <article className="reviews-panel reviews-distribution-panel">
          <div className="reviews-panel-heading">
            <div>
              <h2>Rating Distribution</h2>
              <p>Customer rating breakdown</p>
            </div>
            <div className="reviews-heading-icon">
              <Star size={19} />
            </div>
          </div>

          <div className="reviews-distribution">
            {stats.distribution.map((item) => (
              <div className="reviews-rating-row" key={item.rating}>
                <span className="reviews-rating-label">
                  {item.rating}
                  <Star size={13} fill="currentColor" />
                </span>

                <div
                  className="reviews-rating-track"
                  role="progressbar"
                  aria-label={`${item.rating} star reviews`}
                  aria-valuenow={Math.round(item.percentage)}
                  aria-valuemin={0}
                  aria-valuemax={100}
                >
                  <div
                    className="reviews-rating-fill"
                    style={{ width: `${item.percentage}%` }}
                  />
                </div>

                <span className="reviews-rating-count">
                  {item.count}
                </span>
              </div>
            ))}
          </div>
        </article>

        <article className="reviews-panel reviews-feedback-panel">
          <div className="reviews-panel-heading">
            <div>
              <h2>Feedback Overview</h2>
              <p>Overall customer satisfaction</p>
            </div>
            <div className="reviews-heading-icon cyan">
              <TrendingUp size={19} />
            </div>
          </div>

          {stats.total === 0 ? (
            <div className="reviews-overview-empty">
              <MessageSquareText size={34} />
              <strong>No feedback yet</strong>
              <p>Customer reviews will appear here after submission.</p>
            </div>
          ) : (
            <div className="reviews-feedback-summary">
              <div className="reviews-feedback-icon">
                <CheckCircle2 size={25} />
              </div>

              <div>
                <strong>{stats.average} / 5.0</strong>
                <p>Average customer rating</p>
                <small>
                  Calculated from {stats.total} customer{" "}
                  {stats.total === 1 ? "review" : "reviews"}.
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
            <Search size={18} />
            <input
              type="search"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Search customer or feedback..."
              aria-label="Search customer reviews"
            />

            {search && (
              <button
                type="button"
                aria-label="Clear search"
                onClick={() => setSearch("")}
              >
                <X size={16} />
              </button>
            )}
          </div>

          <select
            className="reviews-rating-filter"
            value={ratingFilter}
            onChange={(event) => setRatingFilter(event.target.value)}
            aria-label="Filter reviews by rating"
          >
            <option value="all">All Ratings</option>
            <option value="5">5 Stars</option>
            <option value="4">4 Stars</option>
            <option value="3">3 Stars</option>
            <option value="2">2 Stars</option>
            <option value="1">1 Star</option>
          </select>
        </div>

        {filteredReviews.length === 0 ? (
          <div className="reviews-empty">
            <div className="reviews-empty-icon">
              <MessageSquareText size={30} />
            </div>

            <h3>
              {reviews.length ? "No Matching Reviews" : "No Reviews Found"}
            </h3>

            <p>
              {reviews.length
                ? "Try changing your search or rating filter."
                : "Reviews will appear here when customers submit feedback."}
            </p>

            {(search || ratingFilter !== "all") && (
              <button
                type="button"
                className="reviews-clear-btn"
                onClick={clearFilters}
              >
                Clear Filters
              </button>
            )}
          </div>
        ) : (
          <div className="reviews-list">
            {filteredReviews.map((review, index) => {
              const id =
                review?._id ||
                review?.id ||
                review?.review_id ||
                review?.reviewId ||
                `review-${index}`;

              const name = getCustomerName(review);
              const rating = getRating(review);
              const comment =
                getReviewComment(review) ||
                "No written comment was provided.";
              const date = getReviewDate(review);

              return (
                <article className="reviews-item" key={id}>
                  <div className="reviews-item-avatar">
                    {name.charAt(0).toUpperCase()}
                  </div>

                  <div className="reviews-item-content">
                    <div className="reviews-item-top">
                      <div className="reviews-customer-info">
                        <h3>{name}</h3>

                        <span className="reviews-item-date">
                          <CalendarDays size={13} />
                          {formatDate(date)}
                        </span>
                      </div>

                      <span className="reviews-item-rating">
                        <Star size={15} fill="currentColor" />
                        {rating.toFixed(1)}
                      </span>
                    </div>

                    {renderStars(rating, "reviews-item-stars")}

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
