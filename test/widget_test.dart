import 'package:bus_booking/booking_store.dart';
import 'package:bus_booking/seat_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('change is paid out in the biggest notes first', () {
    expect(changeNotes(7000), {5000: 1, 2000: 1});
    expect(changeNotes(0), <int, int>{});
  });

  test('cash must be at least the price and a multiple of 100', () {
    expect(checkCash(2500), isNotNull);
    expect(checkCash(3050), isNotNull);
    expect(checkCash(3000), isNull);
    expect(checkCash(10000), isNull);
  });

  test('priority passengers go ahead of ordinary ones, behind earlier priority', () {
    final waitlist = <Passenger>[];
    joinWaitlist(waitlist, const Passenger('A'));
    joinWaitlist(waitlist, const Passenger('B'));
    joinWaitlist(waitlist, const Passenger('P1', priority: true));
    joinWaitlist(waitlist, const Passenger('P2', priority: true));
    expect(waitlist.map((p) => p.name), ['P1', 'P2', 'A', 'B']);
  });

  test('cancelling moves the first waiting passenger into the seat', () {
    final seat = Seat(4, 'Old');
    final waitlist = [const Passenger('Frank')];
    final message = cancelBooking(seat, waitlist);
    expect(seat.passenger, 'Frank');
    expect(message, 'Frank moved into seat 4');
    expect(waitlist, isEmpty);
  });

  test('money is formatted with thousands separators', () {
    expect(rwf(36000), '36,000');
    expect(rwf(100), '100');
  });

  testWidgets('seat map shows seats sold and money made', (tester) async {
    final seats = [
      for (var number = 1; number <= 12; number++)
        Seat(
          number,
          switch (number) {
            1 => 'Uluat',
            3 => 'Keza',
            6 => 'Jo',
            _ => null,
          },
        ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: SeatMapView(seats: seats, onSeat: (_) {}, onWaitlist: () {}),
      ),
    );
    expect(find.text('3 seats sold · 9,000 RWF'), findsOneWidget);
  });
}