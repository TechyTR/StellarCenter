class StellarAnimationConfig {
  StellarAnimationConfig._();

  // Akıllı tahta için kısa ve hafif animasyonlar.
  static const Duration pageTransition =
      Duration(milliseconds: 280);

  static const Duration navigation =
      Duration(milliseconds: 220);

  static const Duration card =
      Duration(milliseconds: 240);

  static const Duration button =
      Duration(milliseconds: 120);

  static const Duration music =
      Duration(milliseconds: 260);

  static const Duration lyrics =
      Duration(milliseconds: 220);

  static const double pageOffset = 0.035;

  static const double cardOffset = 0.025;

  static const double pressedScale = 0.965;
}
