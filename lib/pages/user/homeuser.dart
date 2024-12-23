import 'package:flutter/material.dart';
import 'package:kesehatan/pages/login.dart';

class HomeUser extends StatefulWidget {
  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  int _selectedIndex = 0;

  // Daftar halaman
  final List<Widget> _pages = [
    AddFoodPage(),
    CalorieCounterPage(),
    ChatConsultationPage(),
    SearchDoctorPage(),
    ProgramListPage(),
    TopUpPage(),
    ArticleListPage(),
    ProfilePage(),
  ];

  // Daftar judul navbar
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

  @override
  Widget build(BuildContext context) {
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
  // Data dummy user (dapat diganti dengan data dinamis dari database)
  final Map<String, String> userData = {
    'Nama': 'John Doe',
    'Email': 'johndoe@example.com',
    'No. HP': '081234567890',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan data user
            Text(
              'Data Profil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...userData.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }).toList(),
            SizedBox(height: 32),
            // Tombol Update Profile
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman update profile
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateProfilePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: Text('Update Profile'),
            ),
            SizedBox(height: 16),
            // Tombol Logout
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(), // Halaman Login
                  ),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman Update Profile
class UpdateProfilePage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

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
            // Input field untuk Nama
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Input field untuk Email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Input field untuk No. HP
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'No. HP',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            // Tombol Simpan
            ElevatedButton(
              onPressed: () {
                // Logika menyimpan perubahan profile
                // Simpan data ke database atau backend
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profil berhasil diperbarui!')),
                );
                Navigator.pop(context); // Kembali ke halaman profile
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
