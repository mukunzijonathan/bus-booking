/// Ephemeral helpers and the in-memory rules from Session 4.
/// The live app keeps bookings in [BookingState], not in these lists.
class Seat {
  Seat(this.number, [this.passenger, this.cash, this.photoUrl]);

  final int number;
  String? passenger;
  final int? cash;
  final String? photoUrl;

  bool get taken => passenger != null;
}

class Passenger {
  const Passenger(this.name, {this.priority = false});

  final String name;
  final bool priority;
}

String? checkName(String raw, Iterable<String> taken) {
  final name = raw.trim();
  if (name.isEmpty) return 'Name cannot be empty';
  if (taken.any((t) => t.toLowerCase() == name.toLowerCase())) {
    return '$name is already booked';
  }
  return null;
}

/// Priority passengers sit ahead of ordinary ones, behind earlier priority
/// passengers.
void joinWaitlist(List<Passenger> waitlist, Passenger passenger) {
  if (passenger.priority) {
    final ahead = waitlist.where((p) => p.priority).length;
    waitlist.insert(ahead, passenger);
  } else {
    waitlist.add(passenger);
  }
}

/// Frees the seat, then moves the first waiting passenger into it.
String? cancelBooking(Seat seat, List<Passenger> waitlist) {
  seat.passenger = null;
  if (waitlist.isEmpty) return null;
  final next = waitlist.removeAt(0);
  seat.passenger = next.name;
  return '${next.name} moved into seat ${seat.number}';
}
