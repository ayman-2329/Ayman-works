const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// Initialize Firebase Admin using service account with explicit projectId
function initFirebaseAdmin() {
  // 1) Inline JSON via env var
  if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    try {
      const svc = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
      admin.initializeApp({
        credential: admin.credential.cert(svc),
        projectId: svc.project_id,
      });
      console.log('Firebase Admin initialized using FIREBASE_SERVICE_ACCOUNT_JSON');
      return;
    } catch (e) {
      console.error('Invalid FIREBASE_SERVICE_ACCOUNT_JSON:', e);
    }
  }

  // 2) Local file in server/ folder
  const localPath = path.join(__dirname, 'firebase-service-account.json');
  if (fs.existsSync(localPath)) {
    const svc = require(localPath);
    admin.initializeApp({
      credential: admin.credential.cert(svc),
      projectId: svc.project_id,
    });
    console.log('Firebase Admin initialized using local firebase-service-account.json');
    return;
  }

  // 3) Application Default Credentials as last resort
  try {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
    console.log('Firebase Admin initialized using applicationDefault()');
    return;
  } catch (e) {
    // fallthrough to error
  }

  throw new Error('Firebase Admin credentials not configured. Provide FIREBASE_SERVICE_ACCOUNT_JSON or server/firebase-service-account.json');
}

initFirebaseAdmin();

// MongoDB connection
const mongoURI = 'mongodb+srv://alokgowtham:gowtham()~~@cluster0.wbthei.mongodb.net/placepro';
mongoose.connect(mongoURI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Middleware
const app = express();
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// Verify Firebase token middleware
const verifyFirebaseToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || req.headers.Authorization || '';
    const match = typeof authHeader === 'string' ? authHeader.match(/^Bearer\s+(.+)$/i) : null;
    const token = match && match[1] ? match[1].trim() : null;

    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    return next();
  } catch (error) {
    console.error('Token verification failed:', {
      message: error?.message,
      code: error?.code,
      name: error?.name,
    });
    return res.status(401).json({ error: 'Invalid token', details: error?.code || error?.message });
  }
};

// Models
const User = require('./models/User');
const Course = require('./models/Course');
const Progress = require('./models/Progress');

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', verifyFirebaseToken, require('./routes/users'));
app.use('/api/courses', verifyFirebaseToken, require('./routes/courses'));
app.use('/api/progress', verifyFirebaseToken, require('./routes/progress'));

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
