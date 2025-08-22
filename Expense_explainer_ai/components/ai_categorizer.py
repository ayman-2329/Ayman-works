import pandas as pd
from sentence_transformers import SentenceTransformer, util
from typing import Dict, List

# Load embedding model once globally for reuse
model = SentenceTransformer("all-MiniLM-L6-v2")

# Define expense categories and associated keywords
CATEGORIES: Dict[str, List[str]] = {
    "Groceries": ["supermarket", "grocery", "walmart", "food market", "produce", "vegetables", "fruits"],
    "Dining": ["restaurant", "dining", "pizza", "burger", "coffee", "cafe", "fast food", "takeout"],
    "Transportation": ["uber", "ola", "fuel", "gas", "bus", "train", "taxi", "metro", "subway"],
    "Shopping": ["amazon", "flipkart", "mall", "clothes", "electronics", "apparel", "shoes", "accessories"],
    "Bills": ["electricity", "mobile", "internet", "recharge", "water", "gas bill", "phone"],
    "Rent": ["rent", "apartment", "flat", "lease", "housing"],
    "Health": ["hospital", "pharmacy", "doctor", "clinic", "medicine", "healthcare"],
    "Entertainment": ["movie", "netflix", "games", "spotify", "leisure", "concert", "theater", "music"]
}

# Precompute category embeddings once
category_embeddings = {
    category: model.encode(keywords, convert_to_tensor=True)
    for category, keywords in CATEGORIES.items()
}

SIMILARITY_THRESHOLD = 0.6

def categorize_expenses(df: pd.DataFrame) -> pd.DataFrame:
    """
    Assign categories to expenses based on description similarity to category keywords.
    Adds a 'category' column to the dataframe.
    """
    df = df.copy()
    descriptions = df["description"].astype(str).fillna("")

    # Compute embeddings for all descriptions once
    desc_embeddings = model.encode(descriptions.tolist(), convert_to_tensor=True)

    categories = []
    for emb in desc_embeddings:
        best_category = "Other"
        best_score = -1.0

        for category, cat_embs in category_embeddings.items():
            # Compute max cosine similarity with any keyword embedding for this category
            score = util.cos_sim(emb, cat_embs).max().item()
            if score > best_score:
                best_score = score
                best_category = category

        if best_score < SIMILARITY_THRESHOLD:
            best_category = "Other"

        categories.append(best_category)

    df["category"] = categories
    return df
