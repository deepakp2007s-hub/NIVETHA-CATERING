
"use strict";

const { test, describe } = require("node:test");
const assert = require("node:assert/strict");

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
  ) {
    return null;
  }

  if (value.includes("T") && Number.isNaN(new Date(value).getTime())) {
    return null;
  }

  return `${yearText}-${monthText}-${dayText}`;
}

function validateNewBooking(input, { requireCateringServices = false } = {}) {
  if (
    typeof input.eventType !== "string" ||
    !input.eventType.trim() ||
    input.eventType.length > 100
  ) {
    return "Event type is required.";
  }

  const eventDateStr = getCalendarDate(input.functionDate);
  if (!eventDateStr) return "A valid function date is required.";

  const [year, month, day] = eventDateStr.split("-").map(Number);
  const eventDate = new Date(year, month - 1, day);
  const today = new Date();

  today.setHours(0, 0, 0, 0);
  eventDate.setHours(0, 0, 0, 0);

  if (eventDate < today) {
    return "Function date cannot be in the past.";
  }

  if (
    typeof input.location !== "string" ||
    !input.location.trim() ||
    input.location.length > 500
  ) {
    return "Event location is required.";
  }

  if (
    typeof input.functionTime !== "string" ||
    !/^(?:[01]\d|2[0-3]):[0-5]\d$/.test(input.functionTime)
  ) {
    return "A valid function time (HH:mm) is required.";
  }

  const persons = Number(input.numberOfPersons);

  if (
    !["number", "string"].includes(typeof input.numberOfPersons) ||
    (typeof input.numberOfPersons === "string" &&
      !input.numberOfPersons.trim()) ||
    !Number.isSafeInteger(persons) ||
    persons < 1 ||
    persons > 1000000
  ) {
    return "Number of persons must be a positive whole number.";
  }

  if (
    input.extraRequirements !== undefined &&
    (typeof input.extraRequirements !== "string" ||
      input.extraRequirements.length > 2000)
  ) {
    return "Extra requirements must not exceed 2000 characters.";
  }

  if (
    input.foodType !== undefined &&
    !["veg", "non-veg", "both"].includes(input.foodType)
  ) {
    return "Invalid food type.";
  }

  if (
    requireCateringServices &&
    !(Array.isArray(input.cateringServices) &&
      input.cateringServices.length > 0) &&
    !(typeof input.cateringService === "string" &&
      input.cateringService.trim())
  ) {
    return "Select at least one catering service.";
  }

  return null;
}

function dateStr(offsetDays) {
  const date = new Date();
  date.setHours(0, 0, 0, 0);
  date.setDate(date.getDate() + offsetDays);

  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");

  return `${year}-${month}-${day}`;
}

const VALID_BASE = {
  eventType: "Wedding",
  functionDate: dateStr(5),
  functionTime: "10:00",
  location: "Chennai Hall",
  numberOfPersons: 100,
  cateringServices: ["cooking"],
};

describe("Booking date validation", () => {
  test("accepts today's date", () => {
    assert.equal(
      validateNewBooking({ ...VALID_BASE, functionDate: dateStr(0) }),
      null
    );
  });

  test("accepts a future date", () => {
    assert.equal(
      validateNewBooking({ ...VALID_BASE, functionDate: dateStr(30) }),
      null
    );
  });

  test("rejects yesterday", () => {
    assert.match(
      validateNewBooking({ ...VALID_BASE, functionDate: dateStr(-1) }),
      /past/i
    );
  });

  test("rejects an invalid date", () => {
    assert.match(
      validateNewBooking({ ...VALID_BASE, functionDate: "2026-02-30" }),
      /valid function date/i
    );
  });

  test("rejects null date", () => {
    assert.match(
      validateNewBooking({ ...VALID_BASE, functionDate: null }),
      /valid function date/i
    );
  });
});

