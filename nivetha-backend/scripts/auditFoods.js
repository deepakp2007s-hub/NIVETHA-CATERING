
import mongoose from 'mongoose';
import dotenv from 'dotenv';

dotenv.config();

async function auditDuplicateFoods() {
  if (!process.env.MONGODB_URI) {
    throw new Error('MONGODB_URI missing from .env');
  }

  try {
    await mongoose.connect(process.env.MONGODB_URI);

    const foods = await mongoose.connection
      .collection('foods')
      .find({})
      .project({ name: 1, tamilName: 1, category: 1, type: 1 })
      .toArray();

    const groups = new Map();

    for (const food of foods) {
      const key = String(food.name ?? '')
        .trim()
        .toLowerCase()
        .replace(/\s+/g, ' ');

      if (!groups.has(key)) groups.set(key, []);
      groups.get(key).push(food);
    }

    const duplicates = [...groups.entries()].filter(
      ([name, items]) => name && items.length > 1
    );

    console.log('\nTotal documents:', foods.length);
    console.log('Duplicate name groups:', duplicates.length);
    console.log(
      'Documents belonging to duplicate groups:',
      duplicates.reduce((sum, [, items]) => sum + items.length, 0)
    );

    for (const [name, items] of duplicates) {
      console.log(`\n${name} (${items.length} documents)`);

      for (const food of items) {
        console.log(
          `  ID: ${food._id} | Name: ${food.name} | Tamil: ${
            food.tamilName ?? 'N/A'
          } | Category: ${food.category ?? 'N/A'} | Type: ${
            food.type ?? 'N/A'
          }`
        );
      }
    }

    console.log('\nRead-only audit complete. No records changed.');
  } catch (error) {
    console.error('Audit failed:', error.message);
    process.exitCode = 1;
  } finally {
    await mongoose.disconnect();
  }
}

auditDuplicateFoods();
