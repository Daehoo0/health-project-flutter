import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_project_flutter/AuthProvider.dart';
import 'package:health_project_flutter/pages/admin/homeadmin.dart';
import 'package:health_project_flutter/pages/dokter/homedokter.dart';
import 'package:health_project_flutter/pages/register.dart';
import 'package:health_project_flutter/pages/user/homeuser.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isHoveringLogin = false;
  bool _isHoveringRegister = false;
  bool _isHoveringForgot = false;

  void _showErrorDialog(String message) {
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
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Login Gagal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
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

  Future<void> _login() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Email dan kata sandi tidak boleh kosong!');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Periksa apakah email dan password sesuai untuk admin
    if (email == 'admin' && password == 'admin') {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeAdmin(userData: {}),
        ),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      context.read<DataLogin>().setuserlogin(uid);

      // Ambil data pengguna berdasarkan UID
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        if (userData['role'] == 'dokter') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeDokter(userData: userData),
            ),
          );
        } else if (userData['role'] == 'Pasien') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeUser(userData: userData),
            ),
          );
        } else {
          _showErrorDialog('Role tidak valid!');
        }
        return;
      } else {
        _showErrorDialog('Akun tidak ditemukan!');
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'Login gagal! Silakan coba lagi.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      body: isWeb ? _buildWebLayout(screenSize) : _buildMobileLayout(screenSize),
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
    'lib/assets/login.json',
    fit: BoxFit.contain,
    ),
    ),
    SizedBox(height: 32),
    Text(
    'Selamat Datang di\nHealthcare Platform',
    textAlign: TextAlign.center,
    style: TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.3,
    ),
    ),
    SizedBox(height: 16),
    Container(
    width: screenSize.width * 0.3,
    child: Text(
    'Platform kesehatan terpercaya untuk menghubungkan pasien dengan dokter profesional',
    textAlign: TextAlign.center,
    style: TextStyle(
    color: Colors.white.withOpacity(0.9),
    fontSize: 16,
    height: 1.5,
    ),
    ),
    ),
    ],
    ),
      ),
      ),

        // Right side - Login form
        Expanded(
          flex: 4,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
                SizedBox(height: 40),
                _buildLoginForm(true),
              ],
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Container(
              height: screenSize.height * 0.25,
              child: Lottie.asset(
                'lib/assets/login.json',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Selamat Datang!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 40),
            _buildLoginForm(false),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isWeb) {
    return Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Email field
          _buildTextField(
          controller: emailController,
          label: 'Email',
          icon: Icons.email,
          isPassword: false,
        ),
        SizedBox(height: 20),

        // Password field
        _buildTextField(
          controller: passwordController,
          label: 'Kata Sandi',
          icon: Icons.lock,
          isPassword: true,
        ),
        SizedBox(height: 30),

        // Login button
        MouseRegion(
          onEnter: (_) => setState(() => _isHoveringLogin = true),
          onExit: (_) => setState(() => _isHoveringLogin = false),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            transform: Matrix4.identity()
              ..translate(0, _isHoveringLogin ? -2 : 0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: _isHoveringLogin ? 8 : 4,
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
                'Login',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 24),

        // Additional links
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            MouseRegion(
            onEnter: (_) => setState(() => _isHoveringRegister = true),
    onExit: (_) => setState(() => _isHoveringRegister = false),
    child: GestureDetector(
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
    },
    child: Text(
    'Daftar Akun',
    style: TextStyle(
    color: Colors.teal,
    fontWeight: FontWeight.w500,
    decoration: _isHoveringRegister ? TextDecoration.underline : TextDecoration.none,
    ),
    ),
    ),
    ),
    SizedBox(width: 20),
    Text('|', style: TextStyle(color: Colors.grey)),
    SizedBox(width: 20),
    MouseRegion(
    onEnter: (_) => setState(() => _isHoveringForgot = true),
    onExit: (_) => setState(() => _isHoveringForgot = false),
    ),
            ],
        ),
          ],
        ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isPassword,
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
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
    ),
    ),
    );
  }
}
