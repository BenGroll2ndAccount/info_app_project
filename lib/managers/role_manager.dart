import 'dart:io';
import 'package:flutter/material.dart';
import 'package:empty_project_template/services/user_service.dart' as user_service;
// HomeScreens
import 'package:empty_project_template/screens/student_homescreen.dart';
import 'package:empty_project_template/screens/teacher_homescreen.dart';
import 'package:empty_project_template/screens/dev_homescreen.dart';


// Decides which HomeScreen you see depending on if you're a student, teacher of dev.
class RoleManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (user_service.userData.value.role == "s") {
      return StudentDirManager();
    } else if (user_service.userData.value.role == "t") {
      return TeacherDirManager();
    } else if (user_service.userData.value.role == "d") {
      return DevHomeScreen();
    } else {
      return Center(
        child: Container(
          child:Text(
            // If your role is not set or does not match the preset ones, this will get shown
            // Replace with support page is inteded
            'Keine Rolle angegeben. Support: '),
       )
      );
    }
  }
}
