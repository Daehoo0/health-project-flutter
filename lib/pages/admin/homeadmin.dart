import 'package:flutter/material.dart';

class HomeAdmin extends StatefulWidget {
  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _selectedIndex = 0; // Untuk mengatur tab yang dipilih di sidebar

  // Daftar menu sidebar
  final List<String> menuTitles = [
    'Dashboard',
    'Manajemen User',
    'Laporan',
    'Pengaturan',
  ];

  // Daftar widget untuk setiap halaman
  final List<Widget> menuPages = [
    Center(child: Text('Dashboard', style: TextStyle(fontSize: 24))),
    Center(child: Text('Manajemen User', style: TextStyle(fontSize: 24))),
    Center(child: Text('Laporan', style: TextStyle(fontSize: 24))),
    Center(child: Text('Pengaturan', style: TextStyle(fontSize: 24))),
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
                          setState(() {
                            _selectedIndex = index;
                          });
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
              child: menuPages[_selectedIndex], // Tampilkan halaman sesuai tab
            ),
          ),
        ],
      ),
    );
  }
}
