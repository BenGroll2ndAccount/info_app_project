import 'dart:io';
import 'package:flutter/material.dart';
import 'package:empty_project_template/services/user_service.dart' as user_service;
// HomeScreens
import 'package:empty_project_template/screens/student_homescreen.dart';
import 'package:empty_project_template/screens/teacher_homescreen.dart';
import 'package:empty_project_template/screens/dev_homescreen.dart';



class RoleManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (user_service.userData.value.role == "s") {
      return DirManager();
    } else if (user_service.userData.value.role == "t") {
      return TeacherHomeScreen();
    } else if (user_service.userData.value.role == "d") {
      return DevHomeScreen();
    } else {
      return Center(
        child: Container(
          child:Text(
            'Keine Rolle angegeben. Bitte melden sie sich beim Zuständigen.'),
       )
      );
    }
  }
}
