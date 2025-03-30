// Create admin user
db.getSiblingDB("admin").createUser({
  user: "adminUser",
  pwd: process.env.MONGO_ADMIN_PASSWORD || "changeThisPassword",
  roles: [{ role: "userAdminAnyDatabase", db: "admin" }, "readWriteAnyDatabase"]
});

// Create application database and user
db.getSiblingDB(process.env.MONGO_INITDB_DATABASE || "mangandoDB").createUser({
  user: process.env.MONGO_APP_USER || "mangandoUser",
  pwd: process.env.MONGO_APP_PASSWORD || "changeThisPassword",
  roles: [{ role: "readWrite", db: process.env.MONGO_INITDB_DATABASE || "mangandoDB" }]
});

// Create collections (if needed)
db.getSiblingDB(process.env.MONGO_INITDB_DATABASE || "mangandoDB").createCollection("users");
db.getSiblingDB(process.env.MONGO_INITDB_DATABASE || "mangandoDB").createCollection("workspaces");
db.getSiblingDB(process.env.MONGO_INITDB_DATABASE || "mangandoDB").createCollection("agents");
db.getSiblingDB(process.env.MONGO_INITDB_DATABASE || "mangandoDB").createCollection("sessions"); 