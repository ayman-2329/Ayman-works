"""
AI-Powered Daily Tips Generator using Hugging Face Transformers
Generates contextual tips for students and professionals
"""

import json
import random
import os
from datetime import datetime, timedelta
from transformers import pipeline, AutoTokenizer, AutoModelForCausalLM
import torch
import threading
import time

class TipGenerator:
    def __init__(self):
        self.tips_file = os.path.join(os.path.dirname(__file__), 'data', 'daily_tips.json')
        self.model_name = "microsoft/DialoGPT-medium"
        self.tip_generator = None
        self.load_model()
        self.tips_data = self.load_tips()
        
    def load_model(self):
        """Initialize the Hugging Face model for tip generation"""
        try:
            # Use a lightweight model for tip generation
            self.tip_generator = pipeline(
                "text-generation",
                model="gpt2",
                tokenizer="gpt2",
                max_length=100,
                num_return_sequences=1,
                temperature=0.7,
                do_sample=True,
                pad_token_id=50256
            )
            print("✅ AI model loaded successfully")
        except Exception as e:
            print(f"❌ Error loading model: {e}")
            self.tip_generator = None
    
    def load_tips(self):
        """Load tips from JSON file"""
        try:
            with open(self.tips_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"❌ Tips file not found: {self.tips_file}")
            return {"tips": [], "categories": {}, "last_updated": "", "current_tip_index": 0}
        except json.JSONDecodeError as e:
            print(f"❌ Error parsing JSON: {e}")
            return {"tips": [], "categories": {}, "last_updated": "", "current_tip_index": 0}
    
    def save_tips(self):
        """Save tips to JSON file"""
        try:
            with open(self.tips_file, 'w', encoding='utf-8') as f:
                json.dump(self.tips_data, f, indent=2, ensure_ascii=False)
            print("✅ Tips saved successfully")
        except Exception as e:
            print(f"❌ Error saving tips: {e}")
    
    def generate_ai_tip(self, category="general", context=""):
        """Generate a new tip using AI model"""
        if not self.tip_generator:
            return self.get_random_tip()
        
        try:
            # Create prompts based on category
            prompts = {
                "productivity": f"Here's a productivity tip for students and professionals: {context}",
                "career": f"Career advice for students entering the job market: {context}",
                "wellness": f"Health and wellness tip for busy professionals: {context}",
                "learning": f"Effective learning strategy for students: {context}",
                "general": f"Daily tip for personal and professional growth: {context}"
            }
            
            prompt = prompts.get(category, prompts["general"])
            
            # Generate tip using the model
            result = self.tip_generator(
                prompt,
                max_length=80,
                num_return_sequences=1,
                temperature=0.8,
                do_sample=True
            )
            
            generated_text = result[0]['generated_text']
            # Extract the tip part (remove the prompt)
            tip = generated_text.replace(prompt, "").strip()
            
            # Clean up the generated tip
            tip = self.clean_generated_tip(tip)
            
            return tip if tip else self.get_random_tip()
            
        except Exception as e:
            print(f"❌ Error generating AI tip: {e}")
            return self.get_random_tip()
    
    def clean_generated_tip(self, tip):
        """Clean and format the generated tip"""
        # Remove unwanted characters and format properly
        tip = tip.strip()
        if not tip:
            return ""
        
        # Ensure the tip ends with a period
        if not tip.endswith('.'):
            tip += '.'
        
        # Capitalize first letter
        tip = tip[0].upper() + tip[1:] if len(tip) > 1 else tip.upper()
        
        # Remove any incomplete sentences
        sentences = tip.split('.')
        complete_sentences = [s.strip() for s in sentences if len(s.strip()) > 10]
        
        return '. '.join(complete_sentences) + '.' if complete_sentences else ""
    
    def get_daily_tip(self):
        """Get the tip of the day"""
        today = datetime.now().strftime("%Y-%m-%d")
        
        # Check if we need to update for today
        if self.tips_data.get("last_updated") != today:
            self.update_daily_tip()
        
        # Get current tip
        current_index = self.tips_data.get("current_tip_index", 0)
        tips = self.tips_data.get("tips", [])
        
        if tips and current_index < len(tips):
            return f"Tip of the Day: {tips[current_index]}"
        else:
            return "Tip of the Day: Stay focused on your goals and maintain a positive mindset."
    
    def get_random_tip(self, category=None):
        """Get a random tip from the specified category or all tips"""
        if category and category in self.tips_data.get("categories", {}):
            tips = self.tips_data["categories"][category]
        else:
            tips = self.tips_data.get("tips", [])
        
        if tips:
            return random.choice(tips)
        else:
            return "Stay focused on your goals and maintain a positive mindset."
    
    def update_daily_tip(self):
        """Update the daily tip and generate new ones if needed"""
        today = datetime.now().strftime("%Y-%m-%d")
        
        # Generate a new AI tip and add it to the collection
        categories = ["productivity", "career", "wellness", "learning"]
        random_category = random.choice(categories)
        
        new_tip = self.generate_ai_tip(random_category)
        
        if new_tip and new_tip not in self.tips_data.get("tips", []):
            self.tips_data.setdefault("tips", []).append(new_tip)
        
        # Update current tip index
        tips_count = len(self.tips_data.get("tips", []))
        if tips_count > 0:
            self.tips_data["current_tip_index"] = random.randint(0, tips_count - 1)
        
        # Update last updated date
        self.tips_data["last_updated"] = today
        
        # Save the updated tips
        self.save_tips()
        
        print(f"✅ Daily tip updated for {today}")
    
    def get_tip_by_category(self, category):
        """Get a tip from a specific category"""
        if category in self.tips_data.get("categories", {}):
            tips = self.tips_data["categories"][category]
            return random.choice(tips) if tips else self.get_random_tip()
        else:
            return self.get_random_tip()
    
    def add_custom_tip(self, tip, category="general"):
        """Add a custom tip to the collection"""
        if category in self.tips_data.get("categories", {}):
            self.tips_data["categories"][category].append(tip)
        else:
            self.tips_data.setdefault("tips", []).append(tip)
        
        self.save_tips()
        return True

# Global instance
tip_generator = TipGenerator()

def get_daily_tip():
    """Get today's tip"""
    return tip_generator.get_daily_tip()

def get_random_tip(category=None):
    """Get a random tip"""
    return tip_generator.get_random_tip(category)

def generate_ai_tip(category="general", context=""):
    """Generate a new AI tip"""
    return tip_generator.generate_ai_tip(category, context)

if __name__ == "__main__":
    # Test the tip generator
    print("🤖 Testing AI Tip Generator...")
    print("\n📝 Daily Tip:")
    print(get_daily_tip())
    
    print("\n🎲 Random Tips:")
    for category in ["productivity", "career", "wellness", "learning"]:
        print(f"{category.title()}: {get_random_tip(category)}")
    
    print("\n🧠 AI Generated Tip:")
    print(generate_ai_tip("productivity", "time management"))
