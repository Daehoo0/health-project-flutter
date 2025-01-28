import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_project_flutter/AuthProvider.dart';
import 'package:health_project_flutter/main.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:health_project_flutter/currency_format.dart';

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
<<<<<<< HEAD
      QuerySnapshot snapshot = await _firestore.collection('programdokter').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['harga'] = data['harga']?.toString() ?? '0';
        data['durasi'] = data['durasi']?.toString() ?? '0';
        return data;
      }).toList();
=======
      var datauserbeli = await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).get();
      var arrdatauserbeli = datauserbeli.data() as Map<String,dynamic>;
      List<Map<String, dynamic>> data = [];
      for(var lode in arrdatauserbeli["list_program"]){
        data.add(lode);
      }
      return data;
>>>>>>> c286ca1aa4a06390d113cc7ef3acd791ca387f64
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
<<<<<<< HEAD
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
=======
    loadsemuaprogram();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem('List Program', 0),
            _buildNavItem('Program Berjalan', 1),
          ],
        ),
        Expanded(
          child: Center(
            child: _selectedIndex == 0 ? FutureBuilder<List<Map<String, dynamic>>>(
              future: loadsemuaprogram(),
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
            )
                :
            FutureBuilder<List<Map<String, dynamic>>>(
              future: loadyangjalan(),
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
                                MaterialPageRoute(builder: (context) => ProgramBerjalan(idprogram:snapshot.data![index]["id"])),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            )
          ),
        ),
      ],
    );
  }
  Widget _buildNavItem(String title, int index) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.blue : Colors.grey,
              ),
            ),
          ),
          Container(
            height: 2,
            width: 80,
            color: isActive ? Colors.blue : Colors.transparent,
          ),
        ],
>>>>>>> c286ca1aa4a06390d113cc7ef3acd791ca387f64
      ),
    );
  }
}

class ProgramDetailPage extends StatelessWidget {
  final String idprogram;
  int hargaprogram = 0;
  ProgramDetailPage({required this.idprogram});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Map<String, dynamic>>> getData() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('programdokter').doc(idprogram).get();
<<<<<<< HEAD
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
=======
      List<Map<String, dynamic>> data = [];
      data.add(snapshot.data() as Map<String, dynamic>);
      DocumentSnapshot snapshotdokter = await _firestore.collection('users').doc(data[0]["owner"]).get();
      var datadokter = snapshotdokter.data() as Map<String,dynamic>;
      // data["nama_dokter"] = snapshotdokter
      data[0]["dokter"] =datadokter["name"];
      data[0]["spesialis"] =datadokter["specialization"];
      hargaprogram = int.parse(data[0]["harga"]);
      // snapshot = await _firestore.collection('users').doc(data).get();
      return data;
>>>>>>> c286ca1aa4a06390d113cc7ef3acd791ca387f64
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======
    void beliprogram() async {
      DocumentSnapshot snapshotuser = await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).get();
      List<Map<String, dynamic>> datauser = [];
      datauser.add(snapshotuser.data() as Map<String, dynamic>);

      if(datauser[0]["saldo"] >= hargaprogram){
        // Kurangi saldo pengguna
        int saldoBaru = datauser[0]["saldo"] - hargaprogram;

        // Update saldo pengguna di Firestore
        await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).update({
          'saldo': saldoBaru,
        });

        DocumentSnapshot snapshot = await _firestore.collection('programdokter').doc(idprogram).get();
        List<Map<String, dynamic>> data = [];
        data.add(snapshot.data() as Map<String, dynamic>);
        List<Map<String,dynamic>> datareport = [];
        for(var hokya = 0;hokya<7;hokya++){
          List<Map<String,dynamic>> isimakanan = [];
          List<Map<String,dynamic>> isiolahraga = [];
          for(var ambil in data[0]["listmakanan"][hokya].split(",")){
            isimakanan.add({
              "nama":ambil,
              "done":false
            });
          }
          for(var ambil in data[0]["listolahraga"][hokya].split(",")){
            isiolahraga.add({
              "nama":ambil,
              "done":false
            });
          }
          datareport.add({
            'untuk_tanggal':DateTime.now().add(Duration(days: hokya)),
            'isi_makanan':isimakanan,
            'isi_olahraga':isiolahraga
          });
        }
        var datasimpan = {
          'id':idprogram,
          'nama':data[0]["nama"],
          'deskripsi':data[0]["deskripsi"],
          'harga':data[0]["harga"],
          'owner':data[0]["owner"],
          'report':datareport,
          'tanggal_beli':DateTime.now(),
          'tanggal_selesai':DateTime.now().add(Duration(days: 8)),
        };
        if(datauser[0]["list_program"] == null){
          await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).update({
            'list_program': [datasimpan],
          });
        }else{
          datauser[0]["list_program"].add(datasimpan);
          await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).update({
            'list_program': datauser[0]["list_program"],
          });
        }
        Navigator.pop(context);
      }else{
        // Tampilkan SnackBar jika uang tidak cukup
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uang tidak cukup!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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
                                'Duration: '+snapshot.data![0]["durasi"].toString()+" Hari",
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
                                CurrencyFormat.convertToIdr(int.parse(snapshot.data![0]["harga"]), 2),
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
                              beliprogram();
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
>>>>>>> c286ca1aa4a06390d113cc7ef3acd791ca387f64
    );
  }
}
class ProgramBerjalan extends StatefulWidget {
  String idprogram = "";
  ProgramBerjalan({required this.idprogram});

