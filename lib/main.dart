import 'package:flutter/material.dart';

void main() {
  runApp(const BusApp());
}

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
  Seat(this.number, [this.passenger]);

  final int number;
  String? passenger;

  bool get taken => passenger != null;
}

class Passenger {
  const Passenger(this.name, {this.priority = false});

  final String name;
  final bool priority;
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

// ---------- App ----------

class BusApp extends StatelessWidget {
  const BusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Booking',
      theme: ThemeData(
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(seedColor: wine),
        appBarTheme: const AppBarTheme(
          backgroundColor: wineDeep,
          foregroundColor: cream,
        ),
      ),
      home: const SeatMapScreen(),
    );
  }
}

// ---------- Seat map ----------

class SeatMapScreen extends StatefulWidget {
  const SeatMapScreen({super.key});

  @override
  State<SeatMapScreen> createState() => _SeatMapScreenState();
}

class _SeatMapScreenState extends State<SeatMapScreen> {
  final seats = [
    Seat(1, 'Uluat'),
    Seat(2),
    Seat(3, 'Keza'),
    Seat(4),
    Seat(5),
    Seat(6, 'Jo'),
    Seat(7),
    Seat(8),
    Seat(9),
    Seat(10),
    Seat(11),
    Seat(12),
  ];

  final waitlist = <Passenger>[];

  int get soldCount => seats.where((s) => s.taken).length;

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> openSeat(Seat seat) async {
    if (seat.taken) {
      final message = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailsScreen(seat: seat, waitlist: waitlist),
        ),
      );
      if (!mounted) return;
      setState(() {});
      if (message != null) showMessage(message);
    } else {
      final name = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => BookingScreen(seat: seat, seats: seats),
        ),
      );
      if (!mounted || name == null) return;
      setState(() => seat.passenger = name);
    }
  }

  Future<void> openWaitlist() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WaitlistScreen(waitlist: waitlist, seats: seats),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sold = soldCount;
    final money = sold * price;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Huye'),
        actions: [
          IconButton(
            tooltip: 'Waitlist',
            icon: const Icon(Icons.groups),
            onPressed: openWaitlist,
          ),
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
                const Text(
                  'Huye',
                  style: TextStyle(color: cream, fontSize: 22),
                ),
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
                  onTap: () => openSeat(seat),
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

// ---------- Book a free seat ----------

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.seat, required this.seats});

  final Seat seat;
  final List<Seat> seats;

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

  void confirm() {
    final taken = widget.seats
        .where((s) => s.taken)
        .map((s) => s.passenger!);
    final cash = int.tryParse(cashController.text.trim());
    final error = checkName(nameController.text, taken) ?? checkCash(cash);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pop(context, nameController.text.trim());
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

// ---------- Taken seat: details and cancel ----------

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({
    super.key,
    required this.seat,
    required this.waitlist,
  });

  final Seat seat;
  final List<Passenger> waitlist;

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
    final message = cancelBooking(seat, waitlist);
    Navigator.pop(context, message ?? '$who cancelled');
  }

  @override
  Widget build(BuildContext context) {
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

// ---------- Waitlist ----------

class WaitlistScreen extends StatefulWidget {
  const WaitlistScreen({
    super.key,
    required this.waitlist,
    required this.seats,
  });

  final List<Passenger> waitlist;
  final List<Seat> seats;

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

  void join() {
    final taken = [
      ...widget.seats.where((s) => s.taken).map((s) => s.passenger!),
      ...widget.waitlist.map((p) => p.name),
    ];
    final error = checkName(nameController.text, taken);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() {
      joinWaitlist(
        widget.waitlist,
        Passenger(nameController.text.trim(), priority: priority),
      );
      nameController.clear();
      priority = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final full = widget.seats.every((s) => s.taken);

    return Scaffold(
      appBar: AppBar(title: const Text('Waitlist')),
      body: Column(
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
                    onChanged: (v) => setState(() => priority = v),
                  ),
                  FilledButton(onPressed: join, child: const Text('Join waitlist')),
                ],
              ),
            ),
          const Divider(),
          Expanded(
            child: widget.waitlist.isEmpty
                ? const Center(child: Text('Nobody is waiting'))
                : ListView.builder(
              itemCount: widget.waitlist.length,
              itemBuilder: (context, index) {
                final p = widget.waitlist[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(p.name),
                  trailing: p.priority
                      ? const Chip(label: Text('Priority'))
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}