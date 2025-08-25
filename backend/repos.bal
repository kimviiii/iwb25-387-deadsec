// === Data Models ===
// Input types (for creation - ID is optional)
type EventInput record {
    string id?;
    string title;
    string description;
    string date;
    string location;
    string[] skills;
    int slots;
};

type VolunteerInput record {
    string id?;
    string name;
    string[] skills;
    string location;
    string availability;
};

type RsvpInput record {
    string id?;
    string volunteerId;
    string eventId;
    string createdAt?;
};

// Stored types (ID is always present)
type Event record {
    string id;
    string title;
    string description;
    string date;
    string location;
    string[] skills;
    int slots;
};

type Volunteer record {
    string id;
    string name;
    string[] skills;
    string location;
    string availability;
};

type Rsvp record {
    string id;
    string volunteerId;
    string eventId;
    string createdAt;
};

// === Request/Response Types ===
type RsvpRequest record {
    string volunteerId;
    string eventId;
};

type MatchResult record {
    string eventId;
    Event event;
    int score;
    string breakdown;
};

// === Repository Contracts ===
type EventsRepo object {
    function create(EventInput e) returns Event|error;
    function list() returns Event[];
    function getById(string id) returns Event?;
};

type VolunteersRepo object {
    function create(VolunteerInput v) returns Volunteer|error;
    function list() returns Volunteer[];
    function getById(string id) returns Volunteer?;
};

type RsvpsRepo object {
    function create(RsvpInput r) returns Rsvp|error;
    function list() returns Rsvp[];
    function exists(string volunteerId, string eventId) returns boolean;
};
