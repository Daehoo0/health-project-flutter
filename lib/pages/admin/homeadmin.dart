import 'package:flutter/material.dart';
import 'package:health_project_flutter/pages/login.dart';
import 'package:health_project_flutter/pages/admin/dokter.dart';
import 'package:health_project_flutter/pages/admin/artikel.dart';
import 'package:health_project_flutter/pages/admin/jadwal.dart';

class HomeAdmin extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeAdmin({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      DoctorPage(),
      SchedulePage(),
      ArticlePage(),
    ];

    final List<String> _pageTitles = [
      'Dokter',
      'Jadwal',
      'Artikel',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        backgroundColor: Colors.teal,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 3) {
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
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Dokter'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Jadwal'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Artikel'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }
}