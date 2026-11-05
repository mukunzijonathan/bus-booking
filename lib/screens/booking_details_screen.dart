import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../state/booking_state.dart';
import '../utils/money.dart';

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({super.key, required this.seat});

  final int seat;

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  bool _saving = false;

  Future<void> _replacePhoto(ImageSource source) async {
    final booking = context.read<BookingState>();
    final current = booking.bookingFor(widget.seat);
    if (current == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 70,
    );
    if (picked == null) return;
    setState(() => _saving = true);
    try {
      await booking.replacePhoto(current, File(picked.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _cancel() async {
    final booking = context.read<BookingState>();
    final current = booking.bookingFor(widget.seat);
    if (current == null) return;
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text(
          "Cancel ${current.name}'s booking on seat ${widget.seat}?",
        ),
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
    if (sure != true || !mounted) return;
    try {
      final message = await booking.cancel(widget.seat);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not cancel: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = context.watch<BookingState>().bookingFor(widget.seat);
    if (current == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Seat ${widget.seat}')),
        body: const Center(child: Text('This seat is free.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Seat ${widget.seat}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (current.photoUrl != null)
            Image.network(
              current.photoUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const SizedBox(
                height: 180,
                child: Center(child: Icon(Icons.broken_image)),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            current.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Seat ${current.seat} · Huye · ${rwf(price)} RWF'),
          const SizedBox(height: 8),
          Text('Cash ${rwf(current.cash)} RWF'),
          Text('Change: ${changeLine(current.cash - price)}'),
          const SizedBox(height: 16),
          if (_saving) const Center(child: CircularProgressIndicator()),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving
                      ? null
                      : () => _replacePhoto(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving
                      ? null
                      : () => _replacePhoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _saving ? null : _cancel,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
  }
}
