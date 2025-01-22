import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health_project_flutter/currency_format.dart';

class ProgramListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Map<String, dynamic>>> getData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('programdokter').get();
      List<Map<String, dynamic>> data = [];
      snapshot.docs.forEach((doc) {
        Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
        docData['id'] = doc.id; // Add the document ID to the data map
        data.add(docData);
      });
      return data;
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
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          return Material(
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(snapshot.data![index]['nama'] ?? 'No details'),
                    subtitle: Text(snapshot.data![index]['deskripsi'] ?? 'No details'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProgramDetailPage(idprogram:snapshot.data![index]["id"])),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}

class ProgramDetailPage extends StatelessWidget {
  final String idprogram;
  ProgramDetailPage({required this.idprogram});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Map<String, dynamic>>> getData() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('programdokter').doc(idprogram).get();
      List<Map<String, dynamic>> data = [];
      data.add(snapshot.data() as Map<String, dynamic>);
      DocumentSnapshot snapshotdokter = await _firestore.collection('users').doc(data[0]["owner"]).get();
      var datadokter = snapshotdokter.data() as Map<String,dynamic>;
      // data["nama_dokter"] = snapshotdokter
      data[0]["dokter"] =datadokter["name"];
      data[0]["spesialis"] =datadokter["specialization"];
      // snapshot = await _firestore.collection('users').doc(data).get();
      return data;
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
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text('Detail '+snapshot.data![0]["nama"]),
                backgroundColor: Colors.teal,
              ),
              backgroundColor: Colors.grey[200],
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bagian gambar di atas
                  Center(
                    child: ClipOval(
                      child: Image.network(
                        'https://res.cloudinary.com/dk0z4ums3/image/upload/v1707809538/setting/1707809536.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover, // Memastikan semua gambar terlihat
                      ),
                    ),
                  ),

                  // Bagian informasi di bawah gambar
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            snapshot.data![0]["dokter"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            snapshot.data![0]["spesialis"],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                'Duration: '+snapshot.data![0]["durasi"]+" Hari",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Icon(Icons.attach_money, size: 20, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                CurrencyFormat.convertToIdr(snapshot.data![0]["harga"], 2),
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'About the program',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                snapshot.data![0]["deskripsi"],
                                style: TextStyle(fontSize: 14, height: 1.5),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Tambahkan logika untuk tombol Buy Program
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Buy Program',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
    );
  }
}
