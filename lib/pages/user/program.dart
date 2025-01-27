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
        // Ensure numeric fields are converted to strings if needed
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          return Material(
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(snapshot.data![index]['nama']?.toString() ?? 'No details'),
                    subtitle: Text(snapshot.data![index]['deskripsi']?.toString() ?? 'No details'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProgramDetailPage(
                            idprogram: snapshot.data![index]["id"].toString(),
                          ),
                        ),
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProgramDetailPage({required this.idprogram});

  Future<List<Map<String, dynamic>>> getData() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('programdokter').doc(idprogram).get();
      if (!snapshot.exists) {
        return [];
      }

      Map<String, dynamic> programData = snapshot.data() as Map<String, dynamic>;

      // Ensure numeric fields are properly converted to strings
      programData['harga'] = programData['harga']?.toString() ?? '0';
      programData['durasi'] = programData['durasi']?.toString() ?? '0';

      // Fetch doctor data
      DocumentSnapshot doctorSnapshot = await _firestore.collection('users').doc(programData["owner"].toString()).get();
      if (doctorSnapshot.exists) {
        Map<String, dynamic> doctorData = doctorSnapshot.data() as Map<String, dynamic>;
        programData["dokter"] = doctorData["name"]?.toString() ?? 'Unknown Doctor';
        programData["spesialis"] = doctorData["specialization"]?.toString() ?? 'Unknown Specialization';
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No data available')),
          );
        }

        final programData = snapshot.data![0];

        return Scaffold(
          appBar: AppBar(
            title: Text('Detail ${programData["nama"]?.toString() ?? ""}'),
            backgroundColor: Colors.teal,
          ),
          backgroundColor: Colors.grey[200],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ClipOval(
                  child: Image.network(
                    'https://res.cloudinary.com/dk0z4ums3/image/upload/v1707809538/setting/1707809536.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        programData["dokter"]?.toString() ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        programData["spesialis"]?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Duration: ${programData["durasi"]} Hari',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            CurrencyFormat.convertToIdr(
                              double.tryParse(programData["harga"].toString()) ?? 0.0,
                              2,
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'About the program',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            programData["deskripsi"]?.toString() ?? '',
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Add buy program logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
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
      },
    );
  }
}