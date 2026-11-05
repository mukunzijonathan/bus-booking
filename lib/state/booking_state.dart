import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../models/waiting.dart';
import '../repositories/booking_repository.dart';
import '../repositories/photo_repository.dart';
import '../repositories/waitlist_repository.dart';
import '../utils/money.dart';
import '../utils/rules.dart';

class BookingState extends ChangeNotifier {
  BookingState(this._bookingsRepo, this._waitlistRepo, this._photos) {
    _bookingSub = _bookingsRepo.watchAll().listen(
      (list) {
        _bookings = list;
        _bookingsReady = true;
        _error = null;
        notifyListeners();
      },
      onError: (Object _) {
        _bookingsReady = true;
        _error = 'Could not load your bookings.';
        notifyListeners();
      },
    );
    _waitSub = _waitlistRepo.watchAll().listen(
      (list) {
        _waitlist = sortedWaitlist(list);
        _waitReady = true;
        notifyListeners();
      },
      onError: (Object _) {
        _waitReady = true;
        _error = 'Could not load the waitlist.';
        notifyListeners();
      },
    );
  }

  final BookingRepository _bookingsRepo;
  final WaitlistRepository _waitlistRepo;
  final PhotoRepository _photos;

  StreamSubscription<List<Booking>>? _bookingSub;
  StreamSubscription<List<Waiting>>? _waitSub;

  List<Booking> _bookings = [];
  List<Waiting> _waitlist = [];
  bool _bookingsReady = false;
  bool _waitReady = false;
  String? _error;
  String _filter = 'all';

  List<Booking> get bookings => _bookings;
  List<Waiting> get waitlist => _waitlist;
  bool get loading => !_bookingsReady || !_waitReady;
  String? get error => _error;
  String get filter => _filter;

  int get seatsSold => _bookings.length;
  int get moneyMade => seatsSold * price;
  int get seatsLeft => 12 - seatsSold;
  bool get full => seatsSold >= 12;

  List<Seat> get seats {
    final bySeat = {for (final booking in _bookings) booking.seat: booking};
    return [
      for (var number = 1; number <= 12; number++)
        Seat(
          number,
          bySeat[number]?.name,
          bySeat[number]?.cash,
          bySeat[number]?.photoUrl,
        ),
    ];
  }

  List<Seat> get visible {
    if (_filter == 'free') return seats.where((seat) => !seat.taken).toList();
    if (_filter == 'taken') return seats.where((seat) => seat.taken).toList();
    return seats;
  }

  Booking? bookingFor(int seat) {
    for (final booking in _bookings) {
      if (booking.seat == seat) return booking;
    }
    return null;
  }

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  Future<String> uploadPhoto(File photo) => _photos.upload(photo);

  Future<void> book({
    required int seat,
    required String name,
    required int cash,
    String? photoUrl,
  }) async {
    final taken = [
      ..._bookings.map((booking) => booking.name),
      ..._waitlist.map((person) => person.name),
    ];
    final nameError = checkName(name, taken);
    if (nameError != null) throw Exception(nameError);
    if (_bookings.any((booking) => booking.seat == seat)) {
      throw Exception('That seat was just booked');
    }
    await _bookingsRepo.setBooking(
      Booking(seat: seat, name: name, cash: cash, photoUrl: photoUrl),
    );
  }

  Future<String> cancel(int seat) async {
    final current = bookingFor(seat);
    if (current == null) return 'That seat is already free';
    await _bookingsRepo.delete(seat);
    if (_waitlist.isEmpty) return '${current.name} cancelled';
    final next = _waitlist.first;
    await _bookingsRepo.setBooking(
      Booking(seat: seat, name: next.name, cash: price),
    );
    await _waitlistRepo.delete(next.id);
    return '${next.name} moved into seat $seat';
  }

  Future<void> replacePhoto(Booking booking, File photo) async {
    final photoUrl = await _photos.upload(photo);
    await _bookingsRepo.setBooking(
      Booking(
        seat: booking.seat,
        name: booking.name,
        cash: booking.cash,
        photoUrl: photoUrl,
      ),
    );
  }

  Future<void> joinWaitlist({
    required String name,
    required bool priority,
  }) async {
    if (!full) {
      throw Exception('Seats are still free. Book one from the seat map.');
    }
    final taken = [
      ..._bookings.map((booking) => booking.name),
      ..._waitlist.map((person) => person.name),
    ];
    final nameError = checkName(name, taken);
    if (nameError != null) throw Exception(nameError);
    await _waitlistRepo.add(name: name, priority: priority);
  }

  @override
  void dispose() {
    _bookingSub?.cancel();
    _waitSub?.cancel();
    super.dispose();
  }
}
