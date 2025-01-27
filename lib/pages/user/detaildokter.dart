import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailDoctorPage extends StatelessWidget {
  final String name;
  final String specialization;
  final String email;
  final Timestamp createdAt;
  final String doctorUid;

  DetailDoctorPage({
    required this.name,
    required this.specialization,
    required this.email,
    required this.createdAt,
    required this.doctorUid,
  });

  @override
  Widget build(BuildContext context) {
    List<String> monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    DateTime joinDate = createdAt.toDate();
    String formattedMonth = monthNames[joinDate.month - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Dokter'),
        backgroundColor: Colors.teal,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.teal[200],
                child: Icon(Icons.person, color: Colors.white, size: 70),
              ),
              SizedBox(height: 20),
              // Doctor's Name
              Text(
                name,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              SizedBox(height: 10),
              // Specialization
              Text(
                'Spesialisasi: $specialization',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              SizedBox(height: 15),
              // Email
              Row(
                children: [
                  Icon(Icons.email, color: Colors.teal, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      email,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              // Joining Date
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.teal, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Telah bergabung sejak ${joinDate.day} $formattedMonth ${joinDate.year}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Section Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'List Program',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              // Program List
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('programdokter')
                    .where('owner', isEqualTo: doctorUid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.teal,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada program yang tersedia.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }

                  var programs = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: programs.length,
                    itemBuilder: (context, index) {
                      var program = programs[index];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                program['nama'] ?? 'Nama Program Tidak Ditemukan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[800],
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Durasi: ${program['durasi'] ?? 'Tidak ada'} hari',
                                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Harga: Rp.${program['harga'] ?? 'Tidak ada'}',
                                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Deskripsi: ${program['deskripsi'] ?? 'Tidak ada'}',
                                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
