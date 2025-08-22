import json
import random
import argparse

def load_fortunes(filename="fortunes.json"):
    with open(filename, "r") as f:
        return json.load(f)

def get_fortune(topic, fortunes):
    return random.choice(fortunes.get(topic, ["I see... mysterious things ahead."]))

def main():
    parser = argparse.ArgumentParser(description="Get your fortune!")
    parser.add_argument("--name", type=str, help="Your name")
    parser.add_argument("--mood", type=str, help="Your current mood")
    parser.add_argument("--topic", type=str, required=True, help="Topic for fortune: career, love, money, health")
    
    args = parser.parse_args()
    fortunes = load_fortunes()

    print("\n🔮 Welcome to the Fortune Teller 🔮")
    if args.name:
        print(f"Hello, {args.name}!")

    print(f"\n✨ Topic: {args.topic.capitalize()}")
    print("🔔 Mood:", args.mood or "Unknown mood")

    print("\nYour Fortune:")
    print("👉", get_fortune(args.topic.lower(), fortunes))
    print()

if __name__ == "__main__":
    main()
