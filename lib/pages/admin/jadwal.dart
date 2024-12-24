import 'package:flutter/material.dart';
import 'package:health_project_flutter/pages/admin/addjadwal.dart';

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal'),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logika untuk menambah jadwal
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSchedulePage()),
          );
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: 5, // Ganti dengan jumlah jadwal dari database
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('Jadwal ${index + 1}'),
              subtitle: Text('Detail Jadwal ${index + 1}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      // Logika edit jadwal
                    },
                    icon: Icon(Icons.edit, color: Colors.orange),
                  ),
                  IconButton(
                    onPressed: () {
                      // Logika hapus jadwal
                    },
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
