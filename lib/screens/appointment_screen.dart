import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  String selectedService = "Haircut";

  List<String> services = [];

  bool loadingServices = true;

  final List<String> timeSlots = [
    "08:00 AM",
    "08:30 AM",
    "09:00 AM",
    "09:30 AM",
    "10:00 AM",
    "10:30 AM",
    "11:00 AM",
    "11:30 AM",
    "12:00 PM",
    "12:30 PM",
    "01:00 PM",
    "01:30 PM",
    "02:00 PM",
    "02:30 PM",
    "03:00 PM",
    "03:30 PM",
    "04:00 PM",
    "04:30 PM",
    "05:00 PM",
    "05:30 PM",
  ];

  List<String> bookedSlots = [];

  bool loadingBookedSlots = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> loadServices() async {
    final snapshot = await firestore
        .collection("services")
        .where("active", isEqualTo: true)
        .get();

    services = snapshot.docs.map((doc) => doc["name"] as String).toList();

    if (services.isNotEmpty) {
      selectedService = services.first;
    }

    setState(() {
      loadingServices = false;
    });
  }

  Future<void> loadBookedSlots(String date) async {
    setState(() {
      loadingBookedSlots = true;
    });

    final snapshot = await firestore
        .collection("appointments")
        .where("appointmentDate", isEqualTo: date)
        .get();

    bookedSlots = snapshot.docs
        .where((doc) {
          final data = doc.data();

          return data["status"] == "Pending" || data["status"] == "Confirmed";
        })
        .map((doc) => doc["time"] as String)
        .toList();

    setState(() {
      loadingBookedSlots = false;
    });
  }

  Future<void> _saveAppointment() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    debugPrint("==================================");
    debugPrint("Current User: $user");
    debugPrint("UID: ${user?.uid}");
    debugPrint("Email: ${user?.email}");
    debugPrint("==================================");

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("You are not logged in.")));
      return;
    }

    debugPrint("Current User: $user");
    debugPrint("User UID: ${user?.uid}");
    debugPrint("User Email: ${user?.email}");

    try {
      final existingAppointment = await firestore
          .collection("appointments")
          .where("appointmentDate", isEqualTo: dateController.text)
          .where("time", isEqualTo: timeController.text)
          .get();

      final alreadyBooked = existingAppointment.docs.any((doc) {
        final data = doc.data();

        return data["status"] == "Pending" || data["status"] == "Confirmed";
      });

      if (alreadyBooked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This time slot has already been booked."),
          ),
        );
        return;
      }

      await firestore.collection("appointments").add({
        "userId": user.uid,
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "service": selectedService,
        "appointmentDate": dateController.text,
        "time": timeController.text,
        "status": "Pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment booked successfully!")),
      );

      nameController.clear();
      phoneController.clear();
      dateController.clear();
      timeController.clear();

      setState(() {
        selectedService = "Haircut";
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      appBar: AppBar(title: const Text("Book Appointment"), centerTitle: true),

      body: SingleChildScrollView(
        child: Padding(
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
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  hintText: "Enter your full name",
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: phoneController,
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

              loadingServices
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      initialValue: selectedService,
                      decoration: const InputDecoration(
                        labelText: "Select Service",
                        border: OutlineInputBorder(),
                      ),
                      items: services.map((service) {
                        return DropdownMenuItem<String>(
                          value: service,
                          child: Text(service),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedService = value;
                          });
                        }
                      },
                    ),

              const SizedBox(height: 20),

              TextField(
                controller: dateController,
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                    ),
                    lastDate: DateTime(2030),
                  );

                  if (pickedDate != null) {
                    final selectedDate =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";

                    setState(() {
                      dateController.text = selectedDate;
                      timeController.clear();
                    });

                    await loadBookedSlots(selectedDate);
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

              DropdownButtonFormField<String>(
                value: timeController.text.isEmpty ? null : timeController.text,
                decoration: const InputDecoration(
                  labelText: "Appointment Time",
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                items: timeSlots.map((time) {
                  final bool isBooked = bookedSlots.contains(time);

                  return DropdownMenuItem<String>(
                    value: isBooked ? null : time,
                    enabled: !isBooked,

                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: isBooked ? Colors.red : Colors.green,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          isBooked ? "$time (Booked)" : time,
                          style: TextStyle(
                            color: isBooked ? Colors.red : Colors.black,
                            fontWeight: isBooked
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      timeController.text = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAppointment,
                  child: const Text("Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dateController.dispose();
    timeController.dispose();

    super.dispose();
  }
}
