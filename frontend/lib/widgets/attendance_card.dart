import 'package:flutter/material.dart';
class AttendanceCard extends StatelessWidget { final String title,status; const AttendanceCard({super.key,required this.title,required this.status}); @override Widget build(BuildContext context)=>Card(child:ListTile(title:Text(title),subtitle:Text(status))); }
