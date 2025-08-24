import ballerina/uuid;
import ballerina/time;

// ------------------- Events Repo -------------------
class InMemoryEventsRepo {
    private Event[] events = [];

    *EventsRepo;

    function create(Event e) returns Event|error {
        Event newE = e.clone();
        newE.id = uuid:createType4AsString(); // use UUID v4 for simplicity
        self.events.push(newE);
        return newE;
    }

    function list() returns Event[] {
        return self.events;
    }

    function getById(string id) returns Event? {
        foreach var ev in self.events {
            if ev.id == id {
                return ev;
            }
        }
        return ();
    }
}

// ------------------- Volunteers Repo -------------------
class InMemoryVolunteersRepo {
    private Volunteer[] volunteers = [];

    *VolunteersRepo;

    function create(Volunteer v) returns Volunteer|error {
        Volunteer newV = v.clone();
        newV.id = uuid:createType4AsString();
        self.volunteers.push(newV);
        return newV;
    }

    function list() returns Volunteer[] {
        return self.volunteers;
    }

    function getById(string id) returns Volunteer? {
        foreach var vol in self.volunteers {
            if vol.id == id {
                return vol;
            }
        }
        return ();
    }
}

// ------------------- RSVPs Repo -------------------
class InMemoryRsvpsRepo {
    private Rsvp[] rsvps = [];

    *RsvpsRepo;

    function create(Rsvp r) returns Rsvp|error {
        // Check for duplicates first
        if self.exists(r.volunteerId, r.eventId) {
            return error("RSVP already exists for this volunteer and event");
        }

        Rsvp newR = r.clone();
        newR.id = uuid:createType4AsString();
        newR.createdAt = time:utcToString(time:utcNow()); // use correct formatter
        self.rsvps.push(newR);
        return newR;
    }

    function list() returns Rsvp[] {
        return self.rsvps;
    }

    function exists(string volunteerId, string eventId) returns boolean {
        foreach var r in self.rsvps {
            if r.volunteerId == volunteerId && r.eventId == eventId {
                return true;
            }
        }
        return false;
    }
}
