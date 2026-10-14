
require("dotenv").config();

const mongoose = require("mongoose");
const connectDB = require("../src/config/db");
const Food = require("../src/models/Food");

const tamilNaduFoods = [
      /* =======================================================
     BREAKFAST - VEG
     ======================================================= */

  {
    name: "Idli",
    tamilName: "இட்லி",
    meal: "Breakfast",
    type: "Veg",
    description: "Soft and fresh steamed idli",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mini Idli",
    tamilName: "மினி இட்லி",
    meal: "Breakfast",
    type: "Veg",
    description: "Small soft steamed idlis",
    image: "",
    isAvailable: true,
  },

  {
    name: "Sambar Idli",
    tamilName: "சாம்பார் இட்லி",
    meal: "Breakfast",
    type: "Veg",
    description: "Idli served with delicious sambar",
    image: "",
    isAvailable: true,
  },

  {
    name: "Dosa",
    tamilName: "தோசை",
    meal: "Breakfast",
    type: "Veg",
    description: "Crispy South Indian dosa",
    image: "",
    isAvailable: true,
  },

  {
    name: "Masala Dosa",
    tamilName: "மசாலா தோசை",
    meal: "Breakfast",
    type: "Veg",
    description: "Crispy dosa with potato masala",
    image: "",
    isAvailable: true,
  },

  {
    name: "Ven Pongal",
    tamilName: "வெண்பொங்கல்",
    meal: "Breakfast",
    type: "Veg",
    description: "Traditional South Indian ven pongal",
    image: "",
    isAvailable: true,
  },

  {
    name: "Poori",
    tamilName: "பூரி",
    meal: "Breakfast",
    type: "Veg",
    description: "Fluffy deep-fried poori",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chapathi",
    tamilName: "சப்பாத்தி",
    meal: "Breakfast",
    type: "Veg",
    description: "Soft Indian wheat chapathi",
    image: "",
    isAvailable: true,
  },

  {
    name: "Parotta",
    tamilName: "பரோட்டா",
    meal: "Breakfast",
    type: "Veg",
    description: "Layered South Indian parotta",
    image: "",
    isAvailable: true,
  },

  {
    name: "Bun Parotta",
    tamilName: "பன் பரோட்டா",
    meal: "Breakfast",
    type: "Veg",
    description: "Soft layered bun parotta",
    image: "",
    isAvailable: true,
  },

  {
    name: "Upma",
    tamilName: "உப்புமா",
    meal: "Breakfast",
    type: "Veg",
    description: "Traditional South Indian upma",
    image: "",
    isAvailable: true,
  },

  {
    name: "Vegetable Kootu",
    tamilName: "காய்கறி கூட்டு",
    meal: "Breakfast",
    type: "Veg",
    description: "Healthy mixed vegetable kootu",
    image: "",
    isAvailable: true,
  },

  {
    name: "Onion Uthappam",
    tamilName: "வெங்காய ஊத்தப்பம்",
    meal: "Breakfast",
    type: "Veg",
    description: "Soft uthappam topped with onions",
    image: "",
    isAvailable: true,
  },

  {
    name: "Veg Kurma",
    tamilName: "வெஜ் குருமா",
    meal: "Breakfast",
    type: "Veg",
    description: "Mixed vegetable kurma",
    image: "",
    isAvailable: true,
  },

  {
    name: "Cauliflower 65",
    tamilName: "காலிஃப்ளவர் 65",
    meal: "Breakfast",
    type: "Veg",
    description: "Crispy cauliflower 65",
    image: "",
    isAvailable: true,
  },


  /* =======================================================
     BREAKFAST - NON VEG
     ======================================================= */

  {
    name: "Egg Dosa",
    tamilName: "முட்டை தோசை",
    meal: "Breakfast",
    type: "Non-Veg",
    description: "Dosa topped with egg",
    image: "",
    isAvailable: true,
  },

  {
    name: "Egg Omelette",
    tamilName: "முட்டை ஆம்லெட்",
    meal: "Breakfast",
    type: "Non-Veg",
    description: "Fresh egg omelette",
    image: "",
    isAvailable: true,
  },

  {
    name: "Egg Kalakki",
    tamilName: "முட்டை கலக்கி",
    meal: "Breakfast",
    type: "Non-Veg",
    description: "Soft South Indian egg kalakki",
    image: "",
    isAvailable: true,
  },

  {
    name: "Egg Appam",
    tamilName: "முட்டை ஆப்பம்",
    meal: "Breakfast",
    type: "Non-Veg",
    description: "Soft appam with egg",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Dosa",
    tamilName: "சிக்கன் தோசை",
    meal: "Breakfast",
    type: "Non-Veg",
    description: "Dosa with spicy chicken filling",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Curry",
    tamilName: "சிக்கன் கறி",
    meal: "Breakfast",
    type: "Non-Veg",
    description: "Traditional chicken curry",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mutton Curry",
    tamilName: "மட்டன் கறி",
    meal: "Breakfast",
    type: "Non-Veg",
    description: "Traditional mutton curry",
    image: "",
    isAvailable: true,
  },


  /* =======================================================
     LUNCH - VEG
     ======================================================= */

  {
    name: "South Indian Meals",
    tamilName: "சவுத் இந்தியன் மீல்ஸ்",
    meal: "Lunch",
    type: "Veg",
    description: "Complete South Indian vegetarian meals",
    image: "",
    isAvailable: true,
  },

  {
    name: "White Rice",
    tamilName: "வெள்ளை சாதம்",
    meal: "Lunch",
    type: "Veg",
    description: "Steamed white rice",
    image: "",
    isAvailable: true,
  },

  {
    name: "Sambar",
    tamilName: "சாம்பார்",
    meal: "Lunch",
    type: "Veg",
    description: "Traditional South Indian sambar",
    image: "",
    isAvailable: true,
  },

  {
    name: "Dal",
    tamilName: "தால்",
    meal: "Lunch",
    type: "Veg",
    description: "Traditional dal",
    image: "",
    isAvailable: true,
  },

  {
    name: "Dal Rasam",
    tamilName: "தால் ரசம்",
    meal: "Lunch",
    type: "Veg",
    description: "Dal based rasam",
    image: "",
    isAvailable: true,
  },

  {
    name: "Rasam",
    tamilName: "ரசம்",
    meal: "Lunch",
    type: "Veg",
    description: "Traditional South Indian rasam",
    image: "",
    isAvailable: true,
  },

  {
    name: "Vatha Kuzhambu",
    tamilName: "வத்தக்குழம்பு",
    meal: "Lunch",
    type: "Veg",
    description: "Traditional spicy vatha kuzhambu",
    image: "",
    isAvailable: true,
  },

  {
    name: "Kara Kuzhambu",
    tamilName: "காரக்குழம்பு",
    meal: "Lunch",
    type: "Veg",
    description: "Spicy South Indian kara kuzhambu",
    image: "",
    isAvailable: true,
  },

  {
    name: "Avial",
    tamilName: "அவியல்",
    meal: "Lunch",
    type: "Veg",
    description: "Mixed vegetables cooked with coconut",
    image: "",
    isAvailable: true,
  },

  {
    name: "Vegetable Kootu",
    tamilName: "காய்கறி கூட்டு",
    meal: "Lunch",
    type: "Veg",
    description: "Mixed vegetable kootu",
    image: "",
    isAvailable: true,
  },

  {
    name: "Potato Poriyal",
    tamilName: "உருளைக்கிழங்கு பொரியல்",
    meal: "Lunch",
    type: "Veg",
    description: "South Indian potato poriyal",
    image: "",
    isAvailable: true,
  },

  {
    name: "Cabbage Poriyal",
    tamilName: "முட்டைக்கோஸ் பொரியல்",
    meal: "Lunch",
    type: "Veg",
    description: "Fresh cabbage poriyal",
    image: "",
    isAvailable: true,
  },

  {
    name: "Beans Poriyal",
    tamilName: "பீன்ஸ் பொரியல்",
    meal: "Lunch",
    type: "Veg",
    description: "Fresh beans poriyal",
    image: "",
    isAvailable: true,
  },

  {
    name: "Carrot Poriyal",
    tamilName: "கேரட் பொரியல்",
    meal: "Lunch",
    type: "Veg",
    description: "Fresh carrot poriyal",
    image: "",
    isAvailable: true,
  },

  {
    name: "Cauliflower Poriyal",
    tamilName: "காலிஃப்ளவர் பொரியல்",
    meal: "Lunch",
    type: "Veg",
    description: "Cauliflower poriyal",
    image: "",
    isAvailable: true,
  },

  {
    name: "Cauliflower 65",
    tamilName: "காலிஃப்ளவர் 65",
    meal: "Lunch",
    type: "Veg",
    description: "Crispy cauliflower 65",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mushroom 65",
    tamilName: "மஷ்ரூம் 65",
    meal: "Lunch",
    type: "Veg",
    description: "Crispy mushroom 65",
    image: "",
    isAvailable: true,
  },

  {
    name: "Paneer Butter Masala",
    tamilName: "பனீர் பட்டர் மசாலா",
    meal: "Lunch",
    type: "Veg",
    description: "Creamy paneer butter masala",
    image: "",
    isAvailable: true,
  },

  {
    name: "Channa Masala",
    tamilName: "சன்னா மசாலா",
    meal: "Lunch",
    type: "Veg",
    description: "Spicy chickpea masala",
    image: "",
    isAvailable: true,
  },

  {
    name: "Rajma Masala",
    tamilName: "ராஜ்மா மசாலா",
    meal: "Lunch",
    type: "Veg",
    description: "Kidney bean masala",
    image: "",
    isAvailable: true,
  },

  {
    name: "Vegetable Biryani",
    tamilName: "வெஜிடபிள் பிரியாணி",
    meal: "Lunch",
    type: "Veg",
    description: "Aromatic vegetable biryani",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mushroom Biryani",
    tamilName: "மஷ்ரூம் பிரியாணி",
    meal: "Lunch",
    type: "Veg",
    description: "Aromatic mushroom biryani",
    image: "",
    isAvailable: true,
  },

  {
    name: "Lemon Rice",
    tamilName: "எலுமிச்சை சாதம்",
    meal: "Lunch",
    type: "Veg",
    description: "Tangy lemon rice",
    image: "",
    isAvailable: true,
  },

  {
    name: "Tomato Rice",
    tamilName: "தக்காளி சாதம்",
    meal: "Lunch",
    type: "Veg",
    description: "Flavourful tomato rice",
    image: "",
    isAvailable: true,
  },

  {
    name: "Curd Rice",
    tamilName: "தயிர் சாதம்",
    meal: "Lunch",
    type: "Veg",
    description: "Traditional curd rice",
    image: "",
    isAvailable: true,
  },

  {
    name: "Coconut Rice",
    tamilName: "தேங்காய் சாதம்",
    meal: "Lunch",
    type: "Veg",
    description: "Aromatic coconut rice",
    image: "",
    isAvailable: true,
  },

  {
    name: "Puliyodarai",
    tamilName: "புளியோதரை",
    meal: "Lunch",
    type: "Veg",
    description: "Traditional tamarind rice",
    image: "",
    isAvailable: true,
  },

  {
    name: "Appalam",
    tamilName: "அப்பளம்",
    meal: "Lunch",
    type: "Veg",
    description: "Crispy South Indian appalam",
    image: "",
    isAvailable: true,
  },

  {
    name: "Pickle",
    tamilName: "ஊறுகாய்",
    meal: "Lunch",
    type: "Veg",
    description: "Traditional Indian pickle",
    image: "",
    isAvailable: true,
  },

  {
    name: "Curds",
    tamilName: "தயிர்",
    meal: "Lunch",
    type: "Veg",
    description: "Fresh curd",
    image: "",
    isAvailable: true,
  },

  {
    name: "Buttermilk",
    tamilName: "மோர்",
    meal: "Lunch",
    type: "Veg",
    description: "Refreshing traditional buttermilk",
    image: "",
    isAvailable: true,
  },


  /* =======================================================
     LUNCH - NON VEG
     ======================================================= */

  {
    name: "Chicken Biryani",
    tamilName: "சிக்கன் பிரியாணி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Premium chicken biryani",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Dum Biryani",
    tamilName: "சிக்கன் தம் பிரியாணி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Traditional dum cooked chicken biryani",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Vadi Biryani",
    tamilName: "சிக்கன் வாடி பிரியாணி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Special chicken vadi biryani",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mutton Biryani",
    tamilName: "மட்டன் பிரியாணி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Aromatic mutton biryani",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mutton Dum Biryani",
    tamilName: "மட்டன் தம் பிரியாணி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Traditional dum cooked mutton biryani",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mutton Vadi Biryani",
    tamilName: "மட்டன் வாடி பிரியாணி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Special mutton vadi biryani",
    image: "",
    isAvailable: true,
  },

  {
    name: "Prawn Biryani",
    tamilName: "இறால் பிரியாணி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Flavourful prawn biryani",
    image: "",
    isAvailable: true,
  },

  {
    name: "Egg Biryani",
    tamilName: "முட்டை பிரியாணி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Aromatic egg biryani",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Rice",
    tamilName: "சிக்கன் ரைஸ்",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Chicken fried rice",
    image: "",
    isAvailable: true,
  },

  {
    name: "Egg Rice",
    tamilName: "முட்டை ரைஸ்",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Egg fried rice",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Noodles",
    tamilName: "சிக்கன் நூடுல்ஸ்",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Chicken noodles",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken 65",
    tamilName: "சிக்கன் 65",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Crispy spicy chicken 65",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Lollipop",
    tamilName: "சிக்கன் லாலிபாப்",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Crispy chicken lollipop",
    image: "",
    isAvailable: true,
  },

  {
    name: "Naatukozhi Varuval",
    tamilName: "நாட்டுக்கோழி வறுவல்",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Traditional country chicken fry",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Pepper Gravy",
    tamilName: "சிக்கன் பெப்பர் கிரேவி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Spicy chicken pepper gravy",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chettinad Chicken Gravy",
    tamilName: "செட்டிநாடு சிக்கன் கிரேவி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Authentic Chettinad chicken gravy",
    image: "",
    isAvailable: true,
  },

  {
    name: "Andhra Spicy Chicken Gravy",
    tamilName: "ஆந்திரா ஸ்பைசி சிக்கன் கிரேவி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Spicy Andhra style chicken gravy",
    image: "",
    isAvailable: true,
  },

  {
    name: "Butter Chicken Gravy",
    tamilName: "பட்டர் சிக்கன் கிரேவி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Creamy butter chicken gravy",
    image: "",
    isAvailable: true,
  },

  {
    name: "Country Chicken Gravy",
    tamilName: "நாட்டுக்கோழி கிரேவி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Traditional country chicken gravy",
    image: "",
    isAvailable: true,
  },

  {
    name: "Pallapalayam Chicken Gravy",
    tamilName: "பல்லபாளையம் சிக்கன் கிரேவி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Traditional Pallapalayam chicken gravy",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Gravy",
    tamilName: "சிக்கன் கிரேவி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Traditional chicken gravy",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Kurma",
    tamilName: "சிக்கன் குருமா",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Rich chicken kurma",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mutton Gravy",
    tamilName: "மட்டன் கிரேவி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Traditional mutton gravy",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chettinad Mutton Gravy",
    tamilName: "செட்டிநாடு மட்டன் கிரேவி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Authentic Chettinad mutton gravy",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mutton Pepper Gravy",
    tamilName: "மட்டன் பெப்பர் கிரேவி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Spicy mutton pepper gravy",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mutton Chukka",
    tamilName: "மட்டன் சுக்கா",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Spicy dry mutton chukka",
    image: "",
    isAvailable: true,
  },

  {
    name: "Coconut Milk Mutton Gravy",
    tamilName: "தேங்காய் பால் மட்டன் கிரேவி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Mutton gravy cooked with coconut milk",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mutton Bone Gravy",
    tamilName: "மட்டன் எலும்பு கிரேவி",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Rich mutton bone gravy",
    image: "",
    isAvailable: true,
  },

  {
    name: "Fish Fry",
    tamilName: "மீன் வறுவல்",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Crispy fish fry",
    image: "",
    isAvailable: true,
  },

  {
    name: "Fish Curry",
    tamilName: "மீன் குழம்பு",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Traditional fish curry",
    image: "",
    isAvailable: true,
  },

  {
    name: "Prawn Masala",
    tamilName: "இறால் மசாலா",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Spicy prawn masala",
    image: "",
    isAvailable: true,
  },

  {
    name: "Egg Curry",
    tamilName: "முட்டை குழம்பு",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Traditional egg curry",
    image: "",
    isAvailable: true,
  },

  {
    name: "Egg Fry",
    tamilName: "முட்டை வறுவல்",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Spicy egg fry",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mutton Kurma",
    tamilName: "மட்டன் குருமா",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Rich mutton kurma",
    image: "",
    isAvailable: true,
  },

  {
    name: "Veg Kurma",
    tamilName: "வெஜ் குருமா",
    meal: "Lunch",
    type: "Non-Veg",
    description: "Vegetable kurma",
    image: "",
    isAvailable: true,
  },


  /* =======================================================
     DINNER - VEG
     ======================================================= */

  {
    name: "Chapathi",
    tamilName: "சப்பாத்தி",
    meal: "Dinner",
    type: "Veg",
    description: "Soft wheat chapathi",
    image: "",
    isAvailable: true,
  },

  {
    name: "Parotta",
    tamilName: "பரோட்டா",
    meal: "Dinner",
    type: "Veg",
    description: "Layered South Indian parotta",
    image: "",
    isAvailable: true,
  },

  {
    name: "Bun Parotta",
    tamilName: "பன் பரோட்டா",
    meal: "Dinner",
    type: "Veg",
    description: "Soft layered bun parotta",
    image: "",
    isAvailable: true,
  },

  {
    name: "Veg Kothu Parotta",
    tamilName: "வெஜ் கொத்து பரோட்டா",
    meal: "Dinner",
    type: "Veg",
    description: "Spicy vegetable kothu parotta",
    image: "",
    isAvailable: true,
  },

  {
    name: "Dosa",
    tamilName: "தோசை",
    meal: "Dinner",
    type: "Veg",
    description: "Crispy South Indian dosa",
    image: "",
    isAvailable: true,
  },

  {
    name: "Masala Dosa",
    tamilName: "மசாலா தோசை",
    meal: "Dinner",
    type: "Veg",
    description: "Crispy dosa with potato masala",
    image: "",
    isAvailable: true,
  },

  {
    name: "Ghee Dosa",
    tamilName: "நெய் தோசை",
    meal: "Dinner",
    type: "Veg",
    description: "Crispy ghee dosa",
    image: "",
    isAvailable: true,
  },

  {
    name: "Roti",
    tamilName: "ரொட்டி",
    meal: "Dinner",
    type: "Veg",
    description: "Soft Indian roti",
    image: "",
    isAvailable: true,
  },

  {
    name: "Naan",
    tamilName: "நான்",
    meal: "Dinner",
    type: "Veg",
    description: "Soft Indian naan",
    image: "",
    isAvailable: true,
  },

  {
    name: "Butter Naan",
    tamilName: "பட்டர் நான்",
    meal: "Dinner",
    type: "Veg",
    description: "Soft naan topped with butter",
    image: "",
    isAvailable: true,
  },

  {
    name: "Kulcha",
    tamilName: "குல்சா",
    meal: "Dinner",
    type: "Veg",
    description: "Soft Indian kulcha",
    image: "",
    isAvailable: true,
  },

  {
    name: "Idly",
    tamilName: "இட்லி",
    meal: "Dinner",
    type: "Veg",
    description: "Soft steamed idly",
    image: "",
    isAvailable: true,
  },

  {
    name: "Idiyappam",
    tamilName: "இடியாப்பம்",
    meal: "Dinner",
    type: "Veg",
    description: "Traditional rice string hoppers",
    image: "",
    isAvailable: true,
  },

  {
    name: "Appam",
    tamilName: "ஆப்பம்",
    meal: "Dinner",
    type: "Veg",
    description: "Soft South Indian appam",
    image: "",
    isAvailable: true,
  },

  {
    name: "Vegetable Fried Rice",
    tamilName: "வெஜிடபிள் ஃப்ரைட் ரைஸ்",
    meal: "Dinner",
    type: "Veg",
    description: "Vegetable fried rice",
    image: "",
    isAvailable: true,
  },

  {
    name: "Gobi Fried Rice",
    tamilName: "கோபி ஃப்ரைட் ரைஸ்",
    meal: "Dinner",
    type: "Veg",
    description: "Cauliflower fried rice",
    image: "",
    isAvailable: true,
  },

  {
    name: "Paneer Fried Rice",
    tamilName: "பனீர் ஃப்ரைட் ரைஸ்",
    meal: "Dinner",
    type: "Veg",
    description: "Paneer fried rice",
    image: "",
    isAvailable: true,
  },

  {
    name: "Veg Noodles",
    tamilName: "வெஜ் நூடுல்ஸ்",
    meal: "Dinner",
    type: "Veg",
    description: "Vegetable noodles",
    image: "",
    isAvailable: true,
  },

  {
    name: "Gobi Manchurian",
    tamilName: "கோபி மஞ்சூரியன்",
    meal: "Dinner",
    type: "Veg",
    description: "Crispy cauliflower manchurian",
    image: "",
    isAvailable: true,
  },

  {
    name: "Cauliflower 65",
    tamilName: "காலிஃப்ளவர் 65",
    meal: "Dinner",
    type: "Veg",
    description: "Crispy cauliflower 65",
    image: "",
    isAvailable: true,
  },

  {
    name: "Paneer Butter Masala",
    tamilName: "பனீர் பட்டர் மசாலா",
    meal: "Dinner",
    type: "Veg",
    description: "Creamy paneer butter masala",
    image: "",
    isAvailable: true,
  },

  {
    name: "Veg Kurma",
    tamilName: "வெஜ் குருமா",
    meal: "Dinner",
    type: "Veg",
    description: "Mixed vegetable kurma",
    image: "",
    isAvailable: true,
  },

  {
    name: "Brinjal Pachadi",
    tamilName: "கத்திரிக்காய் பச்சடி",
    meal: "Dinner",
    type: "Veg",
    description: "Traditional brinjal pachadi",
    image: "",
    isAvailable: true,
  },

  {
    name: "Sambar",
    tamilName: "சாம்பார்",
    meal: "Dinner",
    type: "Veg",
    description: "Traditional South Indian sambar",
    image: "",
    isAvailable: true,
  },

  {
    name: "Vatha Kuzhambu",
    tamilName: "வத்தக்குழம்பு",
    meal: "Dinner",
    type: "Veg",
    description: "Traditional vatha kuzhambu",
    image: "",
    isAvailable: true,
  },

  {
    name: "Dal Fry",
    tamilName: "தால் ஃப்ரை",
    meal: "Dinner",
    type: "Veg",
    description: "Indian dal fry",
    image: "",
    isAvailable: true,
  },

  {
    name: "Rice",
    tamilName: "சாதம்",
    meal: "Dinner",
    type: "Veg",
    description: "Steamed white rice",
    image: "",
    isAvailable: true,
  },


  /* =======================================================
     DINNER - NON VEG
     ======================================================= */

  {
    name: "Chicken Biryani",
    tamilName: "சிக்கன் பிரியாணி",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Aromatic chicken biryani",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mutton Biryani",
    tamilName: "மட்டன் பிரியாணி",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Aromatic mutton biryani",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Rice",
    tamilName: "சிக்கன் ரைஸ்",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Chicken fried rice",
    image: "",
    isAvailable: true,
  },

  {
    name: "Egg Rice",
    tamilName: "முட்டை ரைஸ்",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Egg fried rice",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Noodles",
    tamilName: "சிக்கன் நூடுல்ஸ்",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Chicken noodles",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken 65",
    tamilName: "சிக்கன் 65",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Crispy chicken 65",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Lollipop",
    tamilName: "சிக்கன் லாலிபாப்",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Crispy chicken lollipop",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Pepper Gravy",
    tamilName: "சிக்கன் பெப்பர் கிரேவி",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Spicy chicken pepper gravy",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Gravy",
    tamilName: "சிக்கன் கிரேவி",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Traditional chicken gravy",
    image: "",
    isAvailable: true,
  },

  {
    name: "Chicken Kurma",
    tamilName: "சிக்கன் குருமா",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Rich chicken kurma",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mutton Gravy",
    tamilName: "மட்டன் கிரேவி",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Traditional mutton gravy",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mutton Kurma",
    tamilName: "மட்டன் குருமா",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Rich mutton kurma",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mutton Bone Curry",
    tamilName: "மட்டன் எலும்பு கறி",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Rich mutton bone curry",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mutton Chukka",
    tamilName: "மட்டன் சுக்கா",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Spicy dry mutton chukka",
    image: "",
    isAvailable: true,
  },

  {
    name: "Fish Curry",
    tamilName: "மீன் குழம்பு",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Traditional fish curry",
    image: "",
    isAvailable: true,
  },

  {
    name: "Fish Fry",
    tamilName: "மீன் வறுவல்",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Crispy fish fry",
    image: "",
    isAvailable: true,
  },

  {
    name: "Prawn Masala",
    tamilName: "இறால் மசாலா",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Spicy prawn masala",
    image: "",
    isAvailable: true,
  },

  {
    name: "Egg Curry",
    tamilName: "முட்டை குழம்பு",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Traditional egg curry",
    image: "",
    isAvailable: true,
  },

  {
    name: "Egg Omelette",
    tamilName: "முட்டை ஆம்லெட்",
    meal: "Dinner",
    type: "Non-Veg",
    description: "Fresh egg omelette",
    image: "",
    isAvailable: true,
  },


  /* =======================================================
     SWEETS
     ======================================================= */

  {
    name: "Gulab Jamun",
    tamilName: "குலாப் ஜாமூன்",
    meal: "Sweets",
    type: "Veg",
    description: "Soft gulab jamun soaked in sugar syrup",
    image: "",
    isAvailable: true,
  },

  {
    name: "Rasgulla",
    tamilName: "ரசகுல்லா",
    meal: "Sweets",
    type: "Veg",
    description: "Soft Bengali rasgulla",
    image: "",
    isAvailable: true,
  },

  {
    name: "Rasmalai",
    tamilName: "ரஸ்மலை",
    meal: "Sweets",
    type: "Veg",
    description: "Soft rasmalai in creamy milk",
    image: "",
    isAvailable: true,
  },

  {
    name: "Mysore Pak",
    tamilName: "மைசூர் பாக்",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional Mysore pak",
    image: "",
    isAvailable: true,
  },

  {
    name: "Badam Halwa",
    tamilName: "பாதாம் அல்வா",
    meal: "Sweets",
    type: "Veg",
    description: "Rich almond halwa",
    image: "",
    isAvailable: true,
  },

  {
    name: "Wheat Halwa",
    tamilName: "கோதுமை அல்வா",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional wheat halwa",
    image: "",
    isAvailable: true,
  },

  {
    name: "Carrot Halwa",
    tamilName: "கேரட் அல்வா",
    meal: "Sweets",
    type: "Veg",
    description: "Rich carrot halwa",
    image: "",
    isAvailable: true,
  },

  {
    name: "Kasi Halwa",
    tamilName: "காசி அல்வா",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional kasi halwa",
    image: "",
    isAvailable: true,
  },

  {
    name: "Tirunelveli Halwa",
    tamilName: "திருநெல்வேலி அல்வா",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional Tirunelveli halwa",
    image: "",
    isAvailable: true,
  },

  {
    name: "Bread Halwa",
    tamilName: "பிரெட் அல்வா",
    meal: "Sweets",
    type: "Veg",
    description: "Soft bread halwa",
    image: "",
    isAvailable: true,
  },

  {
    name: "Kesari",
    tamilName: "கேசரி",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional kesari",
    image: "",
    isAvailable: true,
  },

  {
    name: "Rava Kesari",
    tamilName: "ரவா கேசரி",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional rava kesari",
    image: "",
    isAvailable: true,
  },

  {
    name: "Pineapple Kesari",
    tamilName: "அன்னாசி கேசரி",
    meal: "Sweets",
    type: "Veg",
    description: "Flavourful pineapple kesari",
    image: "",
    isAvailable: true,
  },

  {
    name: "Paal Payasam",
    tamilName: "பால் பாயசம்",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional milk payasam",
    image: "",
    isAvailable: true,
  },

  {
    name: "Semiya Payasam",
    tamilName: "சேமியா பாயசம்",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional semiya payasam",
    image: "",
    isAvailable: true,
  },

  {
    name: "Paruppu Payasam",
    tamilName: "பருப்பு பாயசம்",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional dal payasam",
    image: "",
    isAvailable: true,
  },

  {
    name: "Jangiri",
    tamilName: "ஜாங்கிரி",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional South Indian jangiri",
    image: "",
    isAvailable: true,
  },

  {
    name: "Jalebi",
    tamilName: "ஜிலேபி",
    meal: "Sweets",
    type: "Veg",
    description: "Crispy jalebi soaked in sugar syrup",
    image: "",
    isAvailable: true,
  },

  {
    name: "Laddu",
    tamilName: "லட்டு",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional laddu",
    image: "",
    isAvailable: true,
  },

  {
    name: "Boondi Laddu",
    tamilName: "பூந்தி லட்டு",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional boondi laddu",
    image: "",
    isAvailable: true,
  },

  {
    name: "Motichoor Laddu",
    tamilName: "மோதிச்சூர் லட்டு",
    meal: "Sweets",
    type: "Veg",
    description: "Soft motichoor laddu",
    image: "",
    isAvailable: true,
  },

  {
    name: "Coconut Burfi",
    tamilName: "தேங்காய் பர்ஃபி",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional coconut burfi",
    image: "",
    isAvailable: true,
  },

  {
    name: "Milk Peda",
    tamilName: "பால் பேடா",
    meal: "Sweets",
    type: "Veg",
    description: "Soft milk peda",
    image: "",
    isAvailable: true,
  },

  {
    name: "Badusha",
    tamilName: "பாதுஷா",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional badusha",
    image: "",
    isAvailable: true,
  },

  {
    name: "Poli",
    tamilName: "போளி",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional sweet poli",
    image: "",
    isAvailable: true,
  },

  {
    name: "Sweet Pongal",
    tamilName: "சக்கரை பொங்கல்",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional sweet pongal",
    image: "",
    isAvailable: true,
  },

  {
    name: "Sweet Appam",
    tamilName: "ஸ்வீட் ஆப்பம்",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional sweet appam",
    image: "",
    isAvailable: true,
  },

  {
    name: "Moong Dal Payasam",
    tamilName: "பாசிப்பருப்பு பாயசம்",
    meal: "Sweets",
    type: "Veg",
    description: "Traditional moong dal payasam",
    image: "",
    isAvailable: true,
  },
];


const seedFoods = async () => {
  try {
    await connectDB();

    let inserted = 0;
    let skipped = 0;

    for (const item of tamilNaduFoods) {
      const existing = await Food.findOne({ name: item.name });

      if (existing) {
        skipped++;
        continue;
      }

      await Food.create({
        ...item,
        description: "Traditional Tamil Nadu catering menu item",
        price: 0,
        image: "",
        // Owner must set the actual price and enable the item.
        available: false,
      });

      inserted++;
    }

    console.log("Tamil Nadu food catalogue seeding completed.");
    console.log(`New foods added: ${inserted}`);
    console.log(`Existing foods skipped: ${skipped}`);
    console.log("New foods are disabled until the owner sets their prices.");

    await mongoose.disconnect();
    process.exitCode = 0;
  } catch (error) {
    console.error("Food catalogue seeding failed:", error.message);

    try {
      await mongoose.disconnect();
    } catch {}

    process.exitCode = 1;
  }
};

seedFoods();
