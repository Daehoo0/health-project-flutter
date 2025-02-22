import 'package:flutter/material.dart';
import 'package:health_project_flutter/pages/dokter/artikel.dart';
import 'package:health_project_flutter/pages/dokter/chat.dart';
import 'package:health_project_flutter/pages/dokter/profile.dart';
import 'package:health_project_flutter/pages/dokter/program.dart';
import 'package:health_project_flutter/pages/login.dart';

class HomeDokter extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeDokter({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeDokterState createState() => _HomeDokterState();
}

class _HomeDokterState extends State<HomeDokter> {
  int _selectedIndex = 0;

  /// Fungsi untuk memperbarui data pengguna di halaman profil
  void _updateUserData(Map<String, dynamic> updatedData) {
    setState(() {
      widget.userData.addAll(updatedData);
    });
  }

  // Getter untuk daftar halaman
  List<Widget> get menuPages => [
    ArtikelDokterPage(),
    ChatPage(),
    ProgramPage(),
    ProfilePage(
      updateUserData: _updateUserData,
    ),
  ];

  // Daftar menu sidebar
  final List<String> menuTitles = [
    'Artikel',
    'Chat',
    'Program',
    'Profile',
    'Logout',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.teal.shade800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header sidebar
                Container(
                  height: 120,
                  color: Colors.teal.shade600,
                  child: Center(
                    child: Text(
                      'Dokter Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
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
                          _getIconForMenu(index),
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
                            fontSize: 16,
                          ),
                        ),
                        selected: _selectedIndex == index,
                        selectedTileColor: Colors.teal.shade700,
                        onTap: () {
                          if (menuTitles[index] == 'Logout') {
                            // Logika logout
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                                  (route) => false,
                            );
                          } else {
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
              padding: EdgeInsets.all(20),
              color: Colors.grey.shade100,
              child: _selectedIndex < menuPages.length
                  ? menuPages[_selectedIndex]
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mendapatkan ikon sesuai menu
  IconData _getIconForMenu(int index) {
    switch (index) {
      case 0:
        return Icons.article;
      case 1:
        return Icons.chat;
      case 2:
        return Icons.assignment;
      case 3:
        return Icons.person;
      default:
        return Icons.exit_to_app;
    }
  }
}
