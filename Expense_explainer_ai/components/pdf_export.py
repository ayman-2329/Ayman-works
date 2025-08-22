from io import BytesIO
from fpdf import FPDF
import pandas as pd
import os
from datetime import datetime
import unicodedata
from typing import List, Optional, Union


def safe_text(text: Union[str, object]) -> str:
    """
    Clean text for FPDF rendering:
    - Remove control characters and emojis
    - Strip whitespace
    - Return safe fallback if empty
    """
    if not isinstance(text, str):
        text = str(text)
    cleaned = ''.join(
        c for c in text
        if unicodedata.category(c)[0] != 'C' and ord(c) < 256
    )
    cleaned = cleaned.encode('latin-1', 'ignore').decode('latin-1').strip()
    return cleaned if cleaned else " "


def generate_pdf(
    df: pd.DataFrame,
    explanations: List[str],
    recurring: pd.DataFrame,
    forecast: Optional[pd.DataFrame],
    openai_summary: str
) -> BytesIO:
    """
    Generate a PDF report of expense analysis.

    Args:
        df: DataFrame with expense data.
        explanations: List of sentiment explanation strings.
        recurring: DataFrame of recurring transactions.
        forecast: DataFrame of forecast data.
        openai_summary: AI-generated financial summary string.

    Returns:
        BytesIO buffer with PDF content.
    """
    pdf = FPDF()
    pdf.add_page()

    font_path = os.path.join(os.path.dirname(__file__), "DejaVuSans.ttf")
    if os.path.exists(font_path):
        try:
            pdf.add_font("DejaVu", "", font_path, uni=True)
            pdf.set_font("DejaVu", size=12)
        except Exception as e:
            print(f"⚠️ Could not load DejaVuSans.ttf font: {e}")
            pdf.set_font("Helvetica", size=12)
    else:
        print(f"⚠️ DejaVuSans.ttf font file not found at {font_path}, using default font.")
        pdf.set_font("Helvetica", size=12)

    # Title
    pdf.cell(190, 10, safe_text("AI Expense Report"), ln=True, align='C')
    pdf.ln(10)

    # AI Summary
    pdf.multi_cell(190, 10, safe_text("AI Summary:"))
    pdf.multi_cell(190, 10, safe_text(openai_summary))
    pdf.ln(5)

    # Sentiment Explanations
    pdf.multi_cell(190, 10, safe_text("Sentiment Explanations:"))
    for explanation in explanations:
        pdf.multi_cell(190, 10, safe_text(f"- {explanation}"))
    pdf.ln(5)

    # Forecast Section
    if isinstance(forecast, pd.DataFrame) and not forecast.empty and 'ds' in forecast and 'yhat' in forecast:
        pdf.multi_cell(190, 10, safe_text("Forecast Trend:"))
        # Show only next 30 days forecast or less
        future_forecast = forecast.tail(30)
        for _, row in future_forecast.iterrows():
            date_label = row["ds"].strftime("%Y-%m-%d") if pd.notna(row["ds"]) else "N/A"
            amount = row["yhat"]
            pdf.cell(190, 10, safe_text(f"{date_label}: ₹{amount:.2f}"), ln=True)
    else:
        pdf.multi_cell(190, 10, safe_text("Forecast data not available."))
    pdf.ln(5)

    # Recurring Transactions Section
    if not recurring.empty:
        pdf.multi_cell(190, 10, safe_text("Recurring Transactions:"))
        for _, row in recurring.iterrows():
            date_str = row["date"].strftime("%Y-%m-%d") if pd.notna(row["date"]) else "N/A"
            amount = row["amount"]
            desc = row["description"]
            pdf.cell(190, 10, safe_text(f"{date_str} - ₹{amount:.2f} - {desc}"), ln=True)
    else:
        pdf.multi_cell(190, 10, safe_text("No recurring transactions found."))

    buffer = BytesIO()
    pdf_output = pdf.output(dest="S")
    if isinstance(pdf_output, str):
        pdf_bytes = pdf_output.encode("latin-1")
    else:
        pdf_bytes = pdf_output
    buffer.write(pdf_bytes)
    buffer.seek(0)
    return buffer
