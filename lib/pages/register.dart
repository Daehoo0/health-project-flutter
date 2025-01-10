import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _selectedGender = 'Laki-laki';
  String _selectedRole = 'Pasien';  // Default to Pasien
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _registerUser() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String height = _heightController.text.trim();
    String weight = _weightController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || height.isEmpty || weight.isEmpty) {
      _showMessage('Semua field harus diisi!');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Password dan konfirmasi password tidak cocok!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'gender': _selectedGender,
        'height': double.parse(height),
        'weight': double.parse(weight),
        'saldo': 0,
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to either 'dokter' or 'users' collection based on role
      if (_selectedRole == 'Dokter') {
        await _firestore.collection('dokter').doc(userCredential.user?.uid).set(userData);
      } else {
        await _firestore.collection('users').doc(userCredential.user?.uid).set(userData);
      }

      _showMessage('Registrasi berhasil!');
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: 100),
                  Lottie.asset('lib/assets/register.json', height: 200),
                  SizedBox(height: 20),
                  Text(
                    'Buat Akun Baru',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(_nameController, 'Nama Lengkap', Icons.person),
                  SizedBox(height: 10),
                  _buildTextField(_emailController, 'Email', Icons.email),
                  SizedBox(height: 10),
                  _buildTextField(_passwordController, 'Password', Icons.lock, obscureText: true),
                  SizedBox(height: 10),
                  _buildTextField(_confirmPasswordController, 'Konfirmasi Password', Icons.lock_outline, obscureText: true),
                  SizedBox(height: 10),
                  _buildDropdown(),
                  SizedBox(height: 10),
                  _buildTextField(_heightController, 'Tinggi Badan (cm)', Icons.height, keyboardType: TextInputType.number),
                  SizedBox(height: 10),
                  _buildTextField(_weightController, 'Berat Badan (kg)', Icons.monitor_weight, keyboardType: TextInputType.number),
                  SizedBox(height: 20),
                  _buildRoleDropdown(),  // Role selection added
                  SizedBox(height: 20),
                  _buildRegisterButton(),
                  SizedBox(height: 10),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.teal.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      items: [
        DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
        DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
      ],
      onChanged: (value) => setState(() => _selectedGender = value!),
      decoration: InputDecoration(
        labelText: 'Jenis Kelamin',
        prefixIcon: Icon(Icons.person_outline, color: Colors.teal),
        filled: true,
        fillColor: Colors.teal.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      items: [
        DropdownMenuItem(value: 'Pasien', child: Text('Pasien')),
        DropdownMenuItem(value: 'Dokter', child: Text('Dokter')),
      ],
      onChanged: (value) => setState(() => _selectedRole = value!),
      decoration: InputDecoration(
        labelText: 'Pilih Role',
        prefixIcon: Icon(Icons.account_circle, color: Colors.teal),
        filled: true,
        fillColor: Colors.teal.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _registerUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.teal.withOpacity(0.3),
        elevation: 5,
      ),
      child: Text('Daftar', style: TextStyle(fontSize: 18)),
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Text(
        'Sudah punya akun? Login di sini',
        style: TextStyle(color: Colors.teal, fontSize: 16),
      ),
    );
  }
}
