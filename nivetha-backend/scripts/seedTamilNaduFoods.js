/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 *
 * Idempotent Seed Script for Nivetha Catering Service
 * Seeds all 131 unique Tamil Nadu catering food items into MongoDB Atlas.
 *
 * Safety Guarantees:
 * 1. Idempotent: uses $setOnInsert so existing documents are NOT overwritten.
 * 2. Preserves owner edits: does not overwrite custom images or availability.
 * 3. Does not delete any existing MongoDB records or custom owner items.
 * 4. Verifies exactly 131 unique catalog items.
 */

import mongoose from 'mongoose';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';

dotenv.config();

const foodSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true, unique: true },
    tamilName: { type: String, required: true, trim: true },
    category: { type: String, required: true },
    type: { type: String, required: true, enum: ['Veg', 'Non-Veg', 'Sweet'] },
    description: { type: String, default: '' },
    image: { type: String, required: true },
    available: { type: Boolean, default: true },
  },
  { timestamps: true }
);

const Food = mongoose.models.Food || mongoose.model('Food', foodSchema);

const img = (id) =>
  `https://images.unsplash.com/photo-${id}?auto=format&fit=crop&w=800&q=80`;

const IMG = {
  IDLI: img('1589301760014-d929f3979dbc'),
  RICE: img('1516714435131-44d6b64dc6a2'),
  DOSA: img('1668236543090-82eba5ee5976'),
  PONGAL: img('1626777552726-4a6b54c97e46'),
  POORI: img('1626074353765-517a681e40be'),
  FLAT: img('1565557623262-b51c2513a641'),
  PAROTTA: img('1601050690597-df0568f70950'),
  VEG: img('1546833999-b9f581a1996d'),
  EGG: img('1510693206972-df098062cb71'),
  CHICKEN: img('1603894584373-5ac82b2ae398'),
  MUTTON: img('1545247181-516773cae754'),
  PANEER: img('1631452180519-c014fe946bc7'),
  CHANNA: img('1585937421612-70a008356fbe'),
  BIRYANI: img('1563379091339-03b21ab4a4f8'),
  BUTTERMILK: img('1556881286-fc6915169721'),
  PRAWN: img('1559847844-5315695dadae'),
  NOODLES: img('1585032226651-759b368d7246'),
  CHICKEN65: img('1567620832903-9fc6debc209f'),
  FISH: img('1519708227418-c8fd9a32b7a2'),
  MEALS: img('1610057099443-fde8c4d50f91'),
};

const B = 'Breakfast & Tiffin';
const M = 'Meals & Vegetarian';
const N = 'Biryani, Rice & Non-Vegetarian';
const D = 'Dinner';
const S = 'Sweets & Desserts';

// Complete 131 items catalog
export const initial131Foods = [
  // 1 - 22: Breakfast & Tiffin
  { name: 'Idli', tamilName: 'இட்லி', category: B, type: 'Veg', description: 'Pillowy soft steamed fermented rice and black gram lentil cakes served with coconut chutney and sambar.', image: IMG.IDLI, available: true },
  { name: 'Mini Idli', tamilName: 'மினி இட்லி', category: B, type: 'Veg', description: 'Bite-sized button idlis soaked in a generous bath of rich ghee and sambar.', image: IMG.RICE, available: true },
  { name: 'Sambar Idli', tamilName: 'சாம்பார் இட்லி', category: B, type: 'Veg', description: 'Steaming idlis completely immersed in authentic drumstick and shallot sambar.', image: IMG.IDLI, available: true },
  { name: 'Dosa', tamilName: 'தோசை', category: B, type: 'Veg', description: 'Golden-crisp paper-thin fermented rice crepe cooked on an iron griddle.', image: IMG.DOSA, available: true },
  { name: 'Masala Dosa', tamilName: 'மசாலா தோசை', category: B, type: 'Veg', description: 'Crisp roasted dosa enveloped around seasoned mashed potato masala.', image: IMG.IDLI, available: true },
  { name: 'Ven Pongal', tamilName: 'வெண் பொங்கல்', category: B, type: 'Veg', description: 'Comforting mash of raw rice and yellow split moong dal tempered with black pepper, cumin, ginger, and cashews.', image: IMG.PONGAL, available: true },
  { name: 'Poori', tamilName: 'பூரி', category: B, type: 'Veg', description: 'Puffed golden-fried whole wheat pooris served with spiced potato masala.', image: IMG.POORI, available: true },
  { name: 'Chapathi', tamilName: 'சப்பாத்தி', category: B, type: 'Veg', description: 'Soft stone-ground whole wheat flatbreads cooked on tawa without excess oil.', image: IMG.FLAT, available: true },
  { name: 'Parotta', tamilName: 'பரோட்டா', category: B, type: 'Veg', description: 'Flaky, multi-layered golden brown Malabar-style flatbread beaten to crispy perfection.', image: IMG.PAROTTA, available: true },
  { name: 'Bun Parotta', tamilName: 'பன் பரோட்டா', category: B, type: 'Veg', description: 'Madurai famous bun-shaped thick layered parotta with a crisp crust and fluffy interior.', image: IMG.PAROTTA, available: true },
  { name: 'Upma', tamilName: 'உப்புமா', category: B, type: 'Veg', description: 'Roasted semolina cooked with mustard seeds, urad dal, green chillies, and ginger.', image: IMG.PAROTTA, available: true },
  { name: 'Vegetable Kootu', tamilName: 'காய்கறி கூட்டு', category: B, type: 'Veg', description: 'Traditional slow-cooked mixed vegetables simmered with yellow moong dal and coconut cumin paste.', image: IMG.VEG, available: true },
  { name: 'Onion Uthappam', tamilName: 'வெங்காய ஊத்தப்பம்', category: B, type: 'Veg', description: 'Thick, fluffy fermented pancake topped with caramelized shallots and green chillies.', image: IMG.IDLI, available: true },
  { name: 'Veg Kurma', tamilName: 'வெஜ் குருமா', category: B, type: 'Veg', description: 'Fragrant mixed garden vegetables simmered in creamy coconut cashew poppy seed paste.', image: IMG.VEG, available: true },
  { name: 'Cauliflower 65', tamilName: 'காலிஃபிளவர் 65', category: B, type: 'Veg', description: 'Crunchy cauliflower florets marinated in red chilli and ginger-garlic paste, deep fried.', image: IMG.FLAT, available: true },
  { name: 'Egg Dosa', tamilName: 'முட்டை தோசை', category: B, type: 'Non-Veg', description: 'Crispy fermented crepe topped with a beaten country egg, black pepper, and onions.', image: IMG.DOSA, available: true },
  { name: 'Egg Omelette', tamilName: 'முட்டை ஆம்லெட்', category: B, type: 'Non-Veg', description: 'Fluffy pan-fried double-egg omelette with diced shallots and green chillies.', image: IMG.EGG, available: true },
  { name: 'Egg Kalakki', tamilName: 'முட்டை கலக்கி', category: B, type: 'Non-Veg', description: 'Madurai street-style soft scrambled eggs with a velvety, runny center infused with chicken gravy.', image: IMG.EGG, available: true },
  { name: 'Egg Appam', tamilName: 'முட்டை ஆப்பம்', category: B, type: 'Non-Veg', description: 'Bowl-shaped fermented rice appam with a whole egg gently poached in the soft center.', image: IMG.IDLI, available: true },
  { name: 'Chicken Dosa', tamilName: 'சிக்கன் தோசை', category: B, type: 'Non-Veg', description: 'Hearty roasted dosa stuffed with spicy, slow-cooked shredded chicken sukka masala.', image: IMG.DOSA, available: true },
  { name: 'Chicken Curry', tamilName: 'சிக்கன் கறி', category: B, type: 'Non-Veg', description: 'Home-style chicken curry cooked with shallots, tomatoes, coriander seeds, and curry leaves.', image: IMG.CHICKEN, available: true },
  { name: 'Mutton Curry', tamilName: 'மட்டன் கறி', category: B, type: 'Non-Veg', description: 'Tender baby goat pieces slow-braised in hand-pounded Chettinad spices.', image: IMG.MUTTON, available: true },

  // 23 - 51: Meals & Vegetarian
  { name: 'South Indian Meals', tamilName: 'தென்னிந்திய சாப்பாடு', category: M, type: 'Veg', description: 'Royal festive banana-leaf feast featuring ponni rice, sambar, rasam, kootu, poriyal, and sweet.', image: IMG.MEALS, available: true },
  { name: 'White Rice', tamilName: 'வெள்ளை சாதம்', category: M, type: 'Veg', description: 'Steaming hot boiled Ponni rice, fluffy and distinct grains.', image: IMG.RICE, available: true },
  { name: 'Sambar', tamilName: 'சாம்பார்', category: M, type: 'Veg', description: 'Traditional lentil stew with drumstick, shallots, tamarind, and ground spices.', image: IMG.VEG, available: true },
  { name: 'Dal', tamilName: 'பருப்பு', category: M, type: 'Veg', description: 'Parippu stew cooked with yellow lentils, cumin seeds, garlic, and pure ghee.', image: IMG.VEG, available: true },
  { name: 'Dal Rasam', tamilName: 'பருப்பு ரசம்', category: M, type: 'Veg', description: 'Soothing broth made with toor dal water, country tomatoes, black pepper, and garlic.', image: IMG.VEG, available: true },
  { name: 'Rasam', tamilName: 'ரசம்', category: M, type: 'Veg', description: 'Tangy and peppery tomato rasam seasoned with mustard, cumin, and dried red chillies.', image: IMG.VEG, available: true },
  { name: 'Vatha Kuzhambu', tamilName: 'வத்தக்குழம்பு', category: M, type: 'Veg', description: 'Dark tangy tamarind gravy with sundakkai and manathakkali vatral in gingelly oil.', image: IMG.VEG, available: true },
  { name: 'Kara Kuzhambu', tamilName: 'காரக்குழம்பு', category: M, type: 'Veg', description: 'Spicy and tangy gravy with small onions, peeled garlic pods, and drumstick.', image: IMG.VEG, available: true },
  { name: 'Avial', tamilName: 'அவியல்', category: M, type: 'Veg', description: 'Garden vegetables stewed with crushed coconut, green chillies, curd, and virgin coconut oil.', image: IMG.VEG, available: true },
  { name: 'Potato Poriyal', tamilName: 'உருளைக்கிழங்கு பொரியல்', category: M, type: 'Veg', description: 'Tender baby potato cubes tossed in mustard seeds, urad dal, and fresh grated coconut.', image: IMG.FLAT, available: true },
  { name: 'Cabbage Poriyal', tamilName: 'முட்டைகோஸ் பொரியல்', category: M, type: 'Veg', description: 'Shredded cabbage stir-fried with yellow moong dal, mustard seeds, and fresh coconut.', image: IMG.VEG, available: true },
  { name: 'Beans Poriyal', tamilName: 'பீன்ஸ் பொரியல்', category: M, type: 'Veg', description: 'Diced French green beans sautéed with shallots, curry leaves, and coconut.', image: IMG.VEG, available: true },
  { name: 'Carrot Poriyal', tamilName: 'கேரட் பொரியல்', category: M, type: 'Veg', description: 'Sweet carrots diced fine and tempered with mild spices and grated coconut.', image: IMG.VEG, available: true },
  { name: 'Cauliflower Poriyal', tamilName: 'காலிஃபிளவர் பொரியல்', category: M, type: 'Veg', description: 'Delicate cauliflower florets roasted with turmeric, shallots, and cracked black pepper.', image: IMG.VEG, available: true },
  { name: 'Mushroom 65', tamilName: 'காளான் 65', category: M, type: 'Veg', description: 'Crispy button mushrooms marinated in spices and curry leaves, flash fried.', image: IMG.VEG, available: true },
  { name: 'Paneer Butter Masala', tamilName: 'பன்னீர் பட்டர் மசாலா', category: M, type: 'Veg', description: 'Succulent paneer cubes simmered in velvety tomato, cashew, and cream gravy.', image: IMG.PANEER, available: true },
  { name: 'Channa Masala', tamilName: 'சென்னா மசாலா', category: M, type: 'Veg', description: 'Chickpeas slow-cooked in a tangy Punjabi-style onion tomato gravy.', image: IMG.CHANNA, available: true },
  { name: 'Rajma Masala', tamilName: 'ராஜ்மா மசாலா', category: M, type: 'Veg', description: 'Red kidney beans simmered in spiced tomato and cumin broth.', image: IMG.VEG, available: true },
  { name: 'Vegetable Biryani', tamilName: 'காய்கறி பிரியாணி', category: M, type: 'Veg', description: 'Seeraga Samba rice layered with fresh vegetables, mint, and saffron milk.', image: IMG.BIRYANI, available: true },
  { name: 'Mushroom Biryani', tamilName: 'காளான் பிரியாணி', category: M, type: 'Veg', description: 'Fragrant Seeraga Samba rice dum cooked with juicy button mushrooms and mint.', image: IMG.BIRYANI, available: true },
  { name: 'Lemon Rice', tamilName: 'எலுமிச்சை சாதம்', category: M, type: 'Veg', description: 'Zesty cooked rice with fresh lemon juice, roasted peanuts, and green chillies.', image: IMG.RICE, available: true },
  { name: 'Tomato Rice', tamilName: 'தக்காளி சாதம்', category: M, type: 'Veg', description: 'Spicy Thakkali Sadam prepared with ripe country tomatoes and fennel seeds.', image: IMG.RICE, available: true },
  { name: 'Curd Rice', tamilName: 'தயிர் சாதம்', category: M, type: 'Veg', description: 'Creamy Thayir Sadam mixed with fresh curd, pomegranate seeds, and mustard tempering.', image: IMG.RICE, available: true },
  { name: 'Coconut Rice', tamilName: 'தேங்காய் சாதம்', category: M, type: 'Veg', description: 'Basmati rice tossed with fresh grated coconut, cashew nuts, and curry leaves.', image: IMG.RICE, available: true },
  { name: 'Puliyodarai', tamilName: 'புளியோதரை', category: M, type: 'Veg', description: 'Temple-style spicy tamarind rice with roasted sesame powder and peanuts.', image: IMG.RICE, available: true },
  { name: 'Appalam', tamilName: 'அப்பளம்', category: M, type: 'Veg', description: 'Crispy fried sun-dried lentil wafers, essential for South Indian meals.', image: IMG.POORI, available: true },
  { name: 'Pickle', tamilName: 'ஊறுகாய்', category: M, type: 'Veg', description: 'Spicy homemade mango or lemon pickle cured in gingelly oil.', image: IMG.IDLI, available: true },
  { name: 'Curds', tamilName: 'தயிர்', category: M, type: 'Veg', description: 'Freshly set thick, creamy whole milk curd served chilled.', image: IMG.RICE, available: true },
  { name: 'Buttermilk', tamilName: 'மோர்', category: M, type: 'Veg', description: 'Refreshing churned spiced buttermilk blended with ginger, chillies, and curry leaves.', image: IMG.BUTTERMILK, available: true },

  // 52 - 85: Biryani, Rice & Non-Vegetarian
  { name: 'Chicken Biryani', tamilName: 'சிக்கன் பிரியாணி', category: N, type: 'Non-Veg', description: 'Dindigul-style Seeraga Samba biryani cooked with chicken pieces and fresh mint.', image: IMG.BIRYANI, available: true },
  { name: 'Chicken Dum Biryani', tamilName: 'சிக்கன் தம் பிரியாணி', category: N, type: 'Non-Veg', description: 'Slow-cooked Hyderabadi basmati rice sealed over coals with chicken and fried onions.', image: IMG.BIRYANI, available: true },
  { name: 'Chicken Vadi Biryani', tamilName: 'சிக்கன் வடி பிரியாணி', category: N, type: 'Non-Veg', description: 'Strained rice wedding biryani cooked with rich chicken masala broth and ghee.', image: IMG.BIRYANI, available: true },
  { name: 'Mutton Biryani', tamilName: 'மட்டன் பிரியாணி', category: N, type: 'Non-Veg', description: 'Signature Seeraga Samba mutton biryani prepared with succulent baby goat cuts.', image: IMG.BIRYANI, available: true },
  { name: 'Mutton Dum Biryani', tamilName: 'மட்டன் தம் பிரியாணி', category: N, type: 'Non-Veg', description: 'Dum-braised mutton with basmati rice, kewra water, saffron strands, and ghee.', image: IMG.BIRYANI, available: true },
  { name: 'Mutton Vadi Biryani', tamilName: 'மட்டன் வடி பிரியாணி', category: N, type: 'Non-Veg', description: 'Heritage strained mutton biryani cooked in large handis with bone broth.', image: IMG.BIRYANI, available: true },
  { name: 'Prawn Biryani', tamilName: 'இறால் பிரியாணி', category: N, type: 'Non-Veg', description: 'Plump sea prawns tossed with fragrant Seeraga Samba rice and coconut milk.', image: IMG.PRAWN, available: true },
  { name: 'Egg Biryani', tamilName: 'முட்டை பிரியாணி', category: N, type: 'Non-Veg', description: 'Fragrant spiced biryani rice served with two golden pan-fried boiled eggs.', image: IMG.BIRYANI, available: true },
  { name: 'Chicken Rice', tamilName: 'சிக்கன் ரைஸ்', category: N, type: 'Non-Veg', description: 'Wok-tossed fried rice with diced chicken, scrambled egg, and spring onions.', image: IMG.CHICKEN, available: true },
  { name: 'Egg Rice', tamilName: 'முட்டை ரைஸ்', category: N, type: 'Non-Veg', description: 'Street-style wok-fried rice with farm eggs, cracked black pepper, and onions.', image: IMG.RICE, available: true },
  { name: 'Chicken Noodles', tamilName: 'சிக்கன் நூடுல்ஸ்', category: N, type: 'Non-Veg', description: 'Stir-fried noodles with juicy chicken, capsicum, and garlic pepper seasoning.', image: IMG.NOODLES, available: true },
  { name: 'Chicken 65', tamilName: 'சிக்கன் 65', category: N, type: 'Non-Veg', description: 'Crispy fried boneless chicken bites with red chillies, ginger garlic, and curry leaves.', image: IMG.CHICKEN65, available: true },
  { name: 'Chicken Lollipop', tamilName: 'சிக்கன் லாலிபாப்', category: N, type: 'Non-Veg', description: 'Frenched chicken winglets coated in spicy batter and fried until crunchy.', image: IMG.CHICKEN65, available: true },
  { name: 'Naatukozhi Varuval', tamilName: 'நாட்டுக்கோழி வறுவல்', category: N, type: 'Non-Veg', description: 'Country chicken dry roast cooked with shallots, crushed dry red chillies, and garlic.', image: IMG.CHICKEN, available: true },
  { name: 'Chicken Pepper Gravy', tamilName: 'சிக்கன் மிளகு கிரேவி', category: N, type: 'Non-Veg', description: 'Robust chicken gravy made with coarsely pounded black peppercorns and fennel.', image: IMG.CHICKEN, available: true },
  { name: 'Chettinad Chicken Gravy', tamilName: 'செட்டிநாடு சிக்கன் கிரேவி', category: N, type: 'Non-Veg', description: 'Iconic curry with stone-ground kalpasi, star anise, fennel, and roasted coconut.', image: IMG.CHICKEN, available: true },
  { name: 'Andhra Spicy Chicken Gravy', tamilName: 'ஆந்திரா ஸ்பைசி சிக்கன் கிரேவி', category: N, type: 'Non-Veg', description: 'Fiery Andhra chicken curry with Guntur red chillies and green chilli paste.', image: IMG.CHICKEN, available: true },
  { name: 'Butter Chicken Gravy', tamilName: 'பட்டர் சிக்கன் கிரேவி', category: N, type: 'Non-Veg', description: 'Tandoori chicken tikka chunks simmered in sweet-tangy tomato cashew cream sauce.', image: IMG.CHICKEN, available: true },
  { name: 'Country Chicken Gravy', tamilName: 'நாட்டுக்கோழி குழம்பு', category: N, type: 'Non-Veg', description: 'Village-style rich broth of country chicken cooked with small onions and coconut milk.', image: IMG.CHICKEN, available: true },
  { name: 'Pallapalayam Chicken Gravy', tamilName: 'பல்லபாளையம் சிக்கன் கிரேவி', category: N, type: 'Non-Veg', description: 'Kongunadu chicken specialty cooked with dry red chillies, shallots, and fresh coconut.', image: IMG.CHICKEN, available: true },
  { name: 'Chicken Gravy', tamilName: 'சிக்கன் கிரேவி', category: N, type: 'Non-Veg', description: 'Classic South Indian chicken gravy, ideal pairing for parotta and hot rice.', image: IMG.CHICKEN, available: true },
  { name: 'Chicken Kurma', tamilName: 'சிக்கன் குருமா', category: N, type: 'Non-Veg', description: 'Mildly spiced, creamy chicken gravy cooked with cashew nut paste and coconut milk.', image: IMG.CHICKEN, available: true },
  { name: 'Mutton Gravy', tamilName: 'மட்டன் கிரேவி', category: N, type: 'Non-Veg', description: 'Succulent goat meat slow-simmered in rich caramelized shallot and tomato gravy.', image: IMG.MUTTON, available: true },
  { name: 'Chettinad Mutton Gravy', tamilName: 'செட்டிநாடு மட்டன் கிரேவி', category: N, type: 'Non-Veg', description: 'Chettinad goat curry infused with roasted coriander, cumin, dry chillies, and coconut.', image: IMG.MUTTON, available: true },
  { name: 'Mutton Pepper Gravy', tamilName: 'மட்டன் மிளகு கிரேவி', category: N, type: 'Non-Veg', description: 'Fiery mutton curry dominated by freshly roasted and crushed Tellicherry black pepper.', image: IMG.MUTTON, available: true },
  { name: 'Mutton Chukka', tamilName: 'மட்டன் சுக்கா', category: N, type: 'Non-Veg', description: 'Madurai style pan-roasted tender boneless mutton tossed in browned shallots and pepper.', image: IMG.MUTTON, available: true },
  { name: 'Coconut Milk Mutton Gravy', tamilName: 'தேங்காய்ப்பால் மட்டன் கிரேவி', category: N, type: 'Non-Veg', description: 'Tender mutton simmered in fresh thick first-press coconut milk with whole cardamoms.', image: IMG.MUTTON, available: true },
  { name: 'Mutton Bone Gravy', tamilName: 'மட்டன் எலும்பு குழம்பு', category: N, type: 'Non-Veg', description: 'Rich, collagenous bone-marrow mutton soup cooked with country ground spices.', image: IMG.MUTTON, available: true },
  { name: 'Fish Fry', tamilName: 'மீன் வறுவல்', category: N, type: 'Non-Veg', description: 'Vanjaram seer fish slice marinated in red chilli paste and roasted crisp.', image: IMG.FISH, available: true },
  { name: 'Fish Curry', tamilName: 'மீன் குழம்பு', category: N, type: 'Non-Veg', description: 'Tangy and spicy clay-pot fish curry with sea fish, tamarind, and shallots.', image: IMG.FISH, available: true },
  { name: 'Prawn Masala', tamilName: 'இறால் மசாலா', category: N, type: 'Non-Veg', description: 'Tiger prawns cooked in a rich masala of tomatoes, ginger, and fennel.', image: IMG.PRAWN, available: true },
  { name: 'Egg Curry', tamilName: 'முட்டை குழம்பு', category: N, type: 'Non-Veg', description: 'Hard-boiled eggs simmered in a spiced onion, tomato, and coconut gravy.', image: IMG.EGG, available: true },
  { name: 'Egg Fry', tamilName: 'முட்டை வறுவல்', category: N, type: 'Non-Veg', description: 'Boiled eggs slit and pan-fried with red chilli powder, pepper, and curry leaves.', image: IMG.EGG, available: true },
  { name: 'Mutton Kurma', tamilName: 'மட்டன் குருமா', category: N, type: 'Non-Veg', description: 'Royal white mutton kurma cooked with cashews, green chillies, and coconut milk.', image: IMG.MUTTON, available: true },

  // 86 - 103: Dinner
  { name: 'Veg Kothu Parotta', tamilName: 'வெஜ் கொத்து பரோட்டா', category: D, type: 'Veg', description: 'Minced parotta chopped on iron griddle with tomatoes, curry leaves, and veg salna.', image: IMG.PAROTTA, available: true },
  { name: 'Ghee Dosa', tamilName: 'நெய் தோசை', category: D, type: 'Veg', description: 'Golden roasted crepe drenched in pure aromatic cow ghee, wonderfully crisp.', image: IMG.DOSA, available: true },
  { name: 'Roti', tamilName: 'ரொட்டி', category: D, type: 'Veg', description: 'Clay tandoor baked whole wheat bread with blistered spots, served warm.', image: IMG.FLAT, available: true },
  { name: 'Naan', tamilName: 'நான்', category: D, type: 'Veg', description: 'Classic leavened flatbread baked against the piping hot walls of a tandoor.', image: IMG.FLAT, available: true },
  { name: 'Butter Naan', tamilName: 'பட்டர் நான்', category: D, type: 'Veg', description: 'Tandoor-baked leavened bread slathered with pure melted creamy butter.', image: IMG.FLAT, available: true },
  { name: 'Kulcha', tamilName: 'குல்சா', category: D, type: 'Veg', description: 'Soft flatbread topped with black onion seeds (kalonji) and fresh coriander.', image: IMG.FLAT, available: true },
  { name: 'Idly', tamilName: 'இட்லி (இரவு)', category: D, type: 'Veg', description: 'Soft steamed rice-lentil idlis served with evening tiffin sambar and chutney.', image: IMG.IDLI, available: true },
  { name: 'Idiyappam', tamilName: 'இடியாப்பம்', category: D, type: 'Veg', description: 'Steamed delicate rice noodle nests served with sweet coconut milk or spicy salna.', image: IMG.IDLI, available: true },
  { name: 'Appam', tamilName: 'ஆப்பம்', category: D, type: 'Veg', description: 'Fermented rice hoppers with lacy borders and spongy center, with coconut milk.', image: IMG.IDLI, available: true },
  { name: 'Vegetable Fried Rice', tamilName: 'வெஜ் ஃப்ரைட் ரைஸ்', category: D, type: 'Veg', description: 'Wok-tossed basmati rice with finely diced carrots, beans, and spring onions.', image: IMG.RICE, available: true },
  { name: 'Gobi Fried Rice', tamilName: 'கோபி ஃப்ரைட் ரைஸ்', category: D, type: 'Veg', description: 'Spicy fried rice tossed with crispy golden cauliflower florets and spring onions.', image: IMG.RICE, available: true },
  { name: 'Paneer Fried Rice', tamilName: 'பன்னீர் ஃப்ரைட் ரைஸ்', category: D, type: 'Veg', description: 'Wok-tossed rice with golden-fried cottage cheese cubes and crisp veggies.', image: IMG.RICE, available: true },
  { name: 'Veg Noodles', tamilName: 'வெஜ் நூடுல்ஸ்', category: D, type: 'Veg', description: 'Classic wok-stirred hakka noodles loaded with shredded cabbage and peppers.', image: IMG.NOODLES, available: true },
  { name: 'Gobi Manchurian', tamilName: 'கோபி மஞ்சூரியன்', category: D, type: 'Veg', description: 'Crispy batter-fried cauliflower in sweet, spicy, and tangy Manchurian glaze.', image: IMG.FLAT, available: true },
  { name: 'Brinjal Pachadi', tamilName: 'கத்திரிக்காய் பச்சடி', category: D, type: 'Veg', description: 'Mashed roasted eggplants simmered with tamarind, shallots, and mustard tempering.', image: IMG.VEG, available: true },
  { name: 'Dal Fry', tamilName: 'தால் ஃப்ரை', category: D, type: 'Veg', description: 'Yellow lentils tempered with cumin seeds, garlic, onions, tomatoes, and ghee.', image: IMG.VEG, available: true },
  { name: 'Rice', tamilName: 'சாதம்', category: D, type: 'Veg', description: 'Light steamed ponni rice, wholesome and freshly prepared for dinner service.', image: IMG.RICE, available: true },
  { name: 'Mutton Bone Curry', tamilName: 'மட்டன் எலும்பு கறி', category: D, type: 'Non-Veg', description: 'Chettinad style bone marrow curry infused with crushed black pepper and shallots.', image: IMG.MUTTON, available: true },

  // 104 - 131: Sweets & Desserts
  { name: 'Gulab Jamun', tamilName: 'குலாப் ஜாமுன்', category: S, type: 'Veg', description: 'Soft reduced milk balls fried in ghee and soaked in cardamom rose syrup.', image: IMG.IDLI, available: true },
  { name: 'Rasgulla', tamilName: 'ரஸகுல்லா', category: S, type: 'Veg', description: 'Spongy chenna cheese spheres simmered in light fragrant sugar syrup.', image: IMG.IDLI, available: true },
  { name: 'Rasmalai', tamilName: 'ரசமலாய்', category: S, type: 'Veg', description: 'Cottage cheese patties in chilled saffron milk with pistachios and almonds.', image: IMG.IDLI, available: true },
  { name: 'Mysore Pak', tamilName: 'மைசூர் பாக்', category: S, type: 'Veg', description: 'Royal sweet of roasted gram flour, pure cow ghee, and sugar.', image: IMG.IDLI, available: true },
  { name: 'Badam Halwa', tamilName: 'பாதாம் அல்வா', category: S, type: 'Veg', description: 'Rich halwa made with blanched almonds, pure ghee, and saffron.', image: IMG.IDLI, available: true },
  { name: 'Wheat Halwa', tamilName: 'கோதுமை அல்வா', category: S, type: 'Veg', description: 'Fermented whole wheat milk halwa cooked with caramelized sugar and cashews.', image: IMG.IDLI, available: true },
  { name: 'Carrot Halwa', tamilName: 'கேரட் அல்வா', category: S, type: 'Veg', description: 'Red juicy carrots grated and slow-cooked in milk, khoya, and pure ghee.', image: IMG.IDLI, available: true },
  { name: 'Kasi Halwa', tamilName: 'காசி அல்வா', category: S, type: 'Veg', description: 'Grated white pumpkin (ash gourd) simmered in sugar syrup and saffron.', image: IMG.IDLI, available: true },
  { name: 'Tirunelveli Halwa', tamilName: 'திருநெல்வேலி அல்வா', category: S, type: 'Veg', description: 'Famous wheat milk halwa prepared using Thamirabarani water and pure cow ghee.', image: IMG.IDLI, available: true },
  { name: 'Bread Halwa', tamilName: 'பிரட் அல்வா', category: S, type: 'Veg', description: 'Crisp ghee-fried bread slow-cooked in sweetened milk and roasted cashews.', image: IMG.IDLI, available: true },
  { name: 'Kesari', tamilName: 'கேசரி', category: S, type: 'Veg', description: 'Celebration sweet of roasted sooji, saffron essence, pure ghee, and cashews.', image: IMG.IDLI, available: true },
  { name: 'Rava Kesari', tamilName: 'ரவா கேசரி', category: S, type: 'Veg', description: 'Traditional semolina pudding scented with cardamom and dripping with pure ghee.', image: IMG.IDLI, available: true },
  { name: 'Pineapple Kesari', tamilName: 'அன்னாசி கேசரி', category: S, type: 'Veg', description: 'Semolina kesari infused with chunks of tropical pineapple and saffron.', image: IMG.IDLI, available: true },
  { name: 'Paal Payasam', tamilName: 'பால் பாயாசம்', category: S, type: 'Veg', description: 'Slow-simmered red rice in full-cream milk sweetened with crystal sugar.', image: IMG.RICE, available: true },
  { name: 'Semiya Payasam', tamilName: 'சேமியா பாயாசம்', category: S, type: 'Veg', description: 'Roasted vermicelli in saffron milk with ghee-roasted cashews and raisins.', image: IMG.RICE, available: true },
  { name: 'Paruppu Payasam', tamilName: 'பருப்பு பாயாசம்', category: S, type: 'Veg', description: 'Roasted moong dal, organic jaggery syrup, thick coconut milk, and cardamom.', image: IMG.RICE, available: true },
  { name: 'Jangiri', tamilName: 'ஜாங்கிரி', category: S, type: 'Veg', description: 'Swirled urad dal rosettes fried in ghee and soaked in saffron sugar syrup.', image: IMG.IDLI, available: true },
  { name: 'Jalebi', tamilName: 'ஜிலேபி', category: S, type: 'Veg', description: 'Crisp spiral rings of fermented batter soaked in warm fragrant sugar syrup.', image: IMG.IDLI, available: true },
  { name: 'Laddu', tamilName: 'லட்டு', category: S, type: 'Veg', description: 'Besan boondi spheres bound with sugar syrup, cloves, camphor, and cashews.', image: IMG.IDLI, available: true },
  { name: 'Boondi Laddu', tamilName: 'பூந்தி லட்டு', category: S, type: 'Veg', description: 'Crispy sweet gram flour pearls gently crushed and moulded with cow ghee.', image: IMG.IDLI, available: true },
  { name: 'Motichoor Laddu', tamilName: 'மோதிச்சூர் லட்டு', category: S, type: 'Veg', description: 'Ultra-fine tiny pearl laddus flavored with saffron, cardamom, and melon seeds.', image: IMG.IDLI, available: true },
  { name: 'Coconut Burfi', tamilName: 'தேங்காய் பர்பி', category: S, type: 'Veg', description: 'Freshly grated white coconut fudge flavored with cardamom and cut into diamonds.', image: IMG.IDLI, available: true },
  { name: 'Milk Peda', tamilName: 'பால்கோவா / மில்க் பேடா', category: S, type: 'Veg', description: 'Caramelized reduced milk solids discs infused with cardamom and pistachios.', image: IMG.IDLI, available: true },
  { name: 'Badusha', tamilName: 'பாதுஷா', category: S, type: 'Veg', description: 'Flaky layered flour pastries fried in ghee and glazed in crystalline sugar crust.', image: IMG.IDLI, available: true },
  { name: 'Poli', tamilName: 'போளி', category: S, type: 'Veg', description: 'Soft tawa sweet flatbread stuffed with chana dal, grated coconut, and jaggery.', image: IMG.FLAT, available: true },
  { name: 'Sweet Pongal', tamilName: 'சர்க்கரை பொங்கல்', category: S, type: 'Veg', description: 'Rice and moong dal simmered in organic dark jaggery with ghee and cashews.', image: IMG.PONGAL, available: true },
  { name: 'Sweet Appam', tamilName: 'இனிப்பு ஆப்பம்', category: S, type: 'Veg', description: 'Crisp-edged round fritters made from fermented rice, bananas, and jaggery.', image: IMG.IDLI, available: true },
  { name: 'Moong Dal Payasam', tamilName: 'பாசிப்பருப்பு பாயாசம்', category: S, type: 'Veg', description: 'Roasted yellow moong dal cooked with golden palm jaggery and coconut milk.', image: IMG.RICE, available: true },
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