const express = require('express');
const router = express.Router();
const User = require('../models/User');
const admin = require('firebase-admin');

// Register/Login user
router.post('/register', async (req, res) => {
  try {
    const { firebaseUid, email, displayName, role = 'student' } = req.body;
    
    // Check if user already exists
    let user = await User.findOne({ firebaseUid });
    
    if (!user) {
      // Create new user
      user = new User({
        firebaseUid,
        email,
        displayName,
        role
      });
      await user.save();
    }
    
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user profile
router.get('/profile', async (req, res) => {
  try {
    const token = req.headers.authorization?.split('Bearer ')[1];
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decodedToken = await admin.auth().verifyIdToken(token);
    const user = await User.findOne({ firebaseUid: decodedToken.uid });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
