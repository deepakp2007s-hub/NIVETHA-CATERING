/**
 * Nivetha Catering – Phase 1 Test Suite
 * Uses Node.js built-in test runner (node:test + node:assert).
 * Run: node --test test/booking-auth.test.js
 *
 * These tests are pure-logic / unit tests — no real DB or network calls.
 */

"use strict";

const { test, describe } = require("node:test");
const assert = require("node:assert/strict");

// ─── helpers (lifted / adapted from bookingController without importing the full module) ──

function getCalendarDate(value) {
  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    const year = value.getFullYear();
    const month = String(value.getMonth() + 1).padStart(2, "0");
    const day = String(value.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
  }
  if (typeof value !== "string") return null;
  const match = /^(\d{4})-(\d{2})-(\d{2})(?:$|T)/.exec(value);
  if (!match) return null;
  const [, yearText, monthText, dayText] = match;
  const year = Number(yearText);
  const month = Number(monthText);
  const day = Number(dayText);
  const check = new Date(Date.UTC(year, month - 1, day));
  if (
    check.getUTCFullYear() !== year ||
    check.getUTCMonth() + 1 !== month ||
    check.getUTCDate() !== day
  ) return null;
  if (value.includes("T") && Number.isNaN(new Date(value).getTime())) return null;
  return `${yearText}-${monthText}-${dayText}`;
}

function validateNewBooking(input, { requireCateringServices = false } = {}) {
  if (typeof input.eventType !== "string" || !input.eventType.trim())
    return "Event type is required.";

  const eventDateStr = getCalendarDate(input.functionDate);
  if (!eventDateStr) return "A valid function date is required.";

  const eventDate = new Date(eventDateStr);
  if (isNaN(eventDate.getTime())) return "A valid function date is required.";

  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const compareDate = new Date(eventDate);
  compareDate.setHours(0, 0, 0, 0);
  if (compareDate < today) return "Function date cannot be in the past.";

  if (typeof input.location !== "string" || !input.location.trim())
    return "Event location is required.";

  if (
    typeof input.functionTime !== "string" ||
    !/^(?:[01]\d|2[0-3]):[0-5]\d$/.test(input.functionTime)
  )
    return "A valid function time (HH:mm) is required.";

  const persons = Number(input.numberOfPersons);
  if (
    !["number", "string"].includes(typeof input.numberOfPersons) ||
    !Number.isInteger(persons) ||
    !Number.isFinite(persons) ||
    persons < 1
  )
    return "Number of persons must be a positive whole number.";

  if (
    requireCateringServices &&
    !(Array.isArray(input.cateringServices) && input.cateringServices.length > 0) &&
    !(typeof input.cateringService === "string" && input.cateringService.trim())
  )
    return "Select at least one catering service.";

  return null;
}

// ─── helpers to build future / past date strings ──

function dateStr(offsetDays) {
  const d = new Date();
  d.setHours(0, 0, 0, 0);
  d.setDate(d.getDate() + offsetDays);
  return d.toISOString().slice(0, 10);
}

const VALID_BASE = {
  eventType: "Wedding",
  functionDate: dateStr(5),      // 5 days in the future
  functionTime: "10:00",
  location: "Chennai Hall",
  numberOfPersons: 100,
  cateringServices: ["cooking"],
};

// ─── Date validation ────────────────────────────────────────────────────────

describe("Booking date validation", () => {
  test("accepts today's date", () => {
    // Build today's YYYY-MM-DD using local time (same as getCalendarDate produces)
    const now = new Date();
    const todayLocal = [
      now.getFullYear(),
      String(now.getMonth() + 1).padStart(2, "0"),
      String(now.getDate()).padStart(2, "0"),
    ].join("-");
    const err = validateNewBooking({ ...VALID_BASE, functionDate: todayLocal });
    assert.equal(err, null, `Expected null but got: ${err}`);
  });

  test("accepts a future date", () => {
    const err = validateNewBooking({ ...VALID_BASE, functionDate: dateStr(30) });
    assert.equal(err, null);
  });

  test("rejects yesterday", () => {
    const err = validateNewBooking({ ...VALID_BASE, functionDate: dateStr(-1) });
    assert.match(err, /past/i);
  });

  test("rejects 30 days ago", () => {
    const err = validateNewBooking({ ...VALID_BASE, functionDate: dateStr(-30) });
    assert.match(err, /past/i);
  });

  test("rejects an invalid date string", () => {
    const err = validateNewBooking({ ...VALID_BASE, functionDate: "not-a-date" });
    assert.match(err, /valid function date/i);
  });

  test("rejects null functionDate", () => {
    const err = validateNewBooking({ ...VALID_BASE, functionDate: null });
    assert.match(err, /valid function date/i);
  });

  test("accepts a Date object for today", () => {
    const today = new Date();
    today.setHours(12, 0, 0, 0);
    const err = validateNewBooking({ ...VALID_BASE, functionDate: today });
    assert.equal(err, null, `Expected null but got: ${err}`);
  });
});

