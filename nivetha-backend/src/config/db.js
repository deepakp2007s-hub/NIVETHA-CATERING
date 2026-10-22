
const mongoose = require("mongoose");

let listenersRegistered = false;

const connectDB = async () => {
  const mongoURI = process.env.MONGODB_URI;

  if (!mongoURI || !mongoURI.trim()) {
    throw new Error("MONGODB_URI is missing in environment variables");
  }

  try {
    if (mongoose.connection.readyState === 1) {
      console.log("MongoDB is already connected");
      console.log("Database:", mongoose.connection.name);
      return mongoose.connection;
    }

    await mongoose.connect(mongoURI, {
      serverSelectionTimeoutMS: 10000,
      connectTimeoutMS: 10000,
      socketTimeoutMS: 45000,
      maxPoolSize: 20,
      minPoolSize: 0,
      maxIdleTimeMS: 60000,
    });

    console.log("MongoDB connected successfully");
    console.log("Database:", mongoose.connection.name);

    if (!listenersRegistered) {
      mongoose.connection.on("error", (error) => {
        console.error("MongoDB connection error:", error.message);
      });

      mongoose.connection.on("disconnected", () => {
        console.warn("MongoDB disconnected");
      });

      mongoose.connection.on("reconnected", () => {
        console.log("MongoDB reconnected successfully");
      });

      listenersRegistered = true;
    }

    return mongoose.connection;
  } catch (error) {
    console.error("MongoDB connection failed:", error.message);
    throw error;
  }
};

module.exports = connectDB;
