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
                const Text(
                  '3,000 RWF',
                  style: TextStyle(color: gold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  '$sold seats sold · ${moneyMade()} RWF',
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
                return Card(
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
                        style: TextStyle(
                          color: ink,
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