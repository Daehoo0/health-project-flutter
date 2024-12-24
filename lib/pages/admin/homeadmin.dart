import 'package:flutter/material.dart';
import 'package:health_project_flutter/pages/login.dart';
import 'package:health_project_flutter/pages/admin/dokter.dart';
import 'package:health_project_flutter/pages/admin/artikel.dart';
import 'package:health_project_flutter/pages/admin/user.dart';
import 'package:health_project_flutter/pages/admin/jadwal.dart';

class HomeAdmin extends StatefulWidget {
  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _selectedIndex = 0; // Untuk mengatur tab yang dipilih di sidebar

  // Daftar menu sidebar
  final List<String> menuTitles = [
    'Dokter',
    'Jadwal',
    'Artikel',
    'User',
    'Logout',
  ];

  // Daftar widget untuk setiap halaman
  final List<Widget> menuPages = [
    DoctorPage(),
    SchedulePage(),
    ArticlePage(),
    DeleteUserPage(),
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
