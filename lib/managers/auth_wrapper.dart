import 'package:flutter/material.dart';
import 'package:empty_project_template/services/user_service.dart'
    as user_service;
import 'package:empty_project_template/screens/login_screen.dart';
import 'package:empty_project_template/managers/role_manager.dart';

ValueNotifier<String> currentName = ValueNotifier<String>("Paul");


class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: user_service.isLoggedIn,
        builder: (BuildContext context, bool value, Widget bruh) {
          if (value) {
            return RoleManager();
          } else {
            return LoginScreen();
          }

          //return value ? RoleManager() : LoginAuth();
        });
  }
}
