// Create admin user
db = db.getSiblingDB('admin');
try {
  db.createUser({
    user: process.env.MONGO_ADMIN_USER || "adminUser",
    pwd: process.env.MONGO_ADMIN_PASSWORD || "changeThisPassword",
    roles: [{ role: "userAdminAnyDatabase", db: "admin" }, "readWriteAnyDatabase"]
  });
  print("Admin user created successfully");
} catch (error) {
  print("Admin user might already exist or couldn't be created: " + error.message);
}

// Create application database and user
const dbName = process.env.MONGO_INITDB_DATABASE || "mangandoDB";
db = db.getSiblingDB(dbName);

try {
  db.createUser({
    user: process.env.MONGO_APP_USER || "mangandoUser",
    pwd: process.env.MONGO_APP_PASSWORD || "changeThisPassword",
    roles: [{ role: "readWrite", db: dbName }]
  });
  print("Application user created successfully");
} catch (error) {
  print("Application user might already exist or couldn't be created: " + error.message);
}

// Create collections (if needed)
try {
  db.createCollection("users");
  print("Collection 'users' created");
} catch (error) {
  print("Collection 'users' might already exist: " + error.message);
}

try {
  db.createCollection("workspaces");
  print("Collection 'workspaces' created");
} catch (error) {
  print("Collection 'workspaces' might already exist: " + error.message);
}

try {
  db.createCollection("agents");
  print("Collection 'agents' created");
} catch (error) {
  print("Collection 'agents' might already exist: " + error.message);
}

try {
  db.createCollection("sessions");
  print("Collection 'sessions' created");
} catch (error) {
  print("Collection 'sessions' might already exist: " + error.message);
}

print("MongoDB initialization completed"); 