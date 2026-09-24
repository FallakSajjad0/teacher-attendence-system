import 'package:flutter/material.dart';
class NotificationBanner extends StatelessWidget { final String message; const NotificationBanner({super.key,required this.message}); @override Widget build(BuildContext context)=>Container(width:double.infinity,padding:const EdgeInsets.all(12),child:Text(message)); }
