import 'package:flutter/material.dart';

class ArticleListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Artikel ${index + 1}'),
            subtitle: Text('Deskripsi singkat artikel ${index + 1}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArticleDetailPage(index + 1)),
              );
            },
          ),
        );
      },
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final int articleId;

  ArticleDetailPage(this.articleId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Detail Artikel'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text('Detail Artikel $articleId', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
