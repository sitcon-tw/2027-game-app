/// Seeded NTAG identifiers for explicitly enabled test gameplay only.
/// This file does not depend on a game implementation or admin API.
abstract final class TestTagIds {
  static const selfUid = '04A1B2C3D4E5F6';
  static const unknownUid = '04F00000000001';
  static String playerUid(int index) => _fixtureUid('B', index, 18);
  static String checkpointUid(int number) => _fixtureUid('C', number, 42);
  static String boothUid(int number) => _fixtureUid('D', number, 3);
  static String stationUid(int number) => _fixtureUid('E', number, 4);

  static String _fixtureUid(String type, int number, int max) {
    if (number < 1 || number > max) throw RangeError.range(number, 1, max);
    return '04${type}000000000${number.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }
}
