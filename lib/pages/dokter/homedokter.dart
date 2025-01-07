import 'package:flutter/material.dart';
import 'package:health_project_flutter/pages/dokter/artikel.dart';
import 'package:health_project_flutter/pages/dokter/chat.dart';
import 'package:health_project_flutter/pages/dokter/profile.dart';
import 'package:health_project_flutter/pages/dokter/program.dart';
import 'package:health_project_flutter/pages/login.dart';

class HomeDokter extends StatefulWidget {
  final Map<String, dynamic> userData;

  HomeDokter({required this.userData});

  @override
  _HomeDokterState createState() => _HomeDokterState();
}

class _HomeDokterState extends State<HomeDokter> {
  int _selectedIndex = 0; // Untuk mengatur tab yang dipilih di sidebar

  // Daftar menu sidebar
  final List<String> menuTitles = [
    'CRUD Artikel',
    'Chat',
    'CRUD Program',
    'Profile',
    'Logout',
  ];

  // Daftar widget untuk setiap halaman
  final List<Widget> menuPages = [
    ArtikelPage(),
    ChatPage(),
    ProgramPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.teal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header di sidebar
                Container(
                  height: 100,
                  color: Colors.teal.shade700,
                  child: Center(
                    child: Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Menu sidebar
                Expanded(
                  child: ListView.builder(
                    itemCount: menuTitles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(
                          Icons.circle,
                          color: _selectedIndex == index
                              ? Colors.white
                              : Colors.teal.shade100,
                        ),
                        title: Text(
                          menuTitles[index],
                          style: TextStyle(
                            color: _selectedIndex == index
                                ? Colors.white
                                : Colors.teal.shade100,
                          ),
                        ),
                        selected: _selectedIndex == index,
                        selectedTileColor: Colors.teal.shade600,
                        onTap: () {
                          if (menuTitles[index] == 'Logout') {
                            // Logika logout
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(), // Halaman Login
                              ),
                                  (route) => false,
                            );
                          } else {
                            // Perbarui halaman yang ditampilkan
                            setState(() {
                              _selectedIndex = index;
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Konten utama
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: _selectedIndex < menuPages.length
                  ? menuPages[_selectedIndex]
                  : Container(),// Tampilkan halaman sesuai tab
            ),
          ),
        ],
      ),
    );
  }
}
