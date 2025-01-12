import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:async/async.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatDoctorPageState createState() => _ChatDoctorPageState();
}

class _ChatDoctorPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String senderId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String? selectedPatientId;
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
    if (selectedPatientId == null) return;
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
          'receiver': selectedPatientId,
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

  Widget _buildPatientList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Tidak ada pasien yang tersedia'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final patientData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final patientId = snapshot.data!.docs[index].id;

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(patientData['name'] ?? 'Nama Pasien'),
                onTap: () {
                  if (senderId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Anda harus login terlebih dahulu')),
                    );
                    return;
                  }
                  setState(() {
                    selectedPatientId = patientId;
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
        // Header bagian atas yang menampilkan informasi pasien
        Container(
          padding: EdgeInsets.all(8.0),
          color: Colors.grey[200],
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(selectedPatientId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.data() == null) return Container();

              final patientData = snapshot.data!.data() as Map<String, dynamic>;
              return Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        selectedPatientId = null;
                      });
                    },
                  ),
                  CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientData['name'] ?? 'Nama Pasien',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),

        // Chat messages list
        Expanded(
          child: selectedPatientId == null
              ? Center(child: Text('Belum ada pesan'))
              : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chat')
                .where('sender', whereIn: [selectedPatientId, senderId]) // Menampilkan chat dari sender atau receiver yang sesuai
                .where('receiver', whereIn: [selectedPatientId, senderId]) // Termasuk chat dari dokter atau user
                .orderBy('timestamp', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('Belum ada pesan'));
              }

              final chatDocs = snapshot.data!.docs;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });

              return ListView.builder(
                controller: _scrollController,
                itemCount: chatDocs.length,
                itemBuilder: (context, index) {
                  final chatData = chatDocs[index].data() as Map<String, dynamic>;
                  final isSender = chatData['sender'] == senderId;
                  final timestamp = chatData['timestamp'] as Timestamp?;

                  return Align(
                    alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: isSender ? Colors.teal : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            chatData['message'] ?? 'No message',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatTimestamp(timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
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

        // Input area untuk mengetik pesan
        GestureDetector(
          onTap: () => _scrollToBottom(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: OutlineInputBorder(),
                    ),
                    onTap: _scrollToBottom,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isLoading ? null : _sendMessage,
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Text('Kirim'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Pasien'),
        backgroundColor: Colors.teal,
      ),
      body: selectedPatientId == null ? _buildPatientList() : _buildChatPanel(),
    );
  }
}
