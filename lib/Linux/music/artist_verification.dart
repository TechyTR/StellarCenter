class StellarArtistVerification {
  StellarArtistVerification._();

  static final StellarArtistVerification instance =
      StellarArtistVerification._();

  /*
   * Buraya doğrulanmış sanatçıları ekle.
   *
   * Örnek:
   *
   * static const Set<String> defaultVerifiedArtists = {
   *   'Sanatçı Adı',
   * };
   *
   * Şu an boş bırakılmıştır çünkü bir sanatçıyı
   * otomatik olarak gerçek/doğrulanmış kabul etmek
   * doğru olmaz.
   */
  static const Set<String> defaultVerifiedArtists = {};

  final Set<String> _verifiedArtists =
      <String>{};

  bool _initialized = false;

  void _ensureInitialized() {
    if (_initialized) {
      return;
    }

    _initialized = true;

    _verifiedArtists.addAll(
      defaultVerifiedArtists.map(_normalize),
    );
  }

  bool isVerified(String artist) {
    _ensureInitialized();

    final normalized = _normalize(artist);

    if (normalized.isEmpty) {
      return false;
    }

    return _verifiedArtists.contains(normalized);
  }

  void setVerified(
    String artist,
    bool verified,
  ) {
    _ensureInitialized();

    final normalized = _normalize(artist);

    if (normalized.isEmpty) {
      return;
    }

    if (verified) {
      _verifiedArtists.add(normalized);
    } else {
      _verifiedArtists.remove(normalized);
    }
  }

  void setVerifiedArtists(
    Iterable<String> artists,
  ) {
    _ensureInitialized();

    _verifiedArtists
      ..clear()
      ..addAll(
        artists
            .map(_normalize)
            .where(
              (artist) => artist.isNotEmpty,
            ),
      );
  }

  void addVerifiedArtist(
    String artist,
  ) {
    setVerified(
      artist,
      true,
    );
  }

  void removeVerifiedArtist(
    String artist,
  ) {
    setVerified(
      artist,
      false,
    );
  }

  Set<String> get verifiedArtists {
    _ensureInitialized();

    return Set<String>.unmodifiable(
      _verifiedArtists,
    );
  }

  void clear() {
    _ensureInitialized();
    _verifiedArtists.clear();
  }

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
