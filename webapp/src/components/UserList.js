import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import './UserList.css';

const UserList = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const response = await axios.get('http://localhost:3000/api/users');
      if (response.data.success) {
        setUsers(response.data.users);
      } else {
        setError('Failed to fetch users');
      }
    } catch (err) {
      console.error('Error fetching users:', err);
      setError('Error connecting to server. Make sure the backend server is running on port 3001.');
    } finally {
      setLoading(false);
    }
  };

  const getRiskLevel = (wellnessReport) => {
    if (!wellnessReport || wellnessReport.trim() === '') {
      return { level: 'No Data', color: '#9E9E9E' };
    }
    const report = wellnessReport.toLowerCase();
    if (report.includes('urgent') || report.includes('severe') || report.includes('critical')) {
      return { level: 'High Risk', color: '#F44336' };
    }
    if (report.includes('appointment') && report.includes('recommended')) {
      return { level: 'Moderate Risk', color: '#FF9800' };
    }
    return { level: 'Low Risk', color: '#4CAF50' };
  };

  if (loading) {
    return (
      <div className="user-list-container">
        <div className="loading">Loading users...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="user-list-container">
        <div className="error">{error}</div>
      </div>
    );
  }

  return (
    <div className="user-list-container">
      <header className="header">
        <h1>Patient Dashboard</h1>
        <p>View and manage patient wellness data</p>
      </header>

      <div className="users-grid">
        {users.map((user) => {
          const risk = getRiskLevel(user.wellnessReport);
          return (
            <div
              key={user.userId}
              className="user-card"
              onClick={() => navigate(`/user/${user.userId}`)}
            >
              <div className="user-card-header">
                <div className="user-avatar">
                  {user.userName ? user.userName.charAt(0).toUpperCase() : '?'}
                </div>
                <div className="user-info">
                  <h3>{user.userName || 'Unknown'}</h3>
                  <p>{user.age ? `${user.age} years old` : 'Age not specified'}</p>
                </div>
              </div>
              
              <div className="user-card-body">
                <div className="user-detail-row">
                  <span className="label">Sex:</span>
                  <span className="value">{user.sex || 'Not specified'}</span>
                </div>
                <div className="user-detail-row">
                  <span className="label">Check Frequency:</span>
                  <span className="value">
                    {user.wellnessCheckFrequency 
                      ? `${user.wellnessCheckFrequency} days` 
                      : 'Not set'}
                  </span>
                </div>
              </div>

              <div className="user-card-footer">
                <div className="risk-badge" style={{ backgroundColor: risk.color }}>
                  {risk.level}
                </div>
                {user.wellnessReport && user.wellnessReport.trim() !== '' && (
                  <span className="has-report">Has Report</span>
                )}
              </div>
            </div>
          );
        })}
      </div>

      {users.length === 0 && (
        <div className="empty-state">
          <p>No users found in the database.</p>
        </div>
      )}
    </div>
  );
};

export default UserList;
