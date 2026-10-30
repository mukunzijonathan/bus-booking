import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'booking_store.dart';

class SeatMapScreen extends StatelessWidget {
  const SeatMapScreen({super.key});

  Future<void> openSeat(BuildContext context, Seat seat) async {
    if (seat.taken) {
      final message = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => BookingDetailsScreen(seat: seat)),
      );
      if (!context.mounted || message == null) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } else {
      final name = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => BookingScreen(seat: seat)),
      );
      if (!context.mounted || name == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name booked seat ${seat.number}')),
      );
    }
  }

  Future<void> openWaitlist(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WaitlistScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: myBookings().snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Huye'),
              actions: const [LogoutButton()],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load your bookings.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Huye'),
              actions: const [LogoutButton()],
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final bookings = snapshot.data!.docs.map(Booking.fromDoc).toList();
        final seats = seatsFromBookings(bookings);
        return SeatMapView(
          seats: seats,
          onSeat: (seat) => openSeat(context, seat),
          onWaitlist: () => openWaitlist(context),
        );
      },
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Log out',
      onPressed: () => FirebaseAuth.instance.signOut(),
    );
  }
}

class SeatMapView extends StatelessWidget {
  const SeatMapView({
    super.key,
    required this.seats,
    required this.onSeat,
    required this.onWaitlist,
  });

  final List<Seat> seats;
  final void Function(Seat seat) onSeat;
  final VoidCallback onWaitlist;

  @override
  Widget build(BuildContext context) {
    final sold = seats.where((seat) => seat.taken).length;
    final money = sold * price;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Huye'),
        actions: [
          IconButton(
            tooltip: 'Waitlist',
            icon: const Icon(Icons.groups),
            onPressed: onWaitlist,
          ),
          const LogoutButton(),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
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
                if (sold == 0) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'No seats sold yet. Tap a free seat to book.',
                    style: TextStyle(color: cream, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: seat.taken ? wine : stone,
                        width: seat.taken ? 0 : 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.seat});

  final Seat seat;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final nameController = TextEditingController();
  final cashController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    cashController.dispose();
    super.dispose();
  }

  Future<void> confirm() async {
    try {
      final bookingDocs = await myBookings().get();
      final waitingDocs = await myWaitlist().get();
      final taken = [
        ...bookingDocs.docs.map((doc) => doc.data()['name'] as String),
        ...waitingDocs.docs.map((doc) => doc.data()['name'] as String),
      ];
      final cash = int.tryParse(cashController.text.trim());
      final error = checkName(nameController.text, taken) ?? checkCash(cash);
      if (error != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        return;
      }
      final seatNo = widget.seat.number;
      final existing = await myBookings().doc('$seatNo').get();
      if (existing.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('That seat was just booked')),
        );
        return;
      }
      final name = nameController.text.trim();
      await myBookings().doc('$seatNo').set(
            Booking(seat: seatNo, name: name, cash: cash!).toMap(),
          );
      if (!mounted) return;
      Navigator.pop(context, name);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Could not book this seat.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cashText = cashController.text.trim();
    final cash = int.tryParse(cashText);
    final cashError = cashText.isEmpty ? null : checkCash(cash);

    return Scaffold(
      appBar: AppBar(title: Text('Seat ${widget.seat.number}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Passenger name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cashController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Cash handed over (RWF)',
                errorText: cashError,
              ),
            ),
            const SizedBox(height: 12),
            if (cashText.isNotEmpty && cashError == null)
              Text('Change: ${changeLine(cash! - price)}'),
            const Spacer(),
            FilledButton(onPressed: confirm, child: const Text('Book seat')),
          ],
        ),
      ),
    );
  }
}

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key, required this.seat});

  final Seat seat;

  Future<void> confirmCancel(BuildContext context) async {
    final who = seat.passenger!;
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text('Cancel $who\'s booking on seat ${seat.number}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
    if (sure != true || !context.mounted) return;
    try {
      await myBookings().doc('${seat.number}').delete();
      final waitingDocs = await myWaitlist().get();
      final waiting = sortedWaitlist(waitingDocs.docs.map(Waiting.fromDoc));
      var message = '$who cancelled';
      if (waiting.isNotEmpty) {
        final next = waiting.first;
        await myBookings().doc('${seat.number}').set(
              Booking(seat: seat.number, name: next.name, cash: price).toMap(),
            );
        await myWaitlist().doc(next.id).delete();
        message = '${next.name} moved into seat ${seat.number}';
      }
      if (!context.mounted) return;
      Navigator.pop(context, message);
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Could not cancel this booking.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cash = seat.cash;
    return Scaffold(
      appBar: AppBar(title: Text('Seat ${seat.number}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              seat.passenger ?? 'Free',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Seat ${seat.number} · Huye · ${rwf(price)} RWF'),
            if (cash != null) ...[
              const SizedBox(height: 8),
              Text('Cash ${rwf(cash)} RWF'),
              Text('Change: ${changeLine(cash - price)}'),
            ],
            const Spacer(),
            OutlinedButton(
              onPressed: () => confirmCancel(context),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cancel booking'),
            ),
          ],
        ),
      ),
    );
  }
}

class WaitlistScreen extends StatefulWidget {
  const WaitlistScreen({super.key});

  @override
  State<WaitlistScreen> createState() => _WaitlistScreenState();
}

class _WaitlistScreenState extends State<WaitlistScreen> {
  final nameController = TextEditingController();
  bool priority = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> join() async {
    try {
      final bookingDocs = await myBookings().get();
      if (bookingDocs.size < 12) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seats are still free. Book one from the seat map.')),
        );
        return;
      }
      final waitingDocs = await myWaitlist().get();
      final taken = [
        ...bookingDocs.docs.map((doc) => doc.data()['name'] as String),
        ...waitingDocs.docs.map((doc) => doc.data()['name'] as String),
      ];
      final error = checkName(nameController.text, taken);
      if (error != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        return;
      }
      await myWaitlist().add({
        'name': nameController.text.trim(),
        'priority': priority,
        'joinedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() {
        nameController.clear();
        priority = false;
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Could not join the waitlist.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waitlist')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: myBookings().snapshots(),
        builder: (context, bookingsSnap) {
          if (bookingsSnap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load your bookings.\n${bookingsSnap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!bookingsSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final full = bookingsSnap.data!.docs.length >= 12;
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: myWaitlist().snapshots(),
            builder: (context, waitSnap) {
              if (waitSnap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load the waitlist.\n${waitSnap.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (!waitSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final waiting = sortedWaitlist(waitSnap.data!.docs.map(Waiting.fromDoc));
              return Column(
                children: [
                  if (!full)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Seats are still free. Book one from the seat map.'),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(labelText: 'Passenger name'),
                          ),
                          SwitchListTile(
                            title: const Text('Priority (elderly, pregnant, disabled)'),
                            value: priority,
                            onChanged: (value) => setState(() => priority = value),
                          ),
                          FilledButton(
                            onPressed: join,
                            child: const Text('Join waitlist'),
                          ),
                        ],
                      ),
                    ),
                  const Divider(),
                  Expanded(
                    child: waiting.isEmpty
                        ? const Center(child: Text('Nobody is waiting'))
                        : ListView.builder(
                            itemCount: waiting.length,
                            itemBuilder: (context, index) {
                              final person = waiting[index];
                              return ListTile(
                                leading: CircleAvatar(child: Text('${index + 1}')),
                                title: Text(person.name),
                                trailing: person.priority
                                    ? const Chip(label: Text('Priority'))
                                    : null,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
