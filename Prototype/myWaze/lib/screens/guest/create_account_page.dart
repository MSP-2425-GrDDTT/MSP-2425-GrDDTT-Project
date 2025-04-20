import 'package:flutter/material.dart';
import 'package:flutter_app_test/data_classes/user_data.dart';
import 'enter_app_options.dart';
import '../home/home_page.dart';
import 'login_page.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Error message to display
  String _errorMessage = '';

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
                      // Create Account Text
                      const Text(
                        'Create an Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xD2FFFFFF),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Name Field
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
                          controller: nameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF289CB6)),
                            hintText: 'Name',
                            hintStyle: TextStyle(fontSize: 16),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                          controller: emailController,
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
                          controller: passwordController,
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
                      // Show error message if any field is empty
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.pink, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Create Account Button
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
                            String name = nameController.text.trim();
                            String email = emailController.text.trim();
                            String password = passwordController.text.trim();

                            // Check if all fields are filled
                            if (name.isEmpty || email.isEmpty || password.isEmpty) {
                              // Set error message if fields are empty
                              setState(() {
                                _errorMessage = 'All fields must be filled!';
                              });
                            } else {
                              // Initialize user singleton with the provided data
                              UserData.instance.initialize(email: email, name: name, password: password);

                              // Clear the error message
                              setState(() {
                                _errorMessage = '';
                              });

                              // Show success popup
                              // Show success popup
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Success'),
                                  content: const Text('Your account has been created!'),
                                  actions: [
                                    // Orange button for the OK action
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF289CB6), // Set the background color to orange
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12), // Optional: Add rounded corners
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Optional: Adjust padding
                                      ),
                                      onPressed: () {
                                        // Close the dialog and navigate to HomePage
                                        Navigator.pop(context); // Close the dialog
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const HomePage()),
                                        );
                                      },
                                      child: const Text(
                                        'OK',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white, // Set the text color to white inside the orange button
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                            }
                          },
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Already have an account link
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(fontSize: 16, color: Color(
                                  0xFFFFFFFF), fontWeight: FontWeight.w500),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate back to LoginPage
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginPage()),
                                );
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFFFFF),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFFFFFFFF),
                                  decorationThickness: 1.8,
                                ),
                              ),
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
          // Back Button at the top-right
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
