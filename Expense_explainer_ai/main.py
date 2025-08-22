import os
import streamlit as st
import pandas as pd
from dotenv import load_dotenv

def inject_custom_css():
    st.markdown("""
        <style>
        /* Import Google Font */
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap');
        
        /* Main Theme */
        :root {
            --primary-color: #00838f;
            --accent-color: #ff6e40;
            --background-color: #0e1117;
            --secondary-bg: #1e2329;
            --text-color: #ffffff;
        }            /* Global Styles */
        html, body, [class*="css"] {
            font-family: 'Inter', sans-serif;
            color: var(--text-color);
            line-height: 1.6;
        }

        .streamlit-expanderHeader {
            font-size: 1.1em;
            font-weight: 600;
        }

        /* Headers */
        h1 {
            font-weight: 600 !important;
            color: var(--text-color) !important;
            margin-bottom: 1.5rem !important;
            padding-top: 1rem !important;
        }

        h2, h3 {
            font-weight: 600 !important;
            color: var(--text-color) !important;
            margin-top: 1.5rem !important;
            margin-bottom: 1rem !important;
        }

        /* Streamlit Components */
        .stButton > button {
            background-color: var(--primary-color);
            color: white;
            border-radius: 6px;
            padding: 0.5rem 1rem;
            border: none;
            transition: all 0.2s ease;
        }

        .stButton > button:hover {
            background-color: var(--accent-color);
            transform: translateY(-2px);
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }

        /* File Uploader */
        .uploadedFile {
            background-color: var(--secondary-bg);
            border-radius: 6px;
            padding: 1rem;
            margin: 1rem 0;
        }

        /* DataFrame Styling */
        .dataframe {
            background-color: var(--secondary-bg);
            border-radius: 6px;
            padding: 1rem;
            margin: 1rem 0;
            font-size: 0.9rem;
        }

        .dataframe th {
            background-color: var(--primary-color);
            color: white;
            padding: 0.75rem !important;
            font-weight: 600 !important;
        }

        .dataframe td {
            padding: 0.5rem !important;
            border-bottom: 1px solid rgba(255,255,255,0.1) !important;
        }

        /* Style alternating rows */
        .dataframe tr:nth-child(even) {
            background-color: rgba(255,255,255,0.02);
        }

        .dataframe tr:hover {
            background-color: rgba(255,255,255,0.05) !important;
        }

        /* Charts */
        .js-plotly-plot {
            background-color: var(--secondary-bg);
            border-radius: 6px;
            padding: 1rem;
            margin: 1rem 0;
        }

        /* Text Input */
        .stTextInput input {
            background-color: var(--secondary-bg);
            border: 1px solid var(--primary-color);
            border-radius: 6px;
            padding: 0.5rem;
            color: var(--text-color);
        }

        /* Success/Info/Warning Messages */
        .stSuccess, .stInfo, .stWarning, .stError {
            border-radius: 6px;
            padding: 1rem;
            margin: 1rem 0;
        }

        /* Spinner */
        .stSpinner > div {
            border-color: var(--primary-color) !important;
        }
        </style>
    """, unsafe_allow_html=True)

from components.file_parser import parse_uploaded_file
from components.ai_categorizer import categorize_expenses
from components.ai_engine import (
    explain_expenses,
    detect_anomalies,
    detect_recurring,
    generate_openai_summary,
)
from components.budget_coach import budget_coach
from components.forecast import forecast_expenses
from components.pdf_export import generate_pdf
from utils.visualizations import (
    generate_line_chart,
    generate_pie_chart,
    generate_forecast_chart,
)
from components.rag_system.rag_system import RAGSystem

load_dotenv()


@st.cache_resource
def load_rag() -> RAGSystem:
    return RAGSystem(docs_path="data/rag_docs")


