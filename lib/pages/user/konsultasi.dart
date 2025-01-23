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
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
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
    return Column(
      children: [
        // Search panel
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            onChanged: (query) {
              setState(() {
                _searchQuery = query.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari nama dokter...',
              prefixIcon: Icon(Icons.search, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        // Doctor list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
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

              // Filter doctors by search query
              final filteredDoctors = snapshot.data!.docs.where((doc) {
                final doctorData = doc.data() as Map<String, dynamic>;
                final doctorName = doctorData['name']?.toLowerCase() ?? '';
                return doctorName.contains(_searchQuery);
              }).toList();

              if (filteredDoctors.isEmpty) {
                return Center(child: Text('Dokter tidak ditemukan'));
              }

              return ListView.builder(
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctorData = filteredDoctors[index].data() as Map<String, dynamic>;
                  final doctorId = filteredDoctors[index].id;

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        child: Icon(Icons.person, size: 30),
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
          ),
        ),
      ],
    );
  }

  Widget _buildChatPanel() {
    return Column(
      children: [
        // Doctor info header
        Container(
          padding: EdgeInsets.all(10.0),
          color: Colors.blue[100],
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
                    radius: 30,
                    child: Icon(Icons.person, size: 35),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'dr. ' + doctorData['name'] ?? 'Nama Dokter',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              );
            },
          ),
        ),

        // Chat messages
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chat')
                .where('sender', whereIn: [senderId, selectedDoctorId])
                .where('receiver', whereIn: [senderId, selectedDoctorId])
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
                    padding: const EdgeInsets.all(10.0),
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
                            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                            decoration: BoxDecoration(
                              color: (chatData['sender'] == senderId) ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              message,
                              style: TextStyle(
                                color: (chatData['sender'] == senderId) ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
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

        // Message input
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ketik pesan...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              SizedBox(width: 10),
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
