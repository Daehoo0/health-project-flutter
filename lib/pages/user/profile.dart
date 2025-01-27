import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:health_project_flutter/pages/login.dart';
import 'package:health_project_flutter/pages/user/updateprofile.dart';
import 'package:image_picker/image_picker.dart';  // Add this package for image picking
import 'dart:io';
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
  File? _profileImage; // To hold the selected image file
  List<Map<String, dynamic>> purchaseHistory = []; // To store purchase history data

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPurchaseHistory(); // Load purchase history
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
            formattedBalance = formatter.format(userData['saldo']);
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
      }
    }
  }

  // Fetch purchase history from Firestore
  Future<void> _loadPurchaseHistory() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot historySnapshot = await FirebaseFirestore.instance
            .collection('history_beli_program')
            .where('buy_by_pasien', isEqualTo: user.uid)
            .get();

        setState(() {
          purchaseHistory = historySnapshot.docs.map((doc) {
            return doc.data() as Map<String, dynamic>;
          }).toList();
        });
      } catch (e) {
        print("Error loading purchase history: $e");
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      _uploadProfileImage(pickedFile); // Upload to Firebase
    }
  }

  Future<void> _uploadProfileImage(XFile pickedFile) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Prepare the file metadata
        final metadata = SettableMetadata(contentType: "image/jpeg");

        // Create a reference to the Firebase Storage bucket
        String fileName = '${user.uid}_profile.jpg'; // Unique filename
        final storageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');

        // Upload file and metadata to Firebase Storage
        final uploadTask = storageRef.putFile(File(pickedFile.path), metadata);

        // Listen for state changes, errors, and completion of the upload
        uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
          switch (taskSnapshot.state) {
            case TaskState.running:
              final progress = 100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
              print("Upload is $progress% complete.");
              break;
            case TaskState.paused:
              print("Upload is paused.");
              break;
            case TaskState.canceled:
              print("Upload was canceled");
              break;
            case TaskState.error:
            // Handle unsuccessful uploads
              break;
            case TaskState.success:
            // Handle successful uploads
              print("Upload successful!");

              // Get the download URL of the uploaded image
              String downloadUrl = await storageRef.getDownloadURL();

              // Update Firestore with the new image URL
              await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                'profile': downloadUrl,
              });

              setState(() {
                userData['profile'] = downloadUrl; // Update local user data
              });
              break;
          }
        });
      } catch (e) {
        print("Error uploading profile image: $e");
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
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: (_profileImage != null)
                            ? FileImage(_profileImage!) // Use the new profile image
                            : (userData['profile'] != null && userData['profile'].isNotEmpty)
                            ? NetworkImage(userData['profile']) // Tampilkan dari Firestore
                            : AssetImage('lib/assets/profile.jpg') as ImageProvider, // Default from assets
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
              // History Purchase Section
              if (purchaseHistory.isNotEmpty)
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
                      Text(
                        'History Pembelian Program',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: purchaseHistory.length,
                        itemBuilder: (context, index) {
                          var history = purchaseHistory[index];
                          String formattedDate = '';
                          if (history['beli_at'] is Timestamp) {
                            DateTime dateTime = (history['beli_at'] as Timestamp).toDate();
                            formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime).toString();
                          }
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text(history['nama_program'] ?? 'N/A'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Beli Pada: ${formattedDate}'),
                                  Text('Durasi: ${history['durasi']} hari'),
                                  Text('By Dokter: ${history['by_dokter'] ?? 'N/A'}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
    // If purchaseHistory is empty, show a message
    else
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
                child: Center(
                child: Text(
                'Belum pernah beli program.',
                style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
                ),
                ),
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
