class MongoDBConfig {
  // Update these values with your actual MongoDB connection details
  // API Server URL (change this based on your deployment)
  static const String baseUrl = 'http://localhost:3000/api';
  
  // For production deployment, use:
  // static const String baseUrl = 'https://your-app-name.herokuapp.com/api';
  
  // MongoDB Atlas connection string (for server use only)
  static const String mongoConnectionString = 'mongodb+srv://alokgowtham:gowtham()~~@cluster0.wbthei.mongodb.net/placepro';
  
  // Endpoints
  static const String coursesEndpoint = '/courses';
  static const String usersEndpoint = '/users';
  static const String progressEndpoint = '/progress';
  static const String authEndpoint = '/auth';
  
  // MongoDB Atlas connection string (for direct MongoDB connection if needed)
  static const String connectionString = 'mongodb+srv://alokgowtham:gowtham()~~@cluster0.wbthei.mongodb.net/placepro';
  
  // Database name
  static const String databaseName = 'placepro';
  
  // Collection names
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String progressCollection = 'progress';
  static const String enrollmentsCollection = 'enrollments';
}
