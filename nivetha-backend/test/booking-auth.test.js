
import test from 'node:test';
import assert from 'node:assert/strict';
import jwt from 'jsonwebtoken';
import { normalizePhone } from '../src/controllers/authController.js';

// Test Suite 1: Phone normalization
test('Phone normalization tests', async (t) => {
  const cases = [
    ['9876543210', '9876543210'],
    ['+919876543210', '9876543210'],
    ['919876543210', '9876543210'],
    [' 98765-43210 ', '9876543210'],
    ['(987) 654-3210', '9876543210'],
  ];

  for (const [input, expected] of cases) {
    await t.test(`normalizePhone(${JSON.stringify(input)})`, () => {
      assert.equal(normalizePhone(input), expected);
    });
  }
});

// Test Suite 2: JWT role isolation
test('JWT generation and role isolation', () => {
  const secret = 'nivetha_test_jwt_secret_2026';

  const ownerToken = jwt.sign(
    { id: 'owner_123', role: 'owner' },
    secret,
    { expiresIn: '1h' }
  );

  const customerToken = jwt.sign(
    { id: 'cust_456', role: 'customer' },
    secret,
    { expiresIn: '1h' }
  );

  const decodedOwner = jwt.verify(ownerToken, secret);
  const decodedCustomer = jwt.verify(customerToken, secret);

  assert.equal(decodedOwner.role, 'owner');
  assert.equal(decodedCustomer.role, 'customer');
  assert.notEqual(decodedCustomer.role, 'owner');
});

// Test Suite 3: Food catalogue model
test('Food model does not define a price field', async () => {
  const { default: Food } = await import('../src/models/Food.js');

  assert.ok(Food, 'Food model should be importable');
  assert.equal(
    Food.schema.path('price'),
    undefined,
    'Food schema should not define price'
  );
});

test('Food model supports required catalogue fields', async () => {
  const { default: Food } = await import('../src/models/Food.js');

  for (const field of [
    'name',
    'tamilName',
    'category',
    'type',
    'description',
    'image',
    'available',
  ]) {
    assert.ok(
      Food.schema.path(field),
      `Food schema should define ${field}`
    );
  }
});
