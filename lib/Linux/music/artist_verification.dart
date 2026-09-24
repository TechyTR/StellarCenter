class StellarArtistVerification {
  StellarArtistVerification._();

  static final StellarArtistVerification instance =
      StellarArtistVerification._();

  final Set<String> _verifiedArtists = <String>{};

  bool isVerified(String artist) {
    return _verifiedArtists.contains(_normalize(artist));
  }

  void setVerified(
    String artist,
    bool verified,
  ) {
    final normalized = _normalize(artist);

    if (normalized.isEmpty) return;

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
            .where((artist) => artist.isNotEmpty),
      );
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}
