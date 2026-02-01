# Spark Web Dashboard

A React web application for viewing patient wellness data from the Spark database.

## Setup

### 1. Install Dependencies

```bash
cd webapp
npm install
```

### 2. Start the Backend Server

Make sure the existing backend server is running (it's already configured to serve the webapp endpoints):

```bash
cd backend
npm start
```

The backend runs on port 3000 and now includes endpoints for the web dashboard.

### 3. Start the React App

```bash
cd webapp
npm start
```

The app will open at `http://localhost:3000` (React's default port). 

**Note:** If port 3000 is already in use by the backend, React will ask to use a different port (like 3001). That's fine - just make sure the backend is running on port 3000.

## Features

- **User List View**: Displays all users from the database as cards
- **User Detail View**: Click on any user card to see detailed information including:
  - Basic information (name, age, sex, height, weight)
  - Medical information (background, conditions, medications, hereditary risks)
  - Wellness report (if available)

## API Endpoints

The backend provides:
- `GET /api/users` - Get all users
- `GET /api/users/:userId` - Get a specific user's details

## Database Connection

The app connects to the same MySQL database as the iOS app:
- Database: `sparkProj`
- Table: `USERS`
- Default password: `GuppyAzam123` (can be changed via `MYSQL_PASSWORD` environment variable)
