# MongoDB Atlas Setup and Migration Guide

## Overview
This document describes the migration from in-memory storage to MongoDB Atlas using the official MongoDB Ballerina connector.

## Configuration

### 1. MongoDB Atlas Connection String
Update your `Config.toml` with your MongoDB Atlas connection string:

```toml
# MongoDB Atlas Configuration
USE_ATLAS=true
MONGO_URI="mongodb+srv://kalanakivindu22:MBN6lcl6cmw8LqA2@cluster0.0hhoh.mongodb.net/volunthere?retryWrites=true&w=majority"
```

### 2. How to get your connection string:
1. Go to MongoDB Atlas Dashboard
2. Click "Connect" on your cluster
3. Select "Drivers"
4. Choose "Ballerina" or "Java" driver
5. Copy the connection string
6. Replace `<password>` with your actual password: `MBN6lcl6cmw8LqA2`
7. Replace `<cluster-url>` with your actual cluster URL (e.g., `cluster0.0hhoh.mongodb.net`)

## Repository Implementation

### Current Status
✅ **COMPLETED:**
- Added MongoDB dependency in `Ballerina.toml`
- Created `mongoRepo.bal` with MongoDB repository implementations
- Updated `main.bal` to use MongoDB repositories when `USE_ATLAS=true`
- Added proper error handling and logging
- Configured connection string in `Config.toml`

### Repository Classes
1. **MongoEventsRepo** - Handles event CRUD operations
2. **MongoVolunteersRepo** - Handles volunteer CRUD operations  
3. **MongoRsvpsRepo** - Handles RSVP CRUD operations

### Fallback Strategy
The application automatically falls back to in-memory repositories when:
- `USE_ATLAS=false` in config
- MongoDB connection fails
- Any MongoDB operation encounters an error

## Database Schema

### Collections
- **events** - Stores event information
- **volunteers** - Stores volunteer profiles
- **rsvps** - Stores volunteer-event registrations

### Document Structure

#### Events Collection
```json
{
  "_id": ObjectId("..."),
  "id": "uuid-string",
  "title": "Community Garden Cleanup",
  "description": "Help clean up the local community garden",
  "date": "2025-09-01",
  "location": "Central Park",
  "skills": ["gardening", "cleaning"],
  "slots": 10
}
```

#### Volunteers Collection
```json
{
  "_id": ObjectId("..."),
  "id": "uuid-string",
  "name": "John Doe",
  "skills": ["gardening", "cleanup"],
  "location": "New York",
  "availability": "weekends"
}
```

#### RSVPs Collection
```json
{
  "_id": ObjectId("..."),
  "id": "uuid-string",
  "volunteerId": "volunteer-uuid",
  "eventId": "event-uuid",
  "createdAt": "2025-08-25T10:30:00Z"
}
```

## Testing

### Quick Test
When you run the application with `USE_ATLAS=true`, it will:

1. Initialize MongoDB repositories
2. Create a test event: "Community Garden Cleanup"
3. Display the total number of events in Atlas
4. Log all operations for debugging

### Manual Testing
You can test the API endpoints:

```bash
# Create an event
curl -X POST http://localhost:8090/events \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Beach Cleanup",
    "description": "Clean up the local beach",
    "date": "2025-09-15",
    "location": "Santa Monica Beach",
    "skills": ["cleanup", "environmental"],
    "slots": 20
  }'

# List all events
curl http://localhost:8090/events

# Create a volunteer
curl -X POST http://localhost:8090/volunteers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Smith",
    "skills": ["cleanup", "organization"],
    "location": "Los Angeles",
    "availability": "weekends"
  }'
```

## Troubleshooting

### Connection Issues
- Verify your MongoDB Atlas cluster is running
- Check if your IP address is whitelisted in Atlas
- Ensure the connection string is correct
- Verify your MongoDB user has proper permissions

### Dependencies
If you encounter issues with the MongoDB connector:
1. Check Ballerina version compatibility
2. Try cleaning and rebuilding: `bal clean && bal build`
3. Verify internet connection for downloading dependencies

### Logs
Check the application logs for detailed error messages:
- MongoDB connection status
- Query execution results
- Error details with stack traces

## Next Steps

1. **Performance Optimization**
   - Add connection pooling
   - Implement query optimization
   - Add database indexes

2. **Error Handling**
   - Retry logic for failed operations
   - Circuit breaker pattern
   - Graceful degradation

3. **Monitoring**
   - Add metrics collection
   - Set up health checks
   - Monitor query performance

4. **Security**
   - Implement authentication
   - Add input validation
   - Use environment variables for secrets
