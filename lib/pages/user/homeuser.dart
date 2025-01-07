import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_project_flutter/pages/login.dart';

class HomeUser extends StatefulWidget {
  final Map<String, dynamic> userData; // Tambahkan parameter userData

  HomeUser({required this.userData}); // Pastikan parameter bersifat required

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  int _selectedIndex = 0;

  // Fungsi untuk mengupdate data pengguna
  void _updateUserData(Map<String, dynamic> updatedData) {
    setState(() {
      widget.userData.addAll(updatedData); // Update data pengguna
    });
  }

  @override
  Widget build(BuildContext context) {
    // Daftar halaman, gunakan widget.userData untuk ProfilePage
    final List<Widget> _pages = [
      AddFoodPage(),
      CalorieCounterPage(),
      ChatConsultationPage(),
      SearchDoctorPage(),
      ProgramListPage(),
      TopUpPage(),
      ArticleListPage(),
      ProfilePage(
        userData: widget.userData, // Berikan data pengguna
        updateUserData: _updateUserData, // Berikan fungsi update
      ),
    ];

    final List<String> _pageTitles = [
      'Tambah Makanan',
      'Hitung Kalori',
      'Konsultasi',
      'Cari Dokter',
      'Program',
      'Top Up Saldo',
      'Artikel',
      'Profile',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        backgroundColor: Colors.teal,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Tambah'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Kalori'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Konsultasi'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari Dokter'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Program'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Top Up'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Artikel'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Halaman Tambah Makanan
class AddFoodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Halaman Tambah Makanan', style: TextStyle(fontSize: 18)),
    );
  }
}

// Halaman Hitung Kalori
class CalorieCounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Halaman Hitung Kalori', style: TextStyle(fontSize: 18)),
    );
  }
}

// Halaman Konsultasi Chat
class ChatConsultationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Halaman Konsultasi Chat', style: TextStyle(fontSize: 18)),
    );
  }
}

// Halaman Cari Dokter
class SearchDoctorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Halaman Cari Dokter', style: TextStyle(fontSize: 18)),
    );
  }
}

// Halaman Daftar Program
class ProgramListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // Ganti dengan jumlah program
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Program ${index + 1}'),
            subtitle: Text('Deskripsi singkat program ${index + 1}'),
            onTap: () {
              // Navigasi ke halaman detail program
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProgramDetailPage(index + 1)),
              );
            },
          ),
        );
      },
    );
  }
}

// Halaman Detail Program
class ProgramDetailPage extends StatelessWidget {
  final int programId;

  ProgramDetailPage(this.programId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Program'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text('Detail Program $programId', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

// Halaman Top Up Saldo
class TopUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Halaman Top Up Saldo', style: TextStyle(fontSize: 18)),
    );
  }
}

// Halaman Daftar Artikel
class ArticleListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // Ganti dengan jumlah artikel
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Artikel ${index + 1}'),
            subtitle: Text('Deskripsi singkat artikel ${index + 1}'),
            onTap: () {
              // Navigasi ke halaman detail artikel
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArticleDetailPage(index + 1)),
              );
            },
          ),
        );
      },
    );
  }
}

// Halaman Detail Artikel
class ArticleDetailPage extends StatelessWidget {
  final int articleId;

  ArticleDetailPage(this.articleId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Artikel'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text('Detail Artikel $articleId', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

// Halaman Profile
class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) updateUserData;

  ProfilePage({required this.userData, required this.updateUserData});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> labelMapping = {
      'name': 'Nama Lengkap',
      'email': 'Email',
      'gender': 'Gender',
      'height': 'Tinggi Badan',
      'weight': 'Berat Badan',
    };

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Profil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...labelMapping.keys.map((key) {
              if (userData.containsKey(key)) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '${labelMapping[key]}: ${userData[key]}',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }
              return Container();
            }).toList(),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateProfilePage(
                      userData: userData,
                      updateUserData: updateUserData,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text('Update Profile'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) updateUserData; // Callback untuk mengupdate data

  UpdateProfilePage({required this.userData, required this.updateUserData});

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  late String selectedGender;
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mengisi data awal dari userData
    selectedGender = widget.userData['gender'] ?? 'Laki-laki';
    heightController.text = widget.userData['height']?.toString() ?? '';
    weightController.text = widget.userData['weight']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown untuk memilih gender
            DropdownButtonFormField<String>(
              value: selectedGender,
              onChanged: (newValue) {
                setState(() {
                  selectedGender = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: ['Laki-laki', 'Perempuan']
                  .map((gender) => DropdownMenuItem(
                value: gender,
                child: Text(gender),
              ))
                  .toList(),
            ),
            SizedBox(height: 16),
            // Input field untuk tinggi badan
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Tinggi Badan (cm)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Input field untuk berat badan
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Berat Badan (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            // Tombol Simpan
            ElevatedButton(
              onPressed: () async {
                // Mengupdate userData dengan nilai baru
                final updatedData = {
                  'gender': selectedGender,
                  'height': double.tryParse(heightController.text) ?? 0.0,
                  'weight': double.tryParse(weightController.text) ?? 0.0,
                };

                // Mendapatkan email dari userData
                String userEmail = widget.userData['email'];
                print('User Email: $userEmail');  // Menampilkan email di konsol

                try {
                  // Mencari pengguna berdasarkan email
                  var userQuerySnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: userEmail)
                      .get();

                  if (userQuerySnapshot.docs.isNotEmpty) {
                    // Mengambil ID dokumen pengguna yang ditemukan
                    String userId = userQuerySnapshot.docs.first.id;
                    print('User ID ditemukan: $userId');

                    // Update data pengguna di Firestore
                    await FirebaseFirestore.instance.collection('users').doc(userId).update(updatedData);

                    // Mengupdate data di UI
                    widget.updateUserData(updatedData);

                    // Menampilkan SnackBar dan kembali ke halaman profil
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profil berhasil diperbarui!')),
                    );
                    Navigator.pop(context); // Kembali ke halaman profile
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pengguna dengan email tersebut tidak ditemukan!')),
                    );
                  }
                } catch (e) {
                  // Menangani kesalahan jika terjadi
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Terjadi kesalahan saat memperbarui profil')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: Text('Simpan'),
            )
            ,
          ],
        ),
      ),
    );
  }
}