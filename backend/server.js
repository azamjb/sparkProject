// Simple Node.js backend for MySQL database
// Run with: node server.js
// Make sure to install dependencies: npm install express mysql2 cors

const express = require("express");
const mysql = require("mysql2/promise");
const cors = require("cors");

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// MySQL connection configuration
// If you have a password, set it here. If no password, leave as empty string or undefined
const MYSQL_PASSWORD = process.env.MYSQL_PASSWORD || ""; // Can also set via environment variable

const dbConfig = {
  host: "127.0.0.1",
  port: 3306,
  user: "root",
  password: "GuppyAzam123",
  database: "sparkProj",
};

// Only add password if it's provided
if (MYSQL_PASSWORD) {
  dbConfig.password = MYSQL_PASSWORD;
}

// Create connection pool
const pool = mysql.createPool({
  ...dbConfig,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// Test database connection
pool
  .getConnection()
  .then((connection) => {
    console.log("✅ Connected to MySQL database");
    connection.release();
  })
  .catch((err) => {
    console.error("❌ Database connection error:", err.message);
    console.log("💡 Make sure MySQL is running and credentials are correct");
  });

// Create user endpoint
app.post("/api/users", async (req, res) => {
  try {
    const {
      userName,
      age,
      height,
      weight,
      sex,
      medicalBackground,
      chronicConditions,
      currentMedications,
      hereditaryRiskPatterns,
      wellnessCheckFrequency,
      wellnessReport,
    } = req.body;

    const [result] = await pool.execute(
      `INSERT INTO USERS (
                userName, age, height, weight, sex,
                medicalBackground, chronicConditions, currentMedications,
                hereditaryRiskPatterns, wellnessCheckFrequency, wellnessReport
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        userName || "",
        age || "",
        height || "",
        weight || "",
        sex || "",
        medicalBackground || "",
        chronicConditions || "",
        currentMedications || "",
        hereditaryRiskPatterns || "",
        wellnessCheckFrequency || "",
        wellnessReport || "",
      ],
    );

    res.status(201).json({
      success: true,
      userId: result.insertId,
      message: "User created successfully",
    });
  } catch (error) {
    console.error("Error creating user:", error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// Update wellness report endpoint - MUST come before /api/users/:userId
app.put("/api/users/:userId/wellness-report", async (req, res) => {
  try {
    const userId = req.params.userId;
    const { wellnessReport } = req.body;

    console.log(`📝 Updating wellness report for user ${userId}`);

    await pool.execute(
      "UPDATE USERS SET wellnessReport = ? WHERE userId = ?",
      [wellnessReport || "", userId]
    );

    res.status(200).json({
      success: true,
      message: "Wellness report updated successfully",
    });
  } catch (error) {
    console.error("Error updating wellness report:", error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// Update wellness check frequency endpoint - MUST come before /api/users/:userId
app.put("/api/users/:userId/wellness-frequency", async (req, res) => {
  try {
    const userId = req.params.userId;
    const { wellnessCheckFrequency } = req.body;

    console.log(`📊 Updating wellness check frequency for user ${userId}: ${wellnessCheckFrequency} days`);

    await pool.execute(
      "UPDATE USERS SET wellnessCheckFrequency = ? WHERE userId = ?",
      [wellnessCheckFrequency || "", userId]
    );

    res.status(200).json({
      success: true,
      message: "Wellness check frequency updated successfully",
    });
  } catch (error) {
    console.error("Error updating wellness check frequency:", error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// Update user endpoint
app.put("/api/users/:userId", async (req, res) => {
  try {
    const userId = req.params.userId;
    const {
      userName,
      age,
      height,
      weight,
      sex,
      medicalBackground,
      chronicConditions,
      currentMedications,
      hereditaryRiskPatterns,
    } = req.body;

    await pool.execute(
      `UPDATE USERS SET
                userName = ?, age = ?, height = ?, weight = ?, sex = ?,
                medicalBackground = ?, chronicConditions = ?, currentMedications = ?,
                hereditaryRiskPatterns = ?
            WHERE userId = ?`,
      [
        userName || "",
        age || "",
        height || "",
        weight || "",
        sex || "",
        medicalBackground || "",
        chronicConditions || "",
        currentMedications || "",
        hereditaryRiskPatterns || "",
        userId,
      ],
    );

    res.status(200).json({
      success: true,
      message: "User updated successfully",
    });
  } catch (error) {
    console.error("Error updating user:", error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

    // Get all users endpoint (for web dashboard)
    app.get("/api/users", async (req, res) => {
      try {
        const [rows] = await pool.execute(
          "SELECT userId, userName, age, sex, wellnessCheckFrequency, wellnessReport FROM USERS ORDER BY userId DESC"
        );
        res.status(200).json({ success: true, users: rows });
      } catch (error) {
        console.error("Error fetching users:", error);
        res.status(500).json({ success: false, error: error.message });
      }
    });

// Get all users endpoint (for web dashboard)
app.get("/api/users", async (req, res) => {
  try {
    const [rows] = await pool.execute(
      "SELECT userId, userName, age, sex, wellnessCheckFrequency, wellnessReport FROM USERS ORDER BY userId DESC"
    );
    res.status(200).json({ success: true, users: rows });
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get user endpoint
app.get("/api/users/:userId", async (req, res) => {
      try {
        const userId = req.params.userId;
        const [rows] = await pool.execute("SELECT * FROM USERS WHERE userId = ?", [
          userId,
        ]);

        if (rows.length === 0) {
          return res.status(404).json({
            success: false,
            message: "User not found",
          });
        }

        res.status(200).json({
          success: true,
          user: rows[0],
        });
      } catch (error) {
        console.error("Error fetching user:", error);
        res.status(500).json({
          success: false,
          error: error.message,
        });
      }
    });

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://127.0.0.1:${PORT}`);
  console.log(`📱 For iOS simulator, use: http://127.0.0.1:${PORT}`);
  console.log(`📱 For real device, use your Mac's IP address`);
});
