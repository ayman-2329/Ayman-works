"""
Test script for PlacePro AI Backend
Tests all endpoints and functionality
"""

import requests
import json
import time
from datetime import datetime

BASE_URL = "http://localhost:5000"

def test_health_check():
    """Test server health"""
    try:
        response = requests.get(f"{BASE_URL}/", timeout=5)
        if response.status_code == 200:
            print("✅ Health check passed")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

def test_daily_tip():
    """Test daily tip endpoint"""
    try:
        response = requests.get(f"{BASE_URL}/api/tip/daily", timeout=10)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print(f"✅ Daily tip: {data['tip'][:50]}...")
                return True
            else:
                print(f"❌ Daily tip failed: {data.get('error')}")
                return False
        else:
            print(f"❌ Daily tip HTTP error: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Daily tip error: {e}")
        return False

def test_random_tip():
    """Test random tip endpoint"""
    try:
        response = requests.get(f"{BASE_URL}/api/tip/random?category=productivity", timeout=10)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print(f"✅ Random tip: {data['tip'][:50]}...")
                return True
            else:
                print(f"❌ Random tip failed: {data.get('error')}")
                return False
        else:
            print(f"❌ Random tip HTTP error: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Random tip error: {e}")
        return False

def test_ai_generation():
    """Test AI tip generation"""
    try:
        payload = {
            "category": "career",
            "context": "interview preparation"
        }
        response = requests.post(
            f"{BASE_URL}/api/tip/generate",
            json=payload,
            timeout=15
        )
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print(f"✅ AI generated tip: {data['tip'][:50]}...")
                return True
            else:
                print(f"❌ AI generation failed: {data.get('error')}")
                return False
        else:
            print(f"❌ AI generation HTTP error: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ AI generation error: {e}")
        return False

def test_chatbot():
    """Test chatbot endpoint"""
    try:
        payload = {"message": "How should I prepare for technical interviews?"}
        response = requests.post(
            f"{BASE_URL}/api/chat",
            json=payload,
            timeout=15
        )
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print(f"✅ Chatbot response: {data['response'][:50]}...")
                return True
            else:
                print(f"❌ Chatbot failed: {data.get('error')}")
                return False
        else:
            print(f"❌ Chatbot HTTP error: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Chatbot error: {e}")
        return False

def test_categories():
    """Test categories endpoint"""
    try:
        response = requests.get(f"{BASE_URL}/api/tip/categories", timeout=10)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print(f"✅ Categories: {data['categories']}")
                return True
            else:
                print(f"❌ Categories failed: {data.get('error')}")
                return False
        else:
            print(f"❌ Categories HTTP error: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Categories error: {e}")
        return False

def test_stats():
    """Test stats endpoint"""
    try:
        response = requests.get(f"{BASE_URL}/api/stats", timeout=10)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                stats = data['stats']
                print(f"✅ Server stats: {stats['tips_available']} tips available")
                return True
            else:
                print(f"❌ Stats failed: {data.get('error')}")
                return False
        else:
            print(f"❌ Stats HTTP error: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Stats error: {e}")
        return False

def run_all_tests():
    """Run comprehensive test suite"""
    print("🧪 PlacePro AI Backend Test Suite")
    print("=" * 50)
    
    tests = [
        ("Health Check", test_health_check),
        ("Daily Tip", test_daily_tip),
        ("Random Tip", test_random_tip),
        ("AI Generation", test_ai_generation),
        ("Chatbot", test_chatbot),
        ("Categories", test_categories),
        ("Stats", test_stats),
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n🔍 Testing {test_name}...")
        if test_func():
            passed += 1
        time.sleep(1)  # Brief pause between tests
    
    print("\n" + "=" * 50)
    print(f"📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Backend is working correctly.")
    else:
        print("⚠️  Some tests failed. Check server logs for details.")
    
    return passed == total

if __name__ == "__main__":
    print("Starting backend tests...")
    print("Make sure the backend server is running on localhost:5000")
    print()
    
    # Wait for user confirmation
    input("Press Enter to start tests...")
    
    success = run_all_tests()
    
    if success:
        print("\n✅ Backend ready for Flutter integration!")
    else:
        print("\n❌ Please fix issues before using with Flutter app.")
