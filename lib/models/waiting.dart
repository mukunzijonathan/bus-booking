import 'package:cloud_firestore/cloud_firestore.dart';

class Waiting {
  const Waiting({
    required this.id,
    required this.name,
    required this.priority,
    this.joinedAt,
  });

  final String id;
  final String name;
  final bool priority;
  final DateTime? joinedAt;

  factory Waiting.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Waiting(
      id: doc.id,
      name: data['name'] as String,
      priority: data['priority'] as bool? ?? false,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate(),
    );
  }
}

List<Waiting> sortedWaitlist(Iterable<Waiting> people) {
  final list = people.toList();
  list.sort((a, b) {
    if (a.priority != b.priority) return a.priority ? -1 : 1;
    if (a.joinedAt == null && b.joinedAt == null) return 0;
    if (a.joinedAt == null) return 1;
    if (b.joinedAt == null) return -1;
    return a.joinedAt!.compareTo(b.joinedAt!);
  });
  return list;
}
