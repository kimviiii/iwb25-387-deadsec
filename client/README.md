# Volunteer Match Frontend

The **frontend** for the Volunteer Match platform — a simple React + TypeScript app styled with Tailwind CSS and shadcn-ui.  
It connects to the backend API and provides pages for events, volunteers, matches, and registration.

---

## ⚙️ Tech Stack

- **Framework**: [React](https://react.dev/) + [Vite](https://vitejs.dev/)  
- **Language**: TypeScript  
- **Styling**: Tailwind CSS + shadcn-ui  
- **Build Tool**: Vite  
- **Infra/DevX**: Works locally or via Docker Compose (see root README)

---

## 🚀 Quickstart

### 1. Run Locally

Make sure you have **Node.js** & **npm** installed.  
(Recommended: install via [nvm](https://github.com/nvm-sh/nvm#installing-and-updating))

```bash
# Step 1: Clone the repository
git clone <YOUR_GIT_URL>

# Step 2: Navigate to the frontend project
cd volunteer-match/frontend

# Step 3: Install dependencies
npm i

# Step 4: Start the dev server
npm run dev
```

Visit: [http://localhost:8080](http://localhost:8080)

---

### 2. Run with Docker Compose

From the **project root** (not the frontend folder):

```bash
docker compose up --build
```

This will build both backend and frontend together.  
Frontend will be available at [http://localhost:8080](http://localhost:8080).

---

## 🛠 Editing the Code

- Open in your IDE (e.g., VS Code).  
- Modify `.tsx` components inside `/src`.  
- Changes auto-reload when running `npm run dev`.  

Alternatively:  
- Edit files directly on GitHub and commit changes.  
- Or use GitHub Codespaces to develop in the cloud.

---

## 📂 Repo Structure (Frontend)

```
/frontend
  ├── public        → Static assets
  ├── src           → React source code (.tsx)
  │    ├── pages    → App pages (Home, Events, Matches, etc.)
  │    ├── components → UI components (EventCard, MatchList, etc.)
  ├── index.html    → Entry HTML
  ├── package.json  → Dependencies & scripts
  └── vite.config.ts → Vite configuration
```

---

## 🌐 Deployment

You can deploy the frontend to any static hosting provider:  

- **Vercel**  
- **Netlify**  
- **GitHub Pages**  
- **Cloudflare Pages**  

For production with backend, prefer **Docker Compose** deployment (see root README).

---

## 📝 License

MIT
