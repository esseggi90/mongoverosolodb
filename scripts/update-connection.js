#!/usr/bin/env node

/**
 * This script helps update the MongoDB connection string in your main application.
 * Usage: node update-connection.js <service-url> <password>
 */

const fs = require('fs');
const path = require('path');

// Get the service URL and password from command line arguments
const serviceUrl = process.argv[2];
const password = process.argv[3];

if (!serviceUrl || !password) {
  console.error('Usage: node update-connection.js <service-url> <password>');
  process.exit(1);
}

// Create the new MongoDB connection string
const connectionString = `mongodb://mangandoUser:${password}@${serviceUrl}:27017/mangandoDB`;

console.log('New connection string:');
console.log(connectionString);

// Locations to check for a .env file (relative to this script)
const possibleEnvLocations = [
  '../.env',
  '../../.env',
  '../../backend/.env'
];

let envFileFound = false;

for (const location of possibleEnvLocations) {
  const envPath = path.resolve(__dirname, location);
  
  try {
    if (fs.existsSync(envPath)) {
      // Read the .env file
      let envContent = fs.readFileSync(envPath, 'utf8');
      
      // Replace the MONGODB_URI line or add it if it doesn't exist
      if (envContent.includes('MONGODB_URI=')) {
        envContent = envContent.replace(/MONGODB_URI=.*$/m, `MONGODB_URI=${connectionString}`);
      } else {
        envContent += `\nMONGODB_URI=${connectionString}`;
      }
      
      // Write the updated content back to the .env file
      fs.writeFileSync(envPath, envContent);
      
      console.log(`Updated MongoDB connection string in ${envPath}`);
      envFileFound = true;
      break;
    }
  } catch (error) {
    console.error(`Error checking ${envPath}:`, error);
  }
}

if (!envFileFound) {
  console.log('\nNo .env file found. To update your application:');
  console.log('1. Set the MONGODB_URI environment variable to:');
  console.log(`   ${connectionString}`);
  console.log('2. Or add it to your .env file as:');
  console.log(`   MONGODB_URI=${connectionString}`);
} 