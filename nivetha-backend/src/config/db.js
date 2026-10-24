import mongoose from 'mongoose';

/**
 * Connect to MongoDB Atlas with robust connection handling,
 * auto-reconnect, and safe logging (hiding credentials).
 */
export const connectDB = async () => {
  const uri = process.env.MONGODB_URI;

  if (!uri) {
    console.warn('⚠️ [MongoDB] MONGODB_URI not found in environment variables. Running in in-memory/test fallback mode.');
    return false;
  }

  // Safe URI for logging (mask password)
  const maskedUri = uri.replace(/\/\/([^:]+):([^@]+)@/, '//$1:****@');

  try {
    const conn = await mongoose.connect(uri, {
      serverSelectionTimeoutMS: 8000,
      socketTimeoutMS: 45000,
    });

    console.log(`✅ [MongoDB] Connected successfully to host: ${conn.connection.host}`);
    return true;
  } catch (error) {
    console.error(`❌ [MongoDB] Connection error (${maskedUri}):`, error.message);
    return false;
  }
};

mongoose.connection.on('disconnected', () => {
  console.warn('⚠️ [MongoDB] Disconnected from MongoDB cluster.');
});

mongoose.connection.on('reconnected', () => {
  console.log('🔄 [MongoDB] Reconnected to MongoDB cluster.');
});

export default connectDB;
