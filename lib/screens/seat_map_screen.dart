import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/booking_state.dart';
import '../utils/colors.dart';
import '../utils/money.dart';
import '../utils/rules.dart';
import 'booking_details_screen.dart';
import 'booking_form_screen.dart';
import 'waitlist_screen.dart';

class SeatMapScreen extends StatelessWidget {
  const SeatMapScreen({super.key});

  void _open(BuildContext context, Seat seat) {
    final booking = context.read<BookingState>();
    final page = seat.taken
        ? BookingDetailsScreen(seat: seat.number)
        : BookingFormScreen(seat: seat.number);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<BookingState>.value(
          value: booking,
          child: page,
        ),
      ),
    );
  }

  void _openWaitlist(BuildContext context) {
    final booking = context.read<BookingState>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<BookingState>.value(
          value: booking,
          child: const WaitlistScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Huye'),
        actions: [
          IconButton(
            tooltip: 'Waitlist',
            icon: const Icon(Icons.groups),
            onPressed: () => _openWaitlist(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: booking.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(booking.error!, textAlign: TextAlign.center),
              ),
            )
          : booking.loading
          ? const Center(child: CircularProgressIndicator())
          : SeatMapBody(
              seats: booking.visible,
              sold: booking.seatsSold,
              money: booking.moneyMade,
              seatsLeft: booking.seatsLeft,
              filter: booking.filter,
              showEmptyFilter:
                  booking.filter != 'all' && booking.visible.isEmpty,
              onFilter: (value) =>
                  context.read<BookingState>().setFilter(value),
              onSeat: (seat) => _open(context, seat),
            ),
    );
  }
}

class SeatMapBody extends StatelessWidget {
  const SeatMapBody({
    super.key,
    required this.seats,
    required this.sold,
    required this.money,
    required this.seatsLeft,
    required this.filter,
    required this.showEmptyFilter,
    required this.onFilter,
    required this.onSeat,
  });

  final List<Seat> seats;
  final int sold;
  final int money;
  final int seatsLeft;
  final String filter;
  final bool showEmptyFilter;
  final ValueChanged<String> onFilter;
  final ValueChanged<Seat> onSeat;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: wine,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Huye', style: TextStyle(color: cream, fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                '${rwf(price)} RWF',
                style: const TextStyle(color: gold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                '$sold seats sold · ${rwf(money)} RWF',
                style: const TextStyle(color: cream, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                '$seatsLeft seats left',
                style: const TextStyle(color: gold, fontSize: 16),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: [
              for (final choice in ['all', 'free', 'taken'])
                ChoiceChip(
                  label: Text(choice[0].toUpperCase() + choice.substring(1)),
                  selected: filter == choice,
                  onSelected: (_) => onFilter(choice),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: showEmptyFilter
              ? const Center(child: Text('Nothing matches this filter.'))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: seats.length,
                  itemBuilder: (context, index) {
                    final seat = seats[index];
                    final ink = seat.taken ? cream : wineDeep;
                    return GestureDetector(
                      onTap: () => onSeat(seat),
                      child: Card(
                        color: seat.taken ? wine : blush,
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: seat.taken ? wine : stone,
                            width: seat.taken ? 0 : 1.5,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (seat.photoUrl != null)
                              CircleAvatar(
                                backgroundImage: NetworkImage(seat.photoUrl!),
                                radius: 16,
                              )
                            else
                              Icon(
                                seat.taken ? Icons.person : Icons.event_seat,
                                color: seat.taken ? gold : wine,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              '${seat.number}',
                              style: TextStyle(
                                color: ink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              seat.passenger ?? 'Free',
                              style: TextStyle(color: ink, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
