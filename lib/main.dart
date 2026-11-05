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
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDyFHgSVjt-w4QdfulRKLi7W7l-i9-BdA4',
      authDomain: 'bus-booking-62768.firebaseapp.com',
      projectId: 'bus-booking-62768',
      storageBucket: 'bus-booking-62768.firebasestorage.app',
      messagingSenderId: '958738470680',
      appId: '1:958738470680:web:82f417d44c0dabe482706d',
    ),
  );
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
