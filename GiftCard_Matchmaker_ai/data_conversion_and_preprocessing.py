import json
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.preprocessing import LabelEncoder
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics import mean_squared_error, accuracy_score
import numpy as np

def convert_jsonl_to_json(jsonl_path, json_path):
    data = []
    with open(jsonl_path, 'r', encoding='utf-8') as f:
        for line in f:
            data.append(json.loads(line))
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)

def preprocess_meta_data(meta_json_path):
    with open(meta_json_path, 'r', encoding='utf-8') as f:
        meta = json.load(f)
    df = pd.DataFrame(meta)
    # Drop rows with missing critical fields
    df = df.dropna(subset=['title', 'description', 'price'])
    # Convert price to numeric
    df['price'] = pd.to_numeric(df['price'], errors='coerce')
    df = df.dropna(subset=['price'])
    # Encode categories
    df['category'] = df['categories'].apply(lambda x: x[0] if isinstance(x, list) and len(x) > 0 else 'Unknown')
    le = LabelEncoder()
    df['category_encoded'] = le.fit_transform(df['category'])
    # Combine text fields for vectorization
    df['text'] = df['title'] + ' ' + df['description'].apply(lambda x: ' '.join(x) if isinstance(x, list) else x)
    return df, le

def train_linear_regression(df):
    # Use price and category_encoded to predict average_rating if available
    if 'average_rating' not in df.columns:
        print("average_rating not found in data, skipping linear regression.")
        return None
    df = df.dropna(subset=['average_rating'])
    X = df[['price', 'category_encoded']]
    y = df['average_rating']
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    model = LinearRegression()
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    mse = mean_squared_error(y_test, y_pred)
    print(f"Linear Regression MSE: {mse}")
    return model

def train_logistic_regression(df):
    # Example: classify if rating is above 3.5 (good) or not
    if 'average_rating' not in df.columns:
        print("average_rating not found in data, skipping logistic regression.")
        return None
    df = df.dropna(subset=['average_rating'])
    df['good_rating'] = (df['average_rating'] > 3.5).astype(int)
    X = df[['price', 'category_encoded']]
    y = df['good_rating']
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    model = LogisticRegression(max_iter=1000)
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    print(f"Logistic Regression Accuracy: {accuracy}")
    return model

if __name__ == "__main__":
    # Convert JSONL to JSON
    convert_jsonl_to_json('data/Gift_Cards.jsonl', 'data/Gift_Cards.json')
    convert_jsonl_to_json('data/meta_Gift_Cards.jsonl', 'data/meta_Gift_Cards.json')

    # Preprocess meta data
    df_meta, label_encoder = preprocess_meta_data('data/meta_Gift_Cards.json')

    # Train models
    linear_model = train_linear_regression(df_meta)
    logistic_model = train_logistic_regression(df_meta)

    # Further steps: implement RAG (to be done)
