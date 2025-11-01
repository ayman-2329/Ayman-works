# PlacePro AI Backend - Setup & Usage Guide

## 🤖 Overview
This AI-powered backend provides intelligent daily tips and chatbot functionality for the PlacePro Flutter application using Hugging Face Transformers.

## 🚀 Quick Start

### Option 1: Windows Batch Script
```bash
# Double-click or run from command line
start_ai_backend.bat
```

### Option 2: Manual Setup
```bash
# Navigate to backend directory
cd python_backend

# Install dependencies
pip install -r requirements.txt

# Start the server
python app.py
```

## 📋 Requirements
- Python 3.8+
- 4GB+ RAM (for AI models)
- Internet connection (for initial model download)

## 🔧 Dependencies
- **Flask**: Web server framework
- **Transformers**: Hugging Face AI models
- **PyTorch**: Machine learning backend
- **Flask-CORS**: Cross-origin requests support

## 🌐 API Endpoints

### Daily Tips
- `GET /api/tip/daily` - Get today's AI-generated tip
- `GET /api/tip/random?category=<category>` - Get random tip by category
- `POST /api/tip/generate` - Generate new AI tip
- `GET /api/tip/categories` - Get available categories

### AI Chatbot
- `POST /api/chat` - Chat with AI bot
- `GET /api/chat/history` - Get conversation history
- `POST /api/chat/clear` - Clear chat history

### System
- `GET /` - Health check
- `GET /api/stats` - Server statistics

## 📊 Categories
- **Productivity**: Time management, organization
- **Career**: Job search, professional development
- **Wellness**: Health, stress management
- **Learning**: Study techniques, skill development

## 🔄 Auto-Generation
- Tips auto-update daily at midnight
- Backup updates every 6 hours
- AI models generate contextual content
- Fallback to curated tips if AI unavailable

## 🛠️ Configuration
Edit `data/daily_tips.json` to:
- Add custom tips
- Modify categories
- Update fallback content

## 📱 Flutter Integration
The Flutter app automatically:
- Checks backend availability
- Falls back to local tips if offline
- Displays AI-powered or static content
- Handles errors gracefully

## 🔍 Troubleshooting

### Backend Not Starting
1. Check Python version: `python --version`
2. Install dependencies: `pip install -r requirements.txt`
3. Check port 5000 availability

### AI Models Not Loading
1. Ensure stable internet connection
2. Allow 2-3 minutes for initial download
3. Check available disk space (2GB+)

### Flutter Connection Issues
1. Verify backend running on `localhost:5000`
2. Check CORS configuration
3. Ensure network permissions

## 📈 Performance
- **Startup Time**: 30-60 seconds (first run)
- **Response Time**: 1-3 seconds per request
- **Memory Usage**: 1-2GB RAM
- **Model Size**: ~500MB download

## 🔐 Security
- CORS enabled for Flutter web
- No authentication required (local use)
- Input validation on all endpoints
- Error handling prevents crashes

## 📝 Logs
Server logs display:
- ✅ Successful operations
- ❌ Errors and warnings
- 🔄 Scheduled updates
- 📊 Usage statistics

## 🎯 Example Usage

### Get Daily Tip
```bash
curl http://localhost:5000/api/tip/daily
```

### Chat with Bot
```bash
curl -X POST http://localhost:5000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "How do I prepare for interviews?"}'
```

### Generate Custom Tip
```bash
curl -X POST http://localhost:5000/api/tip/generate \
  -H "Content-Type: application/json" \
  -d '{"category": "productivity", "context": "time management"}'
```

## 🔧 Development
To modify the AI behavior:
1. Edit `tip_generator.py` for tip generation
2. Edit `chatbot.py` for conversation logic
3. Update `data/daily_tips.json` for content
4. Restart server to apply changes

## 📞 Support
For issues or questions:
1. Check logs for error messages
2. Verify all dependencies installed
3. Ensure Python 3.8+ compatibility
4. Test API endpoints individually