describe("Booking field validation", () => {
  test("rejects an empty event type", () => {
    assert.match(
      validateNewBooking({ ...VALID_BASE, eventType: " " }),
      /event type/i
    );
  });

  test("rejects an event type over 100 characters", () => {
    assert.match(
      validateNewBooking({ ...VALID_BASE, eventType: "A".repeat(101) }),
      /event type/i
    );
  });

  test("rejects an empty location", () => {
    assert.match(
      validateNewBooking({ ...VALID_BASE, location: " " }),
      /location/i
    );
  });

  test("rejects invalid time", () => {
    assert.match(
      validateNewBooking({ ...VALID_BASE, functionTime: "25:00" }),
      /function time/i
    );
  });

  test("accepts valid time", () => {
    assert.equal(
      validateNewBooking({ ...VALID_BASE, functionTime: "23:59" }),
      null
    );
  });

  test("rejects zero persons", () => {
    assert.match(
      validateNewBooking({ ...VALID_BASE, numberOfPersons: 0 }),
      /persons/i
    );
  });

  test("rejects fractional persons", () => {
    assert.match(
      validateNewBooking({ ...VALID_BASE, numberOfPersons: 50.5 }),
      /persons/i
    );
  });

  test("rejects more than one million persons", () => {
    assert.match(
      validateNewBooking({ ...VALID_BASE, numberOfPersons: 1000001 }),
      /persons/i
    );
  });

  test("accepts a numeric string for persons", () => {
    assert.equal(
      validateNewBooking({ ...VALID_BASE, numberOfPersons: "200" }),
      null
    );
  });

  test("rejects an invalid food type", () => {
    assert.match(
      validateNewBooking({ ...VALID_BASE, foodType: "unknown" }),
      /food type/i
    );
  });
});

describe("Catering service validation", () => {
  test("requires a catering service when requested", () => {
    assert.match(
      validateNewBooking(
        { ...VALID_BASE, cateringServices: [], cateringService: "" },
        { requireCateringServices: true }
      ),
      /catering service/i
    );
  });

  test("accepts a catering service array", () => {
    assert.equal(
      validateNewBooking(
        { ...VALID_BASE, cateringServices: ["cooking", "serving"] },
        { requireCateringServices: true }
      ),
      null
    );
  });

  test("accepts the singular cateringService field", () => {
    assert.equal(
      validateNewBooking(
        { ...VALID_BASE, cateringServices: [], cateringService: "cooking" },
        { requireCateringServices: true }
      ),
      null
    );
  });
});

describe("Payment balance calculation", () => {
  function calculateBalance(totalAmount, advanceAmount) {
    if (
      typeof totalAmount !== "number" ||
      typeof advanceAmount !== "number" ||
      !Number.isFinite(totalAmount) ||
      !Number.isFinite(advanceAmount) ||
      totalAmount < 0 ||
      advanceAmount < 0
    ) {
      throw new TypeError("Amounts must be non-negative finite numbers.");
    }

    if (advanceAmount > totalAmount) {
      throw new RangeError("Advance cannot exceed total.");
    }

    return Math.round((totalAmount - advanceAmount) * 100) / 100;
  }

  test("calculates balance", () => {
    assert.equal(calculateBalance(10000, 3000), 7000);
  });

  test("returns zero when fully paid", () => {
    assert.equal(calculateBalance(5000, 5000), 0);
  });

  test("rejects advance greater than total", () => {
    assert.throws(() => calculateBalance(1000, 2000), RangeError);
  });

  test("rejects negative amounts", () => {
    assert.throws(() => calculateBalance(-100, 0), TypeError);
  });

  test("rejects non-finite amounts", () => {
    assert.throws(() => calculateBalance(Infinity, 0), TypeError);
  });

  test("rounds decimal balances correctly", () => {
    assert.equal(calculateBalance(10000.5, 3333.33), 6667.17);
  });
});

describe("Bearer token parsing", () => {
  function extractBearerToken(authHeader) {
    if (
      typeof authHeader !== "string" ||
      !authHeader.startsWith("Bearer ")
    ) {
      return null;
    }

    const token = authHeader.slice(7).trim();
    return token || null;
  }

  test("extracts a valid Bearer token", () => {
    assert.equal(
      extractBearerToken("Bearer abc.def.ghi"),
      "abc.def.ghi"
    );
  });

  test("rejects a missing header", () => {
    assert.equal(extractBearerToken(undefined), null);
  });

  test("rejects a non-Bearer scheme", () => {
    assert.equal(extractBearerToken("Basic abc123"), null);
  });

  test("rejects an empty Bearer token", () => {
    assert.equal(extractBearerToken("Bearer "), null);
  });

  test("rejects a non-string header", () => {
    assert.equal(extractBearerToken(123), null);
  });
});
