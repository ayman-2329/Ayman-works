import pandas as pd
from difflib import SequenceMatcher

def similar(a: str, b: str) -> float:
    return SequenceMatcher(None, a, b).ratio()

def detect_recurring_expenses(df: pd.DataFrame, amount_tolerance: float = 0.05, min_months: int = 3) -> pd.DataFrame:
    if "description" not in df.columns or "date" not in df.columns or "amount" not in df.columns:
        return pd.DataFrame()  # Missing required fields

    df = df.copy()

    # Normalize description
    df["description"] = df["description"].str.lower().str.strip()

    # Ensure datetime and drop invalid dates
    df["date"] = pd.to_datetime(df["date"], errors="coerce")
    df = df.dropna(subset=["date"])

    # Add month column for grouping
    df["month"] = df["date"].dt.to_period("M")

    # Group by description and amount, count how many unique months it appeared in
    grouped = (
        df.groupby(["description", "amount"])
        .agg(
            months=("month", "nunique"),
            first_date=("date", "min"),
            last_date=("date", "max"),
            count=("date", "count"),
        )
        .reset_index()
    )

    # Filter those that appeared in at least min_months unique months
    filtered = grouped[grouped["months"] >= min_months]

    # Fuzzy match descriptions within filtered to merge similar recurring transactions
    merged = []
    used = set()
    for i, row_i in filtered.iterrows():
        if i in used:
            continue
        desc_i = row_i["description"]
        amount_i = row_i["amount"]
        similar_rows = [row_i]
        used.add(i)
        for j, row_j in filtered.iterrows():
            if j <= i or j in used:
                continue
            desc_j = row_j["description"]
            amount_j = row_j["amount"]
            if similar(desc_i, desc_j) > 0.8 and abs(amount_i - amount_j) <= amount_tolerance * amount_i:
                similar_rows.append(row_j)
                used.add(j)
        # Aggregate similar rows
        agg_desc = desc_i
        agg_amount = sum(r["amount"] for r in similar_rows) / len(similar_rows)
        agg_months = max(r["months"] for r in similar_rows)
        agg_first_date = min(r["first_date"] for r in similar_rows)
        agg_last_date = max(r["last_date"] for r in similar_rows)
        agg_count = sum(r["count"] for r in similar_rows)
        merged.append({
            "description": agg_desc,
            "amount": agg_amount,
            "months": agg_months,
            "first_date": agg_first_date,
            "last_date": agg_last_date,
            "count": agg_count
        })

    result = pd.DataFrame(merged)
    result = result.sort_values("first_date")
    return result
