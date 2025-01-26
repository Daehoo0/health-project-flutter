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

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
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
        backgroundColor: Colors.teal,
        title: Text('Profil Pengguna'),
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
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Profil
                    Center(
                      child:
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: (userData['profile'] != null && userData['profile'].isNotEmpty)
                            ? NetworkImage(userData['profile']) // Tampilkan dari Firestore
                            : AssetImage('lib/assets/profile.jpg') as ImageProvider, // Default dari asset
                        backgroundColor: Colors.teal[100],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Nama Pengguna
                    Center(
                      child: Text(
                        userData['name'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(),

                    // Informasi Pengguna
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.teal),
                      title: Text('Email'),
                      subtitle: Text(userData['email'] ?? 'N/A'),
                    ),
                    ListTile(
                      leading: Icon(Icons.account_balance_wallet, color: Colors.teal),
                      title: Text('Saldo'),
                      subtitle: Text('Rp$formattedBalance'),
                    ),
                    ListTile(
                      leading: Icon(Icons.male, color: Colors.teal),
                      title: Text('Jenis Kelamin'),
                      subtitle: Text(userData['gender'] ?? 'N/A'),
                    ),
                    ListTile(
                      leading: Icon(Icons.height, color: Colors.teal),
                      title: Text('Tinggi Badan'),
                      subtitle: Text('${userData['height'] ?? 0} cm'),
                    ),
                    ListTile(
                      leading: Icon(Icons.fitness_center, color: Colors.teal),
                      title: Text('Berat Badan'),
                      subtitle: Text('${userData['weight'] ?? 0} kg'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Tombol Edit dan Logout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shadowColor: Colors.teal.withOpacity(0.3),
                      elevation: 5,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Edit Profil',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shadowColor: Colors.red.withOpacity(0.3),
                      elevation: 5,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Logout',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
