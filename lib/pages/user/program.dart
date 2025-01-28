import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health_project_flutter/currency_format.dart';

class ProgramListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('programdokter').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['harga'] = data['harga']?.toString() ?? '0';
        data['durasi'] = data['durasi']?.toString() ?? '0';
        return data;
      }).toList();
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Program Kesehatan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.teal),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan',
                      style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.healing_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada program tersedia',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final program = snapshot.data![index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProgramDetailPage(
                              idprogram: program["id"].toString(),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.healing,
                                    color: Colors.teal,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        program['nama']?.toString() ?? 'No details',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal[800],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        program['deskripsi']?.toString() ?? 'No details',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.teal,
                                  size: 16,
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${program['durasi']} Hari',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  CurrencyFormat.convertToIdr(
                                    double.tryParse(program['harga']) ?? 0,
                                    0,
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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

class ProgramDetailPage extends StatelessWidget {
  final String idprogram;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProgramDetailPage({required this.idprogram});

  Future<List<Map<String, dynamic>>> getData() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('programdokter').doc(idprogram).get();
      if (!snapshot.exists) {
        return [];
      }

      Map<String, dynamic> programData = snapshot.data() as Map<String, dynamic>;
      programData['harga'] = programData['harga']?.toString() ?? '0';
      programData['durasi'] = programData['durasi']?.toString() ?? '0';

      DocumentSnapshot doctorSnapshot = await _firestore.collection('users').doc(programData['owner'].toString()).get();
      if (doctorSnapshot.exists) {
        Map<String, dynamic> doctorData = doctorSnapshot.data() as Map<String, dynamic>;
        programData['dokter'] = doctorData['name']?.toString() ?? 'Unknown Doctor';
        programData['spesialis'] = doctorData['specialization']?.toString() ?? 'Unknown Specialization';
      }

      return [programData];
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: getData(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Scaffold(
    body: Center(child: CircularProgressIndicator(color: Colors.teal)),
    );
    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
    return Scaffold(
    body: Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.error_outline,
    size: 64,
    color: Colors.red[300],
    ),
    SizedBox(height: 16),
    Text(
    'Program tidak ditemukan',
    style: TextStyle(fontSize: 18, color: Colors.grey[800]),
    ),
    ],
    ),
    ),
    );
    }

    final programData = snapshot.data![0];

    return Scaffold(
    body: CustomScrollView(
    slivers: [
    SliverAppBar(
    expandedHeight: 200,
    pinned: true,
    flexibleSpace: FlexibleSpaceBar(
    background: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.teal, Colors.teal.shade700],
    ),
    ),
    child: Stack(
    fit: StackFit.expand,
    children: [
    Center(
    child: CircleAvatar(
    radius: 60,
    backgroundColor: Colors.white,
    child: ClipOval(
    child: Image.network(
    'https://res.cloudinary.com/dk0z4ums3/image/upload/v1707809538/setting/1707809536.png',
    width: 110,
    height: 110,
    fit: BoxFit.cover,
    ),
    ),
    ),
    ),
    ],
    ),
    ),
    ),
    ),
    SliverToBoxAdapter(
    child: Container(
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(30),
    ),
    ),
    child: Padding(
    padding: EdgeInsets.all(24),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    programData["nama"]?.toString() ?? '',
    style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.teal[800],
    ),
    ),
    SizedBox(height: 8),
    Row(
    children: [
    Icon(Icons.person, size: 20, color: Colors.teal),
    SizedBox(width: 8),
    Text(
    programData["dokter"]?.toString() ?? '',
    style: TextStyle(
    fontSize: 16,
    color: Colors.grey[800],
    ),
    ),
    ],
    ),
    SizedBox(height: 4),
    Row(
    children: [
    Icon(Icons.medical_services, size: 20, color: Colors.teal),
    SizedBox(width: 8),
    Text(
    programData["spesialis"]?.toString() ?? '',
    style: TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
    ),
    ),
    ],
    ),
    SizedBox(height: 24),
    Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: Colors.teal.shade50,
    borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
    children: [
    Expanded(
    child: Column(
    children: [
    Icon(Icons.calendar_today, color: Colors.teal),
    SizedBox(height: 8),
    Text(
    '${programData["durasi"]} Hari',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.teal,
    ),
    ),
    Text(
    'Durasi',
    style: TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
    ),
    ),
    ],
    ),
    ),
    Container(
    width: 1,
    height: 40,
    color: Colors.teal.shade200,
    ),
    Expanded(
    child: Column(
    children: [
    Icon(Icons.payments, color: Colors.teal),
    SizedBox(height: 8),
    Text(
    CurrencyFormat.convertToIdr(
    double.tryParse(programData["harga"].toString()) ?? 0.0,
    0,
    ),
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.teal,
    ),
    ),
    Text(
    'Biaya',
    style: TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    SizedBox(height: 24),
    Text(
    'Tentang Program',
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.teal[800],
    ),
    ),
    SizedBox(height: 12),
    Text(
    programData["deskripsi"]?.toString() ?? '',
    style: TextStyle(
    fontSize: 16,
    height: 1.6,
    color: Colors.grey[800],
    ),
    ),
    SizedBox(height: 32),
    Container(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
    onPressed: () {
    // Add buy program logic here
    },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            'Mulai Program',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
    ),
      SizedBox(height: 24),
      // Tambahan informasi program
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.orange[800],
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Program ini akan dimulai setelah pembayaran berhasil dikonfirmasi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange[800],
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 16),
      // Fitur program
      Text(
        'Fitur Program',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.teal[800],
        ),
      ),
      SizedBox(height: 16),
      _buildFeatureItem(
        icon: Icons.chat_outlined,
        title: 'Konsultasi Online',
        description: 'Konsultasi langsung dengan dokter melalui chat',
      ),
      SizedBox(height: 12),
      _buildFeatureItem(
        icon: Icons.article_outlined,
        title: 'Panduan Program',
        description: 'Panduan lengkap program kesehatan',
      ),
      SizedBox(height: 12),
      _buildFeatureItem(
        icon: Icons.track_changes_outlined,
        title: 'Progress Tracking',
        description: 'Pantau perkembangan program Anda',
      ),
    ],
    ),
    ),
    ),
    ),
    ],
    ),
    );
    },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.teal,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}