import 'package:bus_booking/models/waiting.dart';
import 'package:bus_booking/screens/seat_map_screen.dart';
import 'package:bus_booking/utils/money.dart';
import 'package:bus_booking/utils/rules.dart';
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

  test(
    'priority passengers go ahead of ordinary ones, behind earlier priority',
    () {
      final waitlist = <Passenger>[];
      joinWaitlist(waitlist, const Passenger('A'));
      joinWaitlist(waitlist, const Passenger('B'));
      joinWaitlist(waitlist, const Passenger('P1', priority: true));
      joinWaitlist(waitlist, const Passenger('P2', priority: true));
      expect(waitlist.map((p) => p.name), ['P1', 'P2', 'A', 'B']);
    },
  );

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

  test('priority waiters come first, then earlier join time', () {
    final people = [
      Waiting(
        id: '1',
        name: 'Late',
        priority: false,
        joinedAt: DateTime(2026, 1, 2),
      ),
      Waiting(
        id: '2',
        name: 'Early',
        priority: false,
        joinedAt: DateTime(2026, 1, 1),
      ),
      Waiting(
        id: '3',
        name: 'Priority late',
        priority: true,
        joinedAt: DateTime(2026, 1, 3),
      ),
      const Waiting(id: '4', name: 'No time', priority: false),
    ];
    expect(sortedWaitlist(people).map((person) => person.name), [
      'Priority late',
      'Early',
      'Late',
      'No time',
    ]);
  });

  testWidgets('seat map shows seats sold and money made', (tester) async {
    final seats = [
      for (var number = 1; number <= 12; number++)
        Seat(number, switch (number) {
          1 => 'Uluat',
          3 => 'Keza',
          6 => 'Jo',
          _ => null,
        }),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SeatMapBody(
            seats: seats,
            sold: 3,
            money: 9000,
            seatsLeft: 9,
            filter: 'all',
            showEmptyFilter: false,
            onFilter: (_) {},
            onSeat: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('3 seats sold · 9,000 RWF'), findsOneWidget);
    expect(find.text('9 seats left'), findsOneWidget);
  });

  testWidgets('a filter with no matches says so', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SeatMapBody(
            seats: const [],
            sold: 3,
            money: 9000,
            seatsLeft: 9,
            filter: 'free',
            showEmptyFilter: true,
            onFilter: (_) {},
            onSeat: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('Nothing matches this filter.'), findsOneWidget);
    expect(find.text('3 seats sold · 9,000 RWF'), findsOneWidget);
  });
}
