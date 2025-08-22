from sentence_transformers import SentenceTransformer, util
import pandas as pd
import os
import joblib

model = SentenceTransformer(os.getenv("EMBEDDING_MODEL"))

# Load trained models
try:
    linear_model = joblib.load("linear_regression_model.joblib")
    logistic_model = joblib.load("logistic_regression_model.joblib")
except:
    linear_model = None
    logistic_model = None

def recommend_cards(meta_df, query, max_price=1000, top_n=5):
    df = meta_df.copy()
    df["text"] = df["title"].astype(str) + " " + df["description"].astype(str)
    df = df[df["price"] <= max_price]

    if df.empty:
        return pd.DataFrame()

    embeddings = model.encode(df["text"].tolist(), convert_to_tensor=True)
    query_embedding = model.encode(query, convert_to_tensor=True)

    scores = util.cos_sim(query_embedding, embeddings)[0]
    df["embedding_score"] = scores.cpu().numpy()

    # Prepare features for model prediction
    if linear_model is not None and logistic_model is not None:
        # Encode category
        df['category'] = df['categories'].apply(lambda x: x[0] if isinstance(x, list) and len(x) > 0 else 'Unknown')
        # For simplicity, encode categories as categorical codes
        df['category_encoded'] = pd.Categorical(df['category']).codes
        features = df[['price', 'category_encoded']]

        # Predict ratings and purchase likelihood
        df['predicted_rating'] = linear_model.predict(features)
        df['predicted_purchase_prob'] = logistic_model.predict_proba(features)[:,1]

        # Combine embedding score and model predictions for final score
        df['final_score'] = (df['embedding_score'] + df['predicted_rating'] + df['predicted_purchase_prob']) / 3
    else:
        df['final_score'] = df['embedding_score']

    return df.sort_values(by="final_score", ascending=False).head(top_n)
