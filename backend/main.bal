import ballerina/io;
import ballerina/http;
import ballerina/openapi;

// Configuration
configurable boolean USE_ATLAS = false;

// Global repository variables
EventsRepo eventsRepo = new InMemoryEventsRepo();
VolunteersRepo volunteersRepo = new InMemoryVolunteersRepo();
RsvpsRepo rsvpsRepo = new InMemoryRsvpsRepo();

public function main() returns error? {
    // Check configuration and initialize Atlas repositories if needed
    if USE_ATLAS {
        io:println("🔄 Initializing MongoDB Atlas repos...");
        eventsRepo = new MongoEventsRepo();
        volunteersRepo = new MongoVolunteersRepo();
        rsvpsRepo = new MongoRsvpsRepo();
        io:println("MongoDB Atlas repos initialized ✅");
        
        // Optional test snippet - insert a sample event and list all events
        EventInput testEvent = {
            title: "Community Garden Cleanup",
            description: "Help clean up the local community garden",
            date: "2025-09-01",
            location: "Central Park",
            skills: ["gardening", "cleaning"],
            slots: 10
        };
        
        
        Event|error result = eventsRepo.create(testEvent);
        if result is Event {
            io:println("✅ Test event created with ID: " + result.id);
        } else {
            io:println("❌ Failed to create test event: " + result.message());
        }
        
        Event[] events = eventsRepo.list();
        io:println("📋 Total events in Atlas: " + events.length().toString());
    } else {
        io:println("InMemory repos initialized ✅");
        
        // Wire up the in-memory repositories for slot management
        InMemoryEventsRepo inMemEventsRepo = <InMemoryEventsRepo>eventsRepo;
        InMemoryRsvpsRepo inMemRsvpsRepo = <InMemoryRsvpsRepo>rsvpsRepo;
        inMemRsvpsRepo.setEventsRepo(inMemEventsRepo);
        
        // Seed demo data
        error? seedResult = seedDemoData();
        if seedResult is error {
            io:println("❌ Failed to seed demo data: " + seedResult.message());
        } else {
            // Test the score function with demo data
            testScoreFunction();
        }
    }
    
    io:println("HTTP service started on port 8090 ✅");
}

@openapi:ServiceInfo {
    title: "VoluntHere API",
    'version: "1.0.0",
    description: "Volunteer Match backend API"
}
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["GET", "POST", "OPTIONS"],
        allowHeaders: ["*"]
    }
}
service / on new http:Listener(8090) {

    // Health endpoint with Atlas status check
    @openapi:ResourceInfo {
        summary: "Health check endpoint",
        tags: ["System"]
    }
    resource function get health() returns json {
        return {
            "status": "ok",
            "atlas": "disabled"
        };
    }

    // Events endpoints
    @openapi:ResourceInfo {
        summary: "Create a new event",
        tags: ["Events"]
    }
    resource function post events(EventInput event) returns Event|http:BadRequest|http:InternalServerError {
        Event|error result = eventsRepo.create(event);
        if result is error {
            return <http:InternalServerError>{body: {"error": result.message()}};
        }
        return result;
    }

    @openapi:ResourceInfo {
        summary: "Get all events",
        tags: ["Events"]
    }
    resource function get events() returns Event[] {
        return eventsRepo.list();
    }

    @openapi:ResourceInfo {
        summary: "Get event by ID",
        tags: ["Events"]
    }
    resource function get events/[string id]() returns Event|http:NotFound {
        Event? event = eventsRepo.getById(id);
        if event is Event {
            return event;
        }
        return <http:NotFound>{body: {"error": "Event not found"}};
    }

    // Volunteers endpoints
    @openapi:ResourceInfo {
        summary: "Create a new volunteer",
        tags: ["Volunteers"]
    }
    resource function post volunteers(VolunteerInput volunteer) returns Volunteer|http:BadRequest|http:InternalServerError {
        Volunteer|error result = volunteersRepo.create(volunteer);
        if result is error {
            return <http:InternalServerError>{body: {"error": result.message()}};
        }
        return result;
    }

    @openapi:ResourceInfo {
        summary: "Get all volunteers",
        tags: ["Volunteers"]
    }
    resource function get volunteers() returns Volunteer[] {
        return volunteersRepo.list();
    }

    @openapi:ResourceInfo {
        summary: "Get volunteer by ID",
        tags: ["Volunteers"]
    }
    resource function get volunteers/[string id]() returns Volunteer|http:NotFound {
        Volunteer? volunteer = volunteersRepo.getById(id);
        if volunteer is Volunteer {
            return volunteer;
        }
        return <http:NotFound>{body: {"error": "Volunteer not found"}};
    }

    // RSVP endpoints
    @openapi:ResourceInfo {
        summary: "Create an RSVP for an event",
        tags: ["RSVPs"]
    }
    resource function post rsvp(RsvpRequest rsvpReq) returns Rsvp|http:BadRequest|http:InternalServerError {
        // Validate that volunteer and event exist
        Volunteer? volunteer = volunteersRepo.getById(rsvpReq.volunteerId);
        if volunteer is () {
            return <http:BadRequest>{body: {"error": "Volunteer not found"}};
        }

        Event? event = eventsRepo.getById(rsvpReq.eventId);
        if event is () {
            return <http:BadRequest>{body: {"error": "Event not found"}};
        }

        // Create RSVP - the repository will handle duplicate checking and slot decrementing
        RsvpInput newRsvp = {
            volunteerId: rsvpReq.volunteerId,
            eventId: rsvpReq.eventId
        };

        Rsvp|error result = rsvpsRepo.create(newRsvp);
        if result is error {
            string errorMsg = result.message();
            if errorMsg.includes("Duplicate") {
                return <http:BadRequest>{body: {"error": errorMsg}};
            }
            return <http:InternalServerError>{body: {"error": errorMsg}};
        }
        return result;
    }

    @openapi:ResourceInfo {
        summary: "Get all RSVPs",
        tags: ["RSVPs"]
    }
    resource function get rsvps() returns Rsvp[] {
        return rsvpsRepo.list();
    }
    
    @openapi:ResourceInfo {
        summary: "Create an RSVP using JSON payload",
        tags: ["RSVPs"]
    }
    resource function post rsvps(@http:Payload json payload) returns json|http:BadRequest|http:InternalServerError {
        // Extract data from payload
        string volunteerId;
        string eventId;
        
        // Extract fields with error handling
        var vid = payload.volunteerId;
        var eid = payload.eventId;
        
        if vid is string {
            volunteerId = vid;
        } else {
            return <http:BadRequest>{body: {"error": "Invalid volunteerId"}};
        }
        
        if eid is string {
            eventId = eid;
        } else {
            return <http:BadRequest>{body: {"error": "Invalid eventId"}};
        }
        
        // Validate that volunteer and event exist
        Volunteer? volunteer = volunteersRepo.getById(volunteerId);
        if volunteer is () {
            return <http:BadRequest>{body: {"error": "Volunteer not found"}};
        }

        Event? event = eventsRepo.getById(eventId);
        if event is () {
            return <http:BadRequest>{body: {"error": "Event not found"}};
        }

        // Create RSVP - the repository will handle duplicate checking and slot decrementing
        RsvpInput newRsvp = {
            volunteerId: volunteerId,
            eventId: eventId
        };

        Rsvp|error result = rsvpsRepo.create(newRsvp);
        if result is error {
            string errorMsg = result.message();
            if errorMsg.includes("Duplicate") {
                return <http:BadRequest>{body: {"error": errorMsg}};
            }
            return <http:InternalServerError>{body: {"error": errorMsg}};
        }
        
        // Convert to JSON for response
        return {
            "id": result.id,
            "volunteerId": result.volunteerId,
            "eventId": result.eventId,
            "createdAt": result.createdAt
        };
    }

    // Matching endpoint
    @openapi:ResourceInfo {
        summary: "Get event matches for a volunteer",
        tags: ["Matching"]
    }
    resource function get 'match(string volunteerId) returns json[]|http:NotFound|http:InternalServerError {
        // Look up the volunteer by ID
        Volunteer? volunteer = volunteersRepo.getById(volunteerId);
        if volunteer is () {
            return <http:NotFound>{body: {"error": "Volunteer not found"}};
        }

        // Get all events from EventsRepo
        Event[] events = eventsRepo.list();
        
        // If no events, return empty array
        if events.length() == 0 {
            return [];
        }

        // Build list of results for each event
        json[] results = [];
        foreach Event event in events {
            // Call the existing score function
            MatchScore matchScore = score(volunteer, event);
            
            // Build result with required fields
            json result = {
                "eventId": event.id,
                "title": event.title,
                "score": matchScore.score,
                "why": matchScore.why
            };
            results.push(result);
        }

        // Sort results by score in descending order using bubble sort
        int n = results.length();
        foreach int i in 0 ..< n-1 {
            foreach int j in 0 ..< n-i-1 {
                json current = results[j];
                json next = results[j+1];
                
                // Extract scores for comparison - handle potential errors
                var currentScoreVal = current.score;
                var nextScoreVal = next.score;
                
                if currentScoreVal is int && nextScoreVal is int {
                    if currentScoreVal < nextScoreVal {
                        results[j] = next;
                        results[j+1] = current;
                    }
                }
            }
        }
        
        return results;
    }

    // Export endpoint (for debugging/backup)
    @openapi:ResourceInfo {
        summary: "Export all data for debugging and backup",
        tags: ["Export"]
    }
    resource function get export() returns json {
        json[] eventsJson = [];
        foreach Event event in eventsRepo.list() {
            eventsJson.push({
                "id": event.id,
                "title": event.title,
                "description": event.description,
                "date": event.date,
                "location": event.location,
                "skills": event.skills,
                "slots": event.slots
            });
        }
        
        json[] volunteersJson = [];
        foreach Volunteer volunteer in volunteersRepo.list() {
            volunteersJson.push({
                "id": volunteer.id,
                "name": volunteer.name,
                "skills": volunteer.skills,
                "location": volunteer.location,
                "availability": volunteer.availability
            });
        }
        
        json[] rsvpsJson = [];
        foreach Rsvp rsvp in rsvpsRepo.list() {
            rsvpsJson.push({
                "id": rsvp.id,
                "volunteerId": rsvp.volunteerId,
                "eventId": rsvp.eventId,
                "createdAt": rsvp.createdAt
            });
        }
        
        return {
            "events": eventsJson,
            "volunteers": volunteersJson,
            "rsvps": rsvpsJson
        };
    }

    // Reset endpoint (dev/demo only)
    @openapi:ResourceInfo {
        summary: "Reset all data (development only)",
        tags: ["System"]
    }
    resource function post reset() returns json {
        // Note: This would require adding a reset method to repos
        // For now, just return success
        return {"message": "Reset functionality not implemented yet"};
    }

    // OpenAPI spec endpoint
    @openapi:ResourceInfo {
        summary: "Get OpenAPI specification",
        tags: ["System"]
    }
    resource function get openapi() returns json {
        return {
            "openapi": "3.0.1",
            "info": {
                "title": "VoluntHere API",
                "version": "1.0.0",
                "description": "Volunteer Match backend API - Connect volunteers with meaningful opportunities"
            },
            "tags": [
                {
                    "name": "System",
                    "description": "System health and monitoring endpoints"
                },
                {
                    "name": "Events",
                    "description": "Event management operations"
                },
                {
                    "name": "Volunteers",
                    "description": "Volunteer management operations"
                },
                {
                    "name": "RSVPs",
                    "description": "RSVP and registration operations"
                },
                {
                    "name": "Matching",
                    "description": "Volunteer-event matching operations"
                },
                {
                    "name": "Export",
                    "description": "Data export and debugging operations"
                }
            ],
            "paths": {
                "/health": {
                    "get": {
                        "tags": ["System"],
                        "summary": "Health check endpoint",
                        "description": "Check if the service is running and healthy",
                        "responses": {
                            "200": {
                                "description": "Service is healthy",
                                "content": {
                                    "application/json": {
                                        "example": {
                                            "status": "ok",
                                            "atlas": "disabled"
                                        }
                                    }
                                }
                            }
                        }
                    }
                },
                "/events": {
                    "get": {
                        "tags": ["Events"],
                        "summary": "Get all events",
                        "description": "Retrieve a list of all available volunteer events",
                        "responses": {
                            "200": {
                                "description": "List of events",
                                "content": {
                                    "application/json": {
                                        "schema": {
                                            "type": "array",
                                            "items": {
                                                "type": "object"
                                            }
                                        },
                                        "example": [
                                            {
                                                "id": "evt_123",
                                                "title": "Beach Cleanup Drive",
                                                "description": "Help clean up the local beach and protect marine life",
                                                "date": "2025-09-15",
                                                "location": "Santa Monica",
                                                "skills": ["environmental", "physical"],
                                                "slots": 20
                                            }
                                        ]
                                    }
                                }
                            }
                        }
                    },
                    "post": {
                        "tags": ["Events"],
                        "summary": "Create a new event",
                        "description": "Create a new volunteer event",
                        "requestBody": {
                            "required": true,
                            "content": {
                                "application/json": {
                                    "schema": {
                                        "type": "object",
                                        "required": ["title", "description", "date", "location", "skills", "slots"],
                                        "properties": {
                                            "title": {"type": "string"},
                                            "description": {"type": "string"},
                                            "date": {"type": "string", "format": "date"},
                                            "location": {"type": "string"},
                                            "skills": {"type": "array", "items": {"type": "string"}},
                                            "slots": {"type": "integer", "minimum": 1}
                                        }
                                    },
                                    "example": {
                                        "title": "Community Garden Planting",
                                        "description": "Help plant vegetables for the community garden",
                                        "date": "2025-09-28",
                                        "location": "Central Park",
                                        "skills": ["gardening", "environmental", "physical"],
                                        "slots": 15
                                    }
                                }
                            }
                        },
                        "responses": {
                            "200": {
                                "description": "Event created successfully",
                                "content": {
                                    "application/json": {
                                        "example": {
                                            "id": "evt_456",
                                            "title": "Community Garden Planting",
                                            "description": "Help plant vegetables for the community garden",
                                            "date": "2025-09-28",
                                            "location": "Central Park",
                                            "skills": ["gardening", "environmental", "physical"],
                                            "slots": 15
                                        }
                                    }
                                }
                            },
                            "400": {
                                "description": "Bad request - invalid input data"
                            }
                        }
                    }
                },
                "/volunteers": {
                    "get": {
                        "tags": ["Volunteers"],
                        "summary": "Get all volunteers",
                        "description": "Retrieve a list of all registered volunteers",
                        "responses": {
                            "200": {
                                "description": "List of volunteers",
                                "content": {
                                    "application/json": {
                                        "example": [
                                            {
                                                "id": "vol_123",
                                                "name": "Alice Johnson",
                                                "skills": ["technology", "teaching", "customer service"],
                                                "location": "Beverly Hills",
                                                "availability": "2025-09-10"
                                            }
                                        ]
                                    }
                                }
                            }
                        }
                    },
                    "post": {
                        "tags": ["Volunteers"],
                        "summary": "Create a new volunteer",
                        "description": "Register a new volunteer in the system",
                        "requestBody": {
                            "required": true,
                            "content": {
                                "application/json": {
                                    "schema": {
                                        "type": "object",
                                        "required": ["name", "skills", "location", "availability"],
                                        "properties": {
                                            "name": {"type": "string"},
                                            "skills": {"type": "array", "items": {"type": "string"}},
                                            "location": {"type": "string"},
                                            "availability": {"type": "string", "format": "date"}
                                        }
                                    },
                                    "example": {
                                        "name": "John Smith",
                                        "skills": ["environmental", "leadership", "communication"],
                                        "location": "Santa Monica",
                                        "availability": "2025-09-15"
                                    }
                                }
                            }
                        },
                        "responses": {
                            "200": {
                                "description": "Volunteer created successfully"
                            },
                            "400": {
                                "description": "Bad request - invalid input data"
                            }
                        }
                    }
                },
                "/rsvp": {
                    "post": {
                        "tags": ["RSVPs"],
                        "summary": "Create an RSVP (structured payload)",
                        "description": "Create an RSVP using structured RsvpRequest object",
                        "requestBody": {
                            "required": true,
                            "content": {
                                "application/json": {
                                    "schema": {
                                        "type": "object",
                                        "required": ["volunteerId", "eventId"],
                                        "properties": {
                                            "volunteerId": {"type": "string"},
                                            "eventId": {"type": "string"}
                                        }
                                    },
                                    "example": {
                                        "volunteerId": "vol_123",
                                        "eventId": "evt_456"
                                    }
                                }
                            }
                        },
                        "responses": {
                            "200": {
                                "description": "RSVP created successfully"
                            },
                            "400": {
                                "description": "Bad request - volunteer or event not found, or duplicate RSVP"
                            }
                        }
                    }
                },
                "/rsvps": {
                    "get": {
                        "tags": ["RSVPs"],
                        "summary": "Get all RSVPs",
                        "description": "Retrieve a list of all RSVPs",
                        "responses": {
                            "200": {
                                "description": "List of RSVPs",
                                "content": {
                                    "application/json": {
                                        "example": [
                                            {
                                                "id": "rsvp_789",
                                                "volunteerId": "vol_123",
                                                "eventId": "evt_456",
                                                "createdAt": "2025-08-27T10:30:00Z"
                                            }
                                        ]
                                    }
                                }
                            }
                        }
                    },
                    "post": {
                        "tags": ["RSVPs"],
                        "summary": "Create an RSVP (JSON payload)",
                        "description": "Create an RSVP using generic JSON payload - alternative endpoint with JSON response",
                        "requestBody": {
                            "required": true,
                            "content": {
                                "application/json": {
                                    "schema": {
                                        "type": "object",
                                        "required": ["volunteerId", "eventId"],
                                        "properties": {
                                            "volunteerId": {"type": "string"},
                                            "eventId": {"type": "string"}
                                        }
                                    },
                                    "example": {
                                        "volunteerId": "vol_123",
                                        "eventId": "evt_456"
                                    }
                                }
                            }
                        },
                        "responses": {
                            "200": {
                                "description": "RSVP created successfully",
                                "content": {
                                    "application/json": {
                                        "example": {
                                            "id": "rsvp_789",
                                            "volunteerId": "vol_123",
                                            "eventId": "evt_456",
                                            "createdAt": "2025-08-27T10:30:00Z"
                                        }
                                    }
                                }
                            },
                            "400": {
                                "description": "Bad request - volunteer or event not found, or duplicate RSVP"
                            }
                        }
                    }
                },
                "/match": {
                    "get": {
                        "tags": ["Matching"],
                        "summary": "Get event matches for a volunteer",
                        "description": "Find and rank events that match a volunteer's skills and availability",
                        "parameters": [
                            {
                                "name": "volunteerId",
                                "in": "query",
                                "required": true,
                                "schema": {
                                    "type": "string"
                                },
                                "description": "ID of the volunteer to match",
                                "example": "vol_123"
                            }
                        ],
                        "responses": {
                            "200": {
                                "description": "List of event matches ranked by score",
                                "content": {
                                    "application/json": {
                                        "example": [
                                            {
                                                "eventId": "evt_456",
                                                "title": "Beach Cleanup Drive",
                                                "score": 17,
                                                "why": "2 skills (+8), same city (+5), date match (+3), slots available (+1) = 17"
                                            },
                                            {
                                                "eventId": "evt_789",
                                                "title": "Food Bank Sorting",
                                                "score": 13,
                                                "why": "1 skills (+4), same city (+5), date match (+3), slots available (+1) = 13"
                                            }
                                        ]
                                    }
                                }
                            },
                            "404": {
                                "description": "Volunteer not found"
                            }
                        }
                    }
                },
                "/export": {
                    "get": {
                        "tags": ["Export"],
                        "summary": "Export all data",
                        "description": "Export all events, volunteers, and RSVPs for debugging and backup purposes",
                        "responses": {
                            "200": {
                                "description": "Complete data export",
                                "content": {
                                    "application/json": {
                                        "example": {
                                            "events": [{"id": "evt_123", "title": "Sample Event"}],
                                            "volunteers": [{"id": "vol_123", "name": "Sample Volunteer"}],
                                            "rsvps": [{"id": "rsvp_123", "volunteerId": "vol_123", "eventId": "evt_123"}]
                                        }
                                    }
                                }
                            }
                        }
                    }
                },
                "/openapi": {
                    "get": {
                        "tags": ["System"],
                        "summary": "Get OpenAPI specification",
                        "description": "Retrieve the complete OpenAPI specification for this API",
                        "responses": {
                            "200": {
                                "description": "OpenAPI specification in JSON format"
                            }
                        }
                    }
                }
            }
        };
    }
}

