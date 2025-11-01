"""
Flask API Server for PlacePro AI Tips and Chatbot
Provides REST endpoints for daily tips and AI chatbot functionality
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import schedule
import time
import threading
from datetime import datetime
import os
import sys

# Add the current directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from tip_generator import get_daily_tip, get_random_tip, generate_ai_tip, tip_generator
from chatbot_enhanced import chatbot

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter web app

# Global variables
server_start_time = datetime.now()

@app.route('/', methods=['GET'])
def health_check():
    """Health check endpoint"""
    uptime = datetime.now() - server_start_time
    return jsonify({
        "status": "healthy",
        "service": "PlacePro AI Backend",
        "uptime": str(uptime),
        "timestamp": datetime.now().isoformat()
    })

@app.route('/api/tip/daily', methods=['GET'])
def get_daily_tip_endpoint():
    """Get the daily tip"""
    try:
        tip = get_daily_tip()
        return jsonify({
            "success": True,
            "tip": tip,
            "timestamp": datetime.now().isoformat(),
            "type": "daily"
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e),
            "tip": "Stay focused on your goals and maintain a positive mindset."
        }), 500

@app.route('/api/tip/random', methods=['GET'])
def get_random_tip_endpoint():
    """Get a random tip, optionally filtered by category"""
    try:
        category = request.args.get('category', None)
        tip = get_random_tip(category)
        return jsonify({
            "success": True,
            "tip": tip,
            "category": category,
            "timestamp": datetime.now().isoformat(),
            "type": "random"
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e),
            "tip": "Stay focused on your goals and maintain a positive mindset."
        }), 500

@app.route('/api/tip/generate', methods=['POST'])
def generate_tip_endpoint():
    """Generate a new AI tip"""
    try:
        data = request.get_json()
        category = data.get('category', 'general')
        context = data.get('context', '')
        
        tip = generate_ai_tip(category, context)
        return jsonify({
            "success": True,
            "tip": tip,
            "category": category,
            "context": context,
            "timestamp": datetime.now().isoformat(),
            "type": "ai_generated"
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e),
            "tip": "Stay focused on your goals and maintain a positive mindset."
        }), 500

@app.route('/api/tip/categories', methods=['GET'])
def get_tip_categories():
    """Get available tip categories"""
    categories = ["productivity", "career", "wellness", "learning", "general"]
    return jsonify({
        "success": True,
        "categories": categories,
        "timestamp": datetime.now().isoformat()
    })

@app.route('/api/chat', methods=['POST'])
def chat_with_bot():
    """Chat with enhanced AI bot endpoint"""
    try:
        data = request.get_json()
        user_message = data.get('message', '')
        
        if not user_message:
            return jsonify({
                'success': False,
                'error': 'Message is required'
            }), 400
        
        # Get enhanced bot response
        bot_response = chatbot.chat(user_message)
        
        return jsonify(bot_response)
        
    except Exception as e:
        print(f"❌ Chat error: {e}")
        return jsonify({
            'success': False,
            'error': 'Failed to process chat message'
        }), 500

@app.route('/api/chat/history', methods=['GET'])
def get_chat_history_endpoint():
    """Get recent chat history"""
    try:
        history = chatbot.get_chat_history()
        return jsonify(history)
    except Exception as e:
        print(f"❌ Error getting chat history: {e}")
        return jsonify({
            "success": False,
            "error": "Failed to get chat history"
        }), 500

@app.route('/api/chat/clear', methods=['POST'])
def clear_chat_history_endpoint():
    """Clear chat history"""
    try:
        result = chatbot.clear_chat_history()
        return jsonify(result)
    except Exception as e:
        print(f"❌ Error clearing chat history: {e}")
        return jsonify({
            "success": False,
            "error": "Failed to clear chat history"
        }), 500

@app.route('/api/stats', methods=['GET'])
def get_stats():
    """Get API usage statistics"""
    try:
        return jsonify({
            "success": True,
            "stats": {
                "server_uptime": str(datetime.now() - server_start_time),
                "tips_available": len(tip_generator.tips_data.get("tips", [])),
                "last_updated": tip_generator.tips_data.get("last_updated", ""),
                "categories": list(tip_generator.tips_data.get("categories", {}).keys())
            },
            "timestamp": datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

def update_daily_tips():
    """Background task to update daily tips"""
    print(f"🔄 Running daily tip update at {datetime.now()}")
    try:
        tip_generator.update_daily_tip()
        print("✅ Daily tips updated successfully")
    except Exception as e:
        print(f"❌ Error updating daily tips: {e}")

def run_scheduler():
    """Run the background scheduler"""
    # Schedule daily tip updates at midnight
    schedule.every().day.at("00:00").do(update_daily_tips)
    
    # Also run every 6 hours as backup
    schedule.every(6).hours.do(update_daily_tips)
    
    print("📅 Scheduler started - Daily tips will update automatically")
    
    while True:
        schedule.run_pending()
        time.sleep(60)  # Check every minute

def start_background_scheduler():
    """Start the background scheduler in a separate thread"""
    scheduler_thread = threading.Thread(target=run_scheduler, daemon=True)
    scheduler_thread.start()

if __name__ == '__main__':
    print("🚀 Starting PlacePro AI Backend Server...")
    
    # Start background scheduler
    start_background_scheduler()
    
    # Run initial tip update
    update_daily_tips()
    
    print("✅ Server ready!")
    print("📡 API Endpoints:")
    print("   GET  /api/tip/daily - Get daily tip")
    print("   GET  /api/tip/random?category=<category> - Get random tip")
    print("   POST /api/tip/generate - Generate AI tip")
    print("   GET  /api/tip/categories - Get available categories")
    print("   POST /api/chat - Chat with AI bot")
    print("   GET  /api/chat/history - Get chat history")
    print("   POST /api/chat/clear - Clear chat history")
    print("   GET  /api/stats - Get server statistics")
    
    # Run Flask app
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=False,
        threaded=True
    )
