import pandas as pd
from typing import Tuple

def budget_coach(df: pd.DataFrame) -> str:
    total_spending = df["amount"].sum()
    category_totals = df.groupby("category")["amount"].sum().to_dict()

    insights = "📊 **Budget Insights Based on Your Spending**\n\n"
    if not category_totals:
        insights += "No category data available to analyze."
    else:
        for category, amount in category_totals.items():
            percent = (amount / total_spending) * 100 if total_spending else 0
            insights += f"- **{category}**: ₹{amount:.2f} ({percent:.1f}%) of total spending\n"

        insights += "\n💡 **Tips:**\n"
        if total_spending > 50000:
            insights += "- Consider reviewing high spending categories for possible cuts.\n"
        if category_totals.get("Dining", 0) > total_spending * 0.25:
            insights += "- Dining takes a large portion of your budget. Cooking at home might help save.\n"
        if category_totals.get("Entertainment", 0) < total_spending * 0.05:
            insights += "- Low entertainment spend — make sure you're balancing fun and finance.\n"

    return insights
