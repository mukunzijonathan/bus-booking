import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/auth_gate.dart';
import 'utils/colors.dart';

// Session 7 translation table.
// MoMo Wallet          Bus Booking
// Txn, txn.dart         Booking, models/booking.dart
// transactions          bookings  (and waitlist)
// TxnRepository         BookingRepository, WaitlistRepository
// WalletState           BookingState
// balance               seatsLeft, moneyMade
// WalletScreen          SeatMapScreen
// TxnForm               BookingFormScreen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BusApp());
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
      home: const AuthGate(),
    );
  }
}
