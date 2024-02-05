// Create a new user with read and write permissions for the specified database

// Specify the database to use
db = db.getSiblingDB('admin');

db.createUser({
    user: "myuser",
    pwd: "mypassword",
    roles: [
      { role: "readWrite", db: "mydatabase" }
    ]
  });
  