import ballerina/io;
import ballerina/uuid;
import ballerina/time;

// === Data structure for JSON file ===
type DataStore record {
    Event[] events;
    Volunteer[] volunteers;
    Rsvp[] rsvps;
};

// === File JSON Events Repository ===
class FileJsonEventsRepo {
    private string filePath = "data.json";
    private DataStore dataStore = {events: [], volunteers: [], rsvps: []};

    *EventsRepo;

    function init() returns error? {
        self.dataStore = check self.loadData();
    }

    function create(Event e) returns Event|error {
        Event newE = e.clone();
        newE.id = uuid:createType4AsString();
        self.dataStore.events.push(newE);
        check self.saveData();
        return newE;
    }

    function list() returns Event[] {
        return self.dataStore.events;
    }

    function getById(string id) returns Event? {
        foreach var ev in self.dataStore.events {
            if ev.id == id {
                return ev;
            }
        }
        return ();
    }

    private function loadData() returns DataStore|error {
        string|io:Error content = io:fileReadString(self.filePath);
        if content is io:Error {
            // File doesn't exist or can't be read, initialize with empty data
            DataStore emptyData = {
                events: [],
                volunteers: [],
                rsvps: []
            };
            return emptyData;
        }

        if content.trim() == "" {
            // Handle empty file
            DataStore emptyData = {
                events: [],
                volunteers: [],
                rsvps: []
            };
            return emptyData;
        }

        json jsonData = check content.fromJsonString();
        DataStore data = check jsonData.cloneWithType(DataStore);
        return data;
    }

    private function saveData() returns error? {
        json jsonData = self.dataStore.toJson();
        check io:fileWriteString(self.filePath, jsonData.toJsonString());
    }
}

// === File JSON Volunteers Repository ===
class FileJsonVolunteersRepo {
    private string filePath = "data.json";
    private DataStore dataStore = {events: [], volunteers: [], rsvps: []};

    *VolunteersRepo;

    function init() returns error? {
        self.dataStore = check self.loadData();
    }

    function create(Volunteer v) returns Volunteer|error {
        Volunteer newV = v.clone();
        newV.id = uuid:createType4AsString();
        self.dataStore.volunteers.push(newV);
        check self.saveData();
        return newV;
    }

    function list() returns Volunteer[] {
        return self.dataStore.volunteers;
    }

    function getById(string id) returns Volunteer? {
        foreach var vol in self.dataStore.volunteers {
            if vol.id == id {
                return vol;
            }
        }
        return ();
    }

    private function loadData() returns DataStore|error {
        string|io:Error content = io:fileReadString(self.filePath);
        if content is io:Error {
            DataStore emptyData = {
                events: [],
                volunteers: [],
                rsvps: []
            };
            return emptyData;
        }

        if content.trim() == "" {
            DataStore emptyData = {
                events: [],
                volunteers: [],
                rsvps: []
            };
            return emptyData;
        }

        json jsonData = check content.fromJsonString();
        DataStore data = check jsonData.cloneWithType(DataStore);
        return data;
    }

    private function saveData() returns error? {
        json jsonData = self.dataStore.toJson();
        check io:fileWriteString(self.filePath, jsonData.toJsonString());
    }
}

// === File JSON RSVPs Repository ===
class FileJsonRsvpsRepo {
    private string filePath = "data.json";
    private DataStore dataStore = {events: [], volunteers: [], rsvps: []};

    *RsvpsRepo;

    function init() returns error? {
        self.dataStore = check self.loadData();
    }

    function create(Rsvp r) returns Rsvp|error {
        // Check for duplicates first
        if self.exists(r.volunteerId, r.eventId) {
            return error("RSVP already exists for this volunteer and event");
        }

        Rsvp newR = r.clone();
        newR.id = uuid:createType4AsString();
        newR.createdAt = time:utcToString(time:utcNow());
        self.dataStore.rsvps.push(newR);
        check self.saveData();
        return newR;
    }

    function list() returns Rsvp[] {
        return self.dataStore.rsvps;
    }

    function exists(string volunteerId, string eventId) returns boolean {
        foreach var r in self.dataStore.rsvps {
            if r.volunteerId == volunteerId && r.eventId == eventId {
                return true;
            }
        }
        return false;
    }

    private function loadData() returns DataStore|error {
        string|io:Error content = io:fileReadString(self.filePath);
        if content is io:Error {
            DataStore emptyData = {
                events: [],
                volunteers: [],
                rsvps: []
            };
            return emptyData;
        }

        if content.trim() == "" {
            DataStore emptyData = {
                events: [],
                volunteers: [],
                rsvps: []
            };
            return emptyData;
        }

        json jsonData = check content.fromJsonString();
        DataStore data = check jsonData.cloneWithType(DataStore);
        return data;
    }

    private function saveData() returns error? {
        json jsonData = self.dataStore.toJson();
        check io:fileWriteString(self.filePath, jsonData.toJsonString());
    }
}
