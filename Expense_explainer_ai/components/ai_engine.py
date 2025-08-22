import pandas as pd
from typing import List, Optional, Tuple
from sklearn.ensemble import IsolationForest

from transformers import pipeline

sentiment_classifier = pipeline("sentiment-analysis", model="distilbert-base-uncased-finetuned-sst-2-english")



try:
    summarizer = pipeline("summarization", model="sshleifer/distilbart-cnn-12-6")
except Exception as e:
    summarizer = None
    print(f"⚠️ Summarization model could not be loaded: {e}")


def explain_expenses(df: pd.DataFrame, limit: int = 5) -> List[str]:
    """
    Provide sentiment explanations for the first `limit` transactions.
    """
    explanations = []
    for _, row in df.head(limit).iterrows():
        desc = str(row.get("description", "")).strip()
        amt = row.get("amount", 0)
        if desc:
            try:
                result = sentiment_classifier(desc[:512])
                if result and isinstance(result, list):
                    label = result[0].get("label", "UNKNOWN")
                    score = int(result[0].get("score", 0) * 100)
                    sentiment_text = (
                        f"Transaction: '{desc[:40]}...' has a sentiment of {label} "
                        f"with confidence {score}%. This indicates the transaction is perceived as {label.lower()}."
                    )
                else:
                    sentiment_text = f"No sentiment detected for '{desc[:40]}...'"
            except Exception as e:
                sentiment_text = f"No sentiment detected for '{desc[:40]}...' due to error: {e}"
        else:
            sentiment_text = f"Transaction of ₹{amt} has no description."
        explanations.append(sentiment_text)

    return explanations or ["No transactions to analyze for sentiment."]


def detect_recurring(df: pd.DataFrame) -> pd.DataFrame:
    """
    Detect recurring transactions by grouping on lowercase description with at least 3 occurrences.
    Returns a DataFrame of recurring transactions with date, description, amount columns.
    """
    if "description" not in df.columns:
        return pd.DataFrame()

    recurring_groups = df.groupby(df["description"].str.lower())
    filtered = recurring_groups.filter(lambda x: len(x) >= 3)
    return filtered[["date", "description", "amount"]].drop_duplicates()


def detect_anomalies(df: pd.DataFrame) -> pd.DataFrame:
    """
    Detect anomalies in 'amount' using IsolationForest.
    Adds 'anomaly_score' and 'is_anomaly' columns to DataFrame.
    """
    df = df.copy()
    if "amount" not in df.columns or df["amount"].isnull().all():
        df["anomaly_score"] = 0
        df["is_anomaly"] = False
        return df

    # Optional: scale amounts before anomaly detection if needed
    X = df[["amount"]].fillna(0)
    clf = IsolationForest(contamination=0.05, random_state=42)
    df["anomaly_score"] = clf.fit_predict(X)
    df["is_anomaly"] = df["anomaly_score"] == -1
    return df


def generate_openai_summary(df: pd.DataFrame) -> str:
    """
    Generate a financial summary using summarization pipeline.
    Returns a string summary or warning if summarizer not available.
    """
    if summarizer is None:
        return "⚠️ Summarization model not available."

    try:
        total = df["amount"].sum()
        categories = df["category"].value_counts().to_dict()

        summary_text = (
            f"Financial Summary Report:\n"
            f"- Total amount spent: ₹{total:.2f}\n"
            f"- Spending breakdown by category:\n"
        )
        for category, count in categories.items():
            summary_text += f"  * {category}: {count} transactions\n"
        summary_text += (
            "Based on this spending behavior, provide 3 practical financial tips to help manage expenses better.\n"
            "Suggest potential areas for savings or caution.\n"
            "Identify any unusual spending patterns or anomalies."
        )

        input_length = len(summary_text.split())
        max_len = max(60, int(input_length * 1.2))
        result = summarizer(summary_text[:512], max_length=max_len, min_length=60, do_sample=False)

        if result and isinstance(result, list) and "summary_text" in result[0]:
            return result[0]["summary_text"]
        elif result and isinstance(result, list) and "summary_text" not in result[0]:
            # Sometimes summarizer returns 'summary_text' under 'summary_text' or 'summary_text'
            return result[0].get("summary_text") or result[0].get("summary_text", "⚠️ No summary generated.")
        else:
            return "⚠️ No summary generated."
    except Exception as e:
        return f"⚠️ Error generating summary: {e}"