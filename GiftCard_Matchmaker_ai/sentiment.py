from transformers.pipelines import pipeline

# Load the sentiment analysis model
sentiment_analyzer = pipeline(
    "sentiment-analysis",
    model="nlptown/bert-base-multilingual-uncased-sentiment"
)

def get_sentiment(text):
    if not text or not isinstance(text, str):
        return "❓ No review"

    try:
        # Trim input to 512 characters (model-safe)
        text = text.strip()
        if len(text) > 512:
            text = text[:512] + "…"

        result_raw = sentiment_analyzer(text)
        if result_raw is None:
            return "⚠️ Error: No result from sentiment analyzer"
        try:
            analysis_result = list(result_raw)
        except TypeError:
            return "⚠️ Error: Unexpected result type from sentiment analyzer"

        if not analysis_result:
            return "⚠️ Error: No result from sentiment analyzer"

        result = analysis_result[0]
        if not isinstance(result, dict):
            return "⚠️ Error: Unexpected format"

        label = result.get('label')     # e.g., '5 stars'
        score = result.get('score')     # Float: 0.9

        if label is None:
            return "⚠️ Error: Missing label"

        num_stars = int(label.split()[0])  # Extract numeric part

        # Emoji map for UI clarity
        emoji_map = {
            5: "😍 Very Positive",
            4: "😊 Positive",
            3: "😐 Neutral",
            2: "😟 Negative",
            1: "😡 Very Negative"
        }

        sentiment_text = emoji_map.get(num_stars, "🤔 Unknown")
        return f"{sentiment_text} ({int(score * 100)}%)" if score is not None else f"{sentiment_text} (No score)"

    except Exception as e:
        return f"⚠️ Error: {str(e)}"


# 🧪 Optional: Run test examples when executing directly
if __name__ == "__main__":
    test_reviews = [
        "Loved it! Perfect gift for my friend ❤️",
        "",
        None,
        "Terrible experience. Not valid on checkout.",
        "😊" * 600  # long emoji input test
    ]

    for review in test_reviews:
        print("\nReview:", repr(review))
        print("Sentiment:", get_sentiment(review))
