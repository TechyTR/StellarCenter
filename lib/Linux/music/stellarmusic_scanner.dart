class StellarArtistVerification {
  StellarArtistVerification._();

  static final StellarArtistVerification instance =
      StellarArtistVerification._();

  static const Set<String> _verifiedArtists = {
    'stellar center',
  };

  bool isVerified(String artist) {
    final normalized = artist.trim().toLowerCase();

    if (normalized.isEmpty) {
      return false;
    }

    return _verifiedArtists.contains(
      normalized,
    );
  }
}
