import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detaildokter.dart'; // Import halaman detail dokter

class SearchDoctorPage extends StatefulWidget {
  @override
  _SearchDoctorPageState createState() => _SearchDoctorPageState();
}

class _SearchDoctorPageState extends State<SearchDoctorPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar with improved styling
            TextField(
              controller: _searchController,
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              decoration: InputDecoration(
                hintText: 'Ketik nama dokter...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  borderSide: BorderSide(color: Colors.teal),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 20),
            // StreamBuilder for doctor list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .where('role', isEqualTo: 'dokter')
                    .where('is_active', isEqualTo: 1)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada dokter yang tersedia.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  // Filter doctors by search query (based on email in this case)
                  final List<QueryDocumentSnapshot> doctors = snapshot.data!.docs
                      .where((doc) {
                    final name = doc['name'].toLowerCase();
                    return name.contains(_searchQuery.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      final name = 'dr. ' + doctor['name'];
                      final specialization = doctor['specialization'] ?? 'Tidak ada spesialisasi';

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        elevation: 4, // Card shadow for depth
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0), // Rounded corners
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.teal, // Placeholder color
                            child: Icon(Icons.person, color: Colors.white, size: 30),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text(
                            'Spesialisasi: $specialization',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          onTap: () {
                            // Navigate to DetailDoctorPage and pass uid
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailDoctorPage(
                                  doctorUid: doctor.id, // Using the document ID as uid
                                  name: name,
                                  specialization: specialization,
                                  email: doctor['email'],
                                  createdAt: doctor['createdAt'],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
