import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_services_screen.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  final TextEditingController searchController = TextEditingController();

  String searchText = "";
  String selectedStatus = "All";

  Color getStatusColor(String status) {
    switch (status) {
      case "Confirmed":
        return Colors.green;

      case "Completed":
        return Colors.blue;

      case "Cancelled":
        return Colors.red;

      case "Pending":
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("appointments")
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No appointments available"));
          }

          final appointments = snapshot.data!.docs;

          final filteredAppointments = appointments.where((doc) {
            final appointment = doc.data() as Map<String, dynamic>;

            final customer = (appointment["name"] ?? "")
                .toString()
                .toLowerCase();

            final phone = (appointment["phone"] ?? "").toString().toLowerCase();

            final service = (appointment["service"] ?? "")
                .toString()
                .toLowerCase();

            final status = (appointment["status"] ?? "Pending").toString();

            final matchesSearch =
                customer.contains(searchText) ||
                phone.contains(searchText) ||
                service.contains(searchText);

            final matchesStatus =
                selectedStatus == "All" || status == selectedStatus;

            return matchesSearch && matchesStatus;
          }).toList();

          final totalAppointments = appointments.length;

          final pendingCount = appointments
              .where(
                (e) =>
                    (e.data() as Map<String, dynamic>)["status"] == "Pending",
              )
              .length;

          final confirmedCount = appointments
              .where(
                (e) =>
                    (e.data() as Map<String, dynamic>)["status"] == "Confirmed",
              )
              .length;

          final completedCount = appointments
              .where(
                (e) =>
                    (e.data() as Map<String, dynamic>)["status"] == "Completed",
              )
              .length;

          final cancelledCount = appointments
              .where(
                (e) =>
                    (e.data() as Map<String, dynamic>)["status"] == "Cancelled",
              )
              .length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Search customer...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          searchText = searchController.text.toLowerCase();
                        });
                      },

                      icon: const Icon(Icons.search),

                      label: const Text("Search"),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: Row(
                    children: [
                      _buildFilterButton("All"),
                      const SizedBox(width: 8),

                      _buildFilterButton("Pending"),
                      const SizedBox(width: 8),

                      _buildFilterButton("Confirmed"),
                      const SizedBox(width: 8),

                      _buildFilterButton("Completed"),
                      const SizedBox(width: 8),

                      _buildFilterButton("Cancelled"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildStatCard(
                      "Total Appointments",
                      totalAppointments.toString(),
                      Colors.blue,
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Pending",
                            pendingCount.toString(),
                            Colors.orange,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _buildStatCard(
                            "Confirmed",
                            confirmedCount.toString(),
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Completed",
                            completedCount.toString(),
                            Colors.blue,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _buildStatCard(
                            "Cancelled",
                            cancelledCount.toString(),
                            Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.design_services),
                        label: const Text("Manage Services"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminServicesScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "All Appointments",

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ...filteredAppointments.map((doc) {
                      final appointment = doc.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),

                        child: ListTile(
                          leading: const Icon(Icons.content_cut),

                          title: Text(appointment["service"] ?? "Service"),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text("Customer: ${appointment["name"]}"),

                              Text("Phone: ${appointment["phone"]}"),

                              Text("Date: ${appointment["appointmentDate"]}"),

                              Text("Time: ${appointment["time"]}"),

                              const SizedBox(height: 8),

                              DropdownButton<String>(
                                value: appointment["status"] ?? "Pending",

                                isExpanded: true,

                                style: TextStyle(
                                  color: getStatusColor(
                                    appointment["status"] ?? "Pending",
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),

                                items: const [
                                  DropdownMenuItem(
                                    value: "Pending",
                                    child: Text("Pending"),
                                  ),

                                  DropdownMenuItem(
                                    value: "Confirmed",
                                    child: Text("Confirmed"),
                                  ),

                                  DropdownMenuItem(
                                    value: "Completed",
                                    child: Text("Completed"),
                                  ),

                                  DropdownMenuItem(
                                    value: "Cancelled",
                                    child: Text("Cancelled"),
                                  ),
                                ],

                                onChanged: (newStatus) async {
                                  if (newStatus == null) return;

                                  await doc.reference.update({
                                    "status": newStatus,
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterButton(String status) {
    final bool isSelected = selectedStatus == status;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedStatus = status;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(status),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
