
import path from 'node:path';
import fs from 'node:fs';
import { fileURLToPath, pathToFileURL } from 'node:url';
import dotenv from 'dotenv';
import mongoose from 'mongoose';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load .env from backend root
dotenv.config({
  path: path.resolve(__dirname, '../.env')
});
dotenv.config();

// Load existing database configuration
let connectDB;

const dbPaths = [
  path.resolve(__dirname, '../src/config/db.js'),
  path.resolve(__dirname, '../config/db.js')
];

for (const dbPath of dbPaths) {
  if (!fs.existsSync(dbPath)) continue;

  try {
    const dbModule = await import(pathToFileURL(dbPath).href);

    connectDB =
      dbModule.default ||
      dbModule.connectDB ||
      dbModule.connectDatabase;

    if (typeof connectDB === 'function') break;
  } catch (error) {
    console.warn(
      `Could not load database config ${dbPath}:`,
      error.message
    );
  }
}

if (typeof connectDB !== 'function') {
  connectDB = async () => {
    const mongoURI =
      process.env.MONGODB_URI ||
      process.env.MONGO_URI;

    if (!mongoURI) {
      throw new Error(
        'MONGODB_URI or MONGO_URI is missing from the backend .env file.'
      );
    }

    return mongoose.connect(mongoURI);
  };
}

// Load existing Food model
let Food;

const foodPaths = [
  path.resolve(__dirname, '../src/models/Food.js'),
  path.resolve(__dirname, '../src/models/food.js'),
  path.resolve(__dirname, '../models/Food.js'),
  path.resolve(__dirname, '../models/food.js')
];

for (const foodPath of foodPaths) {
  if (!fs.existsSync(foodPath)) continue;

  try {
    const foodModule = await import(pathToFileURL(foodPath).href);

    Food =
      foodModule.default ||
      foodModule.Food ||
      foodModule.foodModel;

    if (Food) break;
  } catch (error) {
    console.warn(
      `Could not load Food model ${foodPath}:`,
      error.message
    );
  }
}

if (!Food) {
  const foodSchema = new mongoose.Schema(
    {
      name: {
        type: String,
        required: true,
        trim: true,
        unique: true
      },
      tamilName: {
        type: String,
        trim: true,
        default: ''
      },
      category: {
        type: String,
        required: true,
        enum: [
          'Breakfast',
          'Meals',
          'Rice',
          'Veg Gravy',
          'Non-Veg Gravy',
          'Biryani',
          'Starter',
          'Seafood',
          'Bread',
          'Sweets'
        ],
        trim: true
      },
      type: {
        type: String,
        required: true,
        enum: ['Veg', 'Non-Veg'],
        trim: true
      },
      description: {
        type: String,
        trim: true,
        default: ''
      },
      imageUrl: {
        type: String,
        trim: true,
        default: ''
      },
      isSeeded: {
        type: Boolean,
        default: true
      },
      isAvailable: {
        type: Boolean,
        default: true
      }
    },
    { timestamps: true }
  );

  Food =
    mongoose.models.Food ||
    mongoose.model('Food', foodSchema);
}

