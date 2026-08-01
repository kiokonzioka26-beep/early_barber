import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text("Book Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Book Your Appointment",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  selectedDate == null
                      ? "Choose Date"
                      : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _selectDate,
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(
                  selectedTime == null
                      ? "Choose Time"
                      : selectedTime!.format(context),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
