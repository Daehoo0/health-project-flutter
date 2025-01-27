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
import 'package:health_project_flutter/pages/user/goals.dart';

class HomeUser extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeUser({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  int _selectedIndex = 0;

  /// Fungsi untuk memperbarui data pengguna di halaman profil
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
      Caloridarifoto(),
      Goals(userData: widget.userData), // Melewatkan userData ke Goals
      ChatConsultationPage(),
      SearchDoctorPage(),
      ProgramListPage(),
      TopUpPage(),
      ArticleListPage(),
      ProfilePage(
        // userData: widget.userData,
        updateUserData: _updateUserData,
      ),
    ];

    final List<String> _pageTitles = [
      'Tambah Makanan',
      'Hitung Kalori',
      'Goals',
      'Konsultasi',
      'Cari Dokter',
      'Program',
      'Top Up Saldo',
      'Artikel',
      'Profil',
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
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Tambah'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Kalori'),
          BottomNavigationBarItem(icon: Icon(Icons.account_tree_sharp), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Konsultasi'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Dokter'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Program'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Top Up'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Artikel'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
