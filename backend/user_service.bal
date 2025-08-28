import ballerinax/mongodb;
import ballerina/http;
import ballerina/crypto;
import ballerina/jwt;
import ballerina/time;

// Configuration
configurable string JWT_SECRET = ?;

// Request/Response types
public type RegisterRequest record {|
    string name;
    string email;
    string password;
    string role; // "volunteer" or "organizer"
|};

public type LoginRequest record {|
    string email;
    string password;
|};

public type RegisterResponse record {|
    string message;
    string id;
|};

public type LoginResponse record {|
    string message;
    string token;
    UserProfile user;
|};

public type UserProfile record {|
    string id;
    string name;
    string email;
    string role;
    time:Utc createdAt;
|};

public type ErrorResponse record {|
    string message;
    int code;
|};

// Authentication service
service /auth on new http:Listener(8081) {
    
    // POST /auth/register
    resource function post register(RegisterRequest request) returns RegisterResponse|ErrorResponse|error {
        // Validate role
        if request.role != "volunteer" && request.role != "organizer" {
            return <ErrorResponse>{
                message: "Invalid role. Must be 'volunteer' or 'organizer'",
                code: 400
            };
        }
        
        // Validate email format (basic validation)
        if !isValidEmail(request.email) {
            return <ErrorResponse>{
                message: "Invalid email format",
                code: 400
            };
        }
        
        // Get user collection
        mongodb:Collection userCollection = check getUserCollection();
        
        // Check if user already exists
        map<json> filter = {"email": request.email};
        User? existingUser = check userCollection->findOne(filter);
        
        if existingUser is User {
            return <ErrorResponse>{
                message: "User with this email already exists",
                code: 409
            };
        }
        
        // Hash password
        string passwordHash = hashPassword(request.password);
        
        // Create user
        User newUser = {
            name: request.name,
            email: request.email,
            passwordHash: passwordHash,
            role: request.role,
            createdAt: time:utcNow()
        };
        
        // Insert user into MongoDB
        mongodb:Error? insertResult = userCollection->insertOne(newUser);
        
        if insertResult is mongodb:Error {
            return <ErrorResponse>{
                message: "Failed to create user: " + insertResult.message(),
                code: 500
            };
        }
        
        return <RegisterResponse>{
            message: "User registered successfully",
            id: "User created" // MongoDB doesn't return the ID in this version
        };
    }
    
    // POST /auth/login
    resource function post login(LoginRequest request) returns LoginResponse|ErrorResponse|error {
        // Get user collection
        mongodb:Collection userCollection = check getUserCollection();
        
        // Find user by email
        map<json> filter = {"email": request.email};
        User? user = check userCollection->findOne(filter);
        
        if user is () {
            return <ErrorResponse>{
                message: "Invalid email or password",
                code: 401
            };
        }
        
        // Verify password
        if !verifyPassword(request.password, user.passwordHash) {
            return <ErrorResponse>{
                message: "Invalid email or password",
                code: 401
            };
        }
        
        // Generate JWT token
        jwt:IssuerConfig issuerConfig = {
            username: "volunthere",
            issuer: "volunthere",
            audience: ["volunthere-users"],
            keyId: "volunthere-key",
            customClaims: {
                "userId": user?._id ?: "",
                "email": user.email,
                "role": user.role
            },
            expTime: 3600 // 1 hour
        };
        
        string token = check jwt:issue(issuerConfig);
        
        UserProfile userProfile = {
            id: user?._id ?: "",
            name: user.name,
            email: user.email,
            role: user.role,
            createdAt: user.createdAt
        };
        
        return <LoginResponse>{
            message: "Login successful",
            token: token,
            user: userProfile
        };
    }
    
    // GET /auth/me
    resource function get me(http:Request req) returns UserProfile|ErrorResponse|error {
        // Get JWT token from Authorization header
        string|http:HeaderNotFoundError authHeader = req.getHeader("Authorization");
        
        if authHeader is http:HeaderNotFoundError {
            return <ErrorResponse>{
                message: "Authorization header required",
                code: 401
            };
        }
        
        // Extract token from "Bearer <token>"
        string authHeaderStr = authHeader;
        
        // Simple string parsing for Bearer token
        if !authHeaderStr.startsWith("Bearer ") {
            return <ErrorResponse>{
                message: "Invalid authorization header format",
                code: 401
            };
        }
        
        string token = authHeaderStr.substring(7); // Remove "Bearer " prefix
        
        // Verify JWT token
        jwt:ValidatorConfig validatorConfig = {
            issuer: "volunthere",
            audience: ["volunthere-users"],
            signatureConfig: {
                secret: JWT_SECRET
            }
        };
        
        jwt:Payload|jwt:Error payload = jwt:validate(token, validatorConfig);
        
        if payload is jwt:Error {
            return <ErrorResponse>{
                message: "Invalid or expired token",
                code: 401
            };
        }
        
        // Extract user ID from token
        anydata userIdData = payload["userId"];
        string userId = userIdData.toString();
        
        // Get user collection
        mongodb:Collection userCollection = check getUserCollection();
        
        // Find user by ID
        map<json> filter = {"_id": {"$oid": userId}};
        User? user = check userCollection->findOne(filter);
        
        if user is () {
            return <ErrorResponse>{
                message: "User not found",
                code: 404
            };
        }
        
        return <UserProfile>{
            id: user?._id ?: "",
            name: user.name,
            email: user.email,
            role: user.role,
            createdAt: user.createdAt
        };
    }
}

// Helper functions

// Hash password using crypto module
function hashPassword(string password) returns string {
    byte[] passwordBytes = password.toBytes();
    byte[] hashedBytes = crypto:hashSha256(passwordBytes);
    return hashedBytes.toBase64();
}

// Verify password
function verifyPassword(string password, string storedHash) returns boolean {
    string hashedPassword = hashPassword(password);
    return hashedPassword == storedHash;
}

// Basic email validation
function isValidEmail(string email) returns boolean {
    return email.includes("@") && email.includes(".");
}
