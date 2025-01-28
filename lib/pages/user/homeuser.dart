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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
<<<<<<< HEAD
      CalorieCounterPage(),
      Goals(userData: widget.userData),
=======
      Goals(userData: widget.userData), // Melewatkan userData ke Goals
>>>>>>> c286ca1aa4a06390d113cc7ef3acd791ca387f64
      ChatConsultationPage(),
      SearchDoctorPage(),
      ProgramListPage(),
      TopUpPage(),
      ArticleListPage(),
      ProfilePage(updateUserData: _updateUserData),
    ];

    final List<String> _pageTitles = [
      'Tambah Makanan',
      'Goals',
      'Konsultasi',
      'Cari Dokter',
      'Program',
      'Top Up Saldo',
      'Artikel',
      'Profil',
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          _pageTitles[_selectedIndex],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
<<<<<<< HEAD
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
          const SizedBox(width: 8),
=======
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
          BottomNavigationBarItem(icon: Icon(Icons.account_tree_sharp), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Konsultasi'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Dokter'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Program'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Top Up'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Artikel'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
>>>>>>> c286ca1aa4a06390d113cc7ef3acd791ca387f64
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            items: [
              _buildNavItem(Icons.fastfood, 'Tambah'),
              _buildNavItem(Icons.camera_alt, 'Kalori'),
              _buildNavItem(Icons.account_tree_sharp, 'Goals'),
              _buildNavItem(Icons.chat_bubble_outline, 'Konsultasi'),
              _buildNavItem(Icons.search, 'Dokter'),
              _buildNavItem(Icons.list_alt, 'Program'),
              _buildNavItem(Icons.account_balance_wallet_outlined, 'Top Up'),
              _buildNavItem(Icons.article_outlined, 'Artikel'),
              _buildNavItem(Icons.person_outline, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}