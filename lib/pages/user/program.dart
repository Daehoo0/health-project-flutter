import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_project_flutter/AuthProvider.dart';
import 'package:health_project_flutter/main.dart';
import 'package:intl/intl.dart';
import 'package:health_project_flutter/currency_format.dart';
import 'package:health_project_flutter/pages/user/konsultasi.dart';

class ProgramListPage extends StatefulWidget {
  const ProgramListPage({super.key});

  @override
  State<ProgramListPage> createState() => _ProgramListPageState();
}

class _ProgramListPageState extends State<ProgramListPage> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> loadyangjalan() async {
    try {
      var datauserbeli = await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).get();
      var arrdatauserbeli = datauserbeli.data() as Map<String,dynamic>;
      List<Map<String, dynamic>> data = [];
      for(var lode in arrdatauserbeli["list_program"]){
        data.add(lode);
      }
      return data;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> loadsemuaprogram() async {
    try {
      var datauserbeli = await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).get();
      var arrdatauserbeli = datauserbeli.data() as Map<String,dynamic>;
      QuerySnapshot snapshot = await _firestore.collection('programdokter').get();
      List<Map<String, dynamic>> data = [];
      snapshot.docs.forEach((doc) {
        Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
        var bisa = true;
        if(arrdatauserbeli["list_program"] != null){
          for(var cek in arrdatauserbeli["list_program"]){
            if(doc.id == cek["id"]){
              bisa = false;
            }
          }
        }
        if(bisa){
          docData["id"] = doc.id;
          data.add(docData);
        }
      });
      return data;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem('List Program', 0),
                _buildNavItem('Program Berjalan', 1),
              ],
            ),
          ),
          Expanded(
            child: _selectedIndex == 0
                ? _buildProgramList()
                : _buildActivePrograms(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loadsemuaprogram(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No programs available');
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return _buildProgramCard(snapshot.data![index]);
          },
        );
      },
    );
  }

  Widget _buildActivePrograms() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loadyangjalan(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No active programs');
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return _buildActiveProgramCard(snapshot.data![index]);
          },
        );
      },
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProgramDetailPage(idprogram: program["id"])),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                program['nama'] ?? 'No Name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                program['deskripsi'] ?? 'No description available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveProgramCard(Map<String, dynamic> program) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProgramBerjalan(idprogram: program["id"])),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                program['nama'] ?? 'No Name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                program['deskripsi'] ?? 'No description available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              LinearProgressIndicator(
                value: 0.7, // You can calculate this based on program progress
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String title, int index) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.teal : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.teal : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ProgramDetailPage implementation with enhanced UI
class ProgramDetailPage extends StatelessWidget {
  final String idprogram;
  int hargaprogram = 0;

  ProgramDetailPage({required this.idprogram});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getData() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('programdokter').doc(idprogram).get();
      List<Map<String, dynamic>> data = [];
      data.add(snapshot.data() as Map<String, dynamic>);
      DocumentSnapshot snapshotdokter = await _firestore.collection('users').doc(data[0]["owner"]).get();
      var datadokter = snapshotdokter.data() as Map<String,dynamic>;
      data[0]["dokter"] = datadokter["name"];
      data[0]["spesialis"] = datadokter["specialization"];
      hargaprogram = int.parse(data[0]["harga"]);
      return data;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  void beliprogram(BuildContext context) async {
    try {
      DocumentSnapshot snapshotuser = await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).get();
      List<Map<String, dynamic>> datauser = [];
      datauser.add(snapshotuser.data() as Map<String, dynamic>);

      if(datauser[0]["saldo"] >= hargaprogram){
        int saldoBaru = datauser[0]["saldo"] - hargaprogram;
        await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).update({
          'saldo': saldoBaru,
        });

        DocumentSnapshot snapshot = await _firestore.collection('programdokter').doc(idprogram).get();
        List<Map<String, dynamic>> data = [];
        data.add(snapshot.data() as Map<String, dynamic>);
        List<Map<String,dynamic>> datareport = [];

        for(var hokya = 0; hokya < 7; hokya++){
          List<Map<String,dynamic>> isimakanan = [];
          List<Map<String,dynamic>> isiolahraga = [];

          for(var ambil in data[0]["listmakanan"][hokya].split(",")){
            isimakanan.add({
              "nama": ambil,
              "done": false
            });
          }

          for(var ambil in data[0]["listolahraga"][hokya].split(",")){
            isiolahraga.add({
              "nama": ambil,
              "done": false
            });
          }

          datareport.add({
            'untuk_tanggal': DateTime.now().add(Duration(days: hokya)),
            'isi_makanan': isimakanan,
            'isi_olahraga': isiolahraga
          });
        }

        var datasimpan = {
          'id': idprogram,
          'nama': data[0]["nama"],
          'deskripsi': data[0]["deskripsi"],
          'harga': data[0]["harga"],
          'owner': data[0]["owner"],
          'report': datareport,
          'tanggal_beli': DateTime.now(),
          'tanggal_selesai': DateTime.now().add(Duration(days: 8)),
        };

        if(datauser[0]["list_program"] == null){
          await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).update({
            'list_program': [datasimpan],
          });
        } else {
          datauser[0]["list_program"].add(datasimpan);
          await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).update({
            'list_program': datauser[0]["list_program"],
          });
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Program purchased successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient balance'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred while purchasing program'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: getData(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Scaffold(
    body: Center(child: CircularProgressIndicator()),
    );
    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
    return Scaffold(
    body: Center(child: Text('Error loading program details')),
    );
    }

