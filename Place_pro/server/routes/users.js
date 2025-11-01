const express = require('express');
const router = express.Router();
const User = require('../models/User');

// Get all users (admin only)
router.get('/', async (req, res) => {
  try {
    const currentUser = await User.findOne({ firebaseUid: req.user.uid });
    if (!currentUser || currentUser.role !== 'admin') {
      return res.status(403).json({ error: 'Admin access required' });
    }
    
    const users = await User.find().select('-firebaseUid');
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user by ID
router.get('/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-firebaseUid');
    if (!user) return res.status(404).json({ error: 'User not found' });
    
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update user profile
router.patch('/profile', async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.user.uid });
    if (!user) return res.status(404).json({ error: 'User not found' });

    Object.assign(user, req.body);
    await user.save();
    
    res.json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

module.exports = router;
