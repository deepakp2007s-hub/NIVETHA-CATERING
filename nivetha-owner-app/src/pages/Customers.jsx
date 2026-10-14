import { useCallback, useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import {
  Users,
  Search,
  RefreshCw,
  Phone,
  Mail,
  CalendarDays,
  Eye,
  UserRound,
  ClipboardList,
  AlertCircle,
  XCircle,
} from "lucide-react";
import api from "../services/api";
import "./Customers.css";

const getCustomerList = (response) => {
  const data = response?.data;

  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.customers)) return data.customers;
  if (Array.isArray(data?.data)) return data.data;
  if (Array.isArray(data?.data?.customers)) return data.data.customers;

  return [];
};

const getCustomerId = (customer) =>
  String(customer?._id || customer?.id || "");

const getCustomerName = (customer) =>
  customer?.name ||
  customer?.fullName ||
  customer?.customerName ||
  "Customer";

const getPhone = (customer) =>
  customer?.phone ||
  customer?.mobile ||
  customer?.mobileNumber ||
  "";

const getEmail = (customer) =>
  customer?.email || "";

const getBookingCount = (customer) => {
  const value =
    customer?.bookingCount ??
    customer?.totalBookings ??
    customer?.bookingsCount;

  if (value != null && Number.isFinite(Number(value))) {
    return Number(value);
  }

  return Array.isArray(customer?.bookings)
    ? customer.bookings.length
    : 0;
};

const formatDate = (value) => {
  if (!value) return "—";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) return "—";

  return date.toLocaleDateString("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
};

const getErrorMessage = (error) =>
  error?.response?.data?.message ||
  "Unable to load customers. Please try again.";

