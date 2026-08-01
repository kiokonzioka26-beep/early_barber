import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController serviceNameController = TextEditingController();

  final TextEditingController servicePriceController = TextEditingController();

  @override
  void dispose() {
    serviceNameController.dispose();
    servicePriceController.dispose();
    super.dispose();
  }

  Future<void> _showAddServiceDialog() async {
    serviceNameController.clear();
    servicePriceController.clear();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Service"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: serviceNameController,
                  decoration: const InputDecoration(labelText: "Service Name"),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: servicePriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price (KES)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (serviceNameController.text.trim().isEmpty ||
                    servicePriceController.text.trim().isEmpty) {
                  return;
                }

                await firestore.collection("services").add({
                  "name": serviceNameController.text.trim(),
                  "price": double.parse(servicePriceController.text.trim()),
                  "createdAt": FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Services")),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection("services")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No services added yet.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final services = snapshot.data!.docs;

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.content_cut)),
                  title: Text(service["name"] ?? ""),
                  subtitle: Text("KES ${service["price"]}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
