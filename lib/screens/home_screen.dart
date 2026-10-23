import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../services/notification_service.dart';
import 'ring_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _setAlarm() async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await NotificationService.scheduleAlarm(scheduledDate, DateTime.now().millisecondsSinceEpoch ~/ 1000);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم ضبط المنبه على ${_selectedTime.format(context)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المنبه الذكي'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('وقت المنبه', style: TextStyle(fontSize: 20, color: Colors.grey)),
            const SizedBox(height: 16),
            Text(
              _selectedTime.format(context),
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.access_time),
              label: const Text('تغيير الوقت'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _setAlarm,
              icon: const Icon(Icons.alarm),
              label: const Text('ضبط المنبه'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 48),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RingScreen()));
              },
              child: const Text('تجربة شاشة الكاميرا (للتأكد فقط)'),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'الحقوق محفوظة © 2026 ALPHA',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}