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
  Trash2,
  LoaderCircle,
} from "lucide-react";

import customerService from "../services/customerService";
import "./Customers.css";

const getCustomerList = (response) => {
  if (Array.isArray(response)) return response;
  if (Array.isArray(response?.customers)) return response.customers;
  if (Array.isArray(response?.data)) return response.data;
  if (Array.isArray(response?.data?.customers)) {
    return response.data.customers;
  }

  return [];
};

const getCustomerId = (customer) =>
  String(customer?._id || customer?.id || "");

const getCustomerName = (customer) =>
  customer?.full_name ||
  customer?.fullName ||
  customer?.name ||
  customer?.customerName ||
  "Customer";

const getPhone = (customer) =>
  customer?.phone ||
  customer?.mobile ||
  customer?.mobileNumber ||
  "";

const getEmail = (customer) => customer?.email || "";

const getBookingCount = (customer) => {
  const value =
    customer?.total_bookings ??
    customer?.bookingCount ??
    customer?.totalBookings ??
    customer?.bookingsCount;

  if (value !== undefined && value !== null && Number.isFinite(Number(value))) {
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

const getErrorMessage = (error) => {
  const detail = error?.response?.data?.detail;

  if (typeof detail === "string") return detail;

  if (Array.isArray(detail)) {
    return detail.map((item) => item.msg || "Validation error").join(", ");
  }

  return (
    error?.response?.data?.message ||
    error?.message ||
    "Unable to complete the request. Please try again."
  );
};

export default function Customers() {
  const [customers, setCustomers] = useState([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [deletingId, setDeletingId] = useState("");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const fetchCustomers = useCallback(async () => {
    setLoading(true);
    setError("");

    try {
      const response = await customerService.getAll({ limit: 100 });

      const list = getCustomerList(response);

      setCustomers(
        list.filter(
          (customer) =>
            customer?.is_deleted !== true &&
            customer?.status !== "deleted"
        )
      );
    } catch (err) {
      setError(getErrorMessage(err));
      setCustomers([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchCustomers();
  }, [fetchCustomers]);

  const handleDeleteCustomer = async (customer) => {
    const customerId = getCustomerId(customer);

    if (!customerId) {
      setError("Invalid customer ID. Cannot delete this customer.");
      return;
    }

    const customerName = getCustomerName(customer);

    const confirmed = window.confirm(
      `Are you sure you want to delete ${customerName}?\n\n` +
        "This customer will be hidden from the active customer list."
    );

    if (!confirmed) return;

    setDeletingId(customerId);
    setError("");
    setSuccess("");

    try {
      await customerService.delete(customerId);

      setCustomers((previous) =>
        previous.filter((item) => getCustomerId(item) !== customerId)
      );

      setSuccess(`${customerName} deleted successfully.`);
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setDeletingId("");
    }
  };

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
    () =>
      customers.reduce(
        (total, customer) => total + getBookingCount(customer),
        0
      ),
    [customers]
  );

  const customersWithBookings = useMemo(
    () =>
      customers.filter((customer) => getBookingCount(customer) > 0).length,
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

      {success && (
        <div className="customers-success" role="status">
          <span>{success}</span>

          <button
            type="button"
            onClick={() => setSuccess("")}
            aria-label="Dismiss success message"
          >
            ×
          </button>
        </div>
      )}

      <div className="customers-toolbar">
        <div>
          <h2>All Customers</h2>
          <p>
            Search customer names, phone numbers or email addresses.
          </p>
        </div>

        <button
          type="button"
          className="customers-refresh-btn"
          onClick={fetchCustomers}
          disabled={loading || Boolean(deletingId)}
        >
          <RefreshCw
            size={17}
            className={loading ? "customers-refresh-spin" : ""}
          />
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
                        <button type="button" onClick={fetchCustomers}>
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
                  const isDeleting = deletingId === id;

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
                            customer?.created_at ||
                              customer?.createdAt ||
                              customer?.registeredAt
                          )}
                        </span>
                      </td>

                      <td>
                        <div className="customer-actions">
                          {id ? (
                            <Link
                              to={`/customers/${encodeURIComponent(id)}`}
                              className="customer-view-btn"
                              aria-label={`View ${name}`}
                            >
                              <Eye size={16} />
                              View
                            </Link>
                          ) : (
                            <span className="customer-no-action">—</span>
                          )}

                          <button
                            type="button"
                            className="customer-delete-btn"
                            onClick={() => handleDeleteCustomer(customer)}
                            disabled={!id || Boolean(deletingId)}
                            aria-label={`Delete ${name}`}
                          >
                            {isDeleting ? (
                              <LoaderCircle
                                size={16}
                                className="customer-delete-spinner"
                              />
                            ) : (
                              <Trash2 size={16} />
                            )}

                            {isDeleting ? "Deleting..." : "Delete"}
                          </button>
                        </div>
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