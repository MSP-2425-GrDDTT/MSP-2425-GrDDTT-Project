import 'package:flutter/material.dart';
import 'package:flutter_app_test/data_classes/user_data.dart';
import 'enter_app_options.dart';
import '../home/home_page.dart';
import 'create_account_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Error message to display
  String _errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan.withOpacity(0.6), Colors.cyanAccent.withOpacity(0.9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Logo
                      Center(
                        child: Image.asset(
                          'assets/logo_transp.png',
                          height: 160,
                          width: 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Login Text
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xD2FFFFFF),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Email Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF289CB6)),
                            hintText: 'Email',
                            hintStyle: TextStyle(fontSize: 16),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          obscureText: true,
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF289CB6)),
                            hintText: 'Password',
                            hintStyle: TextStyle(fontSize: 16),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Show error message if credentials don't match
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.pink, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                      // Login Button
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF289CB6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            minimumSize: const Size(200, 50),
                          ),
                          onPressed: () {
                            String email = _emailController.text.trim();
                            String password = _passwordController.text.trim();

                            // Check if the credentials match with the singleton
                            if (UserData.instance.email == email && UserData.instance.password == password) {
                              // Navigate to HomePage without initializing UserData
                              UserData.instance.isLoggedIn = true;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            } else {
                              // Show error message if credentials don't match
                              setState(() {
                                _errorMessage = "The email or password is incorrect. Please try again.";
                              });
                            }
                          },
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Forgot Password and Create Account
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account?",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CreateAccountPage()),
                                    );
                                  },
                                  child: const Text(
                                    'Create account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFFFFFF),
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFFFFFFFF),
                                      decorationThickness: 1.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Back Button at the top-left
          Positioned(
            top: 24,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
