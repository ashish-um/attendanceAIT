import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ClassDetailsScreen extends StatefulWidget {
  final String classId;
  final String className;
  final List<dynamic> students;

  const ClassDetailsScreen({
    Key? key,
    required this.classId,
    required this.className,
    required this.students,
  }) : super(key: key);

  @override
  _ClassDetailsScreenState createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Set<String> _absentRollNumbers = {};
  List<dynamic> _attendanceLogs = [];
  bool _isLoadingLogs = false;
  bool _isSubmitting = false;

  Future<void> _submitAttendance() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        print("❌ Error: No auth token found.");
        return;
      }

      final response = await http.post(
        Uri.parse('https://attendence-backend-zeta.vercel.app/attendance'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode({
          "classId": widget.classId,
          "absentRollNumbers": _absentRollNumbers.toList(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Attendance recorded successfully")),
        );
        setState(() {
          _absentRollNumbers.clear();
        });
      } else {
        print("❌ Error recording attendance: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception in recording attendance: $e");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _fetchAttendanceLogs() async {
    setState(() {
      _isLoadingLogs = true;
    });

    try {
      String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        print("❌ Error: No auth token found.");
        return;
      }

      final response = await http.get(
        Uri.parse('https://attendence-backend-zeta.vercel.app/attendance/${widget.classId}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _attendanceLogs = jsonDecode(response.body);
          _isLoadingLogs = false;
        });

        _showAttendanceLogsDialog();
      } else {
        print("❌ Error fetching attendance logs: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception in fetching attendance logs: $e");
    } finally {
      setState(() {
        _isLoadingLogs = false;
      });
    }
  }

  void _showAttendanceLogsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Attendance Logs"),
        content: _attendanceLogs.isEmpty
            ? const Text("No attendance records found.")
            : SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: _attendanceLogs.length,
            itemBuilder: (context, index) {
              final log = _attendanceLogs[index];
              final date = DateTime.parse(log['date']).toLocal();
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text("📅 Date: ${date.toString().split(' ')[0]}"),
                  subtitle: Text("🚫 Absent: ${log['absentStudents'].join(', ')}"),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className),
        actions: [
          IconButton(
            icon: _isLoadingLogs
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.history),
            onPressed: _fetchAttendanceLogs,
            tooltip: "View Attendance Logs",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.students.length,
              itemBuilder: (context, index) {
                final student = widget.students[index];
                return CheckboxListTile(
                  title: Text("${student['name']} - ${student['rollNo']}"),
                  value: _absentRollNumbers.contains(student['rollNo']),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _absentRollNumbers.add(student['rollNo']);
                      } else {
                        _absentRollNumbers.remove(student['rollNo']);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _absentRollNumbers.isEmpty || _isSubmitting
                    ? null
                    : _submitAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(15),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Submit Attendance",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
