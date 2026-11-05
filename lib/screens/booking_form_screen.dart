import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../state/booking_state.dart';
import '../utils/money.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key, required this.seat});

  final int seat;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final nameController = TextEditingController();
  final cashController = TextEditingController();
  bool _saving = false;
  File? _photo;

  @override
  void dispose() {
    nameController.dispose();
    cashController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 70,
    );
    if (picked == null) return;
    setState(() => _photo = File(picked.path));
  }

  Future<void> _save() async {
    final cash = int.tryParse(cashController.text.trim());
    final cashError = checkCash(cash);
    if (cashError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(cashError)));
      return;
    }
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }
    final booking = context.read<BookingState>();
    setState(() => _saving = true);
    try {
      String? photoUrl;
      if (_photo != null) {
        photoUrl = await booking.uploadPhoto(_photo!);
      }
      await booking.book(
        seat: widget.seat,
        name: nameController.text.trim(),
        cash: cash!,
        photoUrl: photoUrl,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save: $e'.replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Widget _photoPreview() {
    if (_photo == null) return const SizedBox.shrink();
    return Image.file(
      _photo!,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final seatsLeft = context.watch<BookingState>().seatsLeft;
    final cashText = cashController.text.trim();
    final cash = int.tryParse(cashText);
    final cashError = cashText.isEmpty ? null : checkCash(cash);

    return Scaffold(
      appBar: AppBar(title: Text('Seat ${widget.seat}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Seats left: $seatsLeft',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          _photoPreview(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving
                      ? null
                      : () => _pickPhoto(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving
                      ? null
                      : () => _pickPhoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving...' : 'Book seat'),
          ),
        ],
      ),
    );
  }
}
