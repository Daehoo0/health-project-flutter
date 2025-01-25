import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_project_flutter/pages/admin/permintaaddokter.dart';

class DoctorPage extends StatefulWidget {
  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PermintaanPage()),
          );
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.person),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'dokter')
              .where('is_active', isEqualTo: 1)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Tidak ada data dokter.'));
            }

            final doctors = snapshot.data!.docs;

            return GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (MediaQuery.of(context).size.width / 250).floor(), // Menyesuaikan jumlah kolom berdasarkan lebar layar
                childAspectRatio: 3 / 4,  // Menyesuaikan tinggi card dengan rasio lebar dan tinggi
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                final Map<String, dynamic> data = doctor.data() as Map<String, dynamic>;
                final profile = data.containsKey('profile') ? data['profile'] : '';
                final name = data.containsKey('name') ? data['name'] : 'Nama tidak tersedia';
                final specialization = data.containsKey('specialization') ? data['specialization'] : 'Spesialisasi tidak tersedia';

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: profile.isEmpty
                            ? null
                            : NetworkImage(profile),
                        child: profile.isEmpty
                            ? Icon(Icons.person, size: 40)
                            : null,
                      ),
                      SizedBox(height: 12),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        specialization,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Konfirmasi'),
                              content: Text('Apakah Anda yakin ingin membanned dokter ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(doctor.id)
                                        .update({'is_active': 0}).then((_) {
                                      Navigator.pop(context);
                                      setState(() {});
                                    });
                                  },
                                  child: Text('Ya'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Banned'),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
