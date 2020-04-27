import 'package:flutter/material.dart';
import 'package:empty_project_template/managers/auth_wrapper.dart';
import 'services/user_service.dart' as user_service;

void main() {

  runApp(MyApp());
  user_service.tryLogginInSaved();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyGRG',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
    );
  }
}
