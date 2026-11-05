const price = 3000;
const noteValues = [5000, 2000, 1000, 500, 100];

String rwf(int amount) =>
    amount.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');

String? checkCash(int? cash) {
  if (cash == null) return 'Enter a whole amount';
  if (cash < price) return 'Cash must be at least ${rwf(price)} RWF';
  if (cash % 100 != 0) return 'Cash must be a multiple of 100 RWF';
  return null;
}

Map<int, int> changeNotes(int change) {
  final result = <int, int>{};
  var left = change;
  for (final note in noteValues) {
    final count = left ~/ note;
    if (count > 0) {
      result[note] = count;
      left -= count * note;
    }
  }
  return result;
}

String changeLine(int change) {
  final notes = changeNotes(change);
  if (notes.isEmpty) return 'No change';
  return notes.entries.map((e) => '${rwf(e.key)} × ${e.value}').join(' · ');
}
