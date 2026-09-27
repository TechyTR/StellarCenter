class StellarArtistVerification {
  StellarArtistVerification._();

  static final StellarArtistVerification instance =
      StellarArtistVerification._();

  /// Sanatçı adı gerçekten bulunmuşsa mavi tik gösterilir.
  ///
  /// Örneğin:
  /// - "Tarkan" -> mavi tik
  /// - "Barış Manço" -> mavi tik
  /// - "Bilinmeyen Sanatçı" -> mavi tik yok
  /// - boş sanatçı adı -> mavi tik yok
  ///
  /// Böylece manuel sanatçı listesi tutmaya gerek kalmaz.
  bool isVerified(String artist) {
    final normalized = _normalize(artist);

    if (normalized.isEmpty) {
      return false;
    }

    const unknownArtists = <String>{
      'bilinmeyen sanatçı',
      'bilinmeyen sanatci',
      'unknown artist',
      'unknown',
      'artist',
    };

    return !unknownArtists.contains(normalized);
  }

  /// Eski API ile uyumluluk için tutuldu.
  /// Artık manuel doğrulama listesi kullanılmıyor.
  void setVerified(
    String artist,
    bool verified,
  ) {}

  /// Eski API ile uyumluluk için tutuldu.
  void setVerifiedArtists(
    Iterable<String> artists,
  ) {}

  /// Eski API ile uyumluluk için tutuldu.
  void addVerifiedArtist(
    String artist,
  ) {}

  /// Eski API ile uyumluluk için tutuldu.
  void removeVerifiedArtist(
    String artist,
  ) {}

  /// Artık manuel liste kullanılmadığı için boş döner.
  Set<String> get verifiedArtists {
    return const <String>{};
  }

  /// Eski API ile uyumluluk için tutuldu.
  void clear() {}

  String _normalize(String value) {
    return value
        .replaceAll('\u0000', '')
        .trim()
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        )
        .toLowerCase();
  }
}
