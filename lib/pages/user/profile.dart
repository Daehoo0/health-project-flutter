import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_project_flutter/pages/login.dart';
import './updateprofile.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  final Function(Map<String, dynamic>) updateUserData;

  ProfilePage({required this.updateUserData});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};
  String formattedBalance = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fungsi untuk memuat ulang data pengguna dari Firestore
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>;
            final formatter = NumberFormat.decimalPattern('id_ID');
            formattedBalance = formatter.format(userData['balance']);
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
      }
    }
  }

  // Fungsi untuk logout
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Kembali ke halaman login setelah logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(), // Arahkan ke halaman LoginScreen
        ),
      );
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userData.isEmpty
            ? Center(child: CircularProgressIndicator()) // Loading indicator jika data belum ada
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profil Anda',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Nama: ${userData['name'] ?? 'N/A'}'),
            SizedBox(height: 10),
            Text('Email: ${userData['email'] ?? 'N/A'}'),
            SizedBox(height: 10),
            Text('Saldo: Rp$formattedBalance'),
            SizedBox(height: 10),
            Text('Jenis Kelamin: ${userData['gender'] ?? 'N/A'}'),
            SizedBox(height: 10),
            Text('Tinggi Badan: ${userData['height'] ?? 0} (cm)'),
            SizedBox(height: 10),
            Text('Berat Badan: ${userData['weight'] ?? 0} (kg)'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateProfilePage(
                      userData: userData,
                      updateUserData: (updatedData) {
                        setState(() {
                          userData = updatedData;
                        });
                        widget.updateUserData(updatedData);
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: Text('Edit Profil'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
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
