# 🎁 Gift Card Matchmaker AI Bot

An AI-powered web app that helps you **find the perfect gift card** using real Amazon reviews and metadata. It uses **semantic search** and **sentiment analysis** to deliver personalized recommendations through a clean Streamlit UI.

---

## 🧠 How It Works

1. **User Query**: You choose the occasion, recipient type, budget, and optional keywords.
2. **Semantic Search**: The app uses sentence-transformers to match your query to the most relevant gift card titles and descriptions.
3. **Filter by Budget**: Matches are narrowed down based on your price range.
4. **Sentiment Analysis**: One top review is selected per card and analyzed using a Hugging Face transformer model.
5. **Beautiful Display**: Cards are shown in a clean, responsive 2-column layout with sentiment, rating, and key info.

---

## ✨ Features

* 🔍 AI-Powered Semantic Gift Card Search
* 💬 Real Review Sentiment (like "😊 Positive (88%)")
* 🎨 Stylish UI with Responsive Columns
* 📉 Filters by Budget
* 🚀 Works on 4GB RAM Machines
* 🧠 Uses Pretrained HuggingFace & SentenceTransformers

---

## 📁 Folder Structure

```
giftcard-bot/
├── app.py                        # Main Streamlit UI
├── load_data.py                 # Reads and loads review/meta files
├── recommender.py               # Semantic search engine
├── sentiment.py                 # Sentiment classifier using Transformers
├── utils.py                     # Helper functions (cleaning, formatting)
│
├── data/
│   ├── Gift_Cards.jsonl         # Review dataset
│   └── meta_Gift_Cards.jsonl    # Metadata about each gift card
│
├── assets/
│   └── banner.png               # Optional header image
│
├── styles/
│   └── style.css                # UI Styling
│
├── requirements.txt            # Dependencies
└── README.md                   # This file
```

---

## 🛠️ Installation & Setup

### ✅ Prerequisites

* Python 3.8+
* pip
* 4GB RAM minimum

### ⚙️ Setup Instructions

```bash
# 1. Clone the repo
$ git clone https://github.com/your-username/giftcard-bot.git
$ cd giftcard-bot

# 2. Create and activate virtual environment (Windows example)
$ python -m venv venv
$ venv\Scripts\activate

# 3. Install dependencies
$ pip install -r requirements.txt

# 4. Add your data files to /data:
#    - Gift_Cards.jsonl
#    - meta_Gift_Cards.jsonl

# 5. Run the app
$ streamlit run app.py
```

---

## 💡 Example Usage

* 🎉 Occasion: *Birthday*
* 🧑‍🤝‍🧑 Who is it for: *Partner*
* 💰 Budget: ₹1000
* 🔍 Keywords: *romantic, travel*

**Output:** List of cards with titles, price, rating, description, top review snippet and sentiment emoji (like 😍 Very Positive).

---

## 🖼️ Optional Preview

Add this image to `/assets/banner.png`:

```markdown
![App Banner](assets/banner.png)
```

---

## 🔧 Tech Stack

| Tool / Lib                | Use                         |
| ------------------------- | --------------------------- |
| Streamlit                 | UI Framework                |
| Hugging Face Transformers | Sentiment Analysis Model    |
| SentenceTransformers      | Embedding & Semantic Search |
| Pandas                    | Data Loading and Filtering  |
| CSS                       | Custom Styling for UI       |

---

## 📜 License

MIT License – Free to use for learning, research, or demo purposes.

---

## 👨‍💻 Author

**Made with ❤️ by Ayman**
Built using open-source tools. Feel free to fork, improve, or reach out on [LinkedIn](https://linkedin.com/in/your-profile).
