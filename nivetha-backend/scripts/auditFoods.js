
import mongoose from 'mongoose';
import dotenv from 'dotenv';

dotenv.config();

const ALLOWED_CATEGORIES = [
  'Breakfast',
  'Meals',
  'Rice',
  'Veg Gravy',
  'Non-Veg Gravy',
  'Biryani',
  'Starter',
  'Seafood',
  'Bread',
  'Sweets'
];

const ALLOWED_TYPES = ['Veg', 'Non-Veg'];

async function auditFoods() {
  if (!process.env.MONGODB_URI) {
    throw new Error('MONGODB_URI missing from backend .env');
  }

  try {
    await mongoose.connect(process.env.MONGODB_URI);

    const foods = await mongoose.connection
      .collection('foods')
      .find({})
      .project({
        name: 1,
        tamilName: 1,
        category: 1,
        type: 1,
        imageUrl: 1,
        isAvailable: 1
      })
      .toArray();

    const duplicateGroups = new Map();
    const issues = [];

    for (const food of foods) {
      const normalizedName = String(food.name ?? '')
        .trim()
        .toLowerCase()
        .replace(/\s+/g, ' ');

      if (!normalizedName) {
        issues.push({
          id: food._id,
          name: food.name,
          issue: 'Missing food name'
        });
      } else {
        if (!duplicateGroups.has(normalizedName)) {
          duplicateGroups.set(normalizedName, []);
        }

        duplicateGroups.get(normalizedName).push(food);
      }

      if (!food.category) {
        issues.push({
          id: food._id,
          name: food.name,
          issue: 'Missing category'
        });
      } else if (!ALLOWED_CATEGORIES.includes(food.category)) {
        issues.push({
          id: food._id,
          name: food.name,
          issue: `Invalid category: ${food.category}`
        });
      }

      if (!ALLOWED_TYPES.includes(food.type)) {
        issues.push({
          id: food._id,
          name: food.name,
          issue: `Invalid type: ${food.type ?? 'missing'}`
        });
      }

      if (typeof food.isAvailable !== 'boolean') {
        issues.push({
          id: food._id,
          name: food.name,
          issue: 'Missing or invalid isAvailable'
        });
      }

      if (food.imageUrl) {
        try {
          const url = new URL(food.imageUrl);

          if (!['https:', 'http:'].includes(url.protocol)) {
            throw new Error('Invalid protocol');
          }
        } catch {
          issues.push({
            id: food._id,
            name: food.name,
            issue: `Invalid imageUrl: ${food.imageUrl}`
          });
        }
      } else {
        issues.push({
          id: food._id,
          name: food.name,
          issue: 'Missing imageUrl'
        });
      }
    }

    const duplicates = [...duplicateGroups.entries()].filter(
      ([name, items]) => name && items.length > 1
    );

    const vegCount = foods.filter(
      (food) => food.type === 'Veg'
    ).length;

    const nonVegCount = foods.filter(
      (food) => food.type === 'Non-Veg'
    ).length;

    const availableCount = foods.filter(
      (food) => food.isAvailable === true
    ).length;

    console.log('\n========== FOOD CATALOG AUDIT ==========');
    console.log('Total food documents:', foods.length);
    console.log('Expected canonical items:', 131);
    console.log('Count matches 131:', foods.length === 131);
    console.log('Veg items:', vegCount);
    console.log('Non-Veg items:', nonVegCount);
    console.log('Available items:', availableCount);
    console.log('Duplicate name groups:', duplicates.length);
    console.log('Food data issues:', issues.length);

    if (duplicates.length > 0) {
      console.log('\n--- DUPLICATE FOOD NAMES ---');

      for (const [name, items] of duplicates) {
        console.log(`\n${name} (${items.length} records)`);

        for (const food of items) {
          console.log(
            `ID: ${food._id} | Name: ${food.name} | Category: ${food.category}`
          );
        }
      }
    }

    if (issues.length > 0) {
      console.log('\n--- FOOD DATA ISSUES ---');

      for (const item of issues) {
        console.log(
          `ID: ${item.id} | Name: ${item.name ?? 'N/A'} | Issue: ${item.issue}`
        );
      }
    }

    if (duplicates.length === 0 && issues.length === 0) {
      console.log('\nPASS: No duplicate names or schema data issues found.');
    } else {
      console.log('\nCHECK: Review the issues listed above.');
    }

    console.log('\nRead-only audit complete. No records changed.');
  } catch (error) {
    console.error('Food audit failed:', error.message);
    process.exitCode = 1;
  } finally {
    if (mongoose.connection.readyState !== 0) {
      await mongoose.disconnect();
    }
  }
}

auditFoods();
