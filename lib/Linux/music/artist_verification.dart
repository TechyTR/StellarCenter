class StellarArtistVerification {
  StellarArtistVerification._();

  static final StellarArtistVerification instance =
      StellarArtistVerification._();

  final Set<String> _verifiedArtists =
      <String>{};

  bool isVerified(String artist) {
    final normalized = _normalize(artist);

    if (normalized.isEmpty) {
      return false;
    }

    return _verifiedArtists.contains(
      normalized,
    );
  }

  void setVerified(
    String artist,
    bool verified,
  ) {
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

  void addVerifiedArtist(String artist) {
    setVerified(
      artist,
      true,
    );
  }

  void removeVerifiedArtist(String artist) {
    setVerified(
      artist,
      false,
    );
  }

  Set<String> get verifiedArtists {
    return Set<String>.unmodifiable(
      _verifiedArtists,
    );
  }

  String _normalize(String value) {
    return value
        .replaceAll('\u0000', '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
  }
}
