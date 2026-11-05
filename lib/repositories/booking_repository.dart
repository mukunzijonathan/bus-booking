import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking.dart';

class BookingRepository {
  BookingRepository(this.uid);

  final String uid;

  CollectionReference<Map<String, dynamic>> get _bookings => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('bookings');

  Stream<List<Booking>> watchAll() {
    return _bookings.snapshots().map(
      (snap) => snap.docs.map(Booking.fromDoc).toList(),
    );
  }

  Future<void> setBooking(Booking booking) {
    return _bookings.doc('${booking.seat}').set(booking.toMap());
  }

  Future<void> delete(int seat) => _bookings.doc('$seat').delete();

  Future<void> addSamples() async {
    final samples = [
      const Booking(seat: 1, name: 'Uluat', cash: 5000),
      const Booking(seat: 3, name: 'Keza', cash: 10000),
      const Booking(seat: 6, name: 'Jo', cash: 3000),
    ];
    final batch = FirebaseFirestore.instance.batch();
    for (final booking in samples) {
      batch.set(_bookings.doc('${booking.seat}'), booking.toMap());
    }
    await batch.commit();
  }
}
