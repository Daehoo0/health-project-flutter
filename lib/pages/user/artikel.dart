import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Map<String, dynamic>>> getData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('artikel').get();
      List<Map<String, dynamic>> data = [];
      snapshot.docs.forEach((doc) {
        Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
        docData['id'] = doc.id; // Add the document ID to the data map
        data.add(docData);
      });
      return data;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          return Material(
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                    leading: Image.network(
                      snapshot.data![index]["thumbnail_url"] ?? 'https://via.placeholder.com/150', // Gunakan placeholder jika gambar_url null
                      width: 100,
                      height: 100,
                    ),
                    title: Text(snapshot.data![index]['judul'] ?? 'No title'),
                    subtitle: Text(snapshot.data![index]['deskripsi'] ?? 'No details'),
                  onTap: () async {
                    if (snapshot.data![index]['source'] == "personal") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PersonalArticleDetailPage(idartikel: snapshot.data![index]["id"])),
                      );
                    } else {
                      // Open the URL if source is not 'personal'
                      final url = snapshot.data![index]['url_link']; // Assuming 'source' contains the URL
                      if (url != null && await canLaunch(url)) {
                        await launch(url);
                      } else {
                        // Handle the error if the URL cannot be opened
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open the article')));
                      }
                    }
                  }
                  ,
                );
              },
            ),
          );
        }
      },
    );
  }
}

class PersonalArticleDetailPage extends StatelessWidget {
  final String idartikel;
  PersonalArticleDetailPage({required this.idartikel});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Map<String, dynamic>>> getData() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('artikel').doc(idartikel).get();
      List<Map<String, dynamic>> data = [];
      data.add(snapshot.data() as Map<String, dynamic>);
      return data;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            return SafeArea(
              child: Column(
                children: [
                  // Header Section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 24, color: Color(0xFF111418)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Article Title
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      snapshot.data![0]['judul'] ?? 'No title',
                      style: TextStyle(
                        color: Color(0xFF111418),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015,
                      ),
                    ),
                  ),

                  // Article Date
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "By Arthur C. Brooks · Jan 5, 2022",
                      style: TextStyle(
                        color: Color(0xFF637588),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),

                  // Image Section
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(snapshot.data![0]['gambar_url']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Article Content
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      snapshot.data![0]['isi'],
                      style: TextStyle(
                        color: Color(0xFF111418),
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
    );
  }
}