# 💸 Budget Coach Visualization Web Application

A comprehensive personal finance assistant built with Streamlit. Upload bank statements, analyze expenses with AI, detect anomalies and recurring charges, forecast future spending, and receive personalized budget coaching—all through an interactive dashboard.

---

## 📋 Features

1. Multi-format Bank Statement Upload (.csv, .pdf, .docx, image)
2. Advanced File Parsing (structured extraction + OCR support)
3. AI-based Expense Categorization
4. Sentiment Analysis on transaction descriptions
5. Anomaly Detection
6. Recurring Transaction Detection
7. Expense Forecasting using Facebook Prophet
8. Interactive Visualizations:
   - Line chart: expenses over time
   - Pie chart: category-wise distribution
   - Forecast chart: projected spending
9. Personalized Budget Coaching
10. PDF Report Generation
11. Retrieval-Augmented Generation (RAG) Q&A System

---

## 🚀 Installation & Setup

Step 1: Clone the repository

```bash
git clone https://github.com/yourusername/budget-coach-app.git
cd budget-coach-app
```

Step 2: Setup Python virtual environment

```bash
python -m venv venv
```

Activate the environment:

- On Windows:
  ```bash
  venv\Scripts\activate
  ```
- On macOS / Linux:
  ```bash
  source venv/bin/activate
  ```

Step 3: Install dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

Step 4: Install Tesseract OCR (required for image parsing)

- Windows: Download from [UB Mannheim](https://github.com/UB-Mannheim/tesseract/wiki)
- macOS:
  ```bash
  brew install tesseract
  ```
- Ubuntu/Debian:
  ```bash
  sudo apt-get install tesseract-ocr
  ```

✅ Ensure Tesseract is added to your system PATH.

Step 5: Run the application

```bash
streamlit run main.py
```

Open [http://localhost:8501](http://localhost:8501) in your browser.

---

## 📝 Usage Guide

1. Upload your bank statement file (CSV recommended)
2. View parsed transactions: Date, Description, Amount
3. Explore categorized expenses and sentiment scores
4. Detect anomalies and recurring payments
5. Visualize spending trends and forecasts
6. Read personalized budget coaching insights
7. Download a detailed PDF report
8. Ask questions via the RAG interface

---

## 📂 Supported File Formats

| Format | Notes                                           |
|--------|-------------------------------------------------|
| CSV    | ✅ Highest accuracy and parsing reliability      |
| PDF    | ✅ Works well if text is extractable             |
| DOCX   | ✅ Parses structured paragraphs                  |
| Image  | ⚠️ Requires OCR; best with typed scans           |

---

## ⚠️ Known Issues & Tips

- Complex PDF/DOCX layouts may reduce parsing accuracy
- OCR results vary with image quality
- Convert to CSV if “No data extracted” appears
- RAG requires `.txt` files in `data/rag_docs/`
- Forecasting needs months of valid data
- Tesseract must be installed separately

---

## 🛠️ Troubleshooting

| Issue                           | Solution                                           |
|--------------------------------|----------------------------------------------------|
| FileNotFoundError in RAG system | Ensure `data/rag_docs/` folder exists              |
| OCR/libmagic warnings          | Install Tesseract and verify PATH                 |
| Empty DataFrame after parsing  | Improve formatting or convert to CSV              |
| Streamlit dependency errors    | Run `pip install -r requirements.txt`             |
| Forecast chart not displaying  | Verify `date` and `amount` columns in your file   |

---

## 📁 Project Structure

```
budget-coach-app/
├── components/
│   ├── ai_categorizer.py
│   ├── ai_engine.py
│   ├── budget_coach.py
│   ├── file_parser.py
│   ├── forecast.py
│   ├── pdf_export.py
│   └── rag_system/
│       └── rag_system.py
├── data/
│   └── rag_docs/
├── uploads/
│   └── test.csv
├── main.py
├── requirements.txt
└── README.md
```

---

## 📦 Dependencies

- streamlit
- pandas
- PyPDF2
- python-docx
- pytesseract
- sentence-transformers
- faiss-cpu
- langchain
- langchain-community
- prophet
- plotly
- python-dotenv
- dateutil

(See `requirements.txt` for full versions.)

---

## 🤝 Contribution

Contributions, bug reports, and feature requests are welcome!  
Open an issue or submit a pull request.

---

## 📜 License

MIT License © 2025 Mohammed Ayman

---

## 📬 Contact

Questions or feedback?  
📧 mayman2229@gmail.com

---

🎉 Thank you for using Budget Coach Visualization App —  
Manage your finances smarter and with confidence.