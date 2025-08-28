import ballerinax/mongodb;
import ballerina/io;
import ballerina/time;

// Configuration variables
configurable string MONGO_URI = ?;

// Global MongoDB client
mongodb:Client mongoDb = check new ({
    connection: MONGO_URI
});

// Database and collection configuration
const string DATABASE_NAME = "volunthere";
const string USER_COLLECTION = "users";

// User model
public type User record {|
    string? _id?;        // Optional MongoDB ObjectId (auto-generated)
    string name;         // User's full name
    string email;        // Unique email for login
    string passwordHash; // Hashed password (never plain text)
    string role;         // "volunteer" or "organizer"
    time:Utc createdAt;  // Registration timestamp
|};

// Initialize MongoDB connection and setup
public function initMongoDB() returns error? {
    // Create unique index for email field
    check createEmailIndex();
    io:println("✅ MongoDB connection initialized successfully");
}

// Function to create unique index on email field (should be called once during setup)
function createEmailIndex() returns error? {
    mongodb:Database database = check mongoDb->getDatabase(DATABASE_NAME);
    mongodb:Collection userCollection = check database->getCollection(USER_COLLECTION);
    
    // Create unique index on email field
    map<json> keys = {"email": 1};
    mongodb:CreateIndexOptions options = {"unique": true};
    mongodb:Error? result = userCollection->createIndex(keys, options);
    
    if result is mongodb:Error {
        io:println("Warning: Could not create unique index for email: " + result.message());
        return result;
    } else {
        io:println("✅ Unique index created for email field");
    }
    
    return ();
}

// Get user collection
public function getUserCollection() returns mongodb:Collection|error {
    mongodb:Database database = check mongoDb->getDatabase(DATABASE_NAME);
    return check database->getCollection(USER_COLLECTION);
}

// Close MongoDB connection
public function closeMongoDB() returns error? {
    check mongoDb->close();
    io:println("✅ MongoDB connection closed");
}
