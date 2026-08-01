import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("My Appointments")),

      body: user == null
          ? const Center(child: Text("Please login first"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No appointments found",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final appointments = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),

                  itemCount: appointments.length,

                  itemBuilder: (context, index) {
                    final appointment =
                        appointments[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),

                      child: ListTile(
                        leading: const Icon(Icons.calendar_month),

                        title: Text(appointment['service'] ?? "Service"),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text("Date: ${appointment['appointmentDate']}"),

                            Text("Time: ${appointment['time']}"),

                            Text(
                              "Status: ${appointment['status'] ?? 'Pending'}",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
