// === JSON Conversion Utils ===

// Functions to convert records to JSON
function eventToJson(Event event) returns json {
    return {
        "id": event.id,
        "title": event.title,
        "description": event.description,
        "date": event.date,
        "location": event.location,
        "skills": event.skills,
        "slots": event.slots
    };
}

function volunteerToJson(Volunteer volunteer) returns json {
    return {
        "id": volunteer.id,
        "name": volunteer.name,
        "skills": volunteer.skills,
        "location": volunteer.location,
        "availability": volunteer.availability
    };
}

function rsvpToJson(Rsvp rsvp) returns json {
    return {
        "id": rsvp.id,
        "volunteerId": rsvp.volunteerId,
        "eventId": rsvp.eventId,
        "createdAt": rsvp.createdAt
    };
}

// Functions for arrays
function eventsToJson(Event[] events) returns json {
    json[] result = [];
    foreach Event event in events {
        result.push(eventToJson(event));
    }
    return result;
}

function volunteersToJson(Volunteer[] volunteers) returns json {
    json[] result = [];
    foreach Volunteer volunteer in volunteers {
        result.push(volunteerToJson(volunteer));
    }
    return result;
}

function rsvpsToJson(Rsvp[] rsvps) returns json {
    json[] result = [];
    foreach Rsvp rsvp in rsvps {
        result.push(rsvpToJson(rsvp));
    }
    return result;
}
