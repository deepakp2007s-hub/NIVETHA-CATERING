
import dotenv from 'dotenv';
dotenv.config();

import mongoose from 'mongoose';
import connectDB from '../src/config/db.js';
import Owner from '../src/models/Owner.js';
import { normalizePhone } from '../src/controllers/authController.js';

const provisionOwners = async () => {
  console.log('[Nivetha Catering] Starting owner provisioning...');

  try {
    const requiredVariables = [
      'MONGODB_URI',
      'OWNER_1_PHONE',
      'OWNER_1_PASSWORD',
      'OWNER_2_PHONE',
      'OWNER_2_PASSWORD',
    ];

    const missing = requiredVariables.filter(
      (key) => !process.env[key]?.trim()
    );

    if (missing.length > 0) {
      throw new Error(
        `Missing required environment variables: ${missing.join(', ')}`
      );
    }

    const owners = [
      {
        name: process.env.OWNER_1_NAME || 'Nivetha Chief Owner',
        phone: normalizePhone(process.env.OWNER_1_PHONE),
        password: process.env.OWNER_1_PASSWORD,
      },
      {
        name: process.env.OWNER_2_NAME || 'Operations Manager Owner',
        phone: normalizePhone(process.env.OWNER_2_PHONE),
        password: process.env.OWNER_2_PASSWORD,
      },
    ];

    for (const owner of owners) {
      if (!/^\d{10}$/.test(owner.phone)) {
        throw new Error(
          `Owner phone must be a valid 10-digit Indian number: ${owner.name}`
        );
      }

      if (owner.password.length < 6) {
        throw new Error(
          `Owner password must contain at least 6 characters: ${owner.name}`
        );
      }
    }

    if (owners[0].phone === owners[1].phone) {
      throw new Error('Owner phone numbers must be different.');
    }

    await connectDB();

    if (mongoose.connection.readyState !== 1) {
      throw new Error('MongoDB connection failed.');
    }

    let createdCount = 0;
    let skippedCount = 0;

    for (const data of owners) {
      const existing = await Owner.findOne({ phone: data.phone });

      if (existing) {
        console.log(
          `[Skipped] Owner account already exists: ${existing.name}. Existing password preserved.`
        );
        skippedCount++;
        continue;
      }

      await Owner.create({
        name: data.name,
        phone: data.phone,
        password: data.password,
        role: 'owner',
        isAuthorized: true,
      });

      console.log(`[Created] Owner account: ${data.name}`);
      createdCount++;
    }

    console.log('\nOwner provisioning completed.');
    console.log(`Created: ${createdCount}`);
    console.log(`Skipped: ${skippedCount}`);
  } catch (error) {
    console.error('Owner provisioning failed:', error.message);
    process.exitCode = 1;
  } finally {
    if (mongoose.connection.readyState !== 0) {
      await mongoose.connection.close().catch((error) => {
        console.error('MongoDB disconnect error:', error.message);
      });
    }
  }
};

provisionOwners();
