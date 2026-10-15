import 'package:flutter/material.dart';

void main() {
  runApp(const BusApp());
}

const burgundy = Color(0xFF800020);
const price = 3000;

class Seat {
  Seat(this.number, [this.passenger]);

  final int number;
  String? passenger;

  bool get taken => passenger != null;
}

class BusApp extends StatelessWidget {
  const BusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Booking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: burgundy),
        appBarTheme: const AppBarTheme(
          backgroundColor: burgundy,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SeatMapScreen(),
    );
  }
}

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

  int seatsSold() {
    return seats.where((seat) => seat.taken).length;
  }

  int moneyMade() {
    return seatsSold() * price;
  }

  @override
  Widget build(BuildContext context) {
    final sold = seatsSold();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Huye'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: burgundy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Huye · 3,000 RWF',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  '$sold seats sold · ${moneyMade()} RWF',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
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
                return Card(
                  color: seat.taken ? burgundy : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: burgundy, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        seat.taken ? Icons.person : Icons.event_seat,
                        color: seat.taken ? Colors.white : burgundy,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${seat.number}',
                        style: TextStyle(
                          color: seat.taken ? Colors.white : burgundy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        seat.passenger ?? 'Free',
                        style: TextStyle(
                          color: seat.taken ? Colors.white : burgundy,
                          fontSize: 12,
                        ),
                      ),
                    ],
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