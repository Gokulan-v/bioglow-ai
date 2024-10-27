import 'package:bioglow_ai/bot/chatbot_page.dart';
import 'package:flutter/material.dart';
import 'authentication/loginpage.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatbot Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatbotPage(),
    );
  }
}
