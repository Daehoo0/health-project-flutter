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
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    void beliprogram() async {
      DocumentSnapshot snapshotuser = await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).get();
      List<Map<String, dynamic>> datauser = [];
      datauser.add(snapshotuser.data() as Map<String, dynamic>);
      if(datauser[0]["saldo"] >= hargaprogram){
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
      return {'asep':'jos'};
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
      return {'asep':'jos'};
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
                        // snapshot.data!["nama"]
                        'jos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      // 'Deskripsi: '+snapshot.data!["deskripsi"],
                        'Deskripsi: jos',
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