// ─── Required fields ─────────────────────────────────────────────────────────

describe("Booking required field validation", () => {
  test("rejects missing eventType", () => {
    const { eventType: _, ...rest } = VALID_BASE;
    const err = validateNewBooking({ ...rest, eventType: "" });
    assert.match(err, /event type/i);
  });

  test("rejects missing location", () => {
    const err = validateNewBooking({ ...VALID_BASE, location: "  " });
    assert.match(err, /location/i);
  });

  test("rejects bad time format", () => {
    const err = validateNewBooking({ ...VALID_BASE, functionTime: "25:00" });
    assert.match(err, /function time/i);
  });

  test("rejects zero persons", () => {
    const err = validateNewBooking({ ...VALID_BASE, numberOfPersons: 0 });
    assert.match(err, /positive whole number/i);
  });

  test("rejects negative persons", () => {
    const err = validateNewBooking({ ...VALID_BASE, numberOfPersons: -5 });
    assert.match(err, /positive whole number/i);
  });

  test("rejects fractional persons", () => {
    const err = validateNewBooking({ ...VALID_BASE, numberOfPersons: 50.5 });
    assert.match(err, /positive whole number/i);
  });

  test("accepts string number of persons", () => {
    const err = validateNewBooking({ ...VALID_BASE, numberOfPersons: "200" });
    assert.equal(err, null);
  });
});

// ─── Catering services ───────────────────────────────────────────────────────

describe("Catering service validation", () => {
  test("enforces catering service when requireCateringServices=true", () => {
    const input = { ...VALID_BASE, cateringServices: [], cateringService: "" };
    const err = validateNewBooking(input, { requireCateringServices: true });
    assert.match(err, /catering service/i);
  });

  test("accepts singular cateringService string", () => {
    const input = { ...VALID_BASE, cateringServices: [], cateringService: "cooking" };
    const err = validateNewBooking(input, { requireCateringServices: true });
    assert.equal(err, null);
  });

  test("accepts cateringServices array", () => {
    const input = { ...VALID_BASE, cateringServices: ["cooking", "serving"] };
    const err = validateNewBooking(input, { requireCateringServices: true });
    assert.equal(err, null);
  });
});

// ─── Payment calculation helper (Phase 2 preview) ───────────────────────────

describe("Payment amount calculations", () => {
  function calculateBalance(totalAmount, advanceAmount) {
    if (
      typeof totalAmount !== "number" ||
      typeof advanceAmount !== "number" ||
      !isFinite(totalAmount) ||
      !isFinite(advanceAmount) ||
      totalAmount < 0 ||
      advanceAmount < 0
    ) throw new TypeError("Amounts must be non-negative finite numbers");
    if (advanceAmount > totalAmount) throw new RangeError("Advance cannot exceed total");
    return Math.round((totalAmount - advanceAmount) * 100) / 100;
  }

  test("balance = total - advance", () => {
    assert.equal(calculateBalance(10000, 3000), 7000);
  });

  test("balance is zero when advance equals total", () => {
    assert.equal(calculateBalance(5000, 5000), 0);
  });

  test("throws when advance exceeds total", () => {
    assert.throws(() => calculateBalance(1000, 2000), RangeError);
  });

  test("throws for negative amounts", () => {
    assert.throws(() => calculateBalance(-100, 0), TypeError);
  });

  test("rounds floating point correctly", () => {
    assert.equal(calculateBalance(10000.50, 3333.33), 6667.17);
  });
});

// ─── Auth token parsing (pure logic, no network) ────────────────────────────

describe("JWT token header parsing", () => {
  function extractBearerToken(authHeader) {
    if (!authHeader || !authHeader.startsWith("Bearer ")) return null;
    const token = authHeader.slice(7).trim();
    return token || null;
  }

  test("returns token for valid Bearer header", () => {
    assert.equal(extractBearerToken("Bearer abc.def.ghi"), "abc.def.ghi");
  });

  test("returns null for missing header", () => {
    assert.equal(extractBearerToken(undefined), null);
  });

  test("returns null for empty string", () => {
    assert.equal(extractBearerToken(""), null);
  });

  test("returns null for non-Bearer scheme", () => {
    assert.equal(extractBearerToken("Basic abc123"), null);
  });

  test("returns null for Bearer with no token", () => {
    assert.equal(extractBearerToken("Bearer "), null);
  });
});
