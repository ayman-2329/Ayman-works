import pandas as pd
from prophet import Prophet

def forecast_expenses(df: pd.DataFrame) -> pd.DataFrame:
    """
    Use Prophet to forecast future expenses based on historical data.

    Args:
        df: DataFrame with at least 'date' and 'amount' columns.

    Returns:
        DataFrame containing forecast results with columns like 'ds', 'yhat', etc.
        Returns empty DataFrame if insufficient data.
    """
    df = df.copy()
    df["date"] = pd.to_datetime(df["date"], errors="coerce")
    df = df.dropna(subset=["date", "amount"])

    # Group by date and sum amounts
    ts = df.groupby("date").agg({"amount": "sum"}).reset_index()
    ts.columns = ["ds", "y"]

    if len(ts) < 10:
        return pd.DataFrame()

    model = Prophet()
    model.fit(ts)
    future = model.make_future_dataframe(periods=30)
    forecast = model.predict(future)
    return forecast
