const express = require('express');
const router = express.Router();
const Course = require('../models/Course');
const User = require('../models/User');
const Progress = require('../models/Progress');

// Get all courses
router.get('/', async (req, res) => {
  try {
    const courses = await Course.find()
      .populate('instructor', 'displayName email')
      .populate('enrolledStudents', 'displayName email');
    
    res.json(courses);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

// Get courses for current user
router.get('/user/courses', async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.user.uid });
    if (!user) return res.status(404).json({ error: 'User not found' });

    const courses = await Course.find({ enrolledStudents: user._id })
      .populate('instructor', 'displayName email');
    
    res.json(courses);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get available courses (not enrolled)
router.get('/user/available', async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.user.uid });
    if (!user) return res.status(404).json({ error: 'User not found' });

    const courses = await Course.find({ 
      enrolledStudents: { $ne: user._id } 
    }).populate('instructor', 'displayName email');
    
    res.json(courses);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get course by ID
router.get('/:id', async (req, res) => {
  try {
    const course = await Course.findById(req.params.id)
      .populate('instructor', 'displayName email')
      .populate('enrolledStudents', 'displayName email');
    
    if (!course) return res.status(404).json({ error: 'Course not found' });
    
    res.json(course);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create new course
router.post('/', async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.user.uid });
    if (!user) return res.status(404).json({ error: 'User not found' });

    const course = new Course({
      ...req.body,
      instructor: user._id
    });

    await course.save();
    res.status(201).json(course);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Update course
router.patch('/:id', async (req, res) => {
  try {
    const course = await Course.findById(req.params.id);
    if (!course) return res.status(404).json({ error: 'Course not found' });

    const user = await User.findOne({ firebaseUid: req.user.uid });
    if (!user) return res.status(404).json({ error: 'User not found' });

    // Check if user is the instructor or admin
    if (course.instructor.toString() !== user._id.toString() && user.role !== 'admin') {
      return res.status(403).json({ error: 'Not authorized to update this course' });
    }

    Object.assign(course, req.body);
    course.updatedAt = new Date();
    await course.save();
    
    res.json(course);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Delete course
router.delete('/:id', async (req, res) => {
  try {
    const course = await Course.findById(req.params.id);
    if (!course) return res.status(404).json({ error: 'Course not found' });

    const user = await User.findOne({ firebaseUid: req.user.uid });
    if (!user) return res.status(404).json({ error: 'User not found' });

    // Check if user is the instructor or admin
    if (course.instructor.toString() !== user._id.toString() && user.role !== 'admin') {
      return res.status(403).json({ error: 'Not authorized to delete this course' });
    }

    await course.remove();
    res.json({ message: 'Course deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Enroll in course
router.post('/:id/enroll', async (req, res) => {
  try {
    const course = await Course.findById(req.params.id);
    if (!course) return res.status(404).json({ error: 'Course not found' });

    const user = await User.findOne({ firebaseUid: req.user.uid });
    if (!user) return res.status(404).json({ error: 'User not found' });

    if (!course.enrolledStudents.includes(user._id)) {
      course.enrolledStudents.push(user._id);
      await course.save();
      
      // Create progress record
      const progress = new Progress({
        userId: user._id,
        courseId: course._id,
        completedTopics: [],
        progressPercentage: 0
      });
      await progress.save();
    }

    res.json({ message: 'Successfully enrolled in course' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Unenroll from course
router.delete('/:id/enroll', async (req, res) => {
  try {
    const course = await Course.findById(req.params.id);
    if (!course) return res.status(404).json({ error: 'Course not found' });

    const user = await User.findOne({ firebaseUid: req.user.uid });
    if (!user) return res.status(404).json({ error: 'User not found' });

    course.enrolledStudents = course.enrolledStudents.filter(
      id => id.toString() !== user._id.toString()
    );
    await course.save();

    // Remove progress record
    await Progress.deleteOne({ userId: user._id, courseId: course._id });

    res.json({ message: 'Successfully unenrolled from course' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get enrolled students
router.get('/:id/students', async (req, res) => {
  try {
    const course = await Course.findById(req.params.id)
      .populate('enrolledStudents', 'displayName email');
    
    if (!course) return res.status(404).json({ error: 'Course not found' });

    res.json(course.enrolledStudents);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get course topics
router.get('/:id/topics', async (req, res) => {
  try {
    const course = await Course.findById(req.params.id);
    if (!course) return res.status(404).json({ error: 'Course not found' });

    res.json(course.topics);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
