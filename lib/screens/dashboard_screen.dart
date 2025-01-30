import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'classes_screen.dart';
import 'login_screen.dart'; // Import your login screen

class DashboardScreen extends StatelessWidget {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  DashboardScreen({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await _secureStorage.delete(key: 'auth_token'); // Clear stored token

    // Navigate to login screen and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,  // White text color
            fontWeight: FontWeight.bold,  // Bold text
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 Image from URL
                Image.network(
                  'https://media.licdn.com/dms/image/v2/D4D0BAQH8qMQ3Czo41g/company-logo_200_200/company-logo_200_200/0/1685347099285/army_institute_of_technology_ait_pune_logo?e=2147483647&v=beta&t=Zo0npbwdxmAnlYv7UGN1gt7tS0GkNgeMIi60PJF4fzA', // Replace with your image URL
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                  },
                ),
                const SizedBox(height: 20),

                // 🔹 Welcome Text
                const Text(
                  "Welcome to AIT Attendance",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // 🔹 Manage Classes Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ClassesScreen()),
                    );
                  },
                  child: const Text("Manage Classes"),
                ),
              ],
            ),
          ),

          // 🔹 Logout Button at Bottom Right
          Positioned(
            bottom: 50,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("Logout", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
