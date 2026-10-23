import 'package:flutter/widgets.dart';

/// Responsive scaling utility.
/// Scales values relative to a 1440×900 design baseline.
///
/// Usage:
/// ```dart
/// final scale = AppScale.of(context);
/// double size = scale.w(200); // 200 logical px at 1440px wide
/// ```
class AppScale {
  final double _width;
  final double _height;

  const AppScale._({required double width, required double height})
      : _width = width,
        _height = height;

  static AppScale of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return AppScale._(width: size.width, height: size.height);
  }

  /// Scale [value] relative to a 1440 px design width.
  double w(double value) => value * (_width / 1440);

  /// Scale [value] relative to a 900 px design height.
  double h(double value) => value * (_height / 900);

  /// Scale font size, clamped to ±40% of the design size.
  double sp(double value) => value * (_width / 1440).clamp(0.8, 1.4);
}
