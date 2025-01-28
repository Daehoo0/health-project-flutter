import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_project_flutter/pages/admin/addartikel.dart';

class ArticlePage extends StatelessWidget {
  final CollectionReference artikelCollection =
  FirebaseFirestore.instance.collection('artikel');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddArtikelPage()),
          );
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: artikelCollection
              .orderBy('created_at', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Belum ada artikel yang ditambahkan.'));
            }

            final articles = snapshot.data!.docs;

            return GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                (MediaQuery.of(context).size.width / 250).floor(),
                childAspectRatio: 3 / 4, // Menjaga rasio card
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                final data = article.data() as Map<String, dynamic>;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9, // Rasio untuk thumbnail
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            data['thumbnail_url'] ?? '',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['judul'] ?? 'Tanpa Judul',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                            SizedBox(height: 4),
                            Text(
                              data['deskripsi'] ?? 'Tanpa Deskripsi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sumber: ${data['source'] ?? 'Tidak Diketahui'}',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Colors.blueGrey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Dibuat: ${(data['created_at'] as Timestamp?)
                                  ?.toDate()
                                  .toLocal()
                                  .toString() ??
                                  'Tidak Diketahui'}',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (data['source'] == 'web')
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddArtikelPage(
                                      judul: data['judul'],
                                      thumbnailUrl: data['thumbnail_url'],
                                      urlLink: data['url_link'],
                                      deskripsi: data['deskripsi'],
                                      documentId: article.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool? confirmDelete = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Hapus Artikel'),
                                  content: Text(
                                      'Apakah Anda yakin ingin menghapus artikel ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmDelete == true) {
                                await artikelCollection
                                    .doc(article.id)
                                    .delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Artikel berhasil dihapus')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 3),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
