import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String senderId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String? selectedPatientId;
  bool isLoading = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // State for storing chat messages
  List<Map<String, dynamic>> _chatMessages = [];

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
    if (senderId.isEmpty || selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Anda harus login dan pilih pasien terlebih dahulu')),
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
          'receiver': selectedPatientId!,
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
    return Column(
      children: [
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
              hintText: 'Cari nama pasien...',
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
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'Pasien')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('Tidak ada pasien yang tersedia'));
              }

              // Filter patients by search query
              final filteredPatients = snapshot.data!.docs.where((doc) {
                final patientData = doc.data() as Map<String, dynamic>;
                final patientName = patientData['name']?.toLowerCase() ?? '';
                return patientName.contains(_searchQuery);
              }).toList();

              if (filteredPatients.isEmpty) {
                return Center(child: Text('Pasien tidak ditemukan'));
              }

              return ListView.builder(
                itemCount: filteredPatients.length,
                itemBuilder: (context, index) {
                  final patientData = filteredPatients[index].data() as Map<String, dynamic>;
                  final patientId = filteredPatients[index].id;

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
                          _chatMessages = []; // Reset chat messages when a new patient is selected
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
    if (selectedPatientId == null) {
      return Center(child: Text('Pilih pasien terlebih dahulu'));
    }

    return Column(
      children: [
        // Patient info header
        Container(
          padding: EdgeInsets.all(10.0),
          color: Colors.blue[100],
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(selectedPatientId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.data() == null) {
                return Center(child: CircularProgressIndicator());
              }

              final patientData = snapshot.data!.data() as Map<String, dynamic>;
              return Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 35),
                  ),
                  SizedBox(width: 8),
                  Text(
                    patientData['name'] ?? 'Nama Pasien',
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
                .where('sender', whereIn: [senderId, selectedPatientId])
                .where('receiver', whereIn: [senderId, selectedPatientId])
                .orderBy('timestamp', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                // Update the local chat messages list with the latest data
                _chatMessages = snapshot.data!.docs.map((doc) {
                  return doc.data() as Map<String, dynamic>;
                }).toList();
              }

              // Scroll to the bottom after new messages load
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });

              return ListView.builder(
                controller: _scrollController,
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  final chatData = _chatMessages[index];
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
        leading: selectedPatientId != null
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selectedPatientId = null;
            });
          },
        )
            : null,
      ),
      body: selectedPatientId == null
          ? _buildPatientList()
          : _buildChatPanel(),
    );
  }
}