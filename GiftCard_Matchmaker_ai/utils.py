def format_price(price):
    try:
        return f"{float(price):.2f}"
    except:
        return "N/A"
