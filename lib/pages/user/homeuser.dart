import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_project_flutter/AuthProvider.dart';
import 'package:health_project_flutter/main.dart';
import 'package:health_project_flutter/pages/user/tambahmakanan.dart';
import 'package:health_project_flutter/pages/user/hitungkalori.dart';
import 'package:health_project_flutter/pages/user/konsultasi.dart';
import 'package:health_project_flutter/pages/user/caridokter.dart';
import 'package:health_project_flutter/pages/user/program.dart';
import 'package:health_project_flutter/pages/user/topup.dart';
import 'package:health_project_flutter/pages/user/artikel.dart';
import 'package:health_project_flutter/pages/user/profile.dart';

class HomeUser extends StatefulWidget {
  final Map<String, dynamic> userData;

  HomeUser({required this.userData});

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  int _selectedIndex = 0;

  void _updateUserData(Map<String, dynamic> updatedData) {
    setState(() {
      widget.userData.addAll(updatedData);
    });
  }

  @override
  Widget build(BuildContext context) {
    print(context.read<DataLogin>().uiduser);
    final List<Widget> _pages = [
      AddFoodPage(),
      CalorieCounterPage(),
      ChatConsultationPage(),
      SearchDoctorPage(),
      ProgramListPage(),
      TopUpPage(),
      ArticleListPage(),
      ProfilePage(
        updateUserData: _updateUserData,
      ),
    ];

    final List<String> _pageTitles = [
      'Halaman Tambah Makanan',
      'Halaman Hitung Kalori',
      'Halaman Konsultasi',
      'Halaman Cari Dokter',
      'Halaman Program',
      'Halaman Top Up Saldo',
      'Halaman Artikel',
      'Halaman Profil',
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
