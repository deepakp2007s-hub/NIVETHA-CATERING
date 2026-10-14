import {
  createContext,
  useCallback,
  useContext,
  useState,
} from "react";

const BookingContext = createContext(null);

const initialBooking = {
  eventType: "",
  functionDate: "",
  functionTime: "",
  location: "",
  numberOfPersons: "",
  extraRequirements: "",
  cateringServices: [],
  mealType: "",
  foodType: "",
  selectedFoods: [],
};

export function BookingProvider({ children }) {
  const [booking, setBooking] = useState(initialBooking);

  const updateBooking = useCallback((updates) => {
    setBooking((previous) => ({
      ...previous,
      ...updates,
    }));
  }, []);

  const resetBooking = useCallback(() => {
    setBooking({ ...initialBooking });
  }, []);

  const value = {
    booking,
    setBooking,
    updateBooking,
    resetBooking,
  };

  return (
    <BookingContext.Provider value={value}>
      {children}
    </BookingContext.Provider>
  );
}

export function useBooking() {
  const context = useContext(BookingContext);

  if (!context) {
    throw new Error("useBooking must be used inside BookingProvider");
  }

  return context;
}
