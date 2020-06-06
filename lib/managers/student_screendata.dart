import 'package:flutter/material.dart';

ValueNotifier<String> current_dir = ValueNotifier<String>("Home");

  bool has_course_opened = false;
  String course_open_id = "";

void openCourse(id){
  current_dir.value = "Course " + id.toString();
}