class TotpUtils {
  static String generateTOTP(String secret, {int interval = 2000}) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / interval).floor();
    final combined = "$secret-$timestamp";
    
    int hash = 0;
    for (int i = 0; i < combined.length; i++) {
      final char = combined.codeUnitAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; 
    }
    
    return hash.abs().toRadixString(16).padLeft(8, '0').toUpperCase();
  }
}