  @override
  State<ProgramBerjalan> createState() => _ProgramBerjalanState();
}

class _ProgramBerjalanState extends State<ProgramBerjalan> {
  List<Map<String, dynamic>> _olahragalist = [{'nama':'lari','done':true}];
  List<Map<String, dynamic>> _makananlist =[{'nama':'cakue','done':false}];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var mdatahaha = [false,false];
  var odatahaha = [false,false];
  @override
  Future<void> ubahDataMakanan() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).get();
      List<Map<String, dynamic>> data = [];
      data.add(snapshot.data() as Map<String, dynamic>);
      for(var ambil1 in data[0]["list_program"]){
        if(ambil1["id"] == widget.idprogram){
          for(var ambil2 in ambil1["report"]){
            DateTime firebaseDate = ambil2["untuk_tanggal"].toDate();
            DateTime now = DateTime.now();
            final bool isSameDate = firebaseDate.year == now.year &&
                firebaseDate.month == now.month &&
                firebaseDate.day == now.day;
            if(isSameDate){
              ambil2["isi_olahraga"] = _olahragalist;
              ambil2["isi_makanan"] = _makananlist;
            }
          }
        }
      }
      await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).update({
        'list_program': data[0]["list_program"],
      });
    }catch(e) {
      print("Error: $e");
    }
  }
  Future<Map<String,dynamic>> getData() async {
    var nama = "";
    var deskripsi = "";
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).get();
      List<Map<String, dynamic>> data = [];
      data.add(snapshot.data() as Map<String, dynamic>);
      for(var ambil1 in data[0]["list_program"]){
        if(ambil1["id"] == widget.idprogram){
          nama = ambil1["nama"];
          deskripsi = ambil1["deskripsi"];
          for(var ambil2 in ambil1["report"]){
            DateTime firebaseDate = ambil2["untuk_tanggal"].toDate();
            DateTime now = DateTime.now();
            final bool isSameDate = firebaseDate.year == now.year &&
                firebaseDate.month == now.month &&
                firebaseDate.day == now.day;
            if(isSameDate){
              _makananlist.clear();
              _olahragalist.clear();
              for(var ambil3 in ambil2["isi_makanan"]){
                _makananlist.add({
                  "nama":ambil3["nama"],
                  "done":ambil3["done"]
                });
              }
              for(var ambil3 in ambil2["isi_olahraga"]){
                _olahragalist.add({
                  "nama":ambil3["nama"],
                  "done":ambil3["done"]
                });
              }
            }
          }
        }
      }
      return {'nama':nama,'deskripsi':deskripsi};
    } catch (e) {
      print("Error: $e");
      return {};
    }
  }
  Future<Map<String,dynamic>> getDatahh() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).get();
      List<Map<String, dynamic>> data = [];
      data.add(snapshot.data() as Map<String, dynamic>);
      for(var ambil1 in data[0]["list_program"]){
        if(ambil1["id"] == widget.idprogram){
          for(var ambil2 in ambil1["report"]){
            DateTime firebaseDate = ambil2["untuk_tanggal"].toDate();
            DateTime now = DateTime.now();
            final bool isSameDate = firebaseDate.year == now.year &&
                firebaseDate.month == now.month &&
                firebaseDate.day == now.day;
            if(isSameDate){
              mdatahaha.clear();
              odatahaha.clear();
              for(var ambil3 in ambil2["isi_makanan"]){
                mdatahaha.add(ambil3['done']);
              }
              for(var ambil3 in ambil2["isi_olahraga"]){
                odatahaha.add(ambil3['done']);
              }
            }
          }
        }
      }
      return {'nama':data[0]['nama'],'deskripsi':data[0]['deskripsi']};
    } catch (e) {
      print("Error: $e");
      return {};
    }
  }
  void initState() {
    super.initState();
    getDatahh();
  }
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            print(snapshot.data);
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.teal,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back), // Back icon
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous screen
                  },
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        snapshot.data!["nama"],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Deskripsi: '+snapshot.data!["deskripsi"],
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'List Olaharaga',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 300, // Batas maksimal tinggi
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: _olahragalist.asMap().entries.map((entry) {
                            int index = entry.key;
                            var program = entry.value;
                            return CheckboxListTile(
                              title: Text(program['nama']),
                              value: odatahaha[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  odatahaha[index] = value!;
                                  _olahragalist[index]['done'] = value!;
                                });
                                ubahDataMakanan();
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'List Makanan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 300, // Batas maksimal tinggi
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: _makananlist.asMap().entries.map((entry) {
                            int index = entry.key;
                            var program = entry.value;
                            return CheckboxListTile(
                              title: Text(program['nama']),
                              value: mdatahaha[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  mdatahaha[index] = value!;
                                  _makananlist[index]['done'] = value;
                                });
                                ubahDataMakanan();
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tambahkan button di bawah ini
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9, // 90% dari lebar layar
                        child: ElevatedButton(
                          onPressed: () {
                            // Aksi ketika tombol ditekan
                            print("Chat Dokter button clicked");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Warna hijau
                            padding: const EdgeInsets.symmetric(vertical: 16), // Padding tombol
                          ),
                          child: const Text(
                            'Chat Dokter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
    );
  }
}
