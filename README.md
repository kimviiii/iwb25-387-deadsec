# Volunteer Match Platform

A simple platform that connects **event organizers** with **volunteers**, featuring explainable matching, RSVP with capacity checks, and lightweight cloud integration.

---

## 🌍 Problem & Solution

**Problem**  
Event organizers often struggle to find the right volunteers quickly, while volunteers don’t know which opportunities truly fit their skills, time, and location.

**Solution**  
Volunteer Match makes it easy for organizers to post events and for volunteers to register, browse, and get ranked matches. Our matching algorithm is **transparent**: it explains *why* a volunteer is a good fit — increasing trust and fairness.

---

## ⚙️ Tech Stack

- **Backend**: [Ballerina](https://ballerina.io/) (HTTP service, OpenAPI, JSON)
- **Database**:  
  - **MongoDB Atlas Free Tier** via [Data API](https://www.mongodb.com/atlas/database)  
  - Fallbacks: **in-memory** & **fileJson** (for local/demo use)
- **Frontend**: React + Vite (TypeScript `.tsx` components) — can scaffold with [Lovable](https://lovable.dev/)
- **Infra/DevX**: Docker, GitHub Actions (build + test), Postman collection
- **Docs**: OpenAPI spec, Postman, Architecture diagram

---

## 📡 API Endpoints

### Health
- `GET /health`

### Events
- `POST /events`
- `GET /events`
- `GET /events/{id}`

### Volunteers
- `POST /volunteers`
- `GET /volunteers`
- `GET /volunteers/{id}`

### Matching
- `GET /match?volunteerId=...`

### RSVP
- `POST /rsvp`
- `GET /rsvps`

### Utilities
- `GET /export`
- `POST /reset` (dev/demo only)

---

## 🔍 Matching v2

Matches are scored with transparent weights:

- **+4** per overlapping skill (case-insensitive)  
- **+5** if same city  
- **+3** if date matches (exact or ±1 day)  
- **+1** bonus if event slots > 0  

Example:  
`2 skills (+8), same city (+5), date match (+3) = 16`

The API returns the **top 5 matches with breakdowns**.

---

## 🚀 Quickstart

### 1. Run in Local Demo Mode (inMemory/fileJson)
```bash
git clone https://github.com/YOUR-ORG/volunteer-match.git
cd volunteer-match
bal run
```

Visit: [http://localhost:8090/health](http://localhost:8090/health)  
→ should return `{ "status": "ok" }`

---

### 2. Run with Docker
```bash
docker build -t volunteer-match .
docker run -p 8090:8090 volunteer-match
```

---

### 3. Run with Docker Compose

Build and start both **backend (Ballerina)** and **frontend (React + Vite)** services together:

```bash
docker compose up --build
```

This will:

- Build the backend JAR and package it in a lightweight JRE container  
- Build the frontend (TypeScript/React) into static files and serve via Nginx  
- Create a shared Docker network and run both containers  

When successful, you’ll see logs like:

```
volunthere-backend  | HTTP service started on port 8090 ✅
volunthere-client   | nginx: start worker processes
```

Then visit:

- **Backend API** → [http://localhost:8090/health](http://localhost:8090/health)  
- **Frontend App** → [http://localhost:5173](http://localhost:5173) (or port set in `docker-compose.yml`)  

To stop containers:

```bash
docker compose down
```

---

### 4. Connect to MongoDB Atlas
Set env vars (from your Atlas project):
```bash
USE_ATLAS=true
ATLAS_DATA_API_BASE=https://data.mongodb-api.com/app/<app-id>/endpoint/data/v1
ATLAS_API_KEY=xxxxxxxxxxxxxxxx
ATLAS_PROJECT_ID=xxxxxxxxxxxxxxxx
ATLAS_DB=volunteer_match
ATLAS_CLUSTER=Cluster0
```

Run again:
```bash
bal run
```

---

## 📂 Repo Structure
```
/backend      → Ballerina service + repos (inMemory, fileJson, atlasRepo)
/frontend     → React (Vite, TSX)
/postman      → Postman collection
/archive      → Old code & experiments
```

---

## 📝 License
MIT