// === Matching Logic ===
function calculateMatchScore(Volunteer volunteer, Event event) returns int {
    int score = 0;
    
    // +4 per overlapping skill (case-insensitive)
    foreach string vSkill in volunteer.skills {
        foreach string eSkill in event.skills {
            if vSkill.toLowerAscii() == eSkill.toLowerAscii() {
                score += 4;
            }
        }
    }
    
    // +5 if same city (case-insensitive)
    if volunteer.location.toLowerAscii() == event.location.toLowerAscii() {
        score += 5;
    }
    
    // +3 if date matches (simplified - just check if same date string)
    if volunteer.availability == event.date {
        score += 3;
    }
    
    // +1 bonus if event has slots available
    if event.slots > 0 {
        score += 1;
    }
    
    return score;
}

function generateMatchBreakdown(Volunteer volunteer, Event event) returns string {
    string[] breakdown = [];
    int skillMatches = 0;
    
    // Count overlapping skills
    foreach string vSkill in volunteer.skills {
        foreach string eSkill in event.skills {
            if vSkill.toLowerAscii() == eSkill.toLowerAscii() {
                skillMatches += 1;
            }
        }
    }
    
    if skillMatches > 0 {
        breakdown.push(string `${skillMatches} skills (+${skillMatches * 4})`);
    }
    
    if volunteer.location.toLowerAscii() == event.location.toLowerAscii() {
        breakdown.push("same city (+5)");
    }
    
    if volunteer.availability == event.date {
        breakdown.push("date match (+3)");
    }
    
    if event.slots > 0 {
        breakdown.push("slots available (+1)");
    }
    
    return string:'join(", ", ...breakdown);
}

