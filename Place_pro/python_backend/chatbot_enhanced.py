"""
Enhanced AI Chatbot for PlacePro Application
Provides intelligent, context-aware responses for placement and career guidance
"""

import random
import re
import json
from transformers import pipeline
import torch

# Import tip generator for contextual tips
try:
    from tip_generator import TipGenerator
    tip_generator = TipGenerator()
except ImportError:
    tip_generator = None

class PlaceProChatbot:
    def __init__(self):
        self.conversation_pipeline = None
        self.chat_history = []
        self.max_history = 100
        self.context_memory = {}
        self.conversation_context = []
        
        # Enhanced placement-focused knowledge base
        self.placement_knowledge = self._load_placement_knowledge()
        self.load_models()
    
    def _load_placement_knowledge(self):
        """Load comprehensive placement knowledge base"""
        return {
            "interview_types": {
                "technical": {
                    "description": "Technical interviews assess your coding and problem-solving skills",
                    "preparation": [
                        "Practice data structures and algorithms daily",
                        "Solve problems on LeetCode, HackerRank, CodeChef",
                        "Understand time and space complexity",
                        "Practice system design for senior roles",
                        "Review your projects thoroughly"
                    ],
                    "common_topics": ["Arrays", "Linked Lists", "Trees", "Graphs", "Dynamic Programming", "System Design"]
                },
                "hr": {
                    "description": "HR interviews evaluate cultural fit and soft skills",
                    "preparation": [
                        "Research company culture and values",
                        "Prepare STAR method examples",
                        "Practice behavioral questions",
                        "Know your resume inside out"
                    ],
                    "common_questions": [
                        "Tell me about yourself",
                        "Why do you want to work here?",
                        "Describe a challenging situation",
                        "Where do you see yourself in 5 years?"
                    ]
                }
            },
            "resume_tips": {
                "format": "Clean, ATS-friendly, 1-2 pages maximum",
                "sections": ["Header", "Summary", "Education", "Experience", "Skills", "Projects"],
                "keywords": "Match job description, use industry terms",
                "metrics": "Quantify achievements with numbers and percentages"
            },
            "company_research": {
                "basics": ["Mission", "Values", "Products", "Recent news"],
                "culture": ["Work environment", "Employee reviews", "Benefits"],
                "role": ["Job requirements", "Team structure", "Growth opportunities"]
            }
        }
    
    def load_models(self):
        """Load AI models for enhanced conversation"""
        try:
            print("🤖 Loading enhanced AI models...")
            
            self.conversation_pipeline = pipeline(
                "text-generation",
                model="microsoft/DialoGPT-small",
                device=0 if torch.cuda.is_available() else -1
            )
            
            print("✅ Enhanced chatbot models loaded successfully")
            
        except Exception as e:
            print(f"⚠️ Error loading models: {e}")
            print("📝 Using enhanced rule-based responses")
    
    def detect_intent_advanced(self, message):
        """Advanced intent detection with context awareness"""
        message_lower = message.lower()
        
        # Enhanced intent patterns
        intent_patterns = {
            "greeting": ["hello", "hi", "hey", "good morning", "good afternoon", "start"],
            "interview_technical": ["technical interview", "coding interview", "algorithm", "data structure", "programming"],
            "interview_hr": ["hr interview", "behavioral interview", "tell me about yourself", "personal interview"],
            "interview_general": ["interview", "interviews", "interviewing", "interview tips"],
            "resume_building": ["resume", "cv", "curriculum vitae", "resume tips", "resume format"],
            "job_search": ["job search", "job hunting", "find job", "apply job", "job application"],
            "company_research": ["company research", "about company", "company culture", "company info"],
            "salary_negotiation": ["salary", "pay", "compensation", "package", "ctc", "negotiate"],
            "skill_development": ["skills", "skill development", "learn", "improve skills", "technical skills"],
            "networking": ["networking", "professional network", "linkedin", "connections"],
            "internship": ["internship", "intern", "training", "industrial training"],
            "aptitude": ["aptitude", "logical reasoning", "quantitative", "verbal", "aptitude test"],
            "coding_practice": ["coding", "programming", "leetcode", "hackerrank", "practice"],
            "career_guidance": ["career", "career path", "career advice", "profession"],
            "placement_prep": ["placement", "campus placement", "placement preparation"],
            "portfolio": ["portfolio", "projects", "github", "showcase", "work samples"],
            "stress_management": ["stress", "anxiety", "nervous", "pressure", "confidence"],
            "mock_interview": ["mock interview", "practice interview", "interview practice"]
        }
        
        # Check for specific patterns
        for intent, keywords in intent_patterns.items():
            if any(keyword in message_lower for keyword in keywords):
                return intent
        
        return "general"
    
    def get_enhanced_response(self, intent, message):
        """Get enhanced responses based on intent"""
        responses = {
            "greeting": "👋 **Welcome to PlacePro AI Assistant!**\n\nI'm here to help you ace your placements! I can assist with:\n\n🎯 **Interview Preparation** (Technical, HR, Mock)\n📄 **Resume Building & Optimization**\n💼 **Job Search Strategies**\n🏢 **Company Research**\n💰 **Salary Negotiation**\n🚀 **Skill Development**\n🤝 **Professional Networking**\n\nWhat would you like to work on today?",
            
            "interview_technical": "💻 **Technical Interview Mastery**\n\n**Preparation Strategy:**\n• **Daily Practice**: 2-3 coding problems on LeetCode/HackerRank\n• **Core Topics**: Arrays, Strings, Trees, Graphs, DP, System Design\n• **Time Management**: Practice with timer, optimize solutions\n• **Communication**: Explain your approach clearly\n\n**Key Tips:**\n✅ Understand the problem before coding\n✅ Start with brute force, then optimize\n✅ Test with edge cases\n✅ Discuss time/space complexity\n\n**Resources**: LeetCode Top 150, Cracking the Coding Interview, System Design Primer\n\nNeed help with specific topics or mock coding sessions?",
            
            "interview_hr": "🎯 **HR Interview Excellence**\n\n**STAR Method Framework:**\n• **Situation**: Set the context\n• **Task**: Describe your responsibility\n• **Action**: Explain what you did\n• **Result**: Share the outcome\n\n**Common Questions & Approach:**\n\n**\"Tell me about yourself\"**\n→ Present + Past + Future format (2 minutes max)\n\n**\"Why this company?\"**\n→ Research + Alignment + Enthusiasm\n\n**\"Biggest weakness?\"**\n→ Real weakness + Improvement steps\n\n**Preparation Checklist:**\n✅ Research company thoroughly\n✅ Prepare 5-7 STAR examples\n✅ Practice with mock interviews\n✅ Prepare thoughtful questions\n\nWant to practice specific questions?",
            
            "resume_building": "📄 **Resume Excellence Guide**\n\n**Format Best Practices:**\n• **Length**: 1-2 pages maximum\n• **Font**: Professional (Arial, Calibri) 10-12pt\n• **Sections**: Header → Summary → Education → Experience → Skills → Projects\n• **ATS-Friendly**: Simple formatting, no images/graphics\n\n**Content Strategy:**\n\n**Summary (2-3 lines):**\n\"Computer Science student with expertise in [technologies]. Experienced in [domain] with [X] projects. Seeking [role type] opportunities.\"\n\n**Experience/Projects:**\n• Use action verbs (Developed, Implemented, Optimized)\n• Quantify impact (\"Improved performance by 30%\")\n• Include tech stack and methodologies\n\n**Skills Section:**\n• **Languages**: Python, Java, JavaScript\n• **Frameworks**: React, Django, Spring Boot\n• **Tools**: Git, Docker, AWS\n• **Databases**: MySQL, MongoDB\n\n**Pro Tips:**\n✅ Tailor for each application\n✅ Use keywords from job description\n✅ Proofread multiple times\n✅ Get feedback from seniors\n\nNeed help with specific sections?",
            
            "job_search": "🔍 **Strategic Job Search**\n\n**Platform Strategy:**\n• **LinkedIn**: 70% of opportunities, optimize profile\n• **Company Websites**: Direct applications, higher success rate\n• **Job Portals**: Naukri, Indeed, AngelList for startups\n• **Campus Placements**: Leverage college network\n• **Referrals**: 40% of hires come through referrals\n\n**Application Timeline:**\n• **Apply Early**: Within 24-48 hours of posting\n• **Follow Up**: Professional email after 1 week\n• **Track Applications**: Maintain spreadsheet\n\n**Success Metrics:**\n• **Application Rate**: 10-15 quality applications/week\n• **Response Rate**: 10-15% is normal\n• **Interview Conversion**: 20-30% of responses\n\n**Red Flags to Avoid:**\n❌ Mass applying without customization\n❌ Poor LinkedIn profile\n❌ Generic cover letters\n❌ Not following up\n\nWhich aspect needs more focus?",
            
            "company_research": "🏢 **Company Research Framework**\n\n**Phase 1: Basic Research (30 mins)**\n• **Company Website**: Mission, values, products\n• **Recent News**: Google \"[Company] news 2024\"\n• **Leadership**: CEO, CTO, key executives\n• **Financials**: Funding, revenue, growth\n\n**Phase 2: Culture & Reviews (20 mins)**\n• **Glassdoor**: Employee reviews, interview experiences\n• **LinkedIn**: Employee posts, company updates\n• **YouTube**: Company culture videos\n\n**Phase 3: Role-Specific (15 mins)**\n• **Job Description**: Requirements, responsibilities\n• **Team Structure**: Department size, reporting\n• **Growth Path**: Career progression opportunities\n\n**Smart Questions to Ask:**\n• \"What does success look like in this role?\"\n• \"What are the biggest challenges facing the team?\"\n• \"How does the company support professional development?\"\n• \"What's the team culture like?\"\n\n**Research Template:**\n✅ Company mission alignment\n✅ Recent achievements/news\n✅ Technology stack used\n✅ Growth opportunities\n✅ Work culture fit\n\nNeed help researching a specific company?",
            
            "salary_negotiation": "💰 **Salary Negotiation Mastery**\n\n**Research Phase:**\n• **PayScale**: Industry standards by experience\n• **Glassdoor**: Company-specific salaries\n• **Levels.fyi**: Tech company compensation\n• **AmbitionBox**: Indian company salaries\n• **Network**: Ask seniors, alumni\n\n**Negotiation Strategy:**\n\n**For Freshers:**\n• Focus on learning opportunities\n• Negotiate joining bonus, not base salary\n• Consider total package (benefits, growth)\n\n**For Experienced:**\n• Highlight unique value proposition\n• Use competing offers as leverage\n• Negotiate multiple components\n\n**Timing & Approach:**\n✅ **When**: After offer, before acceptance\n✅ **How**: Professional, data-driven\n✅ **Tone**: Enthusiastic about role\n✅ **Backup**: Have alternatives ready\n\n**Sample Script:**\n\"I'm excited about this opportunity. Based on my research and experience with [specific skills], the market rate is [X]. Would there be flexibility in the compensation package?\"\n\n**Components to Consider:**\n• Base salary\n• Joining bonus\n• Performance bonus\n• Stock options\n• Benefits (health, PF)\n• Learning budget\n• Flexible working\n\nNeed help with a specific negotiation scenario?",
            
            "skill_development": "🚀 **Strategic Skill Development**\n\n**Technical Skills Roadmap:**\n\n**Programming Fundamentals:**\n• **Languages**: Master 2-3 languages deeply\n• **Data Structures**: Arrays, Trees, Graphs, Hash Tables\n• **Algorithms**: Sorting, Searching, Dynamic Programming\n• **Complexity**: Time/Space analysis\n\n**Domain-Specific Skills:**\n\n**Web Development:**\n• Frontend: HTML/CSS, JavaScript, React/Angular\n• Backend: Node.js/Python/Java, REST APIs\n• Database: SQL, NoSQL\n• DevOps: Git, Docker, CI/CD\n\n**Data Science:**\n• Python: NumPy, Pandas, Scikit-learn\n• Statistics: Descriptive, Inferential\n• ML: Supervised, Unsupervised learning\n• Visualization: Matplotlib, Tableau\n\n**Mobile Development:**\n• Native: Swift (iOS), Kotlin (Android)\n• Cross-platform: React Native, Flutter\n• Backend integration: APIs, databases\n\n**Soft Skills (Equally Important):**\n• **Communication**: Technical writing, presentations\n• **Problem-solving**: Analytical thinking\n• **Teamwork**: Collaboration, conflict resolution\n• **Leadership**: Project management, mentoring\n\n**Learning Strategy:**\n✅ **70-20-10 Rule**: 70% hands-on, 20% learning from others, 10% formal training\n✅ **Project-based**: Build real applications\n✅ **Community**: Join tech communities, contribute to open source\n✅ **Continuous**: Stay updated with industry trends\n\n**Recommended Resources:**\n• **Coding**: LeetCode, HackerRank, Codechef\n• **Courses**: Coursera, Udemy, edX\n• **Practice**: GitHub projects, hackathons\n• **Networking**: LinkedIn, tech meetups\n\nWhat's your target role and current skill level?",
            
            "networking": "🤝 **Professional Networking Strategy**\n\n**LinkedIn Optimization:**\n• **Profile Photo**: Professional headshot\n• **Headline**: Role + Key skills + Value proposition\n• **Summary**: Your story in 2-3 paragraphs\n• **Experience**: Detailed with achievements\n• **Skills**: Top 10 relevant skills\n• **Activity**: Share insights, comment thoughtfully\n\n**Networking Channels:**\n\n**Online:**\n• **LinkedIn**: Connect with alumni, industry professionals\n• **Twitter**: Follow thought leaders, engage in discussions\n• **GitHub**: Contribute to open source projects\n• **Discord/Slack**: Join tech communities\n\n**Offline:**\n• **Meetups**: Local tech events, workshops\n• **Conferences**: Industry conferences, hackathons\n• **Alumni**: College alumni networks\n• **Workplace**: Colleagues, mentors\n\n**Networking Approach:**\n\n**The GIVE-FIRST Principle:**\n• Offer help before asking for it\n• Share valuable content\n• Make introductions for others\n• Provide feedback or insights\n\n**Conversation Starters:**\n• \"I noticed your work on [project]. Could you share insights about [specific aspect]?\"\n• \"I'm exploring [field]. What trends are you seeing?\"\n• \"Your post about [topic] resonated with me. Have you considered [related idea]?\"\n\n**Follow-up Strategy:**\n✅ **24-48 hours**: Send connection request with personal note\n✅ **1 week**: Share relevant article or opportunity\n✅ **1 month**: Check in with update or question\n✅ **Quarterly**: Maintain relationship with valuable content\n\n**Networking Goals:**\n• **Quality over Quantity**: 5 meaningful connections > 50 random ones\n• **Diverse Network**: Different industries, seniority levels\n• **Mutual Value**: Relationships should benefit both parties\n\nNeed help with LinkedIn optimization or networking strategies?",
            
            "aptitude": "🧠 **Aptitude Test Mastery**\n\n**Test Components:**\n\n**Quantitative Aptitude:**\n• **Topics**: Arithmetic, Algebra, Geometry, Data Interpretation\n• **Strategy**: Learn shortcuts, practice mental math\n• **Time Management**: 1-2 minutes per question\n• **Resources**: R.S. Aggarwal, IndiaBix\n\n**Logical Reasoning:**\n• **Types**: Verbal, Non-verbal, Analytical\n• **Patterns**: Sequences, analogies, classifications\n• **Practice**: Daily 30 minutes, timed tests\n• **Resources**: A Modern Approach to Logical Reasoning\n\n**Verbal Ability:**\n• **Areas**: Reading comprehension, grammar, vocabulary\n• **Improvement**: Read newspapers, novels daily\n• **Practice**: Synonyms, antonyms, sentence correction\n• **Resources**: Word Power Made Easy, Wren & Martin\n\n**Preparation Strategy:**\n\n**Phase 1 (Foundation - 2 months):**\n• Understand concepts and formulas\n• Practice basic problems\n• Build vocabulary (20 words/day)\n\n**Phase 2 (Practice - 1 month):**\n• Solve previous year papers\n• Take mock tests weekly\n• Identify weak areas\n\n**Phase 3 (Perfection - 2 weeks):**\n• Daily mock tests\n• Time management practice\n• Revision of formulas\n\n**Test Day Tips:**\n✅ **Time Allocation**: Easy questions first\n✅ **Accuracy**: Avoid negative marking\n✅ **Guessing**: Eliminate options, then guess\n✅ **Calm**: Deep breathing, positive mindset\n\n**Common Mistakes:**\n❌ Not reading questions carefully\n❌ Spending too much time on difficult questions\n❌ Not practicing under time pressure\n❌ Ignoring negative marking\n\nWhich section needs more focus?",
            
            "stress_management": "🧘 **Stress Management for Placements**\n\n**Understanding Placement Stress:**\n• **Normal Response**: Stress is natural during placements\n• **Performance Impact**: Moderate stress improves performance\n• **Warning Signs**: Sleep issues, anxiety, loss of appetite\n\n**Stress Management Techniques:**\n\n**Physical Wellness:**\n• **Exercise**: 30 minutes daily, releases endorphins\n• **Sleep**: 7-8 hours, consistent schedule\n• **Nutrition**: Balanced diet, avoid excessive caffeine\n• **Breathing**: 4-7-8 technique for instant calm\n\n**Mental Strategies:**\n• **Positive Visualization**: Imagine successful interviews\n• **Affirmations**: \"I am prepared and capable\"\n• **Mindfulness**: 10 minutes daily meditation\n• **Perspective**: Focus on learning, not just outcomes\n\n**Preparation Confidence:**\n• **Mock Interviews**: Practice reduces anxiety\n• **Knowledge**: Well-prepared candidates feel confident\n• **Backup Plans**: Multiple opportunities reduce pressure\n• **Support System**: Friends, family, mentors\n\n**Day-of-Interview Calm:**\n\n**Before Interview:**\n• Arrive 15 minutes early\n• Review key points, not entire preparation\n• Deep breathing exercises\n• Positive self-talk\n\n**During Interview:**\n• Focus on conversation, not evaluation\n• Take pause before answering\n• It's okay to say \"I don't know\" if unsure\n• Show enthusiasm and curiosity\n\n**After Interview:**\n• Reflect on learnings, not mistakes\n• Celebrate the experience\n• Prepare for next opportunity\n• Don't overthink the outcome\n\n**Emergency Stress Relief:**\n• **5-4-3-2-1 Technique**: 5 things you see, 4 you hear, 3 you touch, 2 you smell, 1 you taste\n• **Progressive Relaxation**: Tense and release muscle groups\n• **Call Support**: Talk to someone who believes in you\n\nRemember: Rejection is redirection to better opportunities! 🌟\n\nNeed specific techniques for interview anxiety?",
            
            "general": "🎯 **PlacePro AI Assistant**\n\nI'm your comprehensive placement preparation partner! Here's how I can help:\n\n**📚 Interview Preparation**\n• Technical interview strategies\n• HR interview techniques\n• Mock interview practice\n• Common questions and answers\n\n**📄 Resume & Applications**\n• Resume building and optimization\n• Cover letter writing\n• Application tracking\n• ATS-friendly formatting\n\n**🔍 Job Search Strategy**\n• Platform optimization (LinkedIn, job portals)\n• Company research techniques\n• Application timing and follow-up\n• Networking strategies\n\n**💼 Career Development**\n• Skill development roadmaps\n• Industry insights and trends\n• Salary negotiation tactics\n• Professional growth planning\n\n**🧠 Test Preparation**\n• Aptitude test strategies\n• Coding practice guidance\n• Time management techniques\n• Stress management\n\n**Quick Commands:**\n• \"Help with technical interviews\"\n• \"Review my resume\"\n• \"Company research for [Company Name]\"\n• \"Salary negotiation tips\"\n• \"Mock interview practice\"\n\nWhat specific area would you like to focus on today?"
        }
        
        return responses.get(intent, responses["general"])
    
    def chat(self, message):
        """Main chat function with enhanced responses"""
        try:
            # Detect intent
            intent = self.detect_intent_advanced(message)
            
            # Add to conversation context
            self.conversation_context.append(intent)
            if len(self.conversation_context) > 5:
                self.conversation_context.pop(0)
            
            # Get enhanced response
            response = self.get_enhanced_response(intent, message)
            
            # Add to chat history
            self.chat_history.append({
                "user": message,
                "bot": response,
                "intent": intent
            })
            
            # Limit history size
            if len(self.chat_history) > self.max_history:
                self.chat_history.pop(0)
            
            return {
                "success": True,
                "response": response,
                "intent": intent
            }
            
        except Exception as e:
            print(f"❌ Chat error: {e}")
            return {
                "success": False,
                "response": "I apologize, but I encountered an error. Please try rephrasing your question.",
                "intent": "error"
            }
    
    def get_chat_history(self):
        """Get chat history"""
        return {
            "success": True,
            "history": self.chat_history[-10:]  # Last 10 messages
        }
    
    def clear_chat_history(self):
        """Clear chat history"""
        self.chat_history = []
        self.conversation_context = []
        return {
            "success": True,
            "message": "Chat history cleared successfully"
        }

# Global chatbot instance
chatbot = PlaceProChatbot()
