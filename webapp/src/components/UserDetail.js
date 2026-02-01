import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';
import './UserDetail.css';

const UserDetail = () => {
  const { userId } = useParams();
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchUser();
  }, [userId]);

  const fetchUser = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`http://localhost:3000/api/users/${userId}`);
      if (response.data.success) {
        setUser(response.data.user);
      } else {
        setError('User not found');
      }
    } catch (err) {
      console.error('Error fetching user:', err);
      setError('Error loading user data');
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
      <div className="user-detail-container">
        <div className="loading">Loading user details...</div>
      </div>
    );
  }

  if (error || !user) {
    return (
      <div className="user-detail-container">
        <div className="error">{error || 'User not found'}</div>
        <button onClick={() => navigate('/')} className="back-button">
          Back to List
        </button>
      </div>
    );
  }

  const risk = getRiskLevel(user.wellnessReport);

  return (
    <div className="user-detail-container">
      <button onClick={() => navigate('/')} className="back-button">
        ← Back to Dashboard
      </button>

      <div className="user-detail-header">
        <div className="user-avatar-large">
          {user.userName ? user.userName.charAt(0).toUpperCase() : '?'}
        </div>
        <div className="user-header-info">
          <h1>{user.userName || 'Unknown'}</h1>
          <div className="user-meta">
            <span>{user.age ? `${user.age} years old` : 'Age not specified'}</span>
            {user.sex && <span>• {user.sex}</span>}
          </div>
          <div className="risk-badge-large" style={{ backgroundColor: risk.color }}>
            {risk.level}
          </div>
        </div>
      </div>

      <div className="user-detail-content">
        <div className="detail-section">
          <h2>Basic Information</h2>
          <div className="info-grid">
            <div className="info-item">
              <span className="info-label">Name</span>
              <span className="info-value">{user.userName || 'Not provided'}</span>
            </div>
            <div className="info-item">
              <span className="info-label">Age</span>
              <span className="info-value">{user.age || 'Not provided'}</span>
            </div>
            <div className="info-item">
              <span className="info-label">Sex</span>
              <span className="info-value">{user.sex || 'Not provided'}</span>
            </div>
            <div className="info-item">
              <span className="info-label">Height</span>
              <span className="info-value">{user.height || 'Not provided'}</span>
            </div>
            <div className="info-item">
              <span className="info-label">Weight</span>
              <span className="info-value">{user.weight || 'Not provided'}</span>
            </div>
            <div className="info-item">
              <span className="info-label">Check Frequency</span>
              <span className="info-value">
                {user.wellnessCheckFrequency 
                  ? `${user.wellnessCheckFrequency} days` 
                  : 'Not set'}
              </span>
            </div>
          </div>
        </div>

        <div className="detail-section">
          <h2>Medical Information</h2>
          <div className="info-box">
            <div className="info-item-full">
              <span className="info-label">Medical Background</span>
              <span className="info-value">
                {user.medicalBackground || 'No information provided'}
              </span>
            </div>
            <div className="info-item-full">
              <span className="info-label">Chronic Conditions</span>
              <span className="info-value">
                {user.chronicConditions || 'No information provided'}
              </span>
            </div>
            <div className="info-item-full">
              <span className="info-label">Current Medications</span>
              <span className="info-value">
                {user.currentMedications || 'No information provided'}
              </span>
            </div>
            <div className="info-item-full">
              <span className="info-label">Hereditary Risk Patterns</span>
              <span className="info-value">
                {user.hereditaryRiskPatterns || 'No information provided'}
              </span>
            </div>
          </div>
        </div>

        <div className="detail-section">
          <h2>Wellness Report</h2>
          <div className="wellness-report-box">
            {user.wellnessReport && user.wellnessReport.trim() !== '' ? (
              <p className="wellness-report-text">{user.wellnessReport}</p>
            ) : (
              <p className="no-report">No wellness report available for this user.</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default UserDetail;
