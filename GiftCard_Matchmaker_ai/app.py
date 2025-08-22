import streamlit as st
from load_data import load_data
from recommender import recommend_cards
from sentiment import get_sentiment
from utils import format_price 

# -- Page Config --
st.set_page_config(page_title="🎁 Gift Card Matchmaker", page_icon="💌", layout="wide")
st.markdown('<style>' + open('styles/style.css').read() + '</style>', unsafe_allow_html=True)


# -- Header --
st.markdown("""
    <h1 style='text-align: center; color: #FF4B4B;'>🎁 Gift Card Matchmaker Bot</h1>
    <p style='text-align: center; font-size: 18px;'>Find the perfect gift card for any occasion using AI 💡</p>
    <hr style='margin-top: -10px;'>
""", unsafe_allow_html=True)

# -- Sidebar Input --
with st.sidebar:
    st.header("🔍 Let's Find a Match")
    occasion = st.selectbox("🎉 Occasion", ["Birthday", "Anniversary", "Thank You", "Wedding", "Festival"])
    for_who = st.selectbox("🧑‍🤝‍🧑 Who is it for?", ["Friend", "Partner", "Parent", "Coworker", "Other"])
    budget = st.slider("💰 Your Budget (₹)", 100, 5000, 1000, step=100)
    extra = st.text_input("🔍 Keywords (optional)", placeholder="e.g., digital, romantic, shopping")

    query = f"{occasion} gift card for {for_who} {extra}".strip()

    if st.button("🔎 Search"):
        st.session_state.search_triggered = True
    elif "search_triggered" not in st.session_state:
        st.session_state.search_triggered = False

# -- Load Data --
data_loaded = load_data()
if data_loaded is not None and len(data_loaded) == 2:
    reviews, meta = data_loaded
else:
    reviews, meta = None, None


# -- Results --
if st.session_state.search_triggered:
    with st.spinner("Searching for the best gift cards... 🧠"):
        results = recommend_cards(meta, query, max_price=budget)

        if results is None or results.empty:
            st.warning("😢 No gift cards match your search.")
        else:
            cols = st.columns(2)  # Adjust to 3 or more for wider layout

            for idx, (i, row) in enumerate(results.iterrows()):
                with cols[idx % 2]:
                    with st.container():
                        st.markdown("<div class='card'>", unsafe_allow_html=True)
                        st.markdown(f"### 🎁 {row.get('title', 'No Title')}")
                        st.write(f"💸 **Price:** ₹{row.get('price', 'N/A')}")
                        st.write(f"⭐ **Rating:** {row.get('average_rating', 'N/A')}")
                        
                        # Category
                        categories = row.get("categories", [])
                        category = categories[0] if isinstance(categories, list) and categories else "❓ Unknown"
                        st.write(f"🏷️ **Category:** {category}")

                        # Description
                        description = row.get('description', '')
                        if isinstance(description, list):
                            description = ' '.join(description)
                        description = description.strip() if isinstance(description, str) else ''
                        description = description or "No description available."
                        st.markdown(f"📝 **Description:** {description}")

                        # Show predicted rating and purchase probability if available
                        predicted_rating = row.get('predicted_rating')
                        if predicted_rating is not None:
                            st.write(f"📈 **Predicted Rating:** {predicted_rating:.2f}")
                        predicted_purchase_prob = row.get('predicted_purchase_prob')
                        if predicted_purchase_prob is not None:
                            st.write(f"🛒 **Purchase Probability:** {predicted_purchase_prob:.2%}")

                        # Top review + sentiment
                        asin = row.get('asin') or row.get('parent_asin')
                        top_review = reviews[reviews['asin'] == asin]['text'].dropna().head(1)

                        if not top_review.empty:
                            review = top_review.values[0]
                            sentiment = get_sentiment(review)
                            st.markdown(f"**💬 Top Review:** _{review[:200]}{'...' if len(review) > 200 else ''}_")
                            st.write(f"🧠 **Sentiment:** {sentiment}")

                        st.markdown("</div>", unsafe_allow_html=True)


                    st.markdown("---")  # Divider between cards

            st.success("✨ Done! Hope you found a match.")
else:
    st.info("👈 Use the sidebar to begin your search.")

st.markdown("""
    <hr>
    <p style='text-align: center; color: #888;'>Made with ❤️ by Ayman </p>
    <p style='text-align: center; font-size: 14px;'>Powered by Streamlit, Hugging Face, and Sentence Transformers</p>
""", unsafe_allow_html=True)   