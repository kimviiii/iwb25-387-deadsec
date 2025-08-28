import ballerina/uuid;
import ballerina/time;

// ------------------- Events Repo -------------------
class InMemoryEventsRepo {
    private Event[] events = [];

    *EventsRepo;

    function create(EventInput e) returns Event|error {
        Event newE = {
            id: uuid:createType4AsString(),
            title: e.title,
            description: e.description,
            date: e.date,
            location: e.location,
            skills: e.skills,
            slots: e.slots
        };
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

    // Method to decrement slot count when an RSVP is created
    function decrementSlot(string eventId) returns error? {
        foreach int i in 0 ..< self.events.length() {
            if self.events[i].id == eventId {
                if self.events[i].slots > 0 {
                    Event updatedEvent = {
                        id: self.events[i].id,
                        title: self.events[i].title,
                        description: self.events[i].description,
                        date: self.events[i].date,
                        location: self.events[i].location,
                        skills: self.events[i].skills,
                        slots: self.events[i].slots - 1
                    };
                    self.events[i] = updatedEvent;
                    return ();
                } else {
                    return error("No available slots for this event");
                }
            }
        }
        return error("Event not found");
    }
}

// ------------------- Volunteers Repo -------------------
class InMemoryVolunteersRepo {
    private Volunteer[] volunteers = [];

    *VolunteersRepo;

    function create(VolunteerInput v) returns Volunteer|error {
        Volunteer newV = {
            id: uuid:createType4AsString(),
            name: v.name,
            skills: v.skills,
            location: v.location,
            availability: v.availability
        };
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
    private InMemoryEventsRepo? eventsRepo = ();

    *RsvpsRepo;

    // Set reference to events repo for slot management
    function setEventsRepo(InMemoryEventsRepo eventsRepo) {
        self.eventsRepo = eventsRepo;
    }

    function create(RsvpInput r) returns Rsvp|error {
        // Check for duplicates first
        if self.exists(r.volunteerId, r.eventId) {
            return error("Duplicate RSVP: RSVP already exists for this volunteer and event");
        }

        // Check if event has available slots and decrement if so
        if self.eventsRepo is InMemoryEventsRepo {
            InMemoryEventsRepo repo = <InMemoryEventsRepo>self.eventsRepo;
            Event? event = repo.getById(r.eventId);
            if event is Event {
                if event.slots <= 0 {
                    return error("No available slots for this event");
                }
                // Decrement the slot count
                error? result = repo.decrementSlot(r.eventId);
                if result is error {
                    return result;
                }
            } else {
                return error("Event not found");
            }
        }

        Rsvp newR = {
            id: uuid:createType4AsString(),
            volunteerId: r.volunteerId,
            eventId: r.eventId,
            createdAt: time:utcToString(time:utcNow())
        };
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
