
require("dotenv").config();

const app = require("./src/app");
const connectDB = require("./src/config/db");
const mongoose = require("mongoose");

const PORT = Number(process.env.PORT) || 5000;
const HOST = "0.0.0.0";

let server;
let isShuttingDown = false;

const shutdown = async (reason, exitCode = 0) => {
  if (isShuttingDown) return;

  isShuttingDown = true;

  console.log(`Shutting down server: ${reason}`);

  if (exitCode !== 0) {
    process.exitCode = exitCode;
  }

  if (server?.listening) {
    await new Promise((resolve) => {
      server.close((error) => {
        if (error) {
          console.error("HTTP server shutdown error:", error.message);
          process.exitCode = 1;
        }

        resolve();
      });
    });
  }

  try {
    if (mongoose.connection.readyState !== 0) {
      await mongoose.disconnect();
      console.log("MongoDB disconnected.");
    }
  } catch (error) {
    console.error("MongoDB shutdown error:", error.message);
    process.exitCode = 1;
  }

  if (reason === "SIGTERM" || reason === "SIGINT") {
    process.exit(process.exitCode || 0);
  }
};

const startServer = async () => {
  try {
    await connectDB();

    server = app.listen(PORT, HOST, () => {
      console.log(`Nivetha Catering API running on ${HOST}:${PORT}`);
      console.log("Health check: /api/health");
      console.log(
        `Environment: ${process.env.NODE_ENV || "development"}`
      );
    });

    server.on("error", (error) => {
      console.error("HTTP server error:", error.message);
      shutdown("server-error", 1).catch((shutdownError) => {
        console.error("Shutdown failed:", shutdownError.message);
        process.exit(1);
      });
    });
  } catch (error) {
    console.error("Server startup failed:", error.message);
    process.exitCode = 1;

    try {
      await shutdown("startup-error", 1);
    } catch (shutdownError) {
      console.error("Startup cleanup failed:", shutdownError.message);
      process.exit(1);
    }
  }
};

process.once("SIGTERM", () => {
  shutdown("SIGTERM").catch((error) => {
    console.error("SIGTERM shutdown failed:", error.message);
    process.exit(1);
  });
});

process.once("SIGINT", () => {
  shutdown("SIGINT").catch((error) => {
    console.error("SIGINT shutdown failed:", error.message);
    process.exit(1);
  });
});

startServer();
