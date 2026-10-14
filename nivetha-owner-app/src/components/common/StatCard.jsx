
import {
  TrendingUp,
  TrendingDown,
  Minus,
} from "lucide-react";
import { formatNumber } from "../../utils/formatters";
import "./StatCard.css";
export default function StatCard({
  title,
  value = 0,
  icon: Icon,
  trend,
  trendLabel = "vs previous period",
  description,
  color = "green",
  isCurrency = false,
}) {
  const colorClasses = {
    green: "stat-icon-green",
    blue: "stat-icon-blue",
    orange: "stat-icon-orange",
    purple: "stat-icon-purple",
    red: "stat-icon-red",
  };

  const numericValue = Number(value);
  const validValue = Number.isFinite(numericValue)
    ? numericValue
    : 0;

  const displayValue = isCurrency
    ? new Intl.NumberFormat("en-IN", {
        style: "currency",
        currency: "INR",
        maximumFractionDigits: 2,
      }).format(validValue)
    : formatNumber(validValue);

  const trendValue =
    trend === "" || trend === null || trend === undefined
      ? null
      : Number(trend);

  const validTrend =
    trendValue !== null && Number.isFinite(trendValue)
      ? trendValue
      : null;

  const TrendIcon =
    validTrend === null
      ? Minus
      : validTrend > 0
        ? TrendingUp
        : validTrend < 0
          ? TrendingDown
          : Minus;

  const trendClass =
    validTrend === null || validTrend === 0
      ? "stat-trend-neutral"
      : validTrend > 0
        ? "stat-trend-up"
        : "stat-trend-down";

  return (
    <article className="stat-card">
      <div className="stat-card-top">
        <p className="stat-card-title">{title}</p>

        <div
          className={`stat-card-icon ${
            colorClasses[color] || colorClasses.green
          }`}
        >
          {Icon ? <Icon size={22} /> : <TrendingUp size={22} />}
        </div>
      </div>

      <div className="stat-card-value">
        {displayValue}
      </div>

      {description && (
        <p className="stat-card-description">
          {description}
        </p>
      )}

      {validTrend !== null && (
        <div className={`stat-trend ${trendClass}`}>
          <TrendIcon size={15} />
          <span>
            {Math.abs(validTrend)}%
          </span>
          <span className="stat-trend-label">
            {trendLabel}
          </span>
        </div>
      )}
    </article>
  );
}
