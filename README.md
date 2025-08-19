# Volunteer Match API (Ballerina)

Connects volunteers with events using a simple matching algorithm (skills, location, availability). Built for a hackathon-ready MVP in **Ballerina**.

---

## Why Ballerina
- HTTP-first services with strong typing for JSON.
- Built-in OpenAPI support and visual diagrams.
- Fast to prototype: perfect for a 6-hour MVP.

---

## MVP Features
- Create Events: `POST /events`
- Register Volunteers: `POST /volunteers`
- Get Matches: `GET /match?volunteerId=...` → returns top events with a score and “why”.
- (Optional) RSVP: `POST /rsvp`

---

## Data Models (v1)

```jsonc
// Event
{
  "id": "auto-generated",
  "title": "string",
  "description": "string",
  "date": "YYYY-MM-DD",
  "location": "string",             // city
  "skills": ["string"],
  "slots": 0                        // remaining slots
}

// Volunteer
{
  "id": "auto-generated",
  "name": "string",
  "skills": ["string"],
  "location": "string",
  "availability": "YYYY-MM-DD"
}

// MatchResult (response item)
{
  "eventId": "string",
  "score": 0,
  "why": "string"
}

API Endpoints (MVP)

POST /events
Body: Event (without id)

201 → created event

400 → validation error

POST /volunteers
Body: Volunteer (without id)

201 → created volunteer

400 → validation error

GET /match?volunteerId={id}

200 → { "volunteerId": "...", "matches": [ MatchResult, ... ] }

404 → volunteer not found

200 with empty list → no suitable matches

POST /rsvp (nice-to-have)
Body: { "volunteerId": "...", "eventId": "..." }

200 → success or “event full”

404 → not found

Matching Logic (v1)

Score =

+2 per overlapping skill (case-insensitive)

+3 if same city

+2 if event date equals volunteer availability

Return top 5 by score (desc) and include a short why string.