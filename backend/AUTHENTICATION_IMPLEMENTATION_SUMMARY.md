# VoluntHere Authentication System Implementation

## Overview
Successfully implemented a complete authentication system for the VoluntHere Ballerina backend with MongoDB Atlas integration.

## Files Created/Modified

### 1. `db.bal` - Database Connection & User Model
- MongoDB Atlas connection setup using connection string
- User record type with proper field definitions
- Database initialization with unique email index
- Collection management functions

### 2. `user_service.bal` - Authentication Endpoints  
- **POST /auth/register**: User registration with validation
- **POST /auth/login**: User authentication with JWT token generation
- **GET /auth/me**: Protected endpoint returning user profile
- Password hashing using SHA-256
- JWT token validation and parsing
- Comprehensive error handling

### 3. `Ballerina.toml` - Dependencies
- Updated to include MongoDB connector v5.2.2
- Added JWT library v2.15.0  
- Added crypto library v2.7.0
- Added time library v2.4.0

### 4. `Config.toml` - Configuration
- MongoDB Atlas connection string
- JWT secret key configuration
- Atlas mode enabled by default

### 5. `main.bal` - Application Initialization
- Added MongoDB initialization when USE_ATLAS=true
- Integrated with existing application structure

### 6. `AUTH_API_GUIDE.md` - Documentation
- Complete API testing guide
- Curl examples for all endpoints
- Error response documentation
- Security features overview

## Features Implemented

### ✅ Database Connection
- MongoDB Atlas client using provided connection string
- Database: `volunthere`
- Collection: `users`
- Unique index on email field

### ✅ User Model
- Fields: `_id`, `name`, `email`, `passwordHash`, `role`, `createdAt`
- Role validation: "volunteer" or "organizer"
- Timestamp using `time:utcNow()`

### ✅ Authentication Endpoints

#### POST /auth/register
- Input validation (email format, role validation)
- Email uniqueness check
- Password hashing with SHA-256
- User creation in MongoDB
- Error handling for duplicates

#### POST /auth/login  
- Email-based user lookup
- Password verification
- JWT token generation with user claims
- User profile in response

#### GET /auth/me
- JWT token validation from Authorization header
- User profile retrieval from database
- Protected endpoint requiring valid token

### ✅ Security Implementation
- **Password Hashing**: SHA-256 with Base64 encoding
- **JWT Tokens**: 1-hour expiry with custom claims (userId, email, role)
- **Input Validation**: Email format, role constraints
- **Unique Constraints**: Email uniqueness enforced at database level
- **Error Handling**: Comprehensive error responses with appropriate HTTP status codes

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Client App    │────│  Auth Service    │────│  MongoDB Atlas  │
│                 │    │  (Port 8081)     │    │   (volunthere)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                       ┌──────────────────┐
                       │   Main Service   │
                       │   (Port 8080)    │
                       └──────────────────┘
```

## Testing

The system is ready for testing with the provided curl examples in `AUTH_API_GUIDE.md`. 

To run the application:
```bash
cd backend
bal run
```

Services will be available at:
- Authentication: http://localhost:8081/auth  
- Main application: http://localhost:8080

## Next Steps

1. **Test the authentication flow** using the provided curl examples
2. **Integrate with frontend** applications
3. **Add role-based authorization** to existing endpoints
4. **Implement refresh tokens** for enhanced security
5. **Add password strength validation**
6. **Implement account management** (password reset, email verification)

## MongoDB Atlas Configuration

The system uses the provided connection string:
```
mongodb+srv://kalanakivindu22:MBN6lcl6cmw8LqA2@cluster0.0hhoh.mongodb.net/?retryWrites=true&w=majority&appName=VoluntHere
```

Database: `volunthere`
Collection: `users`

The system automatically creates a unique index on the email field to prevent duplicate registrations.

## Security Considerations

- JWT secret should be changed in production
- Consider implementing bcrypt for stronger password hashing
- Add rate limiting for authentication endpoints
- Implement proper session management
- Consider adding refresh token mechanism
- Add input sanitization for enhanced security
