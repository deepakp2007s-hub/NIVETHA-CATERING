
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });

const readline = require("readline");
const bcrypt = require("bcryptjs");
const mongoose = require("mongoose");

const connectDB = require("../src/config/db");
const Owner = require("../src/models/Owner");

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

const ask = (question) =>
  new Promise((resolve) =>
    rl.question(question, (answer) => resolve(answer.trim()))
  );

const getAllowedPhones = () =>
  [process.env.OWNER_PHONE_1, process.env.OWNER_PHONE_2]
    .filter(Boolean)
    .map((phone) => phone.trim());

const run = async () => {
  try {
    const allowedPhones = getAllowedPhones();

    if (
      allowedPhones.length !== 2 ||
      allowedPhones[0] === allowedPhones[1] ||
      allowedPhones.some((phone) => !/^[6-9]\d{9}$/.test(phone))
    ) {
      throw new Error(
        "Configure two different valid Indian phone numbers in OWNER_PHONE_1 and OWNER_PHONE_2 in .env."
      );
    }

    await connectDB();
    console.log(`\nConnected to database: ${mongoose.connection.name}`);

    const totalOwners = await Owner.countDocuments();

    if (totalOwners > 2) {
      throw new Error(
        `Database already contains ${totalOwners} owners. Review existing accounts before continuing.`
      );
    }

    for (let i = 0; i < allowedPhones.length; i += 1) {
      const phone = allowedPhones[i];

      console.log(`\n--- Configure allowed owner ${i + 1} of 2 ---`);
      console.log(`Phone: ${phone}`);

      const existing = await Owner.findOne({ phone }).select("+passwordHash");
      const name = await ask("Owner name: ");
      const password = await ask("Password (minimum 8 characters): ");

      if (
        !name ||
        name.length > 100 ||
        password.length < 8 ||
        password.length > 128
      ) {
        console.log("Skipped: check the name and password requirements.");
        continue;
      }

      if (existing) {
        const reset = (
          await ask("Account exists. Update name and reset password? (y/n): ")
        ).toLowerCase();

        if (reset !== "y") {
          console.log("Skipped.");
          continue;
        }

        existing.name = name;
        existing.passwordHash = await bcrypt.hash(password, 12);
        existing.isActive = true;
        await existing.save();

        console.log("Owner account updated.");
        continue;
      }

      const currentCount = await Owner.countDocuments();

      if (currentCount >= 2) {
        console.log(
          "Cannot create another owner: the database already contains two accounts."
        );
        continue;
      }

      await Owner.create({
        name,
        phone,
        passwordHash: await bcrypt.hash(password, 12),
        isActive: true,
      });

      console.log("Owner account created.");
    }

    const finalCount = await Owner.countDocuments();
    console.log(`\nTotal owner accounts in database: ${finalCount}`);
    console.log("Only the two configured phone numbers are allowed by the login allowlist.");
  } catch (error) {
    console.error("Failed:", error.message);
    process.exitCode = 1;
  } finally {
    rl.close();

    if (mongoose.connection.readyState !== 0) {
      await mongoose.connection.close();
    }
  }
};

run();
