#!/usr/bin/env node

/**
 * Simple MongoDB health check script
 * This script attempts to connect to MongoDB and perform a simple operation.
 * It can be used as a health check endpoint for services like Render.com.
 */

const { MongoClient } = require('mongodb');

// Default connection string for local testing
// This will be overridden by environment variables in production
const uri = process.env.MONGODB_URI || 'mongodb://mangandoUser:userPassword@localhost:27017/mangandoDB';

async function checkHealth() {
  const client = new MongoClient(uri, {
    serverSelectionTimeoutMS: 5000, // 5 seconds
    connectTimeoutMS: 5000
  });

  try {
    // Connect to the MongoDB server
    await client.connect();
    
    // Ping the database to check if connection is alive
    await client.db('admin').command({ ping: 1 });
    
    console.log('MongoDB connection successful');
    return true;
  } catch (err) {
    console.error('MongoDB health check failed:', err);
    return false;
  } finally {
    await client.close();
  }
}

// If this script is called directly
if (require.main === module) {
  checkHealth()
    .then(isHealthy => {
      if (isHealthy) {
        console.log('Health check passed');
        process.exit(0);
      } else {
        console.error('Health check failed');
        process.exit(1);
      }
    })
    .catch(err => {
      console.error('Error during health check:', err);
      process.exit(1);
    });
}

module.exports = { checkHealth }; 