import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class Riwayatmakanuser extends StatefulWidget {
  const Riwayatmakanuser({super.key});

  @override
  State<Riwayatmakanuser> createState() => _RiwayatmakanuserState();
}

class _RiwayatmakanuserState extends State<Riwayatmakanuser> {
  DateTime selectedDate = DateTime.now();
  DateTime today = DateTime.now();
  final ValueNotifier<int> totalkalorihariini = ValueNotifier<int>(0);
  Future<void> getTotalCalories() async {
    DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
    DateTime endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('makananuser')
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay)) // Mulai hari
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))     // Akhir hari
        .get();
    int totalCalories = snapshot.docs.fold(0, (sum, doc) {
      return sum + (doc['kalori'] != null ? (doc['kalori'] as num).toInt() : 0); // Pastikan field 'kalori' ada
    });
    totalkalorihariini.value = totalCalories;
  }
  Stream<QuerySnapshot> _getFoodData() {
    getTotalCalories();
    DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
    DateTime endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
    return FirebaseFirestore.instance
        .collection('makananuser')
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay)) // Mulai hari
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))   // Akhir hari
        .snapshots();
  }
  String getFormattedDate() {
    if (selectedDate.isAtSameMomentAs(today)) {
      return "Hari ini";
    } else if (selectedDate.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return "Kemarin";
    } else {
      return DateFormat('dd MMMM yyyy').format(selectedDate);
    }
  }

  void _changeDate(int days) {
    var isjalan = true;
    if(selectedDate.isAtSameMomentAs(today) && days == 1){
      isjalan = false;
    }
    if(isjalan){
      setState(() {
        selectedDate = selectedDate.add(Duration(days: days));
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Goal
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Total Kalori',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    ValueListenableBuilder<int>(
                      valueListenable: totalkalorihariini,
                      builder: (context, value, child) {
                        return Text(
                          value.toString(),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Arrows and Today
            Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_left, size: 32, color: Colors.black),
                    onPressed: () => _changeDate(-1),
                  ),
                ),
                Center(
                  child: Text(
                    getFormattedDate(),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.arrow_right, size: 32, color: selectedDate.isAtSameMomentAs(today) ? Colors.grey : null),
                    onPressed: () => _changeDate(1),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Food & Drink Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Food & Drink',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getFoodData(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Terjadi error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada data makanan untuk tanggal ini.'),
                    );
                  }
                  return SingleChildScrollView(
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(4), // First column (Food name and serving)
                        1: FlexColumnWidth(1), // Second column (Calories)
                      },
                      border: TableBorder(
                        horizontalInside: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      children: snapshot.data!.docs.map<TableRow>((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data["nama"],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    data["satuan"],
                                    style: TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                data["kalori"].toString()+" Kalori",
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
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