    final programData = snapshot.data![0];

    return Scaffold(
    body: CustomScrollView(
    slivers: [SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Program Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.teal, Colors.teal.shade700],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            child: Icon(
                              Icons.person,
                              color: Colors.teal,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  programData["dokter"],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  programData["spesialis"],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Program Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Duration',
                        '${programData["durasi"]} Days',
                      ),
                      SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.attach_money,
                        'Price',
                        CurrencyFormat.convertToIdr(int.parse(programData["harga"]), 2),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        programData["deskripsi"],
                        style: TextStyle(
                          height: 1.5,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ],
    ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => beliprogram(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Purchase Program',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
    },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ProgramBerjalan extends StatefulWidget {
  final String idprogram;

  const ProgramBerjalan({required this.idprogram});

  @override
  State<ProgramBerjalan> createState() => _ProgramBerjalanState();
}

class _ProgramBerjalanState extends State<ProgramBerjalan> {
  List<Map<String, dynamic>> _olahragalist = [{'nama': 'lari', 'done': true}];
  List<Map<String, dynamic>> _makananlist = [{'nama': 'cakue', 'done': false}];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<bool> mdatahaha = [false, false];
  List<bool> odatahaha = [false, false];

  @override
  void initState() {
    super.initState();
    getDatahh();
  }

  Future<void> ubahDataMakanan() async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('users')
          .doc(context.read<DataLogin>().uiduser)
          .get();
      List<Map<String, dynamic>> data = [];
      data.add(snapshot.data() as Map<String, dynamic>);

      for (var ambil1 in data[0]["list_program"]) {
        if (ambil1["id"] == widget.idprogram) {
          for (var ambil2 in ambil1["report"]) {
            DateTime firebaseDate = ambil2["untuk_tanggal"].toDate();
            DateTime now = DateTime.now();
            final bool isSameDate = firebaseDate.year == now.year &&
                firebaseDate.month == now.month &&
                firebaseDate.day == now.day;

            if (isSameDate) {
              ambil2["isi_olahraga"] = _olahragalist;
              ambil2["isi_makanan"] = _makananlist;
            }
          }
        }
      }

      await _firestore
          .collection('users')
          .doc(context.read<DataLogin>().uiduser)
          .update({
        'list_program': data[0]["list_program"],
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<Map<String, dynamic>> getData() async {
    var nama = "";
    var deskripsi = "";
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('users')
          .doc(context.read<DataLogin>().uiduser)
          .get();
      List<Map<String, dynamic>> data = [];
      data.add(snapshot.data() as Map<String, dynamic>);

      for (var ambil1 in data[0]["list_program"]) {
        if (ambil1["id"] == widget.idprogram) {
          nama = ambil1["nama"];
          deskripsi = ambil1["deskripsi"];
          for (var ambil2 in ambil1["report"]) {
            DateTime firebaseDate = ambil2["untuk_tanggal"].toDate();
            DateTime now = DateTime.now();
            final bool isSameDate = firebaseDate.year == now.year &&
                firebaseDate.month == now.month &&
                firebaseDate.day == now.day;

            if (isSameDate) {
              _makananlist.clear();
              _olahragalist.clear();
              for (var ambil3 in ambil2["isi_makanan"]) {
                _makananlist.add({
                  "nama": ambil3["nama"],
                  "done": ambil3["done"]
                });
              }
              for (var ambil3 in ambil2["isi_olahraga"]) {
                _olahragalist.add({
                  "nama": ambil3["nama"],
                  "done": ambil3["done"]
                });
              }
            }
          }
        }
      }
      return {'nama': nama, 'deskripsi': deskripsi};
    } catch (e) {
      print("Error: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> getDatahh() async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('users')
          .doc(context.read<DataLogin>().uiduser)
          .get();
      List<Map<String, dynamic>> data = [];
      data.add(snapshot.data() as Map<String, dynamic>);

      for (var ambil1 in data[0]["list_program"]) {
        if (ambil1["id"] == widget.idprogram) {
          for (var ambil2 in ambil1["report"]) {
            DateTime firebaseDate = ambil2["untuk_tanggal"].toDate();
            DateTime now = DateTime.now();
            final bool isSameDate = firebaseDate.year == now.year &&
                firebaseDate.month == now.month &&
                firebaseDate.day == now.day;

            if (isSameDate) {
              mdatahaha.clear();
              odatahaha.clear();
              for (var ambil3 in ambil2["isi_makanan"]) {
                mdatahaha.add(ambil3['done']);
              }
              for (var ambil3 in ambil2["isi_olahraga"]) {
                odatahaha.add(ambil3['done']);
              }
            }
          }
        }
      }
      return {'nama': data[0]['nama'], 'deskripsi': data[0]['deskripsi']};
    } catch (e) {
      print("Error: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            body: Center(child: Text('No data available')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal,
            elevation: 0,
            title: Text(
              snapshot.data!["nama"],
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Program Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            snapshot.data!["deskripsi"],
                            style: TextStyle(
                              height: 1.5,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildSection(
                    'Exercise List',
                    _olahragalist,
                    odatahaha,
                        (index, value) {
                      setState(() {
                        odatahaha[index] = value!;
                        _olahragalist[index]['done'] = value;
                      });
                      ubahDataMakanan();
                    },
                  ),
                  SizedBox(height: 24),
                  _buildSection(
                    'Meal List',
                    _makananlist,
                    mdatahaha,
                        (index, value) {
                      setState(() {
                        mdatahaha[index] = value!;
                        _makananlist[index]['done'] = value;
                      });
                      ubahDataMakanan();
                    },
                  ),
                ],
              ),
            ),
          ),
          // Di dalam bagian kode ProgramBerjalan, pada tombol "Chat with Doctor"
          bottomNavigationBar: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  // Navigasi ke halaman konsultasi
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatConsultationPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Chat with Doctor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(
  String title,
  List<Map<String, dynamic>> items,
  List<bool> checkStates,Function(int, bool?) onChanged,
      ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${checkStates.where((state) => state).length}/${checkStates.length}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(
                    items[index]['nama'],
                    style: TextStyle(
                      decoration: checkStates[index]
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: checkStates[index] ? Colors.grey : Colors.black87,
                    ),
                  ),
                  value: checkStates[index],
                  onChanged: (value) => onChanged(index, value),
                  activeColor: Colors.teal,
                  checkColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  double _calculateProgress(List<bool> states) {
    if (states.isEmpty) return 0.0;
    return states.where((state) => state).length / states.length;
  }

  Widget _buildProgressCard() {
    double exerciseProgress = _calculateProgress(odatahaha);
    double mealProgress = _calculateProgress(mdatahaha);
    double totalProgress = (exerciseProgress + mealProgress) / 2;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildProgressBar('Overall', totalProgress),
            SizedBox(height: 8),
            _buildProgressBar('Exercise', exerciseProgress),
            SizedBox(height: 8),
            _buildProgressBar('Meals', mealProgress),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.teal,
          ),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}