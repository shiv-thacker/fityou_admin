/// Cloudinary account configuration for unsigned, client-side uploads.
///
/// ⚠️ Double-check these two values against your Cloudinary dashboard:
///   • [cloudName]     → Dashboard → "Cloud name" (NOT the "c-xxxxxxxx"
///                       product-environment / account ID string).
///   • [uploadPreset]  → Settings → Upload → Upload presets. The preset
///                       MUST have Signing Mode = "Unsigned", since this
///                       admin panel uploads directly from the browser
///                       without a backend to sign the request.
///
/// If your unsigned preset has a fixed "Folder" configured in Cloudinary,
/// it will override whatever [folder] is passed at upload time — either
/// leave the preset's folder empty, or create one unsigned preset per
/// folder (e.g. `fityou_outfits`, `fityou_models`, `fityou_products`).
abstract final class CloudinaryConfig {
  static const String cloudName = 'dgazvpfty';

  /// Unsigned upload preset used for all admin-panel uploads.
  static const String uploadPreset = 'fityou_models';

  /// Cloudinary folder names — keep these in sync with the folders you see
  /// in the Media Library (Home → models / outfits / products).
  static const String outfitsFolder  = 'outfits';
  static const String modelsFolder   = 'models';
  static const String productsFolder = 'products';

  static String uploadUrl({String resourceType = 'image'}) =>
      'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload';
}