// Keep your existing 131-item dataset below this line.
const tamilNaduFoodItems = [

  // 1 - 15
  {
    name: 'Idli',
    tamilName: 'இட்லி',
    category: 'Breakfast',
    type: 'Veg',
    description: 'Traditional steamed soft, fluffy fermented rice and black gram patties served hot with coconut chutney and sambar.',
    imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Mini Idli',
    tamilName: 'மினி இட்லி',
    category: 'Breakfast',
    type: 'Veg',
    description: 'Bite-sized coin idlis soaked in a bowl of aromatic piping hot ghee sambar, garnished with fresh cilantro.',
    imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Sambar Idli',
    tamilName: 'சாம்பார் இட்லி',
    category: 'Breakfast',
    type: 'Veg',
    description: 'Pillowy steamed idlis completely submerged in rich Madras-style shallot sambar with a spoonful of pure cow ghee.',
    imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Dosa',
    tamilName: 'தோசை',
    category: 'Breakfast',
    type: 'Veg',
    description: 'Golden-brown, thin, crispy crepe roasted on a seasoned cast-iron skillet using fermented lentil-rice batter.',
    imageUrl: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Masala Dosa',
    tamilName: 'மசாலா தோசை',
    category: 'Breakfast',
    type: 'Veg',
    description: 'Crispy roasted crepe folded over a fragrant spiced potato, onion, mustard seed, and curry leaf stuffing.',
    imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Ven Pongal',
    tamilName: 'வெண் பொங்கல்',
    category: 'Breakfast',
    type: 'Veg',
    description: 'Melt-in-mouth rice and yellow moong dal porridge tempered with whole black peppercorns, cumin, fresh ginger, and ghee-roasted cashews.',
    imageUrl: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Poori',
    tamilName: 'பூரி',
    category: 'Breakfast',
    type: 'Veg',
    description: 'Deep-fried golden puffed whole wheat bread, light and crisp, paired with savory potato masala.',
    imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chapathi',
    tamilName: 'சப்பாத்தி',
    category: 'Bread',
    type: 'Veg',
    description: 'Soft and healthy unleavened whole wheat flatbread rolled thin and dry-roasted on hot tawa.',
    imageUrl: 'https://images.unsplash.com/photo-1626074353765-517a681e40be?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Parotta',
    tamilName: 'பரோட்டா',
    category: 'Bread',
    type: 'Veg',
    description: 'Layered flaky flatbread kneaded and expertly tossed by hand, griddled with butter until crisp and flaky.',
    imageUrl: 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Bun Parotta',
    tamilName: 'பன் பரோட்டா',
    category: 'Bread',
    type: 'Veg',
    description: 'Madurai famous thick bun-shaped layered parotta with a crispy golden crust and soft pillowy inner layers.',
    imageUrl: 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Upma',
    tamilName: 'உப்புமா',
    category: 'Breakfast',
    type: 'Veg',
    description: 'Wholesome semolina porridge tempered with mustard seeds, urad dal, green chilies, grated ginger, and curry leaves.',
    imageUrl: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Vegetable Kootu',
    tamilName: 'காய்கறி கூட்டு',
    category: 'Meals',
    type: 'Veg',
    description: 'Mild, comforting South Indian stew of mixed vegetables and chana dal simmered with freshly ground coconut-cumin paste.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Onion Uthappam',
    tamilName: 'வெங்காய உத்தப்பம்',
    category: 'Breakfast',
    type: 'Veg',
    description: 'Thick, fluffy griddle pancake made from fermented batter and topped with caramelized shallots and green chilies.',
    imageUrl: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Veg Kurma',
    tamilName: 'வெஜ் குருமா',
    category: 'Veg Gravy',
    type: 'Veg',
    description: 'Fragrant mixed vegetable gravy in a velvety coconut, poppy seed, cashew, and fennel spice paste.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Cauliflower 65',
    tamilName: 'காலிஃபிளவர் 65',
    category: 'Starter',
    type: 'Veg',
    description: 'Crisp-fried tender cauliflower florets marinated in fiery spices, crushed garlic, and curry leaves.',
    imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80',
  },

  // 16 - 30
  {
    name: 'Egg Dosa',
    tamilName: 'முட்டை தோசை',
    category: 'Breakfast',
    type: 'Non-Veg',
    description: 'Crisp tawa-roasted dosa spread with seasoned beaten eggs, black pepper, and spicy curry salna.',
    imageUrl: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Egg Omelette',
    tamilName: 'முட்டை ஆம்லெட்',
    category: 'Starter',
    type: 'Non-Veg',
    description: 'South Indian style fluffy country egg omelette with diced shallots, green chillies, and freshly cracked pepper.',
    imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Egg Kalakki',
    tamilName: 'முட்டை கலக்கி',
    category: 'Starter',
    type: 'Non-Veg',
    description: 'Madurai iconic street specialty soft-scrambled runny egg pocket infused with rich chicken or mutton salna.',
    imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Egg Appam',
    tamilName: 'முட்டை ஆப்பம்',
    category: 'Breakfast',
    type: 'Non-Veg',
    description: 'Lacy fermented rice hopper bowl holding a soft-steamed sunny egg at its fluffy center with pepper dusting.',
    imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chicken Dosa',
    tamilName: 'சிக்கன் தோசை',
    category: 'Breakfast',
    type: 'Non-Veg',
    description: 'Hot roasted dosa stuffed with spicy, shredded Chettinad boneless chicken sukka and fresh coriander.',
    imageUrl: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chicken Curry',
    tamilName: 'சிக்கன் கறி',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Homestyle chicken gravy cooked with bone-in tender meat, onions, tomatoes, and freshly ground whole spices.',
    imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Mutton Curry',
    tamilName: 'மட்டன் கறி',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Slow-cooked succulent goat meat in an intensely flavored rustic Tamil red gravy infused with cinnamon and cloves.',
    imageUrl: 'https://images.unsplash.com/photo-1545247181-516773ca838b?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'South Indian Meals',
    tamilName: 'தென்னிந்திய சாப்பாடு',
    category: 'Meals',
    type: 'Veg',
    description: 'Grand banana leaf feast served with steamed rice, sambar, rasam, kootu, poriyal, avial, appalam, pickle, and payasam.',
    imageUrl: 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'White Rice',
    tamilName: 'வெள்ளை சாதம்',
    category: 'Rice',
    type: 'Veg',
    description: 'Steamed fluffy premium South Indian Ponni white rice, the heart of traditional meals.',
    imageUrl: 'https://images.unsplash.com/photo-1516684732162-798a0062be99?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Sambar',
    tamilName: 'சாம்பார்',
    category: 'Meals',
    type: 'Veg',
    description: 'Rich toor dal stew simmered with shallots, drumstick, tamarind extract, and freshly roasted Madras sambar masala.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Dal',
    tamilName: 'பருப்பு',
    category: 'Meals',
    type: 'Veg',
    description: 'Mild, comforting yellow toor dal tempered with ghee, cumin seeds, garlic, and hing for piping hot rice.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Dal Rasam',
    tamilName: 'பருப்பு ரசம்',
    category: 'Meals',
    type: 'Veg',
    description: 'Digestive broth made from cooked dal water, fresh tomatoes, tamarind, crushed cumin, and black pepper.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Rasam',
    tamilName: 'ரசம்',
    category: 'Meals',
    type: 'Veg',
    description: 'Pungent, tangy, and invigorating clear broth infused with crushed garlic, black pepper, tamarind, and curry leaves.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Vatha Kuzhambu',
    tamilName: 'வத்த குழம்பு',
    category: 'Meals',
    type: 'Veg',
    description: 'Authentic Brahmin-style tangy tamarind gravy cooked in sesame oil with sun-dried turkey berries (sundakkai).',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Kara Kuzhambu',
    tamilName: 'கார குழம்பு',
    category: 'Meals',
    type: 'Veg',
    description: 'Fiery and tangy tamarind gravy enriched with whole peeled garlic pods, shallots, and spicy roasted masala.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },

  // 31 - 45
  {
    name: 'Avial',
    tamilName: 'அவியல்',
    category: 'Meals',
    type: 'Veg',
    description: 'Traditional medley of native vegetables gently steamed and simmered in a coconut, cumin, and yogurt gravy with coconut oil.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Potato Poriyal',
    tamilName: 'உருளைக்கிழங்கு பொரியல்',
    category: 'Meals',
    type: 'Veg',
    description: 'Tender baby potato cubes roasted with mustard seeds, curry leaves, red chili, and fresh grated coconut.',
    imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Cabbage Poriyal',
    tamilName: 'முட்டைகோஸ் பொரியல்',
    category: 'Meals',
    type: 'Veg',
    description: 'Finely shredded crisp cabbage sautéed with soaked chana dal, green chilies, mustard, and sweet coconut.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Beans Poriyal',
    tamilName: 'பீன்ஸ் பொரியல்',
    category: 'Meals',
    type: 'Veg',
    description: 'Finely diced French beans dry-tempered with mustard, urad dal, and freshly grated coconut garnish.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Carrot Poriyal',
    tamilName: 'கேரட் பொரியல்',
    category: 'Meals',
    type: 'Veg',
    description: 'Sweet and savory grated carrots lightly sautéed with green chillies, curry leaves, and tempered coconut.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Cauliflower Poriyal',
    tamilName: 'காலிஃபிளவர் பொரியல்',
    category: 'Meals',
    type: 'Veg',
    description: 'Blanched cauliflower florets stir-fried in a delicate dry spice blend with shallots and curry leaves.',
    imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Mushroom 65',
    tamilName: 'காளான் 65',
    category: 'Starter',
    type: 'Veg',
    description: 'Deep-fried button mushrooms coated in a spicy red chili, ginger-garlic, and cornstarch batter.',
    imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Paneer Butter Masala',
    tamilName: 'பன்னீர் பட்டர் மசாலா',
    category: 'Veg Gravy',
    type: 'Veg',
    description: 'Succulent cottage cheese cubes simmered in a silky tomato, cashew cream, and butter sauce scented with fenugreek leaves.',
    imageUrl: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Channa Masala',
    tamilName: 'சென்னா மசாலா',
    category: 'Veg Gravy',
    type: 'Veg',
    description: 'Hearty chickpeas slow-cooked in a tangy Punjabi-style onion, tomato, and roasted coriander gravy.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Rajma Masala',
    tamilName: 'ராஜ்மா மசாலா',
    category: 'Veg Gravy',
    type: 'Veg',
    description: 'Melt-in-mouth red kidney beans simmered in a hearty ginger, garlic, and tomato curry gravy.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Vegetable Biryani',
    tamilName: 'வெஜிடபிள் பிரியாணி',
    category: 'Biryani',
    type: 'Veg',
    description: 'Aromatic seeraga samba rice cooked with fresh seasonal vegetables, mint, coriander, and whole royal spices.',
    imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Mushroom Biryani',
    tamilName: 'காளான் பிரியாணி',
    category: 'Biryani',
    type: 'Veg',
    description: 'Dindigul-style seeraga samba rice layered with juicy button mushrooms, green chilies, and aromatic spices.',
    imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Lemon Rice',
    tamilName: 'எலுமிச்சை சாதம்',
    category: 'Rice',
    type: 'Veg',
    description: 'Zesty turmeric rice infused with fresh lemon juice, crunchy roasted peanuts, mustard seeds, and curry leaves.',
    imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Tomato Rice',
    tamilName: 'தக்காளி சாதம்',
    category: 'Rice',
    type: 'Veg',
    description: 'Flavorful spiced rice sautéed with ripe tomatoes, onions, garlic, cinnamon, and fresh mint leaves.',
    imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Curd Rice',
    tamilName: 'தயிர் சாதம்',
    category: 'Rice',
    type: 'Veg',
    description: 'Cooling comfort rice mixed with fresh creamy curd, milk, and tempered mustard seeds, green chillies, and ginger.',
    imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
  },

  // 46 - 60
  {
    name: 'Coconut Rice',
    tamilName: 'தேங்காய் சாதம்',
    category: 'Rice',
    type: 'Veg',
    description: 'Delicate fragrant rice tossed with freshly grated coconut, ghee-roasted cashews, urad dal, and red chillies.',
    imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Puliyodarai',
    tamilName: 'புளியோதரை',
    category: 'Rice',
    type: 'Veg',
    description: 'Classic Tamil temple-style tamarind rice prepared with gingelly oil, roasted peanuts, and spicy proprietary podi.',
    imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Appalam',
    tamilName: 'அப்பளம்',
    category: 'Meals',
    type: 'Veg',
    description: 'Crisp, airy deep-fried lentil wafers, the ultimate crunchy accompaniment for South Indian meals.',
    imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Pickle',
    tamilName: 'ஊறுகாய்',
    category: 'Meals',
    type: 'Veg',
    description: 'Spicy, pungent South Indian raw mango or tender lime pickle aged in mustard oil and red chili.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Curds',
    tamilName: 'கெட்டி தயிர்',
    category: 'Meals',
    type: 'Veg',
    description: 'Freshly set, rich, and creamy homemade whole milk yogurt, soothing and probiotic.',
    imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Buttermilk',
    tamilName: 'மோர்',
    category: 'Meals',
    type: 'Veg',
    description: 'Churned cooling beverage seasoned with ginger, green chili, asafoetida, and crushed curry leaves.',
    imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chicken Biryani',
    tamilName: 'சிக்கன் பிரியாணி',
    category: 'Biryani',
    type: 'Non-Veg',
    description: 'Tamil Nadu style fragrant biryani prepared with bone-in tender chicken, caramelized onions, and mint.',
    imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chicken Dum Biryani',
    tamilName: 'சிக்கன் தம் பிரியாணி',
    category: 'Biryani',
    type: 'Non-Veg',
    description: 'Slow-cooked royal dum biryani where marinated spiced chicken and fragrant rice cook under sealed steam.',
    imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chicken Vadi Biryani',
    tamilName: 'சிக்கன் வாடி பிரியாணி',
    category: 'Biryani',
    type: 'Non-Veg',
    description: 'Kongu Nadu specialty seeraga samba rice biryani cooked with free-range chicken and rustic spices.',
    imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Mutton Biryani',
    tamilName: 'மட்டன் பிரியாணி',
    category: 'Biryani',
    type: 'Non-Veg',
    description: 'Authentic Seeraga Samba mutton biryani with melt-in-mouth tender goat meat cooked in pure ghee.',
    imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Mutton Dum Biryani',
    tamilName: 'மட்டன் தம் பிரியாணி',
    category: 'Biryani',
    type: 'Non-Veg',
    description: 'Layered slow-steamed mutton and aged fragrant rice infused with saffron, ghee, and whole garam masala.',
    imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Mutton Vadi Biryani',
    tamilName: 'மட்டன் வாடி பிரியாணி',
    category: 'Biryani',
    type: 'Non-Veg',
    description: 'Traditional wood-fired Tamil village goat meat biryani prepared in large cauldrons with short-grain rice.',
    imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Prawn Biryani',
    tamilName: 'இறால் பிரியாணி',
    category: 'Biryani',
    type: 'Non-Veg',
    description: 'Coastal seafood delicacy of succulent marine prawns cooked with aromatic spiced basmati rice and mint.',
    imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Egg Biryani',
    tamilName: 'முட்டை பிரியாணி',
    category: 'Biryani',
    type: 'Non-Veg',
    description: 'Spiced aromatic biryani rice served with golden turmeric-roasted boiled eggs and salna.',
    imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chicken Rice',
    tamilName: 'சிக்கன் ரைஸ்',
    category: 'Rice',
    type: 'Non-Veg',
    description: 'Wok-tossed fast-food style fried rice loaded with shredded chicken, scrambled eggs, and spring onions.',
    imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
  },

  // 61 - 75
  {
    name: 'Egg Rice',
    tamilName: 'முட்டை ரைஸ்',
    category: 'Rice',
    type: 'Non-Veg',
    description: 'Street-style smoky stir-fried rice tossed with farm eggs, cabbage, carrots, and freshly cracked black pepper.',
    imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chicken Noodles',
    tamilName: 'சிக்கன் நூடுல்ஸ்',
    category: 'Starter',
    type: 'Non-Veg',
    description: 'Stir-fried noodles with tender chicken strips, shredded vegetables, and zesty chili-garlic seasoning.',
    imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chicken 65',
    tamilName: 'சிக்கன் 65',
    category: 'Starter',
    type: 'Non-Veg',
    description: 'Famous Chennai deep-fried boneless chicken marinated in red chili, ginger-garlic paste, and fried curry leaves.',
    imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chicken Lollipop',
    tamilName: 'சிக்கன் லாலிபாப்',
    category: 'Starter',
    type: 'Non-Veg',
    description: 'Crispy frenched chicken drumettes marinated in savory spices, fried to a crunchy texture, and served with schezwan dip.',
    imageUrl: 'https://images.unsplash.com/photo-1527477396000-e27163b481c2?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Naatukozhi Varuval',
    tamilName: 'நாட்டுக்கோழி வறுவல்',
    category: 'Starter',
    type: 'Non-Veg',
    description: 'Free-range country chicken pan-roasted dry with shallots, crushed peppercorns, garlic, and curry leaves.',
    imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chicken Pepper Gravy',
    tamilName: 'சிக்கன் மிளகு குழம்பு',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Spicy chicken curry with a dominant kick of freshly crushed black pepper, fennel, and coriander.',
    imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chettinad Chicken Gravy',
    tamilName: 'செட்டிநாடு சிக்கன் குழம்பு',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'World-renowned Chettinad chicken curry simmered in freshly roasted kalpasi, star anise, coconut, and dried red chilies.',
    imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Andhra Spicy Chicken Gravy',
    tamilName: 'ஆந்திரா கார சிக்கன் கிரேவி',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Fiery chicken gravy loaded with green chillies, poppy seeds, and a spicy tomato base.',
    imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Butter Chicken Gravy',
    tamilName: 'பட்டர் சிக்கன் கிரேவி',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Tender chicken pieces simmered in a mildly sweet, buttery tomato and cashew gravy with cream.',
    imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Country Chicken Gravy',
    tamilName: 'நாட்டுக்கோழி குழம்பு',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Rustic village-style country chicken broth slow-cooked with freshly ground shallots and stone-ground spices.',
    imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Pallapalayam Chicken Gravy',
    tamilName: 'பள்ளப்பாளையம் சிக்கன் கிரேவி',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Kongu region specialty chicken cooked with shallots, dry red chilies, and copra without turmeric.',
    imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chicken Gravy',
    tamilName: 'சிக்கன் கிரேவி',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Everyday Tamil Nadu style rich onion-tomato salna gravy, perfect for parotta and white rice.',
    imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chicken Kurma',
    tamilName: 'சிக்கன் குருமா',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Delicate, creamy chicken curry made with ground fresh coconut, cashews, fennel seeds, and green chilies.',
    imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Mutton Gravy',
    tamilName: 'மட்டன் கிரேவி',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Tender goat meat cooked in a thick, intensely spiced dark onion-tomato masala gravy.',
    imageUrl: 'https://images.unsplash.com/photo-1545247181-516773ca838b?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Chettinad Mutton Gravy',
    tamilName: 'செட்டிநாடு மட்டன் குழம்பு',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Exemplary Chettinad goat meat curry simmered with stone-ground dagad phool, peppercorns, and fresh coconut.',
    imageUrl: 'https://images.unsplash.com/photo-1545247181-516773ca838b?auto=format&fit=crop&w=800&q=80',
  },

  // 76 - 90
  {
    name: 'Mutton Pepper Gravy',
    tamilName: 'மட்டன் மிளகு கிரேவி',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Invigorating dark goat curry loaded with freshly pounded black peppercorns and aromatic curry leaves.',
    imageUrl: 'https://images.unsplash.com/photo-1545247181-516773ca838b?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Mutton Chukka',
    tamilName: 'மட்டன் சுக்கா',
    category: 'Starter',
    type: 'Non-Veg',
    description: 'Madurai style pan-roasted tender boneless mutton chunks coated in a rich reduction of shallots and fiery spices.',
    imageUrl: 'https://images.unsplash.com/photo-1545247181-516773ca838b?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Coconut Milk Mutton Gravy',
    tamilName: 'தேங்காய்ப்பால் மட்டன் கிரேவி',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Tender mutton gently stewed in freshly pressed coconut milk, mild whole spices, and green chillies.',
    imageUrl: 'https://images.unsplash.com/photo-1545247181-516773ca838b?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Mutton Bone Gravy',
    tamilName: 'மட்டன் எலும்பு குழம்பு',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Nutritious marrow bone broth slow-simmered with crushed ginger, shallots, and medicinal black pepper.',
    imageUrl: 'https://images.unsplash.com/photo-1545247181-516773ca838b?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Fish Fry',
    tamilName: 'மீன் வறுவல்',
    category: 'Seafood',
    type: 'Non-Veg',
    description: 'Fresh Vanjaram (seer fish) steaks marinated in spicy chili-lemon paste, pan-seared to a crispy perfection.',
    imageUrl: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Fish Curry',
    tamilName: 'மீன் குழம்பு',
    category: 'Seafood',
    type: 'Non-Veg',
    description: 'Clay pot cooked tangy fish curry prepared with tamarind, fenugreek seeds, shallots, and fresh curry leaves.',
    imageUrl: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Prawn Masala',
    tamilName: 'இறால் மசாலா',
    category: 'Seafood',
    type: 'Non-Veg',
    description: 'Juicy coastal sea prawns pan-roasted with caramelized onions, tomatoes, and freshly cracked black pepper.',
    imageUrl: 'https://images.unsplash.com/photo-1559737558-245cb70d6a45?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Egg Curry',
    tamilName: 'முட்டை குழம்பு',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Boiled country eggs simmered in a spiced onion, tomato, and coconut gravy.',
    imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Egg Fry',
    tamilName: 'முட்டை வறுவல்',
    category: 'Starter',
    type: 'Non-Veg',
    description: 'Hard-boiled egg halves pan-roasted in sesame oil with crushed shallots, curry leaves, and black pepper.',
    imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Mutton Kurma',
    tamilName: 'மட்டன் குருமா',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Rich and aromatic mutton curry simmered in a velvety paste of cashew nuts, poppy seeds, and coconut.',
    imageUrl: 'https://images.unsplash.com/photo-1545247181-516773ca838b?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Veg Kothu Parotta',
    tamilName: 'வெஜ் கொத்து பரோட்டா',
    category: 'Breakfast',
    type: 'Veg',
    description: 'Flaky shredded parotta chopped vigorously on a searing tawa with mixed vegetables and flavorful veg salna.',
    imageUrl: 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Ghee Dosa',
    tamilName: 'நெய் தோசை',
    category: 'Breakfast',
    type: 'Veg',
    description: 'Wafer-thin golden crispy crepe roasted generously with fragrant desi ghee, served piping hot.',
    imageUrl: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Roti',
    tamilName: 'ரொட்டி',
    category: 'Bread',
    type: 'Veg',
    description: 'Traditional whole wheat flatbread puffed on naked flame, light and comforting.',
    imageUrl: 'https://images.unsplash.com/photo-1626074353765-517a681e40be?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Naan',
    tamilName: 'நான்',
    category: 'Bread',
    type: 'Veg',
    description: 'Traditional teardrop-shaped leavened flatbread baked against the searing clay walls of a tandoor.',
    imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Butter Naan',
    tamilName: 'பட்டர் நான்',
    category: 'Bread',
    type: 'Veg',
    description: 'Soft tandoori flatbread brushed generously with melted butter, wonderfully pillowy and tender.',
    imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80',
  },

  // 91 - 105
  {
    name: 'Kulcha',
    tamilName: 'குல்சா',
    category: 'Bread',
    type: 'Veg',
    description: 'Mildly leavened Indian flatbread sprinkled with nigella seeds and fresh coriander, lightly toasted.',
    imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Idly',
    tamilName: 'இட்லி',
    category: 'Breakfast',
    type: 'Veg',
    description: 'Classic steamed savory rice and black lentil cakes, soft, tender, and served with coconut chutney.',
    imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Idiyappam',
    tamilName: 'இடியாப்பம்',
    category: 'Breakfast',
    type: 'Veg',
    description: 'Delicate steamed rice noodles (string hoppers) served with sweet sweetened coconut milk or spicy kurma.',
    imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Appam',
    tamilName: 'ஆப்பம்',
    category: 'Breakfast',
    type: 'Veg',
    description: 'Crispy lacy-edged bowl hopper made of fermented rice flour and coconut milk with a pillowy soft center.',
    imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Vegetable Fried Rice',
    tamilName: 'வெஜிடபிள் ஃப்ரைட் ரைஸ்',
    category: 'Rice',
    type: 'Veg',
    description: 'Wok-tossed long-grain basmati rice with finely diced carrots, beans, cabbage, and soy seasoning.',
    imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Gobi Fried Rice',
    tamilName: 'கோபி ஃப்ரைட் ரைஸ்',
    category: 'Rice',
    type: 'Veg',
    description: 'Fragrant fried rice tossed with crispy golden spiced cauliflower florets and fresh spring onions.',
    imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Paneer Fried Rice',
    tamilName: 'பன்னீர் ஃப்ரைட் ரைஸ்',
    category: 'Rice',
    type: 'Veg',
    description: 'Aromatic basmati fried rice tossed with golden pan-seared paneer cubes and garden vegetables.',
    imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Veg Noodles',
    tamilName: 'வெஜ் நூடுல்ஸ்',
    category: 'Starter',
    type: 'Veg',
    description: 'Stir-fried noodles loaded with julienned vegetables, spring onions, and savory Asian sauces.',
    imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Gobi Manchurian',
    tamilName: 'கோபி மஞ்சூரியன்',
    category: 'Starter',
    type: 'Veg',
    description: 'Crispy cauliflower florets tossed in a sweet, sour, and tangy Indo-Chinese garlic soy sauce.',
    imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Brinjal Pachadi',
    tamilName: 'கத்திரிக்காய் பச்சடி',
    category: 'Meals',
    type: 'Veg',
    description: 'Smoky roasted eggplant mash seasoned with mustard seeds, green chilies, and tangy tamarind.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Dal Fry',
    tamilName: 'தால் ஃப்ரை',
    category: 'Veg Gravy',
    type: 'Veg',
    description: 'Creamy cooked yellow lentils finished with an aromatic tadka of ghee, cumin, garlic, and dried red chilies.',
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Rice',
    tamilName: 'சாதம்',
    category: 'Rice',
    type: 'Veg',
    description: 'Freshly steamed warm plain white rice, the daily staple grain for South Indian gravies and curries.',
    imageUrl: 'https://images.unsplash.com/photo-1516684732162-798a0062be99?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Mutton Bone Curry',
    tamilName: 'மட்டன் எலும்பு கறி',
    category: 'Non-Veg Gravy',
    type: 'Non-Veg',
    description: 'Rich country-style marrow bone curry cooked with stone-ground shallots, coriander, and black pepper.',
    imageUrl: 'https://images.unsplash.com/photo-1545247181-516773ca838b?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Gulab Jamun',
    tamilName: 'குலாப் ஜாமூன்',
    category: 'Sweets',
    type: 'Veg',
    description: 'Melt-in-mouth golden milk-solid dumplings soaked in aromatic rose and green cardamom scented sugar syrup.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Rasgulla',
    tamilName: 'ரசகுல்லா',
    category: 'Sweets',
    type: 'Veg',
    description: 'Soft and spongy snowy cottage cheese spheres poached gently in light, fragrant sugar syrup.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },

  // 106 - 120
  {
    name: 'Rasmalai',
    tamilName: 'ரசமலாய்',
    category: 'Sweets',
    type: 'Veg',
    description: 'Delicate flattened cottage cheese discs soaked in chilled creamy milk flavored with saffron and pistachio.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Mysore Pak',
    tamilName: 'மைசூர் பாக்',
    category: 'Sweets',
    type: 'Veg',
    description: 'Royal confection crafted from roasted chickpea flour, pure desi ghee, and sugar, melting deliciously on the tongue.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Badam Halwa',
    tamilName: 'பாதாம் அல்வா',
    category: 'Sweets',
    type: 'Veg',
    description: 'Luxurious sweet pudding prepared from blanched ground almonds simmered with ghee, saffron, and sugar.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Wheat Halwa',
    tamilName: 'கோதுமை அல்வா',
    category: 'Sweets',
    type: 'Veg',
    description: 'Traditional Tamil festival halwa cooked from extracted whole wheat milk, pure cow ghee, and caramelized sugar.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Carrot Halwa',
    tamilName: 'கேரட் அல்வா',
    category: 'Sweets',
    type: 'Veg',
    description: 'Finely grated sweet carrots slow-cooked in whole milk, khoya, pure ghee, and roasted cashews.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Kasi Halwa',
    tamilName: 'காசி அல்வா',
    category: 'Sweets',
    type: 'Veg',
    description: 'Festive Tamil Brahmin feast sweet made from grated white pumpkin (ash gourd) slow-cooked in ghee and saffron.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Tirunelveli Halwa',
    tamilName: 'திருநெல்வேலி அல்வா',
    category: 'Sweets',
    type: 'Veg',
    description: 'Legendary dark glossy halwa made from river Thamirabarani water, fermented wheat milk, pure ghee, and caramel.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Bread Halwa',
    tamilName: 'பிரெட் அல்வா',
    category: 'Sweets',
    type: 'Veg',
    description: 'Famous wedding dessert made of ghee-fried bread simmered with milk, sugar, cardamom, and roasted dry fruits.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Kesari',
    tamilName: 'கேசரி',
    category: 'Sweets',
    type: 'Veg',
    description: 'Classic auspicious orange semolina pudding prepared with roasted rava, clarified butter, saffron, and cashews.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Rava Kesari',
    tamilName: 'ரவா கேசரி',
    category: 'Sweets',
    type: 'Veg',
    description: 'Silky smooth semolina confection flavored with cardamom powder, ghee-roasted cashews, and golden raisins.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Pineapple Kesari',
    tamilName: 'அன்னாசி கேசரி',
    category: 'Sweets',
    type: 'Veg',
    description: 'Tantalizing semolina halwa cooked with fresh crushed pineapple tidbits, ghee, and golden saffron.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Paal Payasam',
    tamilName: 'பால் பாயாசம்',
    category: 'Sweets',
    type: 'Veg',
    description: 'Pristine South Indian temple-style rice kheer cooked by reducing full cream milk and sugar for hours.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Semiya Payasam',
    tamilName: 'சேமியா பாயாசம்',
    category: 'Sweets',
    type: 'Veg',
    description: 'Celebratory pudding made with roasted vermicelli noodles simmered in cardamom milk and garnished with cashews.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Paruppu Payasam',
    tamilName: 'பருப்பு பாயாசம்',
    category: 'Sweets',
    type: 'Veg',
    description: 'Traditional Tamil feast kheer prepared with roasted moong dal, dark palm jaggery, thick coconut milk, and ghee.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Jangiri',
    tamilName: 'ஜாங்கிரி',
    category: 'Sweets',
    type: 'Veg',
    description: 'Intricately piped circular flower rosettes of urad dal batter fried crisp and soaked in saffron rose sugar syrup.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },

  // 121 - 131
  {
    name: 'Jalebi',
    tamilName: 'ஜிலேபி',
    category: 'Sweets',
    type: 'Veg',
    description: 'Crisp spiral coils of fermented batter deep-fried to a golden hue and drenched in piping hot saffron syrup.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Laddu',
    tamilName: 'லட்டு',
    category: 'Sweets',
    type: 'Veg',
    description: 'Iconic spherical golden sweet crafted from tiny fried chickpea pearls, sugar syrup, ghee, and cardamom.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Boondi Laddu',
    tamilName: 'பூந்தி லட்டு',
    category: 'Sweets',
    type: 'Veg',
    description: 'Soft and fragrant laddus made of juicy syrup-soaked boondi pearls, cloves, cashews, and edible camphor.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Motichoor Laddu',
    tamilName: 'மோதிச்சூர் லட்டு',
    category: 'Sweets',
    type: 'Veg',
    description: 'Delicate melt-in-the-mouth sweet spheres made from micro gram flour droplets soaked in pure saffron sugar syrup.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Coconut Burfi',
    tamilName: 'தேங்காய் பர்ஃபி',
    category: 'Sweets',
    type: 'Veg',
    description: 'Diamond-cut fudge confection made from freshly grated tender coconut simmered with sugar, milk, and cardamom.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Milk Peda',
    tamilName: 'பால்கோவா / பேடா',
    category: 'Sweets',
    type: 'Veg',
    description: 'Traditional fudge prepared by slowly reducing whole dairy milk and sugar to a dense, rich cardamom-scented treat.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Badusha',
    tamilName: 'பாதுஷா',
    category: 'Sweets',
    type: 'Veg',
    description: 'Flaky layered South Indian style pastry doughnut with a crisp golden exterior and sugar-glazed tender interior.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Poli',
    tamilName: 'போளி',
    category: 'Sweets',
    type: 'Veg',
    description: 'Sweet stuffed flatbread with a rich filing of chana dal, jaggery, cardamom, and coconut, griddled with pure ghee.',
    imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Sweet Pongal',
    tamilName: 'சர்க்கரை பொங்கல்',
    category: 'Sweets',
    type: 'Veg',
    description: 'Sacred temple preparation of rice and moong dal simmered in dark golden jaggery, copious ghee, and roasted cashews.',
    imageUrl: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Sweet Appam',
    tamilName: 'இனிப்பு ஆப்பம்',
    category: 'Sweets',
    type: 'Veg',
    description: 'Golden-fried dumplings made of rice batter, mashed bananas, jaggery, and roasted coconut bits.',
    imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80',
  },
  {
    name: 'Moong Dal Payasam',
    tamilName: 'பாசிப்பருப்பு பாயாசம்',
    category: 'Sweets',
    type: 'Veg',
    description: 'Comforting festive pudding made with roasted yellow moong lentils simmered in organic jaggery and fresh coconut milk.',
    imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=800&q=80',
  },
];


   
async function seedTamilNaduFoods() {
  try {
    await connectDB();
    console.log('MongoDB connected successfully.');

    let insertedCount = 0;
    let updatedCount = 0;

    for (const item of tamilNaduFoodItems) {
      const name = item.name?.trim();

      if (!name) {
        console.warn('Skipping item with missing name.');
        continue;
      }

      const existingFood = await Food.findOne({
        name: {
          $regex: new RegExp(
            `^${name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`,
            'i'
          )
        }
      });

      const foodData = {
        ...item,
        name,
        isSeeded: true,
        isAvailable: item.isAvailable ?? true
      };

      if (existingFood) {
        await Food.updateOne(
          { _id: existingFood._id },
          { $set: foodData },
          { runValidators: true }
        );

        updatedCount++;
      } else {
        await Food.create(foodData);
        insertedCount++;
      }
    }

    console.log('Food seeding completed successfully.');
    console.log(`Inserted: ${insertedCount}`);
    console.log(`Updated: ${updatedCount}`);
    console.log(`Dataset total: ${tamilNaduFoodItems.length}`);
  } catch (error) {
    console.error('Food seeding failed:', error);
    throw error;
  } finally {
    if (mongoose.connection.readyState !== 0) {
      await mongoose.disconnect();
    }
  }
}

const isDirectExecution =
  process.argv[1] &&
  pathToFileURL(path.resolve(process.argv[1])).href === import.meta.url;

if (isDirectExecution) {
  seedTamilNaduFoods()
    .then(() => {
      console.log('Seed execution finished.');
    })
    .catch((error) => {
      console.error('Fatal execution error:', error);
      process.exitCode = 1;
    });
}

export {
  tamilNaduFoodItems,
  seedTamilNaduFoods
};