// New score function that returns MatchScore with total and breakdown
function score(Volunteer volunteer, Event event) returns MatchScore {
    int totalScore = 0;
    string[] breakdownParts = [];
    int skillMatches = 0;
    
    // Count overlapping skills (+4 each)
    foreach string vSkill in volunteer.skills {
        foreach string eSkill in event.skills {
            if vSkill.toLowerAscii() == eSkill.toLowerAscii() {
                skillMatches += 1;
            }
        }
    }
    
    if skillMatches > 0 {
        int skillPoints = skillMatches * 4;
        totalScore += skillPoints;
        breakdownParts.push(string `${skillMatches} skills (+${skillPoints})`);
    }
    
    // Same city bonus (+5)
    if volunteer.location.toLowerAscii() == event.location.toLowerAscii() {
        totalScore += 5;
        breakdownParts.push("same city (+5)");
    }
    
    // Date match bonus (+3)
    if volunteer.availability == event.date {
        totalScore += 3;
        breakdownParts.push("date match (+3)");
    }
    
    // Slots available bonus (+1)
    if event.slots > 0 {
        totalScore += 1;
        breakdownParts.push("slots available (+1)");
    }
    
    string why = string:'join(", ", ...breakdownParts);
    if why.length() > 0 {
        why = why + string ` = ${totalScore}`;
    } else {
        why = string `No matches = ${totalScore}`;
    }
    
    return {
        score: totalScore,
        why: why
    };
}

