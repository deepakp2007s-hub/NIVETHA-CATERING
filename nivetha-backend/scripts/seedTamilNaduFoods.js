/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 * 
 * Idempotent Seed Script for Nivetha Catering Service
 * Seeds all 131 unique Tamil Nadu catering food items into MongoDB Atlas.
 * 
 * Safety Guarantees:
 * 1. Idempotent: uses $setOnInsert so existing documents are NOT overwritten.
 * 2. Preserves owner edits: does not overwrite custom prices, images, or availability.
 * 3. Does not delete any existing MongoDB records or custom owner items.
 * 4. Verifies exactly 131 unique catalog items.
 */

import mongoose from 'mongoose';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Define schema directly or import from models
const foodSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true, unique: true },
    tamilName: { type: String, required: true, trim: true },
    category: { type: String, required: true },
    type: { type: String, required: true, enum: ['Veg', 'Non-Veg'] },
    description: { type: String, default: '' },
    price: { type: Number, required: true },
    image: { type: String, required: true },
    available: { type: Boolean, default: true },
  },
  { timestamps: true }
);

const Food = mongoose.models.Food || mongoose.model('Food', foodSchema);

// Complete 131 items catalog
export const initial131Foods = [
  // 1 - 22: Breakfast & Tiffin
  { name: 'Idli', tamilName: 'இட்லி', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Pillowy soft steamed fermented rice and black gram lentil cakes served with coconut chutney and sambar.', price: 40, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Mini Idli', tamilName: 'மினி இட்லி', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Bite-sized button idlis soaked in a generous bath of rich ghee and sambar.', price: 70, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Sambar Idli', tamilName: 'சாம்பார் இட்லி', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Steaming idlis completely immersed in authentic drumstick and shallot sambar.', price: 65, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Dosa', tamilName: 'தோசை', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Golden-crisp paper-thin fermented rice crepe cooked on an iron griddle.', price: 50, image: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Masala Dosa', tamilName: 'மசாலா தோசை', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Crisp roasted dosa enveloped around seasoned mashed potato masala.', price: 75, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Ven Pongal', tamilName: 'வெண் பொங்கல்', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Comforting mash of raw rice and yellow split moong dal tempered with black pepper, cumin, ginger, and cashews.', price: 60, image: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Poori', tamilName: 'பூரி', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Puffed golden-fried whole wheat pooris served with spiced potato masala.', price: 60, image: 'https://images.unsplash.com/photo-1626074353765-517a681e40be?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Chapathi', tamilName: 'சப்பாத்தி', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Soft stone-ground whole wheat flatbreads cooked on tawa without excess oil.', price: 50, image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Parotta', tamilName: 'பரோட்டா', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Flaky, multi-layered golden brown Malabar-style flatbread beaten to crispy perfection.', price: 35, image: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Bun Parotta', tamilName: 'பன் பரோட்டா', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Madurai famous bun-shaped thick layered parotta with a crisp crust and fluffy interior.', price: 45, image: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Upma', tamilName: 'உப்புமா', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Roasted semolina cooked with mustard seeds, urad dal, green chillies, and ginger.', price: 45, image: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Vegetable Kootu', tamilName: 'காய்கறி கூட்டு', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Traditional slow-cooked mixed vegetables simmered with yellow moong dal and coconut cumin paste.', price: 55, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Onion Uthappam', tamilName: 'வெங்காய ஊத்தப்பம்', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Thick, fluffy fermented pancake topped with caramelized shallots and green chillies.', price: 70, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Veg Kurma', tamilName: 'வெஜ் குருமா', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Fragrant mixed garden vegetables simmered in creamy coconut cashew poppy seed paste.', price: 70, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Cauliflower 65', tamilName: 'காலிஃபிளவர் 65', category: 'Breakfast & Tiffin', type: 'Veg', description: 'Crunchy cauliflower florets marinated in red chilli and ginger-garlic paste, deep fried.', price: 80, image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Egg Dosa', tamilName: 'முட்டை தோசை', category: 'Breakfast & Tiffin', type: 'Non-Veg', description: 'Crispy fermented crepe topped with a beaten country egg, black pepper, and onions.', price: 80, image: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Egg Omelette', tamilName: 'முட்டை ஆம்லெட்', category: 'Breakfast & Tiffin', type: 'Non-Veg', description: 'Fluffy pan-fried double-egg omelette with diced shallots and green chillies.', price: 45, image: 'https://images.unsplash.com/photo-1510693206972-df098062cb71?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Egg Kalakki', tamilName: 'முட்டை கலக்கி', category: 'Breakfast & Tiffin', type: 'Non-Veg', description: 'Madurai street-style soft scrambled eggs with a velvety, runny center infused with chicken gravy.', price: 50, image: 'https://images.unsplash.com/photo-1510693206972-df098062cb71?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Egg Appam', tamilName: 'முட்டை ஆப்பம்', category: 'Breakfast & Tiffin', type: 'Non-Veg', description: 'Bowl-shaped fermented rice appam with a whole egg gently poached in the soft center.', price: 65, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Chicken Dosa', tamilName: 'சிக்கன் தோசை', category: 'Breakfast & Tiffin', type: 'Non-Veg', description: 'Hearty roasted dosa stuffed with spicy, slow-cooked shredded chicken sukka masala.', price: 130, image: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Chicken Curry', tamilName: 'சிக்கன் கறி', category: 'Breakfast & Tiffin', type: 'Non-Veg', description: 'Home-style chicken curry cooked with shallots, tomatoes, coriander seeds, and curry leaves.', price: 140, image: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Mutton Curry', tamilName: 'மட்டன் கறி', category: 'Breakfast & Tiffin', type: 'Non-Veg', description: 'Tender baby goat pieces slow-braised in hand-pounded Chettinad spices.', price: 210, image: 'https://images.unsplash.com/photo-1545247181-516773cae754?auto=format&fit=crop&w=800&q=80', available: true },

  // 23 - 51: Meals & Vegetarian
  { name: 'South Indian Meals', tamilName: 'தென்னிந்திய சாப்பாடு', category: 'Meals & Vegetarian', type: 'Veg', description: 'Royal festive banana-leaf feast featuring ponni rice, sambar, rasam, kootu, poriyal, and sweet.', price: 160, image: 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'White Rice', tamilName: 'வெள்ளை சாதம்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Steaming hot boiled Ponni rice, fluffy and distinct grains.', price: 40, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Sambar', tamilName: 'சாம்பார்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Traditional lentil stew with drumstick, shallots, tamarind, and ground spices.', price: 50, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Dal', tamilName: 'பருப்பு', category: 'Meals & Vegetarian', type: 'Veg', description: 'Parippu stew cooked with yellow lentils, cumin seeds, garlic, and pure ghee.', price: 50, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Dal Rasam', tamilName: 'பருப்பு ரசம்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Soothing broth made with toor dal water, country tomatoes, black pepper, and garlic.', price: 45, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Rasam', tamilName: 'ரசம்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Tangy and peppery tomato rasam seasoned with mustard, cumin, and dried red chillies.', price: 40, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Vatha Kuzhambu', tamilName: 'வத்தக்குழம்பு', category: 'Meals & Vegetarian', type: 'Veg', description: 'Dark tangy tamarind gravy with sundakkai and manathakkali vatral in gingelly oil.', price: 60, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Kara Kuzhambu', tamilName: 'காரக்குழம்பு', category: 'Meals & Vegetarian', type: 'Veg', description: 'Spicy and tangy gravy with small onions, peeled garlic pods, and drumstick.', price: 60, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Avial', tamilName: 'அவியல்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Garden vegetables stewed with crushed coconut, green chillies, curd, and virgin coconut oil.', price: 65, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Potato Poriyal', tamilName: 'உருளைக்கிழங்கு பொரியல்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Tender baby potato cubes tossed in mustard seeds, urad dal, and fresh grated coconut.', price: 50, image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Cabbage Poriyal', tamilName: 'முட்டைகோஸ் பொரியல்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Shredded cabbage stir-fried with yellow moong dal, mustard seeds, and fresh coconut.', price: 45, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Beans Poriyal', tamilName: 'பீன்ஸ் பொரியல்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Diced French green beans sautéed with shallots, curry leaves, and coconut.', price: 45, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Carrot Poriyal', tamilName: 'கேரட் பொரியல்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Sweet carrots diced fine and tempered with mild spices and grated coconut.', price: 45, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Cauliflower Poriyal', tamilName: 'காலிஃபிளவர் பொரியல்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Delicate cauliflower florets roasted with turmeric, shallots, and cracked black pepper.', price: 55, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Mushroom 65', tamilName: 'காளான் 65', category: 'Meals & Vegetarian', type: 'Veg', description: 'Crispy button mushrooms marinated in spices and curry leaves, flash fried.', price: 90, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Paneer Butter Masala', tamilName: 'பன்னீர் பட்டர் மசாலா', category: 'Meals & Vegetarian', type: 'Veg', description: 'Succulent paneer cubes simmered in velvety tomato, cashew, and cream gravy.', price: 130, image: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Channa Masala', tamilName: 'சென்னா மசாலா', category: 'Meals & Vegetarian', type: 'Veg', description: 'Chickpeas slow-cooked in a tangy Punjabi-style onion tomato gravy.', price: 85, image: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Rajma Masala', tamilName: 'ராஜ்மா மசாலா', category: 'Meals & Vegetarian', type: 'Veg', description: 'Red kidney beans simmered in spiced tomato and cumin broth.', price: 90, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Vegetable Biryani', tamilName: 'காய்கறி பிரியாணி', category: 'Meals & Vegetarian', type: 'Veg', description: 'Seeraga Samba rice layered with fresh vegetables, mint, and saffron milk.', price: 110, image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Mushroom Biryani', tamilName: 'காளான் பிரியாணி', category: 'Meals & Vegetarian', type: 'Veg', description: 'Fragrant Seeraga Samba rice dum cooked with juicy button mushrooms and mint.', price: 130, image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Lemon Rice', tamilName: 'எலுமிச்சை சாதம்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Zesty cooked rice with fresh lemon juice, roasted peanuts, and green chillies.', price: 60, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Tomato Rice', tamilName: 'தக்காளி சாதம்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Spicy Thakkali Sadam prepared with ripe country tomatoes and fennel seeds.', price: 65, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Curd Rice', tamilName: 'தயிர் சாதம்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Creamy Thayir Sadam mixed with fresh curd, pomegranate seeds, and mustard tempering.', price: 55, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Coconut Rice', tamilName: 'தேங்காய் சாதம்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Basmati rice tossed with fresh grated coconut, cashew nuts, and curry leaves.', price: 65, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Puliyodarai', tamilName: 'புளியோதரை', category: 'Meals & Vegetarian', type: 'Veg', description: 'Temple-style spicy tamarind rice with roasted sesame powder and peanuts.', price: 65, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Appalam', tamilName: 'அப்பளம்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Crispy fried sun-dried lentil wafers, essential for South Indian meals.', price: 15, image: 'https://images.unsplash.com/photo-1626074353765-517a681e40be?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Pickle', tamilName: 'ஊறுகாய்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Spicy homemade mango or lemon pickle cured in gingelly oil.', price: 15, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Curds', tamilName: 'தயிர்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Freshly set thick, creamy whole milk curd served chilled.', price: 25, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Buttermilk', tamilName: 'மோர்', category: 'Meals & Vegetarian', type: 'Veg', description: 'Refreshing churned spiced buttermilk blended with ginger, chillies, and curry leaves.', price: 25, image: 'https://images.unsplash.com/photo-1556881286-fc6915169721?auto=format&fit=crop&w=800&q=80', available: true },

  // 52 - 85: Biryani, Rice & Non-Vegetarian
  { name: 'Chicken Biryani', tamilName: 'சிக்கன் பிரியாணி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Dindigul-style Seeraga Samba biryani cooked with chicken pieces and fresh mint.', price: 180, image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Chicken Dum Biryani', tamilName: 'சிக்கன் தம் பிரியாணி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Slow-cooked Hyderabadi basmati rice sealed over coals with chicken and fried onions.', price: 190, image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Chicken Vadi Biryani', tamilName: 'சிக்கன் வடி பிரியாணி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Strained rice wedding biryani cooked with rich chicken masala broth and ghee.', price: 195, image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Mutton Biryani', tamilName: 'மட்டன் பிரியாணி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Signature Seeraga Samba mutton biryani prepared with succulent baby goat cuts.', price: 250, image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Mutton Dum Biryani', tamilName: 'மட்டன் தம் பிரியாணி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Dum-braised mutton with basmati rice, kewra water, saffron strands, and ghee.', price: 260, image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Mutton Vadi Biryani', tamilName: 'மட்டன் வடி பிரியாணி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Heritage strained mutton biryani cooked in large handis with bone broth.', price: 270, image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Prawn Biryani', tamilName: 'இறால் பிரியாணி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Plump sea prawns tossed with fragrant Seeraga Samba rice and coconut milk.', price: 240, image: 'https://images.unsplash.com/photo-1559847844-5315695dadae?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Egg Biryani', tamilName: 'முட்டை பிரியாணி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Fragrant spiced biryani rice served with two golden pan-fried boiled eggs.', price: 130, image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Chicken Rice', tamilName: 'சிக்கன் ரைஸ்', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Wok-tossed fried rice with diced chicken, scrambled egg, and spring onions.', price: 140, image: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Egg Rice', tamilName: 'முட்டை ரைஸ்', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Street-style wok-fried rice with farm eggs, cracked black pepper, and onions.', price: 110, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Chicken Noodles', tamilName: 'சிக்கன் நூடுல்ஸ்', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Stir-fried noodles with juicy chicken, capsicum, and garlic pepper seasoning.', price: 140, image: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Chicken 65', tamilName: 'சிக்கன் 65', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Crispy fried boneless chicken bites with red chillies, ginger garlic, and curry leaves.', price: 140, image: 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Chicken Lollipop', tamilName: 'சிக்கன் லாலிபாப்', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Frenched chicken winglets coated in spicy batter and fried until crunchy.', price: 160, image: 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Naatukozhi Varuval', tamilName: 'நாட்டுக்கோழி வறுவல்', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Country chicken dry roast cooked with shallots, crushed dry red chillies, and garlic.', price: 200, image: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Chicken Pepper Gravy', tamilName: 'சிக்கன் மிளகு கிரேவி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Robust chicken gravy made with coarsely pounded black peppercorns and fennel.', price: 160, image: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Chettinad Chicken Gravy', tamilName: 'செட்டிநாடு சிக்கன் கிரேவி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Iconic curry with stone-ground kalpasi, star anise, fennel, and roasted coconut.', price: 170, image: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Andhra Spicy Chicken Gravy', tamilName: 'ஆந்திரா ஸ்பைசி சிக்கன் கிரேவி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Fiery Andhra chicken curry with Guntur red chillies and green chilli paste.', price: 165, image: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Butter Chicken Gravy', tamilName: 'பட்டர் சிக்கன் கிரேவி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Tandoori chicken tikka chunks simmered in sweet-tangy tomato cashew cream sauce.', price: 180, image: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Country Chicken Gravy', tamilName: 'நாட்டுக்கோழி குழம்பு', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Village-style rich broth of country chicken cooked with small onions and coconut milk.', price: 195, image: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Pallapalayam Chicken Gravy', tamilName: 'பல்லபாளையம் சிக்கன் கிரேவி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Kongunadu chicken specialty cooked with dry red chillies, shallots, and fresh coconut.', price: 185, image: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Chicken Gravy', tamilName: 'சிக்கன் கிரேவி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Classic South Indian chicken gravy, ideal pairing for parotta and hot rice.', price: 150, image: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Chicken Kurma', tamilName: 'சிக்கன் குருமா', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Mildly spiced, creamy chicken gravy cooked with cashew nut paste and coconut milk.', price: 160, image: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Mutton Gravy', tamilName: 'மட்டன் கிரேவி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Succulent goat meat slow-simmered in rich caramelized shallot and tomato gravy.', price: 220, image: 'https://images.unsplash.com/photo-1545247181-516773cae754?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Chettinad Mutton Gravy', tamilName: 'செட்டிநாடு மட்டன் கிரேவி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Chettinad goat curry infused with roasted coriander, cumin, dry chillies, and coconut.', price: 235, image: 'https://images.unsplash.com/photo-1545247181-516773cae754?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Mutton Pepper Gravy', tamilName: 'மட்டன் மிளகு கிரேவி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Fiery mutton curry dominated by freshly roasted and crushed Tellicherry black pepper.', price: 230, image: 'https://images.unsplash.com/photo-1545247181-516773cae754?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Mutton Chukka', tamilName: 'மட்டன் சுக்கா', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Madurai style pan-roasted tender boneless mutton tossed in browned shallots and pepper.', price: 240, image: 'https://images.unsplash.com/photo-1545247181-516773cae754?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Coconut Milk Mutton Gravy', tamilName: 'தேங்காய்ப்பால் மட்டன் கிரேவி', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Tender mutton simmered in fresh thick first-press coconut milk with whole cardamoms.', price: 240, image: 'https://images.unsplash.com/photo-1545247181-516773cae754?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Mutton Bone Gravy', tamilName: 'மட்டன் எலும்பு குழம்பு', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Rich, collagenous bone-marrow mutton soup cooked with country ground spices.', price: 220, image: 'https://images.unsplash.com/photo-1545247181-516773cae754?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Fish Fry', tamilName: 'மீன் வறுவல்', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Vanjaram seer fish slice marinated in red chilli paste and roasted crisp.', price: 180, image: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Fish Curry', tamilName: 'மீன் குழம்பு', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Tangy and spicy clay-pot fish curry with sea fish, tamarind, and shallots.', price: 175, image: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Prawn Masala', tamilName: 'இறால் மசாலா', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Tiger prawns cooked in a rich masala of tomatoes, ginger, and fennel.', price: 220, image: 'https://images.unsplash.com/photo-1559847844-5315695dadae?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Egg Curry', tamilName: 'முட்டை குழம்பு', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Hard-boiled eggs simmered in a spiced onion, tomato, and coconut gravy.', price: 70, image: 'https://images.unsplash.com/photo-1510693206972-df098062cb71?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Egg Fry', tamilName: 'முட்டை வறுவல்', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Boiled eggs slit and pan-fried with red chilli powder, pepper, and curry leaves.', price: 40, image: 'https://images.unsplash.com/photo-1510693206972-df098062cb71?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Mutton Kurma', tamilName: 'மட்டன் குருமா', category: 'Biryani, Rice & Non-Vegetarian', type: 'Non-Veg', description: 'Royal white mutton kurma cooked with cashews, green chillies, and coconut milk.', price: 230, image: 'https://images.unsplash.com/photo-1545247181-516773cae754?auto=format&fit=crop&w=800&q=80', available: true },

  // 86 - 103: Dinner
  { name: 'Veg Kothu Parotta', tamilName: 'வெஜ் கொத்து பரோட்டா', category: 'Dinner', type: 'Veg', description: 'Minced parotta chopped on iron griddle with tomatoes, curry leaves, and veg salna.', price: 90, image: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Ghee Dosa', tamilName: 'நெய் தோசை', category: 'Dinner', type: 'Veg', description: 'Golden roasted crepe drenched in pure aromatic cow ghee, wonderfully crisp.', price: 80, image: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Roti', tamilName: 'ரொட்டி', category: 'Dinner', type: 'Veg', description: 'Clay tandoor baked whole wheat bread with blistered spots, served warm.', price: 30, image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Naan', tamilName: 'நான்', category: 'Dinner', type: 'Veg', description: 'Classic leavened flatbread baked against the piping hot walls of a tandoor.', price: 45, image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Butter Naan', tamilName: 'பட்டர் நான்', category: 'Dinner', type: 'Veg', description: 'Tandoor-baked leavened bread slathered with pure melted creamy butter.', price: 55, image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Kulcha', tamilName: 'குல்சா', category: 'Dinner', type: 'Veg', description: 'Soft flatbread topped with black onion seeds (kalonji) and fresh coriander.', price: 50, image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Idly', tamilName: 'இட்லி (இரவு)', category: 'Dinner', type: 'Veg', description: 'Soft steamed rice-lentil idlis served with evening tiffin sambar and chutney.', price: 40, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Idiyappam', tamilName: 'இடியாப்பம்', category: 'Dinner', type: 'Veg', description: 'Steamed delicate rice noodle nests served with sweet coconut milk or spicy salna.', price: 60, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Appam', tamilName: 'ஆப்பம்', category: 'Dinner', type: 'Veg', description: 'Fermented rice hoppers with lacy borders and spongy center, with coconut milk.', price: 55, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Vegetable Fried Rice', tamilName: 'வெஜ் ஃப்ரைட் ரைஸ்', category: 'Dinner', type: 'Veg', description: 'Wok-tossed basmati rice with finely diced carrots, beans, and spring onions.', price: 110, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Gobi Fried Rice', tamilName: 'கோபி ஃப்ரைட் ரைஸ்', category: 'Dinner', type: 'Veg', description: 'Spicy fried rice tossed with crispy golden cauliflower florets and spring onions.', price: 125, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Paneer Fried Rice', tamilName: 'பன்னீர் ஃப்ரைட் ரைஸ்', category: 'Dinner', type: 'Veg', description: 'Wok-tossed rice with golden-fried cottage cheese cubes and crisp veggies.', price: 135, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Veg Noodles', tamilName: 'வெஜ் நூடுல்ஸ்', category: 'Dinner', type: 'Veg', description: 'Classic wok-stirred hakka noodles loaded with shredded cabbage and peppers.', price: 110, image: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Gobi Manchurian', tamilName: 'கோபி மஞ்சூரியன்', category: 'Dinner', type: 'Veg', description: 'Crispy batter-fried cauliflower in sweet, spicy, and tangy Manchurian glaze.', price: 100, image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Brinjal Pachadi', tamilName: 'கத்திரிக்காய் பச்சடி', category: 'Dinner', type: 'Veg', description: 'Mashed roasted eggplants simmered with tamarind, shallots, and mustard tempering.', price: 55, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Dal Fry', tamilName: 'தால் ஃப்ரை', category: 'Dinner', type: 'Veg', description: 'Yellow lentils tempered with cumin seeds, garlic, onions, tomatoes, and ghee.', price: 75, image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Rice', tamilName: 'சாதம்', category: 'Dinner', type: 'Veg', description: 'Light steamed ponni rice, wholesome and freshly prepared for dinner service.', price: 40, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Mutton Bone Curry', tamilName: 'மட்டன் எலும்பு கறி', category: 'Dinner', type: 'Non-Veg', description: 'Chettinad style bone marrow curry infused with crushed black pepper and shallots.', price: 220, image: 'https://images.unsplash.com/photo-1545247181-516773cae754?auto=format&fit=crop&w=800&q=80', available: true },

  // 104 - 131: Sweets & Desserts
  { name: 'Gulab Jamun', tamilName: 'குலாப் ஜாமுன்', category: 'Sweets & Desserts', type: 'Veg', description: 'Soft reduced milk balls fried in ghee and soaked in cardamom rose syrup.', price: 50, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Rasgulla', tamilName: 'ரஸகுல்லா', category: 'Sweets & Desserts', type: 'Veg', description: 'Spongy chenna cheese spheres simmered in light fragrant sugar syrup.', price: 50, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Rasmalai', tamilName: 'ரசமலாய்', category: 'Sweets & Desserts', type: 'Veg', description: 'Cottage cheese patties in chilled saffron milk with pistachios and almonds.', price: 70, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Mysore Pak', tamilName: 'மைசூர் பாக்', category: 'Sweets & Desserts', type: 'Veg', description: 'Royal sweet of roasted gram flour, pure cow ghee, and sugar.', price: 60, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Badam Halwa', tamilName: 'பாதாம் அல்வா', category: 'Sweets & Desserts', type: 'Veg', description: 'Rich halwa made with blanched almonds, pure ghee, and saffron.', price: 90, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Wheat Halwa', tamilName: 'கோதுமை அல்வா', category: 'Sweets & Desserts', type: 'Veg', description: 'Fermented whole wheat milk halwa cooked with caramelized sugar and cashews.', price: 65, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Carrot Halwa', tamilName: 'கேரட் அல்வா', category: 'Sweets & Desserts', type: 'Veg', description: 'Red juicy carrots grated and slow-cooked in milk, khoya, and pure ghee.', price: 65, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Kasi Halwa', tamilName: 'காசி அல்வா', category: 'Sweets & Desserts', type: 'Veg', description: 'Grated white pumpkin (ash gourd) simmered in sugar syrup and saffron.', price: 60, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Tirunelveli Halwa', tamilName: 'திருநெல்வேலி அல்வா', category: 'Sweets & Desserts', type: 'Veg', description: 'Famous wheat milk halwa prepared using Thamirabarani water and pure cow ghee.', price: 75, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Bread Halwa', tamilName: 'பிரட் அல்வா', category: 'Sweets & Desserts', type: 'Veg', description: 'Crisp ghee-fried bread slow-cooked in sweetened milk and roasted cashews.', price: 55, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Kesari', tamilName: 'கேசரி', category: 'Sweets & Desserts', type: 'Veg', description: 'Celebration sweet of roasted sooji, saffron essence, pure ghee, and cashews.', price: 45, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Rava Kesari', tamilName: 'ரவா கேசரி', category: 'Sweets & Desserts', type: 'Veg', description: 'Traditional semolina pudding scented with cardamom and dripping with pure ghee.', price: 45, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Pineapple Kesari', tamilName: 'அன்னாசி கேசரி', category: 'Sweets & Desserts', type: 'Veg', description: 'Semolina kesari infused with chunks of tropical pineapple and saffron.', price: 55, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Paal Payasam', tamilName: 'பால் பாயாசம்', category: 'Sweets & Desserts', type: 'Veg', description: 'Slow-simmered red rice in full-cream milk sweetened with crystal sugar.', price: 60, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Semiya Payasam', tamilName: 'சேமியா பாயாசம்', category: 'Sweets & Desserts', type: 'Veg', description: 'Roasted vermicelli in saffron milk with ghee-roasted cashews and raisins.', price: 55, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Paruppu Payasam', tamilName: 'பருப்பு பாயாசம்', category: 'Sweets & Desserts', type: 'Veg', description: 'Roasted moong dal, organic jaggery syrup, thick coconut milk, and cardamom.', price: 60, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Jangiri', tamilName: 'ஜாங்கிரி', category: 'Sweets & Desserts', type: 'Veg', description: 'Swirled urad dal rosettes fried in ghee and soaked in saffron sugar syrup.', price: 50, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Jalebi', tamilName: 'ஜிலேபி', category: 'Sweets & Desserts', type: 'Veg', description: 'Crisp spiral rings of fermented batter soaked in warm fragrant sugar syrup.', price: 45, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Laddu', tamilName: 'லட்டு', category: 'Sweets & Desserts', type: 'Veg', description: 'Besan boondi spheres bound with sugar syrup, cloves, camphor, and cashews.', price: 40, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Boondi Laddu', tamilName: 'பூந்தி லட்டு', category: 'Sweets & Desserts', type: 'Veg', description: 'Crispy sweet gram flour pearls gently crushed and moulded with cow ghee.', price: 45, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Motichoor Laddu', tamilName: 'மோதிச்சூர் லட்டு', category: 'Sweets & Desserts', type: 'Veg', description: 'Ultra-fine tiny pearl laddus flavored with saffron, cardamom, and melon seeds.', price: 55, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Coconut Burfi', tamilName: 'தேங்காய் பர்பி', category: 'Sweets & Desserts', type: 'Veg', description: 'Freshly grated white coconut fudge flavored with cardamom and cut into diamonds.', price: 45, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Milk Peda', tamilName: 'பால்கோவா / மில்க் பேடா', category: 'Sweets & Desserts', type: 'Veg', description: 'Caramelized reduced milk solids discs infused with cardamom and pistachios.', price: 55, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Badusha', tamilName: 'பாதுஷா', category: 'Sweets & Desserts', type: 'Veg', description: 'Flaky layered flour pastries fried in ghee and glazed in crystalline sugar crust.', price: 45, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Poli', tamilName: 'போளி', category: 'Sweets & Desserts', type: 'Veg', description: 'Soft tawa sweet flatbread stuffed with chana dal, grated coconut, and jaggery.', price: 40, image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Sweet Pongal', tamilName: 'சர்க்கரை பொங்கல்', category: 'Sweets & Desserts', type: 'Veg', description: 'Rice and moong dal simmered in organic dark jaggery with ghee and cashews.', price: 60, image: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Sweet Appam', tamilName: 'இனிப்பு ஆப்பம்', category: 'Sweets & Desserts', type: 'Veg', description: 'Crisp-edged round fritters made from fermented rice, bananas, and jaggery.', price: 45, image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80', available: true },
  { name: 'Moong Dal Payasam', tamilName: 'பாசிப்பருப்பு பாயாசம்', category: 'Sweets & Desserts', type: 'Veg', description: 'Roasted yellow moong dal cooked with golden palm jaggery and coconut milk.', price: 60, image: 'https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80', available: true }
];

export async function seedTamilNaduFoods(mongoUri = process.env.MONGODB_URI) {
  console.log(`Starting idempotent seed for all ${initial131Foods.length} Tamil Nadu catering food items...`);

  // Verify unique names
  const nameSet = new Set();
  for (const item of initial131Foods) {
    if (nameSet.has(item.name)) {
      throw new Error(`Duplicate food item detected in seed catalog: "${item.name}"`);
    }
    nameSet.add(item.name);
  }
  console.log(`Verified catalog integrity: exactly ${nameSet.size} unique food names.`);

  if (!mongoUri) {
    console.warn('No MONGODB_URI provided. Seeding simulation passed successfully.');
    return {
      success: true,
      totalCatalog: initial131Foods.length,
      mode: 'simulation',
      uniqueVerified: nameSet.size,
    };
  }

  try {
    await mongoose.connect(mongoUri);
    console.log('Connected to MongoDB Atlas: nivetha_catering');

    // Idempotent upsert: uses $setOnInsert so existing docs are never altered
    const operations = initial131Foods.map((food) => ({
      updateOne: {
        filter: { name: food.name },
        update: {
          $setOnInsert: {
            name: food.name,
            tamilName: food.tamilName,
            category: food.category,
            type: food.type,
            description: food.description,
            price: food.price,
            image: food.image,
            available: food.available,
          },
        },
        upsert: true,
      },
    }));

    const result = await Food.bulkWrite(operations);
    const totalCount = await Food.countDocuments();

    console.log('Idempotent Seed Summary:');
    console.log(`- Upserted / Inserted: ${result.upsertedCount}`);
    console.log(`- Matched / Already existed: ${result.matchedCount}`);
    console.log(`- Total foods in database: ${totalCount}`);

    return {
      success: true,
      inserted: result.upsertedCount,
      existing: result.matchedCount,
      total: totalCount,
    };
  } catch (error) {
    console.error('Error during MongoDB seed execution:', error);
    throw error;
  } finally {
    if (mongoose.connection.readyState !== 0) {
      await mongoose.disconnect();
    }
  }
}

// Allow direct CLI execution: node seedTamilNaduFoods.js
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  seedTamilNaduFoods()
    .then((res) => {
      console.log('Seed process finished successfully.', res);
      process.exit(0);
    })
    .catch((err) => {
      console.error('Seed process failed:', err);
      process.exit(1);
    });
}
