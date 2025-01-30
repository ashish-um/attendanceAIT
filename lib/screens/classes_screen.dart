import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/auth_provider.dart';
import 'class_details_screen.dart';

class ClassesScreen extends StatefulWidget {
  @override
  _ClassesScreenState createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  List<dynamic> _classes = [];
  bool _isLoading = true;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final TextEditingController _classNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    try {
      String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        print("❌ Error: No auth token found.");
        return;
      }

      final response = await http.get(
        Uri.parse('https://attendence-backend-zeta.vercel.app/classes'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _classes = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        print("❌ Error fetching classes: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception in fetching classes: $e");
    }
  }

  Future<void> _createClass() async {
    String className = _classNameController.text.trim();
    if (className.isEmpty || _students.isEmpty) {
      print("❌ Error: Class name or student list is empty.");
      return;
    }

    try {
      String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        print("❌ Error: No auth token found.");
        return;
      }

      final response = await http.post(
        Uri.parse('https://attendence-backend-zeta.vercel.app/classes'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode({
          "className": className,
          "students": _students,
        }),
      );

      if (response.statusCode == 201) {
        print("✅ Class created successfully.");
        _fetchClasses();
        Navigator.pop(context);
      } else {
        print("❌ Error creating class: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception in creating class: $e");
    }
  }

  List<Map<String, String>> _students = [];

  void _showCreateClassDialog() {
    TextEditingController studentNameController = TextEditingController();
    TextEditingController rollNoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text("Create Class", style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _classNameController,
                    decoration: const InputDecoration(
                      labelText: "Class Name",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("Add Students", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: studentNameController,
                    decoration: const InputDecoration(
                      labelText: "Student Name",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: rollNoController,
                    decoration: const InputDecoration(
                      labelText: "Roll No",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (studentNameController.text.isNotEmpty && rollNoController.text.isNotEmpty) {
                        setState(() {
                          _students.add({
                            "name": studentNameController.text,
                            "rollNo": rollNoController.text,
                          });
                        });
                        studentNameController.clear();
                        rollNoController.clear();
                      }
                    },
                    child: const Text(
                      "Add Student",
                      style: TextStyle(
                        color: Colors.white,  // Set text color to white for contrast
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_students.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text("${_students[index]['name']} - ${_students[index]['rollNo']}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _students.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _students.clear();
                },
                child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: _createClass,
                child: const Text("Create", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Classes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
          ? const Center(child: Text("No classes found.", style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                _classes[index]['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                "Total Students: ${_classes[index]['students'].length}",
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: Icon(Icons.arrow_forward, color: Colors.blueAccent),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassDetailsScreen(
                      classId: _classes[index]['_id'],
                      className: _classes[index]['name'],
                      students: _classes[index]['students'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateClassDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
