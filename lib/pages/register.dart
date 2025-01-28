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
  final TextEditingController _specializationController = TextEditingController(); // New controller for specialization

  String _selectedGender = 'Laki-laki';
  String _selectedRole = 'Pasien'; // Default to Pasien
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isHoveringRegister = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  message.contains('berhasil') ? Icons.check_circle : Icons
                      .error_outline,
                  color: message.contains('berhasil') ? Colors.green : Colors
                      .red,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  message.contains('berhasil') ? 'Sukses' : 'Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: message.contains('berhasil') ? Colors.green : Colors
                        .red,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _registerUser() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();
      String height = _heightController.text.trim();
      String weight = _weightController.text.trim();
      String specialization = _specializationController.text.trim();

      if (name.isEmpty || email.isEmpty || password.isEmpty ||
          confirmPassword.isEmpty || height.isEmpty || weight.isEmpty) {
        _showMessage('Semua field harus diisi!');
        return;
      }

      if (password != confirmPassword) {
        _showMessage('Password dan konfirmasi password tidak cocok!');
        return;
      }

      if (_selectedRole == 'Dokter' && specialization.isEmpty) {
        _showMessage('Specialization harus diisi untuk Dokter!');
        return;
      }

      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
          email: email, password: password);

      final userForUsersTable = {
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'dokter',
        'specialization': specialization,
        'is_active': 0,
        "profile": "",
      };
      await _firestore.collection('users').doc(userCredential.user?.uid).set(
          userForUsersTable);
    } catch (e) {
      _showMessage('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery
        .of(context)
        .size;
    final bool isWeb = screenSize.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isWeb ? _buildWebLayout(screenSize) : _buildMobileLayout(
          screenSize),
    );
  }

  Widget _buildWebLayout(Size screenSize) {
    return Row(
      children: [
        // Left side - Decorative section
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.teal.shade400,
                  Colors.teal.shade800,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: screenSize.height * 0.4,
                  child: Lottie.asset(
                    'lib/assets/register.json',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  'Buat Akun Baru\nHealthcare Platform',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right side - Registration form
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  _buildRegistrationForm(true),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Size screenSize) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 60),
            Container(
              height: screenSize.height * 0.25,
              child: Lottie.asset(
                'lib/assets/register.json',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Buat Akun Baru',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 40),
            _buildRegistrationForm(false),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm(bool isWeb) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Nama Lengkap',
            icon: Icons.person,
            isPassword: false,
          ),
          SizedBox(height: 20),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            isPassword: false,
          ),
          SizedBox(height: 20),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock,
            isPassword: true,
          ),
          SizedBox(height: 20),
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Konfirmasi Password',
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          SizedBox(height: 20),
          _buildDropdown(),
          SizedBox(height: 20),
          _buildTextField(
            controller: _heightController,
            label: 'Tinggi Badan (cm)',
            icon: Icons.height,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          _buildTextField(
            controller: _weightController,
            label: 'Berat Badan (kg)',
            icon: Icons.monitor_weight,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          _buildRoleDropdown(),
          if (_selectedRole == 'Dokter') ...[
            SizedBox(height: 20),
            _buildTextField(
              controller: _specializationController,
              label: 'Spesialisasi',
              icon: Icons.medical_services,
            ),
          ],
          SizedBox(height: 30),
          _buildRegisterButton(),
          SizedBox(height: 20),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.teal),
          prefixIcon: Icon(icon, color: Colors.teal),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.teal,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        items: [
          DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
          DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
        ],
        onChanged: (value) => setState(() => _selectedGender = value!),
        decoration: InputDecoration(
          labelText: 'Jenis Kelamin',
          labelStyle: TextStyle(color: Colors.teal),
          prefixIcon: Icon(Icons.person_outline, color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        items: [
          DropdownMenuItem(value: 'Pasien', child: Text('Pasien')),
          DropdownMenuItem(value: 'Dokter', child: Text('Dokter')),
        ],
        onChanged: (value) => setState(() => _selectedRole = value!),
        decoration: InputDecoration(
          labelText: 'Pilih Role',
          labelStyle: TextStyle(color: Colors.teal),
          prefixIcon: Icon(Icons.account_circle, color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHoveringRegister = true),
      onExit: (_) => setState(() => _isHoveringRegister = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..translate(0, _isHoveringRegister ? -2 : 0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _registerUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: _isHoveringRegister ? 8 : 4,
          ),
          child: _isLoading
              ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          )
              : Text(
            'Daftar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Text(
          'Sudah punya akun? Login di sini',
          style: TextStyle(
            color: Colors.teal,
            fontSize: 16,
            decoration: _isHoveringRegister
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
