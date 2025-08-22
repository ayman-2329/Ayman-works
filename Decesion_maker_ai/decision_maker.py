import argparse
import random
import json
import os

# Load preset choices from JSON file
def load_choices(filename="choices.json"):
    if not os.path.exists(filename):
        return {}
    with open(filename, "r") as f:
        return json.load(f)

# Pick one random choice
def make_decision(choices):
    return random.choice(choices)

def main():
    parser = argparse.ArgumentParser(description="🎲 Decision Maker CLI - Help yourself decide things easily!")
    parser.add_argument("--choices", type=str, help="Comma-separated list of choices. Example: 'pizza, burger, pasta'")
    parser.add_argument("--category", type=str, help="Category name to load choices from choices.json (e.g., food, movies, travel)")
    args = parser.parse_args()

    choices = []

    # Check if custom choices provided via --choices
    if args.choices:
        choices = [choice.strip() for choice in args.choices.split(",") if choice.strip()]
    # Check if category provided via --category
    elif args.category:
        presets = load_choices()
        choices = presets.get(args.category.lower(), [])
        if not choices:
            print(f"⚠️ Category '{args.category}' not found in choices.json.")
            return
    else:
        print("⚠️ Please provide either --choices or --category.\nExample:\n  python decision_maker.py --choices \"read, sleep, code\" \n  OR\n  python decision_maker.py --category food")
        return

    if not choices:
        print("⚠️ No choices provided or found.")
        return

    decision = make_decision(choices)

    print("\n🎲 Decision Maker 🎲")
    if args.choices:
        print("🤔 Choices you provided:", ", ".join(choices))
    else:
        print(f"📂 Using preset category: {args.category}")
        print("📄 Choices from file:", ", ".join(choices))

    print("\n✅ You should go with ➡️", decision)
    print()

if __name__ == "__main__":
    main()
