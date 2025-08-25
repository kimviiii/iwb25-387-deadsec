import ballerina/io;
import ballerina/http;

// Initialize repositories with in-memory implementations
EventsRepo eventsRepo = new InMemoryEventsRepo();
VolunteersRepo volunteersRepo = new InMemoryVolunteersRepo();
RsvpsRepo rsvpsRepo = new InMemoryRsvpsRepo();

public function main() returns error? {
    // Log which repositories are being used
    io:println("InMemory repos initialized ✅");
    
    // Start HTTP service
    _ = check new http:Listener(8090);
    io:println("HTTP service started on port 8090 ✅");
}

service / on new http:Listener(8090) {

    // Health endpoint
    resource function get health() returns json {
        return {"status": "ok"};
    }

    // Events endpoints
    resource function post events(EventInput event) returns Event|http:BadRequest|http:InternalServerError {
        Event|error result = eventsRepo.create(event);
        if result is error {
            return <http:InternalServerError>{body: {"error": result.message()}};
        }
        return result;
    }

    resource function get events() returns Event[] {
        return eventsRepo.list();
    }

    resource function get events/[string id]() returns Event|http:NotFound {
        Event? event = eventsRepo.getById(id);
        if event is Event {
            return event;
        }
        return <http:NotFound>{body: {"error": "Event not found"}};
    }

    // Volunteers endpoints
    resource function post volunteers(VolunteerInput volunteer) returns Volunteer|http:BadRequest|http:InternalServerError {
        Volunteer|error result = volunteersRepo.create(volunteer);
        if result is error {
            return <http:InternalServerError>{body: {"error": result.message()}};
        }
        return result;
    }

    resource function get volunteers() returns Volunteer[] {
        return volunteersRepo.list();
    }

    resource function get volunteers/[string id]() returns Volunteer|http:NotFound {
        Volunteer? volunteer = volunteersRepo.getById(id);
        if volunteer is Volunteer {
            return volunteer;
        }
        return <http:NotFound>{body: {"error": "Volunteer not found"}};
    }

    // RSVP endpoints
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

        // Check if RSVP already exists
        if rsvpsRepo.exists(rsvpReq.volunteerId, rsvpReq.eventId) {
            return <http:BadRequest>{body: {"error": "RSVP already exists for this volunteer and event"}};
        }

        // Create RSVP
        RsvpInput newRsvp = {
            volunteerId: rsvpReq.volunteerId,
            eventId: rsvpReq.eventId
        };

        Rsvp|error result = rsvpsRepo.create(newRsvp);
        if result is error {
            return <http:InternalServerError>{body: {"error": result.message()}};
        }
        return result;
    }

    resource function get rsvps() returns Rsvp[] {
        return rsvpsRepo.list();
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

        // Check if RSVP already exists
        if rsvpsRepo.exists(volunteerId, eventId) {
            return <http:BadRequest>{body: {"error": "RSVP already exists for this volunteer and event"}};
        }

        // Create RSVP
        RsvpInput newRsvp = {
            volunteerId: volunteerId,
            eventId: eventId
        };

        Rsvp|error result = rsvpsRepo.create(newRsvp);
        if result is error {
            return <http:InternalServerError>{body: {"error": result.message()}};
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
    resource function get 'match(string volunteerId) returns MatchResult[]|http:BadRequest {
        Volunteer? volunteer = volunteersRepo.getById(volunteerId);
        if volunteer is () {
            return <http:BadRequest>{body: {"error": "Volunteer not found"}};
        }

        Event[] events = eventsRepo.list();
        MatchResult[] matches = [];

        foreach Event event in events {
            int score = calculateMatchScore(volunteer, event);
            if score > 0 && event.id is string {
                string eventId = event.id;
                MatchResult matchResult = {
                    eventId: eventId,
                    event: event,
                    score: score,
                    breakdown: generateMatchBreakdown(volunteer, event)
                };
                matches.push(matchResult);
            }
        }

        // Sort by score descending and return top 5
        // Simple bubble sort to avoid complex array operations
        int n = matches.length();
        foreach int i in 0 ..< n-1 {
            foreach int j in 0 ..< n-i-1 {
                if matches[j].score < matches[j+1].score {
                    MatchResult temp = matches[j];
                    matches[j] = matches[j+1];
                    matches[j+1] = temp;
                }
            }
        }
        
        // Return top 5
        MatchResult[] topMatches = [];
        int maxResults = n < 5 ? n : 5;
        foreach int i in 0 ..< maxResults {
            topMatches.push(matches[i]);
        }
        return topMatches;
    }

    // Export endpoint (for debugging/backup)
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
    resource function post reset() returns json {
        // Note: This would require adding a reset method to repos
        // For now, just return success
        return {"message": "Reset functionality not implemented yet"};
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

// Removed duplicate /rsvps service that was on port 8080 
// All RSVP endpoints are now in the main service on port 8090