// Example usage / test function for the score function
function testScoreFunction() {
    io:println("\n🧪 Testing Score Function...");
    io:println("==================================================");
    
    // Test Case 1: Good match
    io:println("\n📋 Test Case 1: Good Match");
    Volunteer volunteer1 = {
        id: "vol1",
        name: "John Doe",
        skills: ["environmental", "teamwork"],
        location: "Santa Monica",
        availability: "2025-09-15"
    };
    
    Event event1 = {
        id: "evt1", 
        title: "Beach Cleanup",
        description: "Help clean up the beach",
        date: "2025-09-15",
        location: "Santa Monica",
        skills: ["environmental", "cleaning"],
        slots: 5
    };
    
    MatchScore result1 = score(volunteer1, event1);
    io:println(string `✅ Score: ${result1.score}`);
    io:println(string `📝 Breakdown: ${result1.why}`);
    
    // Test Case 2: Perfect match
    io:println("\n📋 Test Case 2: Perfect Match");
    Volunteer volunteer2 = {
        id: "vol2",
        name: "Alice Smith",
        skills: ["teaching", "mentoring", "communication"],
        location: "Boston",
        availability: "2025-09-20"
    };
    
    Event event2 = {
        id: "evt2", 
        title: "Youth Mentoring",
        description: "Mentor young students",
        date: "2025-09-20",
        location: "Boston",
        skills: ["teaching", "mentoring"],
        slots: 10
    };
    
    MatchScore result2 = score(volunteer2, event2);
    io:println(string `✅ Score: ${result2.score}`);
    io:println(string `📝 Breakdown: ${result2.why}`);
    
    // Test Case 3: No match
    io:println("\n📋 Test Case 3: Poor Match");
    Volunteer volunteer3 = {
        id: "vol3",
        name: "Bob Jones",
        skills: ["coding", "design"],
        location: "New York",
        availability: "2025-10-01"
    };
    
    Event event3 = {
        id: "evt3", 
        title: "Garden Work",
        description: "Physical garden maintenance",
        date: "2025-09-15",
        location: "Los Angeles",
        skills: ["gardening", "physical"],
        slots: 0
    };
    
    MatchScore result3 = score(volunteer3, event3);
    io:println(string `✅ Score: ${result3.score}`);
    io:println(string `📝 Breakdown: ${result3.why}`);
    
    io:println("\n==================================================");
    io:println("🎉 Score function testing complete!");
}

