"""
Startup script for PlacePro AI Backend
Handles dependency installation and server startup
"""

import subprocess
import sys
import os
import time

def install_dependencies():
    """Install required Python packages"""
    print("🔧 Installing Python dependencies...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        print("✅ Dependencies installed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error installing dependencies: {e}")
        return False

def check_python_version():
    """Check if Python version is compatible"""
    version = sys.version_info
    if version.major >= 3 and version.minor >= 8:
        print(f"✅ Python {version.major}.{version.minor}.{version.micro} detected")
        return True
    else:
        print(f"❌ Python 3.8+ required, found {version.major}.{version.minor}.{version.micro}")
        return False

def start_server():
    """Start the Flask server"""
    print("🚀 Starting PlacePro AI Backend Server...")
    try:
        # Change to the backend directory
        os.chdir(os.path.dirname(os.path.abspath(__file__)))
        
        # Start the Flask app
        subprocess.run([sys.executable, "app.py"])
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except Exception as e:
        print(f"❌ Error starting server: {e}")

def main():
    print("=" * 50)
    print("🤖 PlacePro AI Backend Startup")
    print("=" * 50)
    
    # Check Python version
    if not check_python_version():
        sys.exit(1)
    
    # Install dependencies
    if not install_dependencies():
        print("⚠️  Continuing with existing packages...")
    
    # Wait a moment
    time.sleep(2)
    
    # Start server
    start_server()

if __name__ == "__main__":
    main()
