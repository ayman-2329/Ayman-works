import logging
import re
from io import BytesIO
from pathlib import Path
from typing import List

import pandas as pd
from dateutil import parser as date_parser
from PyPDF2 import PdfReader
from docx import Document
from PIL import Image
import pytesseract

# ─── Logging ───────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)
logger = logging.getLogger(__name__)

# ─── Regex Patterns ───────────────────────────────────────────────
# Matches exactly DD/MM/YYYY or D/M/YYYY (slash or dash)
DATE_REGEX = re.compile(r"^\d{1,2}[/-]\d{1,2}[/-]\d{2,4}$")
# Matches amounts like 50,000.00  or -₹5,000.00  or ₹150.75
AMOUNT_REGEX = re.compile(
    r"^[-+]?\s*₹?\s*([\d,]+(?:\.\d{2})?)\s*(?:DR|CR)?$",
    re.IGNORECASE
)

# ─── Supported Extensions ─────────────────────────────────────────
SPREADSHEET_EXTS = {'.csv', '.xls', '.xlsx'}
PDF_EXTS         = {'.pdf'}
DOCX_EXTS        = {'.docx'}
IMAGE_EXTS       = {'.png', '.jpg', '.jpeg', '.bmp', '.tiff'}


def parse_uploaded_file(uploaded_file: BytesIO) -> pd.DataFrame:
    """
    Detect file extension and dispatch to appropriate parser.
    Returns DataFrame with columns ['date','description','amount'].
    """
    suffix = Path(uploaded_file.name).suffix.lower()
    if suffix in SPREADSHEET_EXTS:
        return _parse_spreadsheet(uploaded_file, suffix)
    if suffix in PDF_EXTS:
        return _parse_pdf(uploaded_file)
    if suffix in DOCX_EXTS:
        return _parse_docx(uploaded_file)
    if suffix in IMAGE_EXTS:
        return _parse_image(uploaded_file)
    raise ValueError(f"Unsupported file type: {uploaded_file.name}")


# ─── 1) Spreadsheet Parser ────────────────────────────────────────
def _parse_spreadsheet(fobj: BytesIO, ext: str) -> pd.DataFrame:
    reader = pd.read_excel if ext != '.csv' else pd.read_csv
    df = reader(fobj)

    # Normalize column names
    df.columns = [c.strip().lower() for c in df.columns]
    df.rename(columns={
        'transaction_date': 'date', 'txn_date': 'date',
        'details': 'description', 'desc': 'description',
        'amt': 'amount'
    }, inplace=True)

    if not {'date', 'amount'}.issubset(df.columns):
        raise ValueError("Spreadsheet needs 'date' and 'amount' columns.")

    # Coerce types
    df['date'] = pd.to_datetime(df['date'], errors='coerce', dayfirst=True)
    df['amount'] = pd.to_numeric(df['amount'], errors='coerce')
    df['description'] = df.get('description', '').fillna('No description').astype(str)

    df.dropna(subset=['date', 'amount'], inplace=True)
    return df[['date', 'description', 'amount']]


# ─── 2) PDF Parser ────────────────────────────────────────────────
def _parse_pdf(fobj: BytesIO) -> pd.DataFrame:
    reader = PdfReader(fobj)
    lines: List[str] = []
    for page in reader.pages:
        text = page.extract_text() or ""
        lines += [ln.strip() for ln in text.splitlines() if ln.strip()]
    return _extract_by_index(lines, source='PDF')


# ─── 3) DOCX Parser ──────────────────────────────────────────────
def _parse_docx(fobj: BytesIO) -> pd.DataFrame:
    doc = Document(fobj)
    lines = [p.text.strip() for p in doc.paragraphs if p.text.strip()]
    return _extract_by_index(lines, source='DOCX')


# ─── 4) Image + OCR Parser ───────────────────────────────────────
def _parse_image(fobj: BytesIO) -> pd.DataFrame:
    img = Image.open(fobj).convert("L")
    bw = img.point(lambda px: 0 if px < 140 else 255, '1')
    config = "--psm 6 -c tessedit_char_whitelist=0123456789DRCR₹.,-"
    raw = pytesseract.image_to_string(bw, config=config)
    lines = [ln.strip() for ln in raw.splitlines() if ln.strip()]
    return _extract_by_index(lines, source='IMAGE')


# ─── Core: index-based extraction ────────────────────────────────
def _extract_by_index(lines: List[str], source: str) -> pd.DataFrame:
    """
    For each line that matches DATE_REGEX, assume:
      lines[i]   = date
      lines[i+1] = description
      lines[i+2] = amount
    Skip if description is a header (e.g. 'Description') or amount doesn't match.
    """
    records = []
    for i, ln in enumerate(lines):
        if not DATE_REGEX.match(ln):
            continue

        # Ensure we have room for desc & amt
        if i + 2 >= len(lines):
            break

        desc = lines[i + 1]
        amt_text = lines[i + 2]

        # Skip header rows
        if desc.lower() in ('description', 'amount', 'date'):
            continue

        # Match amount
        m = AMOUNT_REGEX.match(amt_text)
        if not m:
            continue

        # Parse date
        try:
            date = date_parser.parse(ln, dayfirst=True)
        except:
            continue

        # Parse amount with sign
        value = float(m.group(1).replace(',', ''))
        if m.group(0).strip().startswith('-') or m.group('drcr'):
            value = -abs(value)

        records.append({
            'date': date,
            'description': desc,
            'amount': value
        })
        logger.debug("Parsed %s → %s | Rs %.2f", source, ln, value)

    if not records:
        raise ValueError(f"No valid transactions found in {source} content.")

    df = pd.DataFrame(records)
    return df[['date', 'description', 'amount']]