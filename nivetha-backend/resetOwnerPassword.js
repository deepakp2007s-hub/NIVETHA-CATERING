require("dotenv").config();

const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const Owner = require("./src/models/Owner");
const readline = require("readline");

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

const ask = (question) =>
  new Promise((resolve) => rl.question(question, resolve));

async function main() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);

    const phone = (await ask("Enter owner phone number: ")).trim();
    const password = await ask("Enter NEW owner password: ");

    if (!phone || password.length < 8) {
      throw new Error(
        "Phone is required and password must contain at least 8 characters."
      );
    }

    const owner = await Owner.findOne({ phone }).select("+passwordHash");

    if (!owner) {
      throw new Error(
        "Owner account not found. Check the phone number in MongoDB."
      );
    }

    owner.passwordHash = await bcrypt.hash(password, 12);
    await owner.save();

    console.log("Owner password updated successfully!");
  } catch (error) {
    console.error("Password reset failed:", error.message);
  } finally {
    rl.close();
    await mongoose.disconnect();
  }
}

main();
