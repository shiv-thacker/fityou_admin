/// App-wide non-design constants.
abstract final class AppConstants {
  static const String appName     = 'Fashion Admin';
  static const String appSubtitle = 'Management Panel';

  // ── Outfit limits ────────────────────────────────────────────────────────
  static const int maxOutfitImages = 3;
  static const int maxOutfitLinks  = 20;

  // ── Outfit dropdown options ───────────────────────────────────────────────
  static const List<String> outfitSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  /// 4 Indian skin tone tiers used for model persona matching.
  static const List<String> skinTones = [
    'Fair',      // Arjun / Priya   — Fitzpatrick II
    'Wheatish',  // Rohan / Neha    — Fitzpatrick III  (most common in India)
    'Dusky',     // Vikram / Shreya — Fitzpatrick IV-V
    'Dark',      // Karan / Anjali  — Fitzpatrick V-VI
  ];
  static const List<String> genders    = ['Male', 'Female', 'Unisex'];
  static const List<String> categories = [
    'Casual', 'Formal', 'Sportswear', 'Streetwear',
    'Ethnic', 'Party', 'Beach', 'Winter', 'Summer', 'Other',
  ];
}
