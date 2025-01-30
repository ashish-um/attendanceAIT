import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AttendanceScreen extends StatefulWidget {
  final String classId;
  AttendanceScreen({required this.classId});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ApiService _apiService = ApiService();
  List<String> absentStudents = [];

  void _markAttendance() async {
    try {
      await _apiService.markAttendance(widget.classId, absentStudents);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Attendance Marked!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to mark attendance: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mark Attendance")),
      body: Column(
        children: [
          Text("Select absent students"),
          ElevatedButton(onPressed: _markAttendance, child: Text("Submit")),
        ],
      ),
    );
  }
}
