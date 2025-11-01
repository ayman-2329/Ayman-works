const express = require('express');
const router = express.Router();
const Progress = require('../models/Progress');
const User = require('../models/User');
const Course = require('../models/Course');

// Get user's progress for all courses
router.get('/', async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.user.uid });
    if (!user) return res.status(404).json({ error: 'User not found' });

    const progress = await Progress.find({ userId: user._id })
      .populate('courseId', 'title description');
    
    res.json(progress);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get progress for specific course
router.get('/course/:courseId', async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.user.uid });
    if (!user) return res.status(404).json({ error: 'User not found' });

    const progress = await Progress.findOne({ 
      userId: user._id, 
      courseId: req.params.courseId 
    }).populate('courseId', 'title description topics');
    
    res.json(progress);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update progress
router.patch('/course/:courseId', async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.user.uid });
    if (!user) return res.status(404).json({ error: 'User not found' });

    const { completedTopics, progressPercentage } = req.body;

    const progress = await Progress.findOneAndUpdate(
      { userId: user._id, courseId: req.params.courseId },
      { 
        completedTopics, 
        progressPercentage,
        lastAccessed: new Date(),
        updatedAt: new Date()
      },
      { new: true, upsert: true }
    );
    
    res.json(progress);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
