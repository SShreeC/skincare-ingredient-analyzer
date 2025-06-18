# 🌿 Skincare Ingredient Analyzer App (Flutter)

A smart Flutter-based mobile application that helps users analyze the ingredients of skincare products by simply scanning the product label or typing in the ingredient list. The app provides real-time insights about harmful, beneficial, or neutral ingredients based on dermatological research and user preferences.


## 🚀 Features

| Feature | Description |
|--------|-------------|
| 🔍 **Ingredient Scanning** | Scan product labels using your phone camera or upload an image. |
| ✏️ **Manual Input** | Paste or type the full list of ingredients if scanning is not feasible. |
| 💡 **Ingredient Analysis** | Get categorized results: **Safe**, **Moderate**, or **Avoid** based on dermatology datasets. |
| 📚 **Ingredient Dictionary** | In-app glossary for ingredient definitions, common names, and known effects. |
| 🧬 **Allergen Detection** | Flags potential allergens based on user preferences (optional). |
| 📊 **Clean Beauty Score** | Each product receives a score (0-10) based on its formulation. |
| 🧑‍🔬 **Backend LLM Support** | Integrates with AI models to explain ingredients in layman's terms. |
| 🌙 **Dark Mode** | UI adapts to light/dark theme preferences. |
| 💾 **Local Storage** | Recently scanned products and results stored locally. |

---

## 🧠 How It Works

1. **User scans or enters ingredients**
2. **App extracts and parses the text**
3. **Compares with a dermatological ingredient dataset**
4. **Flags harmful ingredients and displays safety level**
5. **Sends input to an LLM or API for plain-language explanation**

---

## 💻 Tech Stack

| Layer         | Tools Used                               |
|--------------|-------------------------------------------|
| **Frontend**  | Flutter (Dart)                           |
| **OCR**       | Google ML Kit       |
| **State Mgmt**| Provider |
| **Database**  | LocalStorage            |
| **API/AI**    | Gemini / GPT API (for advanced analysis) |

---

## 🧪 Sample Use Case

> **User** scans the label of a product containing:
Water, Glycerin, Butylene Glycol, Fragrance, Parabens

yaml
Copy
Edit

> **Output**:
- ✅ *Water, Glycerin* — **Safe**
- ⚠️ *Butylene Glycol* — **Moderate**
- ⚠️ *Fragrance* — **Possible Irritant**
- ❌ *Parabens* — **Avoid (Preservative linked to hormonal disruption)**

---


## 🧩 Future Enhancements

- 📱 Barcode scanning support (for quicker product lookup)
- 🌍 Multi-language ingredient detection
- 🔗 API integration with CosDNA or INCI Beauty databases
- 👥 User accounts for saving favorite/flagged ingredients
- 🧠 Ingredient substitution suggestions

---

## 🚧 Known Limitations

- Not all ingredient names are standardized (may need normalization)
- OCR accuracy can vary based on label clarity
- Clean Beauty Score is an internal metric and not medically certified

---
### Env variables
GEMINI_API_KEY
GEMINI_BASE_URL

## 🔧 Installation

```bash
git clone https://github.com/SShreeC/skincare-analyzer-app.git
cd skincare-analyzer-app
flutter pub get
flutter run

