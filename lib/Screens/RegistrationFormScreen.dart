/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/scheduler.dart';

import 'HomeScreen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLogin = true;
  String _email = '', _password = '', _name = '', _mobile = '';
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _switchMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        if (_isLogin) {
          await _auth.signInWithEmailAndPassword(email: _email, password: _password);
        } else {
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
              email: _email, password: _password);
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'name': _name,
            'mobile': _mobile,
            'email': _email,
          });
        }
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _navigateToHomeScreen();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _navigateToHomeScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) =>  HomePage()),
    );
  }

  void _forgotPassword() async {
    if (_email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email to reset password')),
      );
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: _email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<bool> _checkUserLoggedIn() async {
    User? user = _auth.currentUser;
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.data == true) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _navigateToHomeScreen();
          });
          return const SizedBox(); // Return an empty widget to avoid errors
        } else {
          return Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return _buildLargeScreenLayout(constraints);
                } else {
                  return _buildSmallScreenLayout(constraints);
                }
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildLargeScreenLayout(BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A5F7A), Color(0xFF159895)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.network(
                  'https://assets2.lottiefiles.com/packages/lf20_jcikwtux.json',
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome to EduNet',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Empowering minds, one click at a time',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildAuthForm(constraints),
        ),
      ],
    );
  }

  Widget _buildSmallScreenLayout(BoxConstraints constraints) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A5F7A), Color(0xFF159895)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://assets2.lottiefiles.com/packages/lf20_jcikwtux.json',
              width: 200,
              height: 200,
            ),
            const Text(
              'Welcome to EduNet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Empowering minds, one click at a time',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildAuthForm(constraints),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthForm(BoxConstraints constraints) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              width: constraints.maxWidth > 800 ? 400 : constraints.maxWidth * 0.9,
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isLogin ? 'Welcome Back' : 'Join EduNet',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A5F7A),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (!_isLogin) _buildTextField('Name', Icons.person),
                    if (!_isLogin) const SizedBox(height: 16),
                    if (!_isLogin)
                      _buildTextField('Mobile Number', Icons.phone, TextInputType.phone),
                    if (!_isLogin) const SizedBox(height: 16),
                    _buildTextField('Email', Icons.email, TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildTextField('Password', Icons.lock, TextInputType.visiblePassword,
                         true),
                    const SizedBox(height: 16),
                    if (_isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Color(0xFF1A5F7A)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF57C5B6),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _isLogin ? 'Login' : 'Sign Up',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _switchMode,
                      child: Text(
                        _isLogin ? "Don't have an account? Sign Up" : 'Already have an account? Login',
                        style: const TextStyle(color: Color(0xFF1A5F7A)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, IconData icon,
      [TextInputType? keyboardType, bool isPassword = false]) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1A5F7A)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFE0F2F1),
      ),
      keyboardType: keyboardType,
      obscureText: isPassword,
      validator: (value) {
        if (value!.isEmpty) return 'Please enter $label';
        if (label == 'Email' && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        if (label == 'Password' && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        if (label == 'Mobile Number' && value.length != 10) {
          return 'Mobile number must be 10 digits';
        }
        return null;
      },
      onSaved: (value) {
        switch (label) {
          case 'Name':
            _name = value!;
            break;
          case 'Mobile Number':
            _mobile = value!;
            break;
          case 'Email':
            _email = value!;
            break;
          case 'Password':
            _password = value!;
            break;
        }
      },
    );
  }
}
/*import 'package:edunet/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'Screens/RegistrationFormScreen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //statusBarIconBrightness: Brightness.light,
    statusBarColor: Color(0xFF159895),
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduNet',
      theme: ThemeData(
        primaryColor: const Color(0xFF159895),
        appBarTheme: const AppBarTheme(color: Color(0xFF159895)),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF159895),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        dialogTheme: const DialogTheme(
            // backgroundColor: Colors.white,
            ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor:
                const Color(0xFF159895), // Global text button color
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF159895), // Global progress indicator color
        ),
      ),
      home: const HomePage(),
    );
  }
}
*/
 */