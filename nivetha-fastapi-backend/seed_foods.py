import asyncio
from datetime import datetime, timezone
from app.db.mongo import customer_db

foods_collection = customer_db["foods"]

# FoodCategory values allowed in foods.py:
# "Breakfast", "Lunch", "Dinner", "Sweets"
FOOD_ITEMS = [
    # --- LUNCH (Biryani & Variety Rice) ---
    {"name": "Chicken Biryani (சிக்கன் பிரியாணி)", "category": "Lunch", "is_vegetarian": False, "description": "Traditional aromatic chicken biryani"},
    {"name": "Mutton Biryani (மட்டன் பிரியாணி)", "category": "Lunch", "is_vegetarian": False, "description": "Authentic slow-cooked mutton biryani"},
    {"name": "Veg Biryani (வெஜ் பிரியாணி)", "category": "Lunch", "is_vegetarian": True, "description": "Fragrant vegetable biryani with spices"},
    {"name": "Egg Biryani (முட்டை பிரியாணி)", "category": "Lunch", "is_vegetarian": False, "description": "Spiced egg biryani"},
    {"name": "Paneer Biryani (பன்னீர் பிரியாணி)", "category": "Lunch", "is_vegetarian": True, "description": "Rich paneer dum biryani"},
    {"name": "Prawn Biryani (இறால் பிரியாணி)", "category": "Lunch", "is_vegetarian": False, "description": "Coastal style prawn biryani"},
    {"name": "Mushroom Biryani (மஷ்ரூம் பிரியாணி)", "category": "Lunch", "is_vegetarian": True, "description": "Flavorful mushroom biryani"},
    {"name": "Fish Biryani (மீன் பிரியாணி)", "category": "Lunch", "is_vegetarian": False, "description": "Traditional spiced fish biryani"},
    {"name": "White Rice (வெள்ளைச் சாதம்)", "category": "Lunch", "is_vegetarian": True, "description": "Steamed white rice for full meals"},
    {"name": "Ghee Rice (நெய் சாதம்)", "category": "Lunch", "is_vegetarian": True, "description": "Aromatic ghee-infused basmati/seeraga samba rice"},
    {"name": "Tomato Rice (தக்காளிச் சாதம்)", "category": "Lunch", "is_vegetarian": True, "description": "Tangy South Indian thakkali sadam"},
    {"name": "Lemon Rice (எலுமிச்சைச் சாதம்)", "category": "Lunch", "is_vegetarian": True, "description": "Classic elumichai sadam tempered with mustard and peanuts"},
    {"name": "Tamarind Rice (புளிச் சாதம்)", "category": "Lunch", "is_vegetarian": True, "description": "Traditional puliyodharai"},
    {"name": "Coconut Rice (தேங்காய்ச் சாதம்)", "category": "Lunch", "is_vegetarian": True, "description": "Fragrant thengai sadam"},
    {"name": "Curd Rice (தயிர்ச் சாதம்)", "category": "Lunch", "is_vegetarian": True, "description": "Creamy tempered thayir sadam"},
    {"name": "Mint Rice (புதினாச் சாதம்)", "category": "Lunch", "is_vegetarian": True, "description": "Fresh pudina sadam"},

    # --- SWEETS ---
    {"name": "Sakkarai Pongal (சர்க்கரைப் பொங்கல்)", "category": "Sweets", "is_vegetarian": True, "description": "Traditional jaggery and ghee sweet pongal"},
    {"name": "Paal Payasam (பால் பாயாசம்)", "category": "Sweets", "is_vegetarian": True, "description": "Creamy milk payasam"},
    {"name": "Semiya Payasam (சேமியா பாயாசம்)", "category": "Sweets", "is_vegetarian": True, "description": "Vermicelli payasam with cashews and raisins"},
    {"name": "Laddu (லட்டு)", "category": "Sweets", "is_vegetarian": True, "description": "Classic boondi laddu"},
    {"name": "Jalebi (ஜிலேபி)", "category": "Sweets", "is_vegetarian": True, "description": "Crispy saffron-soaked jalebi"},
    {"name": "Badusha (பாதுஷா)", "category": "Sweets", "is_vegetarian": True, "description": "Flaky traditional South Indian badusha"},
    {"name": "Gulab Jamun (குலாப் ஜாமுன்)", "category": "Sweets", "is_vegetarian": True, "description": "Soft khoya jamuns in rose-cardamom syrup"},
    {"name": "Mysore Pak (மைசூர் பாகு)", "category": "Sweets", "is_vegetarian": True, "description": "Melt-in-the-mouth ghee Mysore pak"},
    {"name": "Kesari (கேசரி)", "category": "Sweets", "is_vegetarian": True, "description": "Ghee-roasted rava kesari"},
    {"name": "Carrot Halwa (கேரட் அல்வா)", "category": "Sweets", "is_vegetarian": True, "description": "Rich slow-cooked carrot halwa"},
    {"name": "Wheat Halwa (கோதுமை அல்வா)", "category": "Sweets", "is_vegetarian": True, "description": "Traditional Tirunelveli style wheat halwa"},
    {"name": "Poli (போளி)", "category": "Sweets", "is_vegetarian": True, "description": "Sweet paruppu/coconut stuffed poli"},

    # --- BREAKFAST (Pongal, Idli, Dosa, Poori, Vadai, Bonda) ---
    {"name": "Ven Pongal (வெண் பொங்கல்)", "category": "Breakfast", "is_vegetarian": True, "description": "Classic ghee-tempered ven pongal"},
    {"name": "Milagu Pongal (மிளகு பொங்கல்)", "category": "Breakfast", "is_vegetarian": True, "description": "Black pepper and cumin spiced pongal"},
    {"name": "Ghee Pongal (நெய் பொங்கல்)", "category": "Breakfast", "is_vegetarian": True, "description": "Rich ghee pongal"},
    {"name": "Idli (இட்லி)", "category": "Breakfast", "is_vegetarian": True, "description": "Soft steamed rice-lentil idlis"},
    {"name": "Mini Idli (மினி இட்லி)", "category": "Breakfast", "is_vegetarian": True, "description": "Bite-sized mini idlis"},
    {"name": "Dosa (தோசை)", "category": "Breakfast", "is_vegetarian": True, "description": "Crispy golden dosa"},
    {"name": "Masala Dosa (மசாலா தோசை)", "category": "Breakfast", "is_vegetarian": True, "description": "Dosa stuffed with spiced potato masala"},
    {"name": "Ghee Dosa (நெய் தோசை)", "category": "Breakfast", "is_vegetarian": True, "description": "Crispy ghee roast dosa"},
    {"name": "Uthappam (ஊத்தாப்பம்)", "category": "Breakfast", "is_vegetarian": True, "description": "Thick soft uthappam"},
    {"name": "Poori (பூரி)", "category": "Breakfast", "is_vegetarian": True, "description": "Fluffy whole-wheat poori"},
    {"name": "Medu Vadai (மெது வடை)", "category": "Breakfast", "is_vegetarian": True, "description": "Crispy urad dal medu vadai"},
    {"name": "Masala Vadai (மசால் வடை)", "category": "Breakfast", "is_vegetarian": True, "description": "Crunchy chana dal masala vadai"},
    {"name": "Paruppu Vadai (பருப்பு வடை)", "category": "Breakfast", "is_vegetarian": True, "description": "Traditional lentil paruppu vadai"},
    {"name": "Masala Bonda (மசாலா போண்டா)", "category": "Breakfast", "is_vegetarian": True, "description": "Spiced gram flour masala bonda"},
    {"name": "Potato Bonda (உருளைக்கிழங்கு போண்டா)", "category": "Breakfast", "is_vegetarian": True, "description": "Crispy urulaikizhangu bonda"},

    # --- DINNER (Tiffin & Breads) ---
    {"name": "Parotta (பரோட்டா)", "category": "Dinner", "is_vegetarian": True, "description": "Layered flaky Malabar/Madurai parotta"},
    {"name": "Chapathi (சப்பாத்தி)", "category": "Dinner", "is_vegetarian": True, "description": "Soft whole wheat chapathi"},
    {"name": "Idiyappam (இடியாப்பம்)", "category": "Dinner", "is_vegetarian": True, "description": "Steamed string hoppers"},
    {"name": "Kothu Parotta (கொத்து பரோட்டா)", "category": "Dinner", "is_vegetarian": True, "description": "Minced parotta tossed with salna and spices"},
]

async def seed():
    now = datetime.now(timezone.utc)
    await foods_collection.delete_many({})

    docs = []
    for item in FOOD_ITEMS:
        docs.append({
            "name": item["name"],
            "category": item["category"],
            "description": item["description"],
            "is_available": True,
            "image_url": None,
            "is_vegetarian": item["is_vegetarian"],
            "created_at": now,
            "updated_at": now,
        })

    result = await foods_collection.insert_many(docs)
    print(f"Successfully inserted {len(result.inserted_ids)} foods into customer_db['foods']!")

if __name__ == "__main__":
    asyncio.run(seed())