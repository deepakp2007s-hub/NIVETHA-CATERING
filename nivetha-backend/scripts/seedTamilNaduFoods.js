import dotenv from 'dotenv';
dotenv.config();

import mongoose from 'mongoose';
import connectDB from '../src/config/db.js';
import Food from '../src/models/Food.js';

/**
 * 42 Traditional Tamil Nadu Catering Foods for Nivetha Catering Service
 * 18 Vegetarian, 14 Non-Vegetarian, 10 Sweets & Desserts
 */
export const initial42Foods = [
  // --- VEGETARIAN (18 Items) ---
  {
    name: 'South Indian Wedding Meals',
    tamilName: 'தென்னிந்திய திருமண சைவ சாப்பாடு',
    category: 'Meals',
    type: 'veg',
    description: 'Grand traditional banana leaf feast with Ponni boiled rice, sambar, rasam, kootu, poriyal, avial, appalam, vadai, and curd.',
    price: 180,
    image: 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Special Wedding Meals',
    tamilName: 'சிறப்பு திருமண சைவ சாப்பாடு',
    category: 'Meals',
    type: 'veg',
    description: 'Deluxe banquet thali including Mysore pak, medu vadai, ghee rice, 2 varieties of poriyal, paneer butter masala, and payasam.',
    price: 250,
    image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Mini Meals',
    tamilName: 'மினி சாப்பாடு',
    category: 'Meals',
    type: 'veg',
    description: 'Compact South Indian lunch with sambar rice, curd rice, poriyal, appalam, and sweet.',
    price: 120,
    image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Idli',
    tamilName: 'இட்லி',
    category: 'Tiffin & Breakfast',
    type: 'veg',
    description: 'Pillowy soft steamed rice cakes served with hotel style sambar, coconut chutney, and kara chutney.',
    price: 40,
    image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Dosa',
    tamilName: 'தோசை',
    category: 'Tiffin & Breakfast',
    type: 'veg',
    description: 'Crispy golden crepe made from fermented rice and lentil batter served with 3 types of chutneys and sambar.',
    price: 60,
    image: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Ven Pongal',
    tamilName: 'வெண் பொங்கல்',
    category: 'Tiffin & Breakfast',
    type: 'veg',
    description: 'Fragrant clarified butter ghee pongal tempered with black pepper, cumin seeds, ginger, and roasted cashews.',
    price: 65,
    image: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Poori Masala',
    tamilName: 'பூரி மசாலா',
    category: 'Tiffin & Breakfast',
    type: 'veg',
    description: 'Puffed golden wheat pooris served with spiced potato onion masala curry.',
    price: 70,
    image: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Chapati with Vegetable Kurma',
    tamilName: 'சப்பாத்தி காய்கறி குருமா',
    category: 'Breads',
    type: 'veg',
    description: 'Soft layered whole wheat rotis served with rich coconut-cashew blended Tamil Nadu vegetable kurma.',
    price: 75,
    image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Vegetable Biryani',
    tamilName: 'காய்கறி பிரியாணி',
    category: 'Biryani & Rice',
    type: 'veg',
    description: 'Aromatic Seeraga Samba rice layered with garden fresh vegetables, mint, and Chettinad spices.',
    price: 130,
    image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Paneer Biryani',
    tamilName: 'பனீர் பிரியாணி',
    category: 'Biryani & Rice',
    type: 'veg',
    description: 'Rich dum biryani studded with marinated cottage cheese cubes, saffron milk, and fried onions.',
    price: 160,
    image: 'https://images.unsplash.com/photo-1645177628172-a94c1f96e6db?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Lemon Rice',
    tamilName: 'எலுமிச்சை சாதம்',
    category: 'Biryani & Rice',
    type: 'veg',
    description: 'Tangy tempered rice with fresh lemon juice, turmeric, crunchy roasted peanuts, and curry leaves.',
    price: 60,
    image: 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Curd Rice',
    tamilName: 'தயிர் சாதம்',
    category: 'Biryani & Rice',
    type: 'veg',
    description: 'Creamy comforting yogurt rice seasoned with mustard seeds, green chillies, ginger, and fresh pomegranate.',
    price: 55,
    image: 'https://images.unsplash.com/photo-1596797038530-2c107229654b?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Sambar Rice',
    tamilName: 'சாம்பார் சாதம்',
    category: 'Biryani & Rice',
    type: 'veg',
    description: 'Traditional temple-style bisibelebath cooked with shallots, drumstick, toor dal, and aromatic ghee.',
    price: 65,
    image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Vegetable Fried Rice',
    tamilName: 'காய்கறி ஃப்ரைட் ரைஸ்',
    category: 'Biryani & Rice',
    type: 'veg',
    description: 'Wok-tossed long-grain Basmati rice with crunchy carrots, cabbage, french beans, and spring onions.',
    price: 110,
    image: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Paneer Butter Masala',
    tamilName: 'பனீர் பட்டர் மசாலா',
    category: 'Curries & Gravies',
    type: 'veg',
    description: 'Tender cottage cheese cubes simmered in a luscious buttery tomato-cashew satin gravy.',
    price: 140,
    image: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Gobi Manchurian',
    tamilName: 'கோபி மஞ்சூரியன்',
    category: 'Sides & Starters',
    type: 'veg',
    description: 'Crisp battered cauliflower florets tossed in garlic, ginger, and scallion indo-chinese sauce.',
    price: 100,
    image: 'https://images.unsplash.com/photo-1625398407796-82650a8c135f?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Vegetable Kothu Parotta',
    tamilName: 'காய்கறி கொத்து பரோட்டா',
    category: 'Sides & Starters',
    type: 'veg',
    description: 'Shredded Tamil Nadu street-style parotta beaten on iron griddle with spiced vegetables and salna.',
    price: 90,
    image: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Mixed Vegetable Curry',
    tamilName: 'கலவை காய்கறி கறி',
    category: 'Curries & Gravies',
    type: 'veg',
    description: 'Home-style Chettinad curry with seasonal vegetables in roasted coriander and fennel masala.',
    price: 80,
    image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=600&q=80',
    available: true,
  },

  // --- NON-VEGETARIAN (14 Items) ---
  {
    name: 'Chicken Biryani',
    tamilName: 'சிக்கன் பிரியாணி',
    category: 'Biryani & Rice',
    type: 'non-veg',
    description: 'Authentic Dindigul/Ambur style Seeraga Samba chicken biryani infused with fresh mint and tender meat.',
    price: 190,
    image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Mutton Biryani',
    tamilName: 'மட்டன் பிரியாணி',
    category: 'Biryani & Rice',
    type: 'non-veg',
    description: 'Royal wedding style dum biryani with melt-in-mouth tender goat meat and caramelized whole spices.',
    price: 270,
    image: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Chicken 65',
    tamilName: 'சிக்கன் 65',
    category: 'Sides & Starters',
    type: 'non-veg',
    description: 'Iconic Chennai red-marinated crisp fried boneless chicken tossed with fried curry leaves and green chillies.',
    price: 150,
    image: 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Chicken Chettinad',
    tamilName: 'செட்டிநாடு சிக்கன்',
    category: 'Curries & Gravies',
    type: 'non-veg',
    description: 'Fiery and fragrant Karaikudi speciality curry made with freshly stone-ground kalpasi and peppercorns.',
    price: 180,
    image: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Pepper Chicken',
    tamilName: 'மிளகு சிக்கன்',
    category: 'Sides & Starters',
    type: 'non-veg',
    description: 'Dry roasted country chicken sautéed with cracked Tellicherry black pepper, shallots, and curry leaves.',
    price: 170,
    image: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Chicken Curry',
    tamilName: 'சிக்கன் குழம்பு',
    category: 'Curries & Gravies',
    type: 'non-veg',
    description: 'Traditional Tamil household chicken gravy simmered with coconut paste and fresh coriander.',
    price: 160,
    image: 'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Mutton Curry',
    tamilName: 'மட்டன் குழம்பு',
    category: 'Curries & Gravies',
    type: 'non-veg',
    description: 'Rich slow-cooked mutton gravy bursting with ginger-garlic, shallots, and ground Indian spices.',
    price: 240,
    image: 'https://images.unsplash.com/photo-1545247181-516773cae754?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Fish Fry',
    tamilName: 'மீன் வறுவல்',
    category: 'Sides & Starters',
    type: 'non-veg',
    description: 'Fresh Vanjaram (Seer fish) steaks coated in spicy tangy masala and tawa fried to golden crispness.',
    price: 190,
    image: 'https://images.unsplash.com/photo-1534939561126-855b8675edd7?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Fish Curry',
    tamilName: 'மீன் குழம்பு',
    category: 'Curries & Gravies',
    type: 'non-veg',
    description: 'Authentic clay-pot Meen Kulambu made with tangy tamarind extract, shallots, garlic, and fresh fish.',
    price: 180,
    image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Prawn Masala',
    tamilName: 'இறால் மசாலா',
    category: 'Curries & Gravies',
    type: 'non-veg',
    description: 'Juicy coastal prawns sautéed in a thick, semi-dry tomato and onion masala with crushed pepper.',
    price: 210,
    image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Egg Curry',
    tamilName: 'முட்டை குழம்பு',
    category: 'Curries & Gravies',
    type: 'non-veg',
    description: 'Hard-boiled farm eggs gently scored and simmered in a mildly spiced onion-tomato gravy.',
    price: 90,
    image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Chicken Fried Rice',
    tamilName: 'சிக்கன் ஃப்ரைட் ரைஸ்',
    category: 'Biryani & Rice',
    type: 'non-veg',
    description: 'High-flame wok tossed Basmati rice with shredded chicken, scrambled eggs, and scallions.',
    price: 140,
    image: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Chicken Kothu Parotta',
    tamilName: 'சிக்கன் கொத்து பரோட்டா',
    category: 'Sides & Starters',
    type: 'non-veg',
    description: 'Madurai style shredded flaky parotta stir-fried with boneless chicken pieces, eggs, and rich gravy.',
    price: 130,
    image: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Mutton Sukka',
    tamilName: 'மட்டன் சுக்கா',
    category: 'Sides & Starters',
    type: 'non-veg',
    description: 'Tender tenderized mutton cubes pan-roasted dry with shallots, crushed garlic, and Chettinad spices.',
    price: 250,
    image: 'https://images.unsplash.com/photo-1545247181-516773cae754?auto=format&fit=crop&w=600&q=80',
    available: true,
  },

  // --- SWEETS & DESSERTS (10 Items) ---
  {
    name: 'Sweet Pongal',
    tamilName: 'சர்க்கரைப் பொங்கல்',
    category: 'Sweets & Desserts',
    type: 'sweet',
    description: 'Traditional festival dessert made with rice, moong dal, organic brown jaggery, pure ghee, and cashews.',
    price: 60,
    image: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Payasam',
    tamilName: 'பாயாசம்',
    category: 'Sweets & Desserts',
    type: 'sweet',
    description: 'Rich wedding milk kheer infused with cardamom pods, golden raisins, and roasted nuts.',
    price: 55,
    image: 'https://images.unsplash.com/photo-1579888944880-d98341245702?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Semiya Payasam',
    tamilName: 'சேமியா பாயாசம்',
    category: 'Sweets & Desserts',
    type: 'sweet',
    description: 'Silky roasted vermicelli cooked in condensed milk, saffron strands, and roasted cashews.',
    price: 55,
    image: 'https://images.unsplash.com/photo-1579888944880-d98341245702?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Gulab Jamun',
    tamilName: 'குலாப் ஜாமுன்',
    category: 'Sweets & Desserts',
    type: 'sweet',
    description: 'Golden fried khoya dumplings soaked in warm rosewater and cardamom flavored sugar syrup.',
    price: 50,
    image: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Kesari',
    tamilName: 'கேசரி',
    category: 'Sweets & Desserts',
    type: 'sweet',
    description: 'Glistening rava kesari flavored with saffron, pure cow ghee, and crisp fried cashews.',
    price: 45,
    image: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Mysore Pak',
    tamilName: 'மைசூர் பாக்',
    category: 'Sweets & Desserts',
    type: 'sweet',
    description: 'Famous melt-in-the-mouth gram flour sweet prepared with generous quantities of desi ghee.',
    price: 60,
    image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Laddu',
    tamilName: 'லட்டு',
    category: 'Sweets & Desserts',
    type: 'sweet',
    description: 'Traditional Tirupati-style boondi laddu with cloves, cardamom, cashews, and sugar crystals.',
    price: 40,
    image: 'https://images.unsplash.com/photo-1596797038530-2c107229654b?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Jangiri',
    tamilName: 'ஜாங்கிரி',
    category: 'Sweets & Desserts',
    type: 'sweet',
    description: 'Intricately patterned urad dal swirl fried to crisp perfection and steeped in saffron syrup.',
    price: 50,
    image: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Badam Halwa',
    tamilName: 'பாதாம் அல்வா',
    category: 'Sweets & Desserts',
    type: 'sweet',
    description: 'Royal dessert crafted with stone-ground California almonds, saffron milk, and pure ghee.',
    price: 85,
    image: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
  {
    name: 'Ice Cream',
    tamilName: 'ஐஸ்கிரீம்',
    category: 'Sweets & Desserts',
    type: 'sweet',
    description: 'Creamy catering scoops available in traditional South Indian flavours including Vanilla, Mango, and Pista.',
    price: 40,
    image: 'https://images.unsplash.com/photo-1501443762994-82bd5dace89a?auto=format&fit=crop&w=600&q=80',
    available: true,
  },
];

/**
 * Idempotent Seed Function
 * - Inserts missing foods
 * - Does NOT overwrite owner-edited price, image, or availability
 * - Does NOT delete owner-created foods
 */
export const seedTamilNaduFoods = async () => {
  console.log('🌾 [Nivetha Catering] Seeding 42 Traditional Tamil Nadu Foods...');

  const connected = await connectDB();
  if (!connected && !process.env.MONGODB_URI) {
    console.warn('⚠️ MONGODB_URI not provided. Skipping live DB seed.');
    return { created: 0, skipped: 0, total: initial42Foods.length };
  }

  let createdCount = 0;
  let skippedCount = 0;

  for (const item of initial42Foods) {
    try {
      const existing = await Food.findOne({ name: item.name });

      if (existing) {
        // Safe: Preserve existing owner modifications (price, image, availability)
        skippedCount++;
      } else {
        await Food.create(item);
        createdCount++;
      }
    } catch (err) {
      console.error(`❌ Error seeding food "${item.name}":`, err.message);
    }
  }

  console.log('\n======================================');
  console.log('📊 Tamil Nadu Food Menu Seed Summary:');
  console.log(`   - Total Specified in Catalog: ${initial42Foods.length}`);
  console.log(`   - Newly Created: ${createdCount}`);
  console.log(`   - Preserved / Skipped: ${skippedCount}`);
  console.log('======================================\n');

  return { created: createdCount, skipped: skippedCount, total: initial42Foods.length };
};

// Auto-run if executed directly
if (process.argv[1] && process.argv[1].endsWith('seedTamilNaduFoods.js')) {
  seedTamilNaduFoods().then(async () => {
    if (mongoose.connection.readyState === 1) {
      await mongoose.connection.close();
    }
    process.exit(0);
  });
}

export default seedTamilNaduFoods;
