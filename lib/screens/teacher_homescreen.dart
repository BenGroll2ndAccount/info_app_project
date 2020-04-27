import 'dart:io';
import 'package:empty_project_template/services/user_service.dart' as user_service;
import 'package:flutter/material.dart';


class TeacherHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: Text('Lehrer Schreibtisch'),
    ));
  }
}
