import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/booking_state.dart';

class WaitlistScreen extends StatefulWidget {
  const WaitlistScreen({super.key});

  @override
  State<WaitlistScreen> createState() => _WaitlistScreenState();
}

class _WaitlistScreenState extends State<WaitlistScreen> {
  final nameController = TextEditingController();
  bool priority = false;
  bool _saving = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final booking = context.read<BookingState>();
    setState(() => _saving = true);
    try {
      await booking.joinWaitlist(
        name: nameController.text.trim(),
        priority: priority,
      );
      if (!mounted) return;
      setState(() {
        nameController.clear();
        priority = false;
        _saving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Waitlist')),
      body: booking.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!booking.full)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Seats are still free. Book one from the seat map.',
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Passenger name',
                          ),
                        ),
                        SwitchListTile(
                          title: const Text(
                            'Priority (elderly, pregnant, disabled)',
                          ),
                          value: priority,
                          onChanged: (value) =>
                              setState(() => priority = value),
                        ),
                        FilledButton(
                          onPressed: _saving ? null : _join,
                          child: Text(_saving ? 'Saving...' : 'Join waitlist'),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                Expanded(
                  child: booking.waitlist.isEmpty
                      ? const Center(child: Text('Nobody is waiting'))
                      : ListView.builder(
                          itemCount: booking.waitlist.length,
                          itemBuilder: (context, index) {
                            final person = booking.waitlist[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(person.name),
                              trailing: person.priority
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
