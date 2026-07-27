import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      appBar: AppBar(title: const Text("Book Appointment"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            const Text(
              "Schedule Your Appointment",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            TextField(
              decoration: const InputDecoration(
                labelText: "Full Name",
                hintText: "Enter your full name",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                hintText: "Enter your phone number",
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Select Service",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: "Haircut",
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: "Haircut", child: Text("Haircut")),
                DropdownMenuItem(
                  value: "Beard Grooming",
                  child: Text("Beard Grooming"),
                ),
                DropdownMenuItem(
                  value: "Kids Haircut",
                  child: Text("Kids Haircut"),
                ),
                DropdownMenuItem(
                  value: "Home Service",
                  child: Text("Home Service"),
                ),
              ],
              onChanged: (value) {},
            ),

            const SizedBox(height: 20),

            TextField(
              controller: dateController,
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );

                if (pickedDate != null) {
                  dateController.text =
                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                }
              },
              decoration: const InputDecoration(
                labelText: "Appointment Date",
                hintText: "Select a date",
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: timeController,
              readOnly: true,
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime != null) {
                  timeController.text = pickedTime.format(context);
                }
              },
              decoration: const InputDecoration(
                labelText: "Appointment Time",
                hintText: "Select a time",
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
