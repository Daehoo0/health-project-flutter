import 'package:flutter/material.dart';

class ProgramListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Program ${index + 1}'),
            subtitle: Text('Deskripsi singkat program ${index + 1}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProgramDetailPage(index + 1)),
              );
            },
          ),
        );
      },
    );
  }
}

class ProgramDetailPage extends StatelessWidget {
  final int programId;

  ProgramDetailPage(this.programId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Program'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text('Detail Program $programId', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
