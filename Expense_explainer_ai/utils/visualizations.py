import pandas as pd
import plotly.express as px
from plotly.graph_objs import Figure
from typing import Optional

def generate_line_chart(
    df: pd.DataFrame, 
    x_col: str, 
    y_col: str, 
    title: str
) -> Figure:
    """
    Generate a Plotly line chart.
    """
    fig = px.line(df, x=x_col, y=y_col, title=title)
    fig.update_layout(margin=dict(l=20, r=20, t=40, b=20))
    return fig

def generate_pie_chart(
    df: pd.DataFrame, 
    names_col: str, 
    values_col: str, 
    title: str
) -> Figure:
    """
    Generate a Plotly pie chart.
    """
    fig = px.pie(df, names=names_col, values=values_col, title=title)
    fig.update_traces(textposition='inside', textinfo='percent+label')
    fig.update_layout(margin=dict(l=20, r=20, t=40, b=20))
    return fig

def generate_forecast_chart(forecast_df: pd.DataFrame) -> Optional[Figure]:
    """
    Generate a line chart for Prophet forecast.
    """
    if forecast_df.empty or 'ds' not in forecast_df or 'yhat' not in forecast_df:
        return None
    
    fig = px.line(
        forecast_df, 
        x='ds', 
        y='yhat', 
        title="Expense Forecast"
    )
    fig.update_layout(margin=dict(l=20, r=20, t=40, b=20))
    return fig