def main() -> None:
    st.set_page_config("💸 EXPENSE EXPLAINER", page_icon="📊", layout="wide")
    inject_custom_css()
    st.title("EXPENSE EXPLAINER BOT")

    uploaded_file = st.file_uploader(
        "Upload your bank statement ('CSV(current)', PDF, DOCX, Image)",
        type=["csv", "pdf", "docx", "png", "jpg", "jpeg", "bmp", "tiff"],
    )

    if uploaded_file:
        try:
            with st.spinner("Parsing your file..."):
                df = parse_uploaded_file(uploaded_file)

            if df.empty:
                st.warning("No data extracted from the file.")
                return

            # Categorize expenses
            df = categorize_expenses(df)

            # Create main container for better organization
            with st.container():
                # Categorize expenses in a container with custom styling
                with st.container():
                    st.markdown("""
                        <div style='background-color: var(--secondary-bg); padding: 1.5rem; border-radius: 10px; margin-bottom: 1rem;'>
                            <h3 style='margin-top: 0 !important; display: flex; align-items: center; gap: 0.5rem;'>
                                📊 Categorized Expenses
                            </h3>
                            <p style='color: rgba(255,255,255,0.6); margin-top: 0.5rem; font-size: 0.9rem;'>
                                Detailed breakdown of your transactions by category
                            </p>
                        </div>
                    """, unsafe_allow_html=True)
                    st.dataframe(df, height=300)

                # Sentiment Analysis
                st.markdown("""
                    <div style='background-color: var(--secondary-bg); padding: 1.5rem; border-radius: 10px; margin-bottom: 1rem;'>
                        <h3 style='margin-top: 0 !important; display: flex; align-items: center; gap: 0.5rem;'>
                            💡 Spending Analysis
                        </h3>
                        <p style='color: rgba(255,255,255,0.6); margin-top: 0.5rem; font-size: 0.9rem;'>
                            AI-powered insights about your spending patterns
                        </p>
                    </div>
                """, unsafe_allow_html=True)
                
                sentiments = explain_expenses(df)
                # Create two columns for sentiment analysis
                col1, col2 = st.columns(2)
                # Split sentiments between columns
                half = len(sentiments) // 2
                
                with col1:
                    for s in sentiments[:half]:
                        st.markdown(f"""
                            <div style='background-color: rgba(255,255,255,0.05); padding: 1.2rem; 
                                border-radius: 8px; margin-bottom: 1rem; border-left: 4px solid var(--primary-color);
                                font-size: 0.95rem; line-height: 1.6;'>
                                <div style='color: rgba(255,255,255,0.9);'>
                                    {s}
                                </div>
                            </div>
                        """, unsafe_allow_html=True)
                
                with col2:
                    for s in sentiments[half:]:
                        st.markdown(f"""
                            <div style='background-color: rgba(255,255,255,0.05); padding: 1.2rem; 
                                border-radius: 8px; margin-bottom: 1rem; border-left: 4px solid var(--primary-color);
                                font-size: 0.95rem; line-height: 1.6;'>
                                <div style='color: rgba(255,255,255,0.9);'>
                                    {s}
                                </div>
                            </div>
                        """, unsafe_allow_html=True)

            # Expenses over time line chart
            if "date" in df.columns:
                df["date"] = pd.to_datetime(df["date"], errors='coerce')
                expense_by_date = df.groupby("date")["amount"].sum().reset_index()
                st.subheader("Expenses Over Time")
                st.plotly_chart(
                    generate_line_chart(expense_by_date, "date", "amount", "Total Expenses Over Time"),
                    use_container_width=True
                )
            else:
                st.warning("No 'date' column for line chart.")

            # Expense distribution pie chart
            expense_summary = df.groupby("category")["amount"].sum().reset_index()
            st.subheader("Expense Distribution")
            st.plotly_chart(
                generate_pie_chart(expense_summary, "category", "amount", "Expense Distribution"),
                use_container_width=True
            )

            # Create columns for anomalies and recurring transactions
            col1, col2 = st.columns(2)

            # Detect anomalies
            with col1:
                df = detect_anomalies(df)
                anomalies = df[df["is_anomaly"] == True]
                if not anomalies.empty:
                    st.markdown("""
                        <div style='background-color: var(--secondary-bg); padding: 1.5rem; border-radius: 10px; margin-bottom: 1rem;'>
                            <h3 style='margin-top: 0 !important; display: flex; align-items: center; gap: 0.5rem;'>
                                ⚠️ Unusual Spending Patterns
                            </h3>
                            <p style='color: rgba(255,255,255,0.6); margin-top: 0.5rem; font-size: 0.9rem;'>
                                Transactions that deviate from your normal spending behavior
                            </p>
                        </div>
                    """, unsafe_allow_html=True)
                    st.dataframe(anomalies, height=200)

            # Recurring transactions
            with col2:
                recurring = detect_recurring(df)
                if not recurring.empty:
                    st.markdown("""
                        <div style='background-color: var(--secondary-bg); padding: 1.5rem; border-radius: 10px; margin-bottom: 2rem;'>
                            <h3 style='margin-top: 0 !important;'>Recurring Transactions</h3>
                        </div>
                    """, unsafe_allow_html=True)
                    st.dataframe(recurring, height=200)

            # Forecast expenses
            forecast_df = forecast_expenses(df)
            if not forecast_df.empty:
                st.subheader("Forecasted Expenses")
                fig = generate_forecast_chart(forecast_df)
                if fig:
                    st.plotly_chart(fig, use_container_width=True)
                else:
                    st.info("Unable to generate forecast chart.")
            else:
                st.info("Not enough data to generate forecast.")

            # AI Summary and Budget Insights in columns
            col1, col2 = st.columns(2)

            # AI-generated financial summary
            with col1:
                summary = generate_openai_summary(df)
                st.markdown("""
                    <div style='background-color: var(--secondary-bg); padding: 1.5rem; border-radius: 10px; margin-bottom: 2rem;'>
                        <h3 style='margin-top: 0 !important;'>AI Financial Summary</h3>
                    </div>
                """, unsafe_allow_html=True)
                summary_html = summary.replace('\n', '<br>')
                st.markdown(f"""
                    <div style='background-color: rgba(255,255,255,0.05); padding: 1.5rem; 
                        border-radius: 8px; margin-bottom: 1rem; border-left: 4px solid var(--accent-color);
                        font-size: 0.95rem; line-height: 1.7;'>
                        <div style='color: rgba(255,255,255,0.9);'>
                            {summary_html}
                        </div>
                    </div>
                """, unsafe_allow_html=True)

            # Budget coach insights
            with col2:
                insights = budget_coach(df)
                st.markdown("""
                    <div style='background-color: var(--secondary-bg); padding: 1.5rem; border-radius: 10px; margin-bottom: 2rem;'>
                        <h3 style='margin-top: 0 !important;'>Budget Insights</h3>
                    </div>
                """, unsafe_allow_html=True)
                insights_html = insights.replace('\n', '<br>')
                st.markdown(f"""
                    <div style='background-color: rgba(255,255,255,0.05); padding: 1.5rem; 
                        border-radius: 8px; margin-bottom: 1rem; border-left: 4px solid var(--primary-color);
                        font-size: 0.95rem; line-height: 1.7;'>
                        <div style='color: rgba(255,255,255,0.9);'>
                            {insights_html}
                        </div>
                    </div>
                """, unsafe_allow_html=True)

            # Download PDF report
            if st.button("📄 Download PDF Report"):
                pdf_buffer = generate_pdf(df, sentiments, recurring, forecast_df, summary)
                st.download_button("Download Report", pdf_buffer, file_name="expense_report.pdf", mime="application/pdf")

            # RAG system question answering
            st.markdown("""
                <div style='background-color: var(--secondary-bg); padding: 1.5rem; border-radius: 10px; margin: 2rem 0;'>
                    <h3 style='margin-top: 0 !important;'>🤖 Ask your Expense Data</h3>
                </div>
            """, unsafe_allow_html=True)
            
            question = st.text_input("Enter your question:")
            if question:
                rag = load_rag()
                answer = rag.query(question)
                st.markdown(f"""
                    <div style='background-color: rgba(255,255,255,0.05); padding: 1rem; 
                        border-radius: 8px; margin: 1rem 0; border-left: 4px solid var(--accent-color);'>
                        {answer}
                    </div>
                """, unsafe_allow_html=True)

        except Exception as e:
            st.error(f"Error: {e}")

    else:
        st.info("Please upload a bank statement to begin.")


if __name__ == "__main__":
    main()
