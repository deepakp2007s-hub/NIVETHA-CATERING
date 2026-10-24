import dotenv from 'dotenv';
dotenv.config();

import mongoose from 'mongoose';
import connectDB from '../src/config/db.js';
import Owner from '../src/models/Owner.js';
import { normalizePhone } from '../src/controllers/authController.js';

/**
 * Script to safely provision the two authorized Owner accounts for Nivetha Catering Service.
 * Preserves existing accounts and does not reset passwords unexpectedly.
 */
const provisionOwners = async () => {
  console.log('🚀 [Nivetha Catering] Starting Owner Provisioning...');

  const connected = await connectDB();
  if (!connected && !process.env.MONGODB_URI) {
    console.error('❌ MONGODB_URI is required to run owner provisioning.');
    process.exit(1);
  }

  // Pre-configured authorized owner definitions (can be overridden via environment variables)
  const authorizedOwners = [
    {
      name: process.env.OWNER_1_NAME || 'Nivetha Chief Owner',
      phone: normalizePhone(process.env.OWNER_1_PHONE || '9677880164'),
      password: process.env.OWNER_1_PASSWORD || 'NivethaOwner@2026',
    },
    {
      name: process.env.OWNER_2_NAME || 'Operations Manager Owner',
      phone: normalizePhone(process.env.OWNER_2_PHONE || '8807669855'),
      password: process.env.OWNER_2_PASSWORD || 'NivethaOps@2026',
    },
  ];

  let createdCount = 0;
  let skippedCount = 0;

  for (const ownerData of authorizedOwners) {
    try {
      const existing = await Owner.findOne({ phone: ownerData.phone });

      if (existing) {
        console.log(`ℹ️ [Owner Exists] Owner "${existing.name}" (${ownerData.phone}) already exists. Password preserved.`);
        skippedCount++;
      } else {
        await Owner.create({
          name: ownerData.name,
          phone: ownerData.phone,
          password: ownerData.password,
          role: 'owner',
          isAuthorized: true,
        });
        console.log(`✅ [Created] Authorized Owner account created for: ${ownerData.name} (${ownerData.phone})`);
        createdCount++;
      }
    } catch (err) {
      console.error(`❌ Error provisioning owner ${ownerData.phone}:`, err.message);
    }
  }

  console.log('\n======================================');
  console.log(`📊 Owner Provisioning Complete:`);
  console.log(`   - Created: ${createdCount}`);
  console.log(`   - Skipped (already exist): ${skippedCount}`);
  console.log('======================================\n');

  if (mongoose.connection.readyState === 1) {
    await mongoose.connection.close();
  }
  process.exit(0);
};

provisionOwners();
