import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailDoctorPage extends StatelessWidget {
  final String name;
  final String specialization;
  final String email;
  final Timestamp createdAt; // Example additional data

  DetailDoctorPage({
    required this.name,
    required this.specialization,
    required this.email,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    // List of months in Bahasa Indonesia
    List<String> monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    // Extracting day, month, and year from createdAt
    DateTime joinDate = createdAt.toDate();
    String formattedMonth = monthNames[joinDate.month - 1]; // Adjusting for zero-based index

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Dokter'),
        backgroundColor: Colors.teal,
        elevation: 0, // Flat app bar
      ),
      body: SingleChildScrollView(  // Allows scrolling when the content is too long
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture with rounded edges and shadow
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, color: Colors.white, size: 60),
              ),
              SizedBox(height: 20),

              // Doctor's Name
              Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              SizedBox(height: 10),

              // Doctor's Specialization
              Text(
                'Spesialisasi: $specialization',
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
              SizedBox(height: 15),

              // Email Address
              Row(
                children: [
                  Icon(Icons.email, color: Colors.teal, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      email,
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,  // Truncates the email if it’s too long
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Joining Date
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.teal, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Telah bergabung sejak ${createdAt.toDate().day} $formattedMonth ${createdAt.toDate().year}',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
