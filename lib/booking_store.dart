import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const wine = Color(0xFF6E2438);
const wineDeep = Color(0xFF3B1220);
const gold = Color(0xFFC4A265);
const cream = Color(0xFFF6F0E8);
const blush = Color(0xFFF8EBE7);
const stone = Color(0xFFE4D2CC);
const price = 3000;
const noteValues = [5000, 2000, 1000, 500, 100];

// ---------- Models ----------

class Seat {
  Seat(this.number, [this.passenger, this.cash]);

  final int number;
  String? passenger;
  final int? cash;

  bool get taken => passenger != null;
}

class Passenger {
  const Passenger(this.name, {this.priority = false});

  final String name;
  final bool priority;
}

class Booking {
  const Booking({required this.seat, required this.name, required this.cash});

  final int seat;
  final String name;
  final int cash;

  Map<String, dynamic> toMap() => {
        'seat': seat,
        'name': name,
        'cash': cash,
      };

  factory Booking.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Booking(
      seat: (data['seat'] as num).toInt(),
      name: data['name'] as String,
      cash: (data['cash'] as num).toInt(),
    );
  }
}

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

// ---------- Rules (no widgets here) ----------

String rwf(int amount) =>
    amount.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');

String? checkName(String raw, Iterable<String> taken) {
  final name = raw.trim();
  if (name.isEmpty) return 'Name cannot be empty';
  if (taken.any((t) => t.toLowerCase() == name.toLowerCase())) {
    return '$name is already booked';
  }
  return null;
}

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

/// Priority passengers sit ahead of ordinary ones, behind earlier priority
/// passengers. The list is kept in that order, so the insert index is the
/// number of priority passengers already waiting.
void joinWaitlist(List<Passenger> waitlist, Passenger passenger) {
  if (passenger.priority) {
    final ahead = waitlist.where((p) => p.priority).length;
    waitlist.insert(ahead, passenger);
  } else {
    waitlist.add(passenger);
  }
}

/// Frees the seat, then moves the first waiting passenger into it.
/// Returns the message to show, or null if nobody was waiting.
String? cancelBooking(Seat seat, List<Passenger> waitlist) {
  seat.passenger = null;
  if (waitlist.isEmpty) return null;
  final next = waitlist.removeAt(0);
  seat.passenger = next.name;
  return '${next.name} moved into seat ${seat.number}';
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

List<Seat> seatsFromBookings(List<Booking> bookings) {
  final bySeat = {for (final booking in bookings) booking.seat: booking};
  return [
    for (var number = 1; number <= 12; number++)
      Seat(number, bySeat[number]?.name, bySeat[number]?.cash),
  ];
}

/// The signed-in user's bookings: users/{uid}/bookings
CollectionReference<Map<String, dynamic>> myBookings() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('bookings');
}

/// The signed-in user's waitlist: users/{uid}/waitlist
CollectionReference<Map<String, dynamic>> myWaitlist() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('waitlist');
}

/// Sample seats, written once when a new account is created.
Future<void> addSampleBookings() async {
  final samples = [
    const Booking(seat: 1, name: 'Uluat', cash: 5000),
    const Booking(seat: 3, name: 'Keza', cash: 10000),
    const Booking(seat: 6, name: 'Jo', cash: 3000),
  ];
  final batch = FirebaseFirestore.instance.batch();
  for (final booking in samples) {
    batch.set(myBookings().doc('${booking.seat}'), booking.toMap());
  }
  await batch.commit();
}
