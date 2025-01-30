import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/classes_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Attendance Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Show login screen if not authenticated
            if (!authProvider.isAuthenticated) {
              return LoginScreen();
            }
            // Show dashboard screen if authenticated
            return DashboardScreen();
          },
        ),
        routes: {
          '/dashboard': (context) => DashboardScreen(),
          '/classes': (context) => ClassesScreen(), // Add route for classes
        },
      ),
    );
  }
}
