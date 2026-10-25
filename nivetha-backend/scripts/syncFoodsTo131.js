
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import { initial131Foods } from './seedTamilNaduFoods.js';
import Food from '../src/models/Food.js';

dotenv.config();

async function syncFoodsTo131() {
  const mongoUri = process.env.MONGODB_URI;

  if (!mongoUri) {
    throw new Error('MONGODB_URI missing. Check nivetha-backend/.env');
  }

  if (!Array.isArray(initial131Foods) || initial131Foods.length !== 131) {
    throw new Error(
      `Expected 131 food items, got ${
        Array.isArray(initial131Foods) ? initial131Foods.length : 'invalid dataset'
      }`
    );
  }

  const names = initial131Foods.map((food) =>
    String(food.name ?? '').trim().toLowerCase()
  );

  if (names.some((name) => !name)) {
    throw new Error('A food item has an empty name.');
  }

  if (new Set(names).size !== 131) {
    throw new Error('Duplicate food names found. No changes made.');
  }

  await mongoose.connect(mongoUri);

  try {
    let inserted = 0;
    let updated = 0;

    for (const item of initial131Foods) {
      const name = item.name.trim();

      const foodData = {
        name,
        tamilName: item.tamilName ?? '',
        category: item.category,
        type: item.type,
        description: item.description ?? '',
        imageUrl: item.imageUrl ?? '',
        isSeeded: true,
        isAvailable: item.isAvailable ?? true
      };

      const existing = await Food.findOne({
        name: { $regex: `^${name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, $options: 'i' }
      });

      if (existing) {
        await Food.updateOne(
          { _id: existing._id },
          { $set: foodData },
          { runValidators: true }
        );
        updated++;
      } else {
        await Food.create(foodData);
        inserted++;
      }
    }

    const total = await Food.countDocuments();

    console.log('Food catalog sync completed.');
    console.log('Catalog items:', initial131Foods.length);
    console.log('Inserted:', inserted);
    console.log('Updated:', updated);
    console.log('Total food records in database:', total);
    console.log('Existing extra food records were preserved.');
  } finally {
    await mongoose.disconnect();
    console.log('MongoDB disconnected.');
  }
}

syncFoodsTo131().catch((error) => {
  console.error('Food catalog sync failed:', error.message);
  process.exitCode = 1;
});
