import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PermintaanPage extends StatefulWidget {
  @override
  _PermintaanPageState createState() => _PermintaanPageState();
}

class _PermintaanPageState extends State<PermintaanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permintaan Dokter'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'dokter')
              .where('is_active', isEqualTo: 0)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Tidak ada permintaan dokter.'));
            }

            final requests = snapshot.data!.docs;

            return GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (MediaQuery.of(context).size.width / 250).floor(),
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final data = request.data() as Map<String, dynamic>;
                final profile = data.containsKey('profile') ? data['profile'] : '';
                final name = data.containsKey('name') ? data['name'] : 'Nama tidak tersedia';
                final specialization = data.containsKey('specialization') ? data['specialization'] : 'Spesialisasi tidak tersedia';

                // Decode base64 string to Uint8List
                Uint8List? imageBytes;
                if (profile.isNotEmpty) {
                  try {
                    imageBytes = base64Decode(profile);
                  } catch (e) {
                    imageBytes = null; // Jika decoding gagal
                  }
                }

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: imageBytes != null
                              ? MemoryImage(imageBytes)
                              : null,
                          child: imageBytes == null
                              ? Icon(Icons.person, size: 40)
                              : null,
                        ),
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
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Konfirmasi'),
                              content: Text('Apakah Anda yakin ingin mengaktifkan dokter ini?'),
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
                                        .doc(request.id)
                                        .update({'is_active': 1}).then((_) {
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: Text('Ya'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Aktifkan'),
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