// === Demo Data Seeding ===
function seedDemoData() returns error? {
    io:println("🌱 Seeding demo data...");
    
    // Create demo events
    EventInput[] demoEvents = [
        {
            title: "Beach Cleanup Drive",
            description: "Help clean up the local beach and protect marine life",
            date: "2025-09-15",
            location: "Santa Monica",
            skills: ["environmental", "cleaning", "teamwork"],
            slots: 20
        },
        {
            title: "Food Bank Sorting",
            description: "Sort and package donations for local families in need",
            date: "2025-09-22",
            location: "Los Angeles",
            skills: ["organization", "teamwork", "logistics"],
            slots: 15
        },
        {
            title: "Senior Center Tech Help",
            description: "Teach seniors how to use smartphones and tablets",
            date: "2025-09-10",
            location: "Beverly Hills",
            skills: ["technology", "teaching", "patience"],
            slots: 8
        },
        {
            title: "Community Garden Planting",
            description: "Help plant vegetables for the community garden",
            date: "2025-09-28",
            location: "Santa Monica",
            skills: ["gardening", "environmental", "physical"],
            slots: 12
        }
    ];
    
    foreach EventInput eventInput in demoEvents {
        Event|error result = eventsRepo.create(eventInput);
        if result is Event {
            io:println("✅ Created demo event: " + result.title);
        } else {
            io:println("❌ Failed to create demo event: " + result.message());
        }
    }
    
    // Create demo volunteers
    VolunteerInput[] demoVolunteers = [
        {
            name: "Alice Johnson",
            skills: ["technology", "teaching", "customer service"],
            location: "Beverly Hills",
            availability: "2025-09-10"
        },
        {
            name: "Bob Martinez",
            skills: ["environmental", "physical", "teamwork"],
            location: "Santa Monica",
            availability: "2025-09-15"
        },
        {
            name: "Carol Smith",
            skills: ["organization", "logistics", "management"],
            location: "Los Angeles",
            availability: "2025-09-22"
        },
        {
            name: "David Chen",
            skills: ["gardening", "environmental", "teaching"],
            location: "Santa Monica",
            availability: "2025-09-28"
        },
        {
            name: "Eva Rodriguez",
            skills: ["cleaning", "teamwork", "organization"],
            location: "Los Angeles",
            availability: "2025-09-15"
        }
    ];
    
    foreach VolunteerInput volunteerInput in demoVolunteers {
        Volunteer|error result = volunteersRepo.create(volunteerInput);
        if result is Volunteer {
            io:println("✅ Created demo volunteer: " + result.name);
        } else {
            io:println("❌ Failed to create demo volunteer: " + result.message());
        }
    }
    
    io:println("🌱 Demo data seeding completed!");
}

// Removed duplicate /rsvps service that was on port 8080 
// All RSVP endpoints are now in the main service on port 8090
