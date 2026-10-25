
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import mongoose from 'mongoose';

import authRoutes from './routes/authRoutes.js';
import customerAuthRoutes from './routes/customerAuthRoutes.js';
import customerRoutes from './routes/customerRoutes.js';
import foodRoutes from './routes/foodRoutes.js';
import bookingRoutes from './routes/bookingRoutes.js';
import dashboardRoutes from './routes/dashboardRoutes.js';
import reportRoutes from './routes/reportRoutes.js';
import notificationRoutes from './routes/notificationRoutes.js';
import reviewRoutes from './routes/reviewRoutes.js';

import notFoundMiddleware from './middleware/notFoundMiddleware.js';
import errorMiddleware from './middleware/errorMiddleware.js';

const app = express();

app.disable('x-powered-by');
app.set('trust proxy', 1);

app.use(
  helmet({
    crossOriginEmbedderPolicy: false,
  })
);

const normalizeOrigin = (origin) =>
  String(origin || '')
    .trim()
    .replace(/^["']|["']$/g, '')
    .replace(/\/+$/, '');

const productionOrigins = [
  'https://nivetha-catering.vercel.app',
  'https://nivetha-catering-kjh1.vercel.app',
];

const configuredOrigins = [
  process.env.CLIENT_URL,
  process.env.CUSTOMER_URL,
  process.env.OWNER_URL,
]
  .filter(Boolean)
  .flatMap((value) => value.split(','))
  .map(normalizeOrigin)
  .filter(Boolean);

const allowedOrigins = new Set([
  ...productionOrigins,
  ...configuredOrigins,
  'http://localhost:3000',
  'http://localhost:5173',
  'http://localhost:5174',
  'http://127.0.0.1:3000',
  'http://127.0.0.1:5173',
  'http://127.0.0.1:5174',
]);

const isFlutterWebLocalOrigin = (origin) =>
  /^http:\/\/(localhost|127\.0\.0\.1):\d+$/.test(origin);

app.use(
  cors({
    origin(origin, callback) {
      // Allow requests without an Origin header, such as server-to-server
      // calls and local command-line API tests.
      if (!origin) {
        return callback(null, true);
      }

      const normalizedOrigin = normalizeOrigin(origin);

      if (
        allowedOrigins.has(normalizedOrigin) ||
        isFlutterWebLocalOrigin(normalizedOrigin)
      ) {
        return callback(null, true);
      }

      const error = new Error('Origin not allowed by CORS');
      error.status = 403;
      return callback(error);
    },
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
    optionsSuccessStatus: 204,
  })
);

app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

app.get('/api/health', (req, res) => {
  const databaseConnected = mongoose.connection.readyState === 1;

  return res.status(databaseConnected ? 200 : 503).json({
    success: databaseConnected,
    message: databaseConnected
      ? 'Nivetha Catering API is running'
      : 'API is running, but database is not connected',
    database: databaseConnected ? 'connected' : 'disconnected',
    timestamp: new Date().toISOString(),
  });
});

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 300,
  standardHeaders: 'draft-8',
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many requests. Please try again later.',
  },
});

app.use('/api', apiLimiter);

app.get('/api', (req, res) => {
  return res.json({
    success: true,
    name: 'Nivetha Catering Service API',
    version: '1.0.0',
    endpoints: {
      ownerAuth: '/api/auth',
      customerAuth: '/api/customer-auth',
      bookings: '/api/bookings',
      customers: '/api/customers',
      foods: '/api/foods',
      dashboard: '/api/dashboard',
      notifications: '/api/notifications',
      reports: '/api/reports',
      reviews: '/api/reviews',
    },
    health: '/api/health',
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/customer-auth', customerAuthRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/foods', foodRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/reviews', reviewRoutes);

app.use(notFoundMiddleware);
app.use(errorMiddleware);

export default app;
