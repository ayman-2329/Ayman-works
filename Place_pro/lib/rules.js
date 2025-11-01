// Firestore rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Courses collection
    match /courses/{courseId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      
      // Course topics
      match /topics/{topicId} {
        allow read: if request.auth != null;
        allow create, update, delete: if request.auth != null && 
          get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      }
    }
    
    // Aptitude questions
    match /aptitude/{category}/{questionId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Logical problems
    match /logical/{category}/{problemId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Drives
    match /drives/{driveId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notes
    match /notes/{noteId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Progress tracking
    match /progress/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Course progress
      match /courses/{courseId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Aptitude progress
      match /aptitude/{questionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Logical progress
      match /logical/{problemId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Calendar events
    match /calendar_events/{eventId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Chat responses
    match /chat_responses/{responseId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}

// Storage rules
service firebase.storage {
  match /b/{bucket}/o {
    // Resumes
    match /resumes/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Course materials
    match /courses/{courseId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notes
    match /notes/{noteId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}