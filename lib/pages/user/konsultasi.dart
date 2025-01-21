import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatConsultationPage extends StatefulWidget {
  @override
  _KonsultasiPageState createState() => _KonsultasiPageState();
}

class _KonsultasiPageState extends State<ChatConsultationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String senderId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String? selectedDoctorId;
  bool isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    if (selectedDoctorId == null) return;
    if (senderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Anda harus login terlebih dahulu')),
      );
      return;
    }

    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      try {
        setState(() {
          isLoading = true;
        });
        await FirebaseFirestore.instance.collection('chat').add({
          'sender': senderId,
          'receiver': selectedDoctorId,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _messageController.clear();
        Future.delayed(Duration(milliseconds: 100), _scrollToBottom);
      } catch (e) {
        print("Error sending message: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('HH:mm').format(timestamp.toDate());
  }

  Widget _buildDoctorList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'dokter')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Tidak ada dokter yang tersedia'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doctorData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final doctorId = snapshot.data!.docs[index].id;

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text('dr. ' + doctorData['name'] ?? 'Nama Dokter'),
                onTap: () {
                  if (senderId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Anda harus login terlebih dahulu')),
                    );
                    return;
                  }
                  setState(() {
                    selectedDoctorId = doctorId;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatPanel() {
    return Column(
      children: [
        // Header bagian atas yang menampilkan informasi dokter
        Container(
          padding: EdgeInsets.all(8.0),
          color: Colors.grey[200],
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(selectedDoctorId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.data() == null) return Container();

              final doctorData = snapshot.data!.data() as Map<String, dynamic>;
              return Row(
                children: [
                  CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'dr. ' + doctorData['name'] ?? 'Nama Dokter',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
        ),

        // Daftar percakapan
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chat')
                .where('sender', whereIn: [senderId, selectedDoctorId]) // Menampilkan chat dari sender atau receiver yang sesuai
                .where('receiver', whereIn: [senderId, selectedDoctorId]) // Termasuk chat dari dokter atau user
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('Belum ada pesan'));
              }

              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final chatData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  final message = chatData['message'] ?? '';
                  final timestamp = chatData['timestamp'] as Timestamp?;
                  final formattedTime = _formatTimestamp(timestamp);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: (chatData['sender'] == senderId)
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: (chatData['sender'] == senderId)
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: (chatData['sender'] == senderId) ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message,
                              style: TextStyle(color: (chatData['sender'] == senderId) ? Colors.white : Colors.black),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            formattedTime,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Form input pesan
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ketik pesan...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: isLoading
                    ? CircularProgressIndicator()
                    : Icon(Icons.send),
                onPressed: isLoading ? null : _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: selectedDoctorId != null
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selectedDoctorId = null;
            });
          },
        )
            : null,
      ),
      body: selectedDoctorId == null
          ? _buildDoctorList()
          : _buildChatPanel(),
    );
  }
}
