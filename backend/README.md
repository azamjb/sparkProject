# Spark Backend Setup

This is a simple Node.js backend API that connects your iOS app to the MySQL database.

## Setup Instructions

### 1. Install Node.js
Make sure you have Node.js installed. Check with:
```bash
node --version
npm --version
```

If not installed, download from: https://nodejs.org/

### 2. Install Dependencies
Navigate to the backend folder and install:
```bash
cd backend
npm install
```

### 3. Configure MySQL Password
Edit `server.js` and update the password if your MySQL root user has a password:
```javascript
password: 'YOUR_MYSQL_PASSWORD_HERE', // Add your MySQL password here if you have one
```

### 4. Start the Server
```bash
npm start
```

You should see:
```
✅ Connected to MySQL database
🚀 Server running on http://127.0.0.1:3000
```

### 5. Test the Connection
The server will automatically test the MySQL connection on startup.

## For iOS Simulator
- Use: `http://127.0.0.1:3000` (already configured)

## For Real iOS Device
1. Find your Mac's IP address:
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```
   Look for something like `192.168.1.100`

2. Update `DatabaseService.swift` in your iOS app:
   ```swift
   private let baseURL = "http://YOUR_MAC_IP:3000/api"
   ```

3. Make sure your Mac and iPhone are on the same WiFi network

## API Endpoints

- `POST /api/users` - Create a new user
- `PUT /api/users/:userId` - Update an existing user
- `GET /api/users/:userId` - Get user by ID

## Troubleshooting

- **"Cannot connect to database"**: Make sure MySQL is running
- **"Access denied"**: Check your MySQL password in server.js
- **"Connection refused"**: Make sure the server is running on port 3000
- **iOS can't connect**: Check firewall settings, make sure Mac and device are on same network
