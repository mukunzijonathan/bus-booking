import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  const Booking({
    this.id = '',
    required this.seat,
    required this.name,
    required this.cash,
    this.photoUrl,
  });

  final String id;
  final int seat;
  final String name;
  final int cash;
  final String? photoUrl;

  Map<String, dynamic> toMap() => {
    'seat': seat,
    'name': name,
    'cash': cash,
    'photoUrl': photoUrl,
  };

  factory Booking.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Booking(
      id: doc.id,
      seat: (data['seat'] as num).toInt(),
      name: data['name'] as String,
      cash: (data['cash'] as num).toInt(),
      photoUrl: data['photoUrl'] as String?,
    );
  }
}
