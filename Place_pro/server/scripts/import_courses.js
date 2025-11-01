const mongoose = require('mongoose');
const Course = require('../models/Course');
const User = require('../models/User');
const fs = require('fs');
const path = require('path');

// MongoDB connection
const mongoURI = 'mongodb+srv://alokgowtham:gowtham()~~@cluster0.wbthei.mongodb.net/placepro';

async function importCourses() {
  try {
    // Connect to MongoDB
    await mongoose.connect(mongoURI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('Connected to MongoDB');

    // Create a default instructor user if not exists
    let instructor = await User.findOne({ email: 'admin@saec.ac.in' });
    if (!instructor) {
      instructor = new User({
        displayName: 'SAEC Admin',
        email: 'admin@saec.ac.in',
        role: 'admin',
        firebaseUid: 'admin-uid'
      });
      await instructor.save();
      console.log('Created default instructor');
    }

    // Determine source JSON file: --file <path> or default to python_basics.json
    const fileFlagIdx = process.argv.indexOf('--file');
    let jsonPath = path.join(__dirname, '../models/python_basics.json');
    if (fileFlagIdx !== -1 && process.argv[fileFlagIdx + 1]) {
      const provided = process.argv[fileFlagIdx + 1];
      jsonPath = path.isAbsolute(provided)
        ? provided
        : path.join(__dirname, provided);
    }
    if (!fs.existsSync(jsonPath)) {
      throw new Error(`JSON file not found: ${jsonPath}`);
    }
    console.log(`Using course data file: ${path.relative(__dirname, jsonPath)}`);
    const courseData = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

    // Flags
    const force = process.argv.includes('--force') || process.argv.includes('--upsert');

    // Transform and import each course
    for (const [courseKey, courseInfo] of Object.entries(courseData.courses)) {
      // Check if course already exists
      const existingCourse = await Course.findOne({ title: courseInfo.title });
      
      // Transform lessons to topics format
      const topics = courseInfo.lessons.map(lesson => ({
        title: lesson.title,
        content: JSON.stringify(lesson.content), // Store full lesson content as JSON string
        order: lesson.order,
        duration: 30 // Default 30 minutes per lesson
      }));

      if (existingCourse) {
        // Upsert logic: if --force, overwrite. If topics empty/missing, fill them.
        const hadTopics = Array.isArray(existingCourse.topics) && existingCourse.topics.length > 0;
        if (force || !hadTopics) {
          existingCourse.description = courseInfo.description || existingCourse.description;
          existingCourse.instructor = existingCourse.instructor || instructor._id;
          existingCourse.topics = topics;
          existingCourse.updatedAt = new Date();
          await existingCourse.save();
          console.log(`Course "${courseInfo.title}" already exists, ${force ? 'overwrote' : 'added'} topics.`);
        } else {
          console.log(`Course "${courseInfo.title}" already exists with topics, skipping...`);
        }
        continue;
      }

      // Create new course
      const newCourse = new Course({
        title: courseInfo.title,
        description: courseInfo.description,
        instructor: instructor._id,
        topics: topics,
        enrolledStudents: []
      });

      await newCourse.save();
      console.log(`Imported course: ${courseInfo.title}`);
    }

    console.log('Course import completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error importing courses:', error);
    process.exit(1);
  }
}

// Run the import
importCourses();

