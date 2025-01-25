import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'Pasien')  // Filter hanya pasien
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Tidak ada data pasien.'));
            }

            final users = snapshot.data!.docs;

            return GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (MediaQuery.of(context).size.width / 250).floor(), // Menyesuaikan jumlah kolom berdasarkan lebar layar
                childAspectRatio: 3 / 4,  // Rasio tinggi dan lebar card
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final Map<String, dynamic> data = user.data() as Map<String, dynamic>;
                final profile = data.containsKey('profile') ? data['profile'] : '';
                final name = data.containsKey('name') ? data['name'] : 'Nama tidak tersedia';
                final email = data.containsKey('email') ? data['email'] : 'Email tidak tersedia';
                final gender = data.containsKey('gender') ? data['gender'] : 'Gender tidak tersedia';
                final saldo = data.containsKey('saldo') ? data['saldo'] : 'Saldo tidak tersedia';
                final weight = data.containsKey('weight') ? data['weight'] : 'Berat tidak tersedia';
                final height = data.containsKey('height') ? data['height'] : 'Tinggi tidak tersedia';

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
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
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Gender: $gender',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Saldo: $saldo',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Weight: $weight kg',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Height: $height cm',
                        style: TextStyle(fontSize: 12),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Konfirmasi'),
                              content: Text('Apakah Anda yakin ingin menghapus pasien ini?'),
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
                                        .doc(user.id)
                                        .delete().then((_) {
                                      Navigator.pop(context);
                                      setState(() {});
                                    });
                                  },
                                  child: Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                        padding: EdgeInsets.all(8),
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
