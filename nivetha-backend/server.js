
import dotenv from 'dotenv';

dotenv.config();

import app from './src/app.js';
import connectDB from './src/config/db.js';

const PORT = Number(process.env.PORT) || 5000;
const HOST = '0.0.0.0';

const startServer = async () => {
  try {
    await connectDB();

    const server = app.listen(PORT, HOST, () => {
      console.log('==============================================');
      console.log('Nivetha Catering Service Backend');
      console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`Port: ${PORT}`);
      console.log(`Health Check: http://localhost:${PORT}/api/health`);
      console.log('MongoDB: Connected');
      console.log('Server Status: Running');
      console.log('==============================================');
    });

    server.on('error', (error) => {
      console.error('Backend server error:', error.message);
      process.exit(1);
    });
  } catch (error) {
    console.error('Backend startup failed:', error.message);
    process.exit(1);
  }
};

startServer();
