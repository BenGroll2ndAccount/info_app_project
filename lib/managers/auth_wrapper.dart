// To either display the Loginscreen or the Homescreen depending on if you're logged in 

import 'package:flutter/material.dart';
import 'package:empty_project_template/services/user_service.dart'
    as user_service;
import 'package:empty_project_template/screens/login_screen.dart';
import 'package:empty_project_template/managers/role_manager.dart';


class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: user_service.isLoggedIn,
        builder: (BuildContext context, bool value, Widget bruh) {
          if (value) {
            // If you're already logged in -> RoleManager ( decides which HomeScreen you see )
            return RoleManager();
          } else {
            // If not, shows you the LoginScreen  -> Only change the variable 'user_service.isLoggedIn' to change between login and home
            return LoginScreen();
          }

          //return value ? RoleManager() : LoginAuth();
        });
  }
}
