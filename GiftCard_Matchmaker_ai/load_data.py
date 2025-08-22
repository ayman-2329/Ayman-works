import pandas as pd
import json

def convert_jsonl_to_json(jsonl_path, json_path):
    data = []
    with open(jsonl_path, 'r', encoding='utf-8') as f:
        for line in f:
            data.append(json.loads(line))
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)

def load_data():
    # Convert JSONL to JSON first
    convert_jsonl_to_json("data/Gift_Cards.jsonl", "data/Gift_Cards.json")
    convert_jsonl_to_json("data/meta_Gift_Cards.jsonl", "data/meta_Gift_Cards.json")

    # Load from JSON files using json.load and convert to DataFrame
    import json
    with open("data/Gift_Cards.json", "r", encoding="utf-8") as f:
        reviews_data = json.load(f)
    with open("data/meta_Gift_Cards.json", "r", encoding="utf-8") as f:
        meta_data = json.load(f)

    reviews = pd.DataFrame(reviews_data)
    meta = pd.DataFrame(meta_data)
    meta = meta.dropna(subset=["title", "description", "price"])
    return reviews, meta
