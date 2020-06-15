import 'package:flutter/material.dart';

ValueNotifier<String> current_dir = ValueNotifier<String> ("Home");

void openCourse(id) {
  current_dir.value = "Course " + id.toString();
}

Future<bool> closeCourse() async {
  current_dir.value = "Home";
  return false;
}
