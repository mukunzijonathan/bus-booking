import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/waiting.dart';

class WaitlistRepository {
  WaitlistRepository(this.uid);

  final String uid;

  CollectionReference<Map<String, dynamic>> get _waitlist => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('waitlist');

  Stream<List<Waiting>> watchAll() {
    return _waitlist.snapshots().map(
      (snap) => snap.docs.map(Waiting.fromDoc).toList(),
    );
  }

  Future<void> add({required String name, required bool priority}) {
    return _waitlist.add({
      'name': name,
      'priority': priority,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String id) => _waitlist.doc(id).delete();
}
