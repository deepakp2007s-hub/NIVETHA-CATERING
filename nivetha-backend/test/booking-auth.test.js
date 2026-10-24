import jwt from 'jsonwebtoken';
import { normalizePhone } from '../nivetha-backend/src/controllers/authController.js';
import { initial42Foods } from '../nivetha-backend/scripts/seedTamilNaduFoods.js';

/**
 * Root Test Runner mirroring nivetha-backend test
 */
const runTests = async () => {
  console.log('\n🧪 ========================================================');
  console.log('🧪 NIVETHA CATERING SERVICE — ROOT VALIDATION TEST SUITE');
  console.log('🧪 ========================================================\n');

  let passed = 0;
  let failed = 0;

  const assert = (condition, testName) => {
    if (condition) {
      console.log(`  ✅ PASS: ${testName}`);
      passed++;
    } else {
      console.error(`  ❌ FAIL: ${testName}`);
      failed++;
    }
  };

  // 1. Phone Normalization Tests
  console.log('🔹 Test Suite 1: Phone Normalization & Input Flexibility');
  assert(normalizePhone('9876543210') === '9876543210', 'Standard 10-digit phone normalized');
  assert(normalizePhone('+919876543210') === '9876543210', '+91 prefix stripped');
  assert(normalizePhone('919876543210') === '9876543210', '91 prefix stripped');
  assert(normalizePhone(' 98765-43210 ') === '9876543210', 'Hyphens and spaces removed');
  assert(normalizePhone('(987) 654-3210') === '9876543210', 'Parentheses and spaces sanitized');

  // 2. JWT Generation & Role Isolation Tests
  console.log('\n🔹 Test Suite 2: JWT Security & Strict Role Isolation');
  const secret = 'nivetha_test_jwt_secret_2026';
  const ownerToken = jwt.sign({ id: 'owner_123', role: 'owner' }, secret, { expiresIn: '1h' });
  const customerToken = jwt.sign({ id: 'cust_456', role: 'customer' }, secret, { expiresIn: '1h' });

  const decodedOwner = jwt.verify(ownerToken, secret);
  const decodedCustomer = jwt.verify(customerToken, secret);

  assert(decodedOwner.role === 'owner', 'Owner token contains role "owner"');
  assert(decodedCustomer.role === 'customer', 'Customer token contains role "customer"');
  assert(decodedCustomer.role !== 'owner', 'Customer token is strictly distinct from owner role');

  // 3. Exactly 42 Tamil Nadu Catering Foods Verification
  console.log('\n🔹 Test Suite 3: 42 Tamil Nadu Catering Food Catalog Audit');
  assert(initial42Foods.length === 42, `Catalog contains exactly 42 food items (Found: ${initial42Foods.length})`);
  assert(initial42Foods.filter((f) => f.type === 'veg').length === 18, 'Catalog has exactly 18 Vegetarian items');
  assert(initial42Foods.filter((f) => f.type === 'non-veg').length === 14, 'Catalog has exactly 14 Non-Vegetarian items');
  assert(initial42Foods.filter((f) => f.type === 'sweet').length === 10, 'Catalog has exactly 10 Sweets & Desserts');

  console.log('\n======================================');
  console.log(`📊 Test Summary: ${passed} Passed, ${failed} Failed`);
  console.log('======================================\n');
};

runTests();
