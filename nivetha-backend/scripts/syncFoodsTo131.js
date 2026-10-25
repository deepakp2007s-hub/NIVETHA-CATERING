
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import { mkdir, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { initial131Foods } from './seedTamilNaduFoods.js';

dotenv.config();

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const confirmed = process.argv.includes('--confirm-replace-catalog');

async function syncFoodsTo131() {
  const mongoUri = process.env.MONGODB_URI;

  if (!mongoUri) {
    throw new Error('MONGODB_URI missing. Check nivetha-backend/.env');
  }

  if (initial131Foods.length !== 131) {
    throw new Error(`Expected 131 catalog items, got ${initial131Foods.length}`);
  }

  const names = initial131Foods.map((food) =>
    String(food.name).trim().toLowerCase()
  );

  if (new Set(names).size !== 131) {
    throw new Error('Catalog contains duplicate names. No changes made.');
  }

  if (!confirmed) {
    console.log('DRY RUN: No database changes made.');
    console.log('Canonical catalog items:', initial131Foods.length);
    console.log(
      'To back up and replace the foods collection, run:'
    );
    console.log('node scripts/syncFoodsTo131.js --confirm-replace-catalog');
    console.log(
      'WARNING: This replaces all current food documents with the 131 catalog items.'
    );
    return;
  }

  try {
    await mongoose.connect(mongoUri);

    const collection = mongoose.connection.collection('foods');
    const existingFoods = await collection.find({}).toArray();

    // Create a local backup before changing anything.
    const backupDir = path.join(__dirname, '..', 'backups');
    await mkdir(backupDir, { recursive: true });

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const backupPath = path.join(
      backupDir,
      `foods-backup-${timestamp}.json`
    );

    await writeFile(
      backupPath,
      JSON.stringify(existingFoods, null, 2),
      'utf8'
    );

    console.log('Backup saved:', backupPath);
    console.log('Existing food documents:', existingFoods.length);

    try {
      await collection.deleteMany({});
      await collection.insertMany(initial131Foods);

      const finalCount = await collection.countDocuments();

      if (finalCount !== 131) {
        throw new Error(`Verification failed: expected 131, got ${finalCount}`);
      }

      console.log('\nSUCCESS: Food catalog synchronized.');
      console.log('Final food count:', finalCount);
      console.log('Backup retained at:', backupPath);
    } catch (error) {
      console.error('Sync failed. Attempting to restore the backup...');

      await collection.deleteMany({});

      if (existingFoods.length > 0) {
        await collection.insertMany(existingFoods);
      }

      console.error('Previous food documents were restored.');
      throw error;
    }
  } finally {
    await mongoose.disconnect();
  }
}

syncFoodsTo131().catch((error) => {
  console.error('\nFood catalog sync failed:', error.message);
  process.exitCode = 1;
});