export default function Customers() {
  const [customers, setCustomers] = useState([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const fetchCustomers = useCallback(async () => {
    setLoading(true);
    setError("");

    try {
      const response = await api.get("/customers");
      setCustomers(getCustomerList(response));
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchCustomers();
  }, [fetchCustomers]);

  const filteredCustomers = useMemo(() => {
    const query = search.trim().toLowerCase();

    if (!query) return customers;

    return customers.filter((customer) => {
      const name = getCustomerName(customer).toLowerCase();
      const phone = String(getPhone(customer)).toLowerCase();
      const email = getEmail(customer).toLowerCase();
      const id = getCustomerId(customer).toLowerCase();

      return (
        name.includes(query) ||
        phone.includes(query) ||
        email.includes(query) ||
        id.includes(query)
      );
    });
  }, [customers, search]);

  const totalBookings = useMemo(
    () => customers.reduce(
      (total, customer) => total + getBookingCount(customer),
      0
    ),
    [customers]
  );

  const customersWithBookings = useMemo(
    () => customers.filter((customer) => getBookingCount(customer) > 0).length,
    [customers]
  );

  return (
    <section className="customers-page">
      <div className="customers-hero">
        <div className="customers-hero-content">
          <span className="customers-eyebrow">
            NIVETHA CATERING SERVICE
          </span>
          <h1>Customer Management</h1>
          <p>
            View customer contact information and their booking activity
            in one place.
          </p>
        </div>

        <div className="customers-hero-icon">
          <Users size={36} />
        </div>
      </div>

      <div className="customers-stats">
        <article className="customer-stat-card">
          <div className="customer-stat-icon customer-stat-gold">
            <Users size={22} />
          </div>
          <div>
            <span>Total Customers</span>
            <h3>{customers.length}</h3>
          </div>
        </article>

        <article className="customer-stat-card">
          <div className="customer-stat-icon customer-stat-green">
            <UserRound size={22} />
          </div>
          <div>
            <span>Customers With Bookings</span>
            <h3>{customersWithBookings}</h3>
          </div>
        </article>

        <article className="customer-stat-card">
          <div className="customer-stat-icon customer-stat-blue">
            <ClipboardList size={22} />
          </div>
          <div>
            <span>Total Recorded Bookings</span>
            <h3>{totalBookings}</h3>
          </div>
        </article>
      </div>

      {error && (
        <div className="customers-alert" role="alert">
          <XCircle size={18} />
          <span>{error}</span>
          <button
            type="button"
            onClick={() => setError("")}
            aria-label="Dismiss error"
          >
            ×
          </button>
        </div>
      )}

      <div className="customers-toolbar">
        <div>
          <h2>All Customers</h2>
          <p>Search customer names, phone numbers or email addresses.</p>
        </div>

        <button
          type="button"
          className="customers-refresh-btn"
          onClick={fetchCustomers}
          disabled={loading}
        >
          <RefreshCw size={17} />
          Refresh
        </button>
      </div>

      <div className="customers-search-panel">
        <div className="customers-search">
          <Search size={19} />
          <input
            type="search"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            placeholder="Search name, phone, email or customer ID..."
            aria-label="Search customers"
          />
          {search && (
            <button
              type="button"
              onClick={() => setSearch("")}
              aria-label="Clear search"
            >
              ×
            </button>
          )}
        </div>

        <span className="customers-result-count">
          {filteredCustomers.length} customer
          {filteredCustomers.length !== 1 ? "s" : ""}
        </span>
      </div>

      <div className="customers-table-card">
        <div className="customers-table-wrapper">
          <table className="customers-table">
            <thead>
              <tr>
                <th>Customer</th>
                <th>Contact Information</th>
                <th>Total Bookings</th>
                <th>Registered Date</th>
                <th>Actions</th>
              </tr>
            </thead>

            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={5} className="customers-table-message">
                    <div className="customers-loading">
                      <span className="customers-spinner" />
                      Loading customers...
                    </div>
                  </td>
                </tr>
              ) : filteredCustomers.length === 0 ? (
                <tr>
                  <td colSpan={5} className="customers-table-message">
                    <div className="customers-empty">
                      {error ? (
                        <AlertCircle size={34} />
                      ) : (
                        <Users size={34} />
                      )}
                      <strong>
                        {error
                          ? "Customers could not be loaded"
                          : search
                            ? "No matching customers"
                            : "No customers found"}
                      </strong>
                      <span>
                        {error
                          ? "Check the API connection and try again."
                          : search
                            ? "Try another search term."
                            : "Customers will appear here when available in the backend."}
                      </span>
                      {error && (
                        <button
                          type="button"
                          onClick={fetchCustomers}
                        >
                          Try Again
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ) : (
                filteredCustomers.map((customer) => {
                  const id = getCustomerId(customer);
                  const name = getCustomerName(customer);
                  const phone = getPhone(customer);
                  const email = getEmail(customer);
                  const bookingCount = getBookingCount(customer);

                  return (
                    <tr key={id || `${name}-${phone}`}>
                      <td>
                        <div className="customer-name-cell">
                          <span className="customer-avatar">
                            {name.charAt(0).toUpperCase()}
                          </span>
                          <div>
                            <strong>{name}</strong>
                            <span>
                              {id ? `ID: ${id.slice(-8)}` : "Customer"}
                            </span>
                          </div>
                        </div>
                      </td>

                      <td>
                        <div className="customer-contact-cell">
                          {phone ? (
                            <a href={`tel:${phone}`}>
                              <Phone size={14} />
                              {phone}
                            </a>
                          ) : (
                            <span className="customer-contact-missing">
                              <Phone size={14} />
                              Not provided
                            </span>
                          )}

                          {email ? (
                            <a href={`mailto:${email}`}>
                              <Mail size={14} />
                              {email}
                            </a>
                          ) : (
                            <span className="customer-contact-missing">
                              <Mail size={14} />
                              No email
                            </span>
                          )}
                        </div>
                      </td>

                      <td>
                        <span className="customer-booking-count">
                          <ClipboardList size={15} />
                          {bookingCount}
                        </span>
                      </td>

                      <td>
                        <span className="customer-date">
                          <CalendarDays size={15} />
                          {formatDate(
                            customer?.createdAt ||
                            customer?.registeredAt ||
                            customer?.created_at
                          )}
                        </span>
                      </td>

                      <td>
                        {id ? (
                          <Link
                            to={`/customers/${encodeURIComponent(id)}`}
                            className="customer-view-btn"
                          >
                            <Eye size={16} />
                            View
                          </Link>
                        ) : (
                          <span className="customer-no-action">—</span>
                        )}
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        <div className="customers-table-footer">
          <span>
            Showing {filteredCustomers.length} of {customers.length} customers
          </span>
        </div>
      </div>
    </section>
  );
}