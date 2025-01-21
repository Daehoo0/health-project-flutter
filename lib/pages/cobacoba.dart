import 'package:flutter/material.dart';
class Cobacobatampilan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bagian gambar di atas
          Center(
            child: ClipOval(
              child: Image.network(
                'https://res.cloudinary.com/dk0z4ums3/image/upload/v1707809538/setting/1707809536.png',
                width: 200,
                height: 200,
                fit: BoxFit.cover, // Memastikan semua gambar terlihat
              ),
            ),
          ),

          // Bagian informasi di bawah gambar
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Dr. William Davis, MD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Cardiologist, New York Times best-selling author of Wheat Belly',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Duration: 6 weeks',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 20, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Price: \$129.99',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'About the program',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        'This is a comprehensive, highly personalized program that will provide you with the tools and support you need to lose weight, regain health, and reverse years of damage in just six weeks.',
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Tambahkan logika untuk tombol Buy Program
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Buy Program',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
