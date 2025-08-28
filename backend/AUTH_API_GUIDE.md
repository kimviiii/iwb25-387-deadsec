# VoluntHere Authentication API Test

## Setup
The authentication service runs on port 8081 and provides three endpoints:

1. **POST /auth/register** - Register a new user
2. **POST /auth/login** - Login and get JWT token 
3. **GET /auth/me** - Get current user profile (requires JWT token)

## Testing the API

### 1. Register a new user
```bash
curl -X POST http://localhost:8081/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com", 
    "password": "securepassword123",
    "role": "volunteer"
  }'
```

Expected response:
```json
{
  "message": "User registered successfully",
  "id": "User created"
}
```

### 2. Login to get JWT token
```bash
curl -X POST http://localhost:8081/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "securepassword123"
  }'
```

Expected response:
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "64f8a1b2c3d4e5f6a7b8c9d0",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "volunteer",
    "createdAt": "2025-08-28T10:30:00Z"
  }
}
```

### 3. Get current user profile
```bash
curl -X GET http://localhost:8081/auth/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

Expected response:
```json
{
  "id": "64f8a1b2c3d4e5f6a7b8c9d0",
  "name": "John Doe", 
  "email": "john@example.com",
  "role": "volunteer",
  "createdAt": "2025-08-28T10:30:00Z"
}
```

## Error Responses

### 400 Bad Request
- Invalid role (must be "volunteer" or "organizer")
- Invalid email format

### 401 Unauthorized  
- Invalid credentials
- Missing or invalid JWT token

### 409 Conflict
- Email already exists during registration

### 404 Not Found
- User not found

### 500 Internal Server Error
- Database connection issues
- Other server errors

## Running the Application

1. Make sure MongoDB Atlas connection is configured in Config.toml
2. Start the application:
   ```bash
   cd backend
   bal run
   ```
3. The authentication service will be available at http://localhost:8081/auth
4. The main application service will be available at http://localhost:8080

## Security Features

- **Password Hashing**: Passwords are hashed using SHA-256 before storage
- **JWT Tokens**: Secure authentication with configurable expiry (1 hour)
- **Unique Email Index**: Prevents duplicate email registrations
- **Role-based Access**: Support for "volunteer" and "organizer" roles
- **Input Validation**: Email format and role validation
