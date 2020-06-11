// Where mainly all dataflows are managed. Way to communicate with the database and the devices filesystem.

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:empty_project_template/managers/student_screendata.dart'
    as student_data;
import 'package:empty_project_template/screens/student_course_screen.dart'
    as student_course_screen;

ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

// Stores the data of the User once logged in to issue less calls to the database -> less waiting time
ValueNotifier<User> userData = ValueNotifier<User>(User());

class User {
  String id;
  String password;
  String role;
  List<dynamic> courses;
  User({this.id, this.password, this.role, this.courses});
}

// Return reference to credentials.txt
Future<File> get _credentialsDocumentReference async {
  String path =
      await getApplicationDocumentsDirectory().then((value) => value.path);
  return File('$path/credentials.txt');
}

// Check if the credentials.txt file exists
Future<bool> get credentialsExist async {
  return _credentialsDocumentReference.then((value) => value.exists());
}

Future<bool> get credentialsSaved async {
  List<String> test = await credentials.then((value) => value);
  if (test != null) {
    return true;
  } else {
    return false;
  }
}

// Function to test if you have saved credentials and if they match the database
Future<bool> tryLogginInSaved() async {
  Future<bool> fileExists = credentialsExist;
  return fileExists.then((value) async {
    bool saved = await credentialsSaved;
    if (value && saved) {
      String id = await credentials.then((value) => value[0]);
      String password = await credentials.then((value) => value[1]);
      String neededPassword = await getUserProperty_base(id, 'password');
      String role = await getUserProperty_base(id, 'role');
      if (password == neededPassword) {
        isLoggedIn.value = true;
        userData.value = User(id: id, password: neededPassword, role: role);
        return true;
      } else {
        isLoggedIn.value = false;
        userData.value = User();
        return false;
      }
    } else {
      isLoggedIn.value = false;
      userData.value = User();
      return false;
    }
  });
}

// function to get the credentials. If not saved, will return null.
Future<List<String>> get credentials async {
  return credentialsExist.then((exist) async {
    if (exist) {
      String credString = await _credentialsDocumentReference
          .then((value) => value.readAsString());
      List<String> creds = credString.split(" ");
      if (creds[0] == "" || creds[1] == "") {
        return null;
      } else {
        return creds;
      }
    } else {
      return null;
    }
  });
}

// Function to write (new) credentials to credentials.txt
void writeCredentials(String id, String password) {
  credentialsExist.then((value) {
    if (value) {
      _credentialsDocumentReference.then((value) {
        credentials.then((valu) => print((valu == null)));
      });
    } else {
      _credentialsDocumentReference.then((value) => value.create());
      _credentialsDocumentReference
          .then((value) => value.writeAsString('$id $password'));
    }
  });
}

// Function to delete the credentials.txt file. Does nothing if the file does not exist
void deleteCredentialsFile() {
  credentialsExist.then((value) {
    if (value) {
      _credentialsDocumentReference.then((value) => value.delete());
    }
  });
}

// Function to get a property out of a file of a user
Future getUserProperty_base(id, prop) {
  return Firestore.instance
      .collection('users')
      .document(id)
      .get()
      .then((value) {
    return value[prop];
  });
}

// ----------------------------------Student------------------------------ //

// Function to get the list of courses a student is in. Returns a list of widgets to use in a ListView
Future<List<Widget>> getUserCoursesStudent(uid) async {
  // gets the 'courses' array from the user
  dynamic courses = await Firestore.instance
      .collection('users')
      .document('000')
      .get()
      .then((value) => value['courses']);
  List<StudentCourseData> coursesnew = [];
  // Converts the array of ID'S into a List of CourseData objects, one for each course.
  for (int i = 0; i < courses.length; i++) {
    DocumentSnapshot newdata = await Firestore.instance
        .collection('courses')
        .document(courses[i])
        .get();
    List<StudentTabData> courseTabsData = [];
    for (int j = 0; j < newdata["tabs"].length; j++) {
      String tabID = newdata["tabs"][j];
      DocumentSnapshot newTabData = await Firestore.instance
          .collection("course-tabs")
          .document(tabID)
          .get();
      StudentTabData finalTabData = StudentTabData(
          id: tabID,
          name: newTabData["name"],
          contents: newTabData["contents"]);
      courseTabsData.add(finalTabData);
    }
    StudentCourseData newCourseData = StudentCourseData(
        id: courses[i],
        members: newdata["members"],
        teacher: newdata["teacher"],
        name: newdata["name"],
        tabs: courseTabsData);
    coursesnew.add(newCourseData);
  }
  // Updates the property in the UserData object which stores the information of all courses. This will update everytime the CourseList is loaded
  User current_data = userData.value;
  userData.value = User(
      id: current_data.id,
      password: current_data.password,
      role: current_data.role,
      courses: coursesnew);
  // Convert the List of CourseData objects into CourseButtonWidgets for display and interaction.
  List<StudentCourseButtonWidget> widgets = coursesnew
      .map((e) => StudentCourseButtonWidget(
            name: e.name,
            teacher: e.teacher,
            id: e.id,
          ))
      .toList();
  // returns the List of CourseButtonWidgets
  return widgets;
}

// Object to store all information about a Course in.
class StudentCourseData {
  List<Widget> get getTabWidgets {
    if (userData.value.role == "s") {
      return tabs
          .map((e) =>
              student_course_screen.StudentTabWidget(id: e.id, name: e.name))
          .toList();
    }
  }

  String id;
  String name;
  String teacher;
  List<dynamic> members;
  List<StudentTabData> tabs;
  StudentCourseData({this.name, this.teacher, this.members, this.id, this.tabs})
      : super();
}

class StudentTabData {
  String id;
  String name;
  List<dynamic> contents;
  StudentTabData({this.id, this.name, this.contents}) : super();
}

// Widget that gets displayed in the StudentHomeScreen Courses Card inside the ListView. If pressed, leads to the page of the course.
class StudentCourseButtonWidget extends StatefulWidget {
  final String name;
  final String teacher;
  final String id;

  StudentCourseButtonWidget({this.name, this.teacher, this.id}) : super();
  @override
  _StudentCourseButtonWidgetState createState() =>
      _StudentCourseButtonWidgetState();
}

class _StudentCourseButtonWidgetState extends State<StudentCourseButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FlatButton(
        onPressed: () {
          student_data.openCourse(widget.id);
        },
        child: Card(
          color: Colors.blue[100],
          elevation: 6.0,
          child: Container(
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(widget.name, style: TextStyle(fontSize: 30.0)),
                    Text(widget.teacher, style: TextStyle(fontSize: 20.0))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<StudentCourseData> getCourseDisplayInfoStudent(String search_id) async {
  dynamic courses = userData.value.courses;
  for (int i = 0; i < courses.length; i++) {
    if (courses[i].id == search_id) {
      return courses[i];
    }
  }
  return StudentCourseData(
      id: "-00", members: [], teacher: "", name: "Kurs nicht gefunden!");
}

// -------------------------------- TEACHER ----------------------------------------------- //
Future<List<Widget>> getUserCoursesTeacher(uid) async {
  // gets the 'courses' array from the user
  dynamic courses = await Firestore.instance
      .collection('users')
      .document('000')
      .get()
      .then((value) => value['courses']);
  List<TeacherCourseData> coursesnew = [];
  // Converts the array of ID'S into a List of CourseData objects, one for each course.
  for (int i = 0; i < courses.length; i++) {
    DocumentSnapshot newdata = await Firestore.instance
        .collection('courses')
        .document(courses[i])
        .get();
    List<TeacherTabData> courseTabsData = [];
    for (int j = 0; j < newdata["tabs"].length; j++) {
      String tabID = newdata["tabs"][j];
      DocumentSnapshot newTabData = await Firestore.instance
          .collection("course-tabs")
          .document(tabID)
          .get();
      TeacherTabData finalTabData = TeacherTabData(
          id: tabID,
          name: newTabData["name"],
          contents: newTabData["contents"]);
      courseTabsData.add(finalTabData);
    }
    TeacherCourseData newCourseData = TeacherCourseData(
        id: courses[i],
        members: newdata["members"],
        teacher: newdata["teacher"],
        name: newdata["name"],
        tabs: courseTabsData);
    coursesnew.add(newCourseData);
  }
  // Updates the property in the UserData object which stores the information of all courses. This will update everytime the CourseList is loaded
  User current_data = userData.value;
  userData.value = User(
      id: current_data.id,
      password: current_data.password,
      role: current_data.role,
      courses: coursesnew);
  // Convert the List of CourseData objects into CourseButtonWidgets for display and interaction.
  List<TeacherCourseButtonWidget> widgets = coursesnew
      .map((e) => TeacherCourseButtonWidget(
            name: e.name,
            teacher: e.teacher,
            id: e.id,
          ))
      .toList();
  // returns the List of CourseButtonWidgets
  return widgets;
}

// Object to store all information about a Course in.
class TeacherCourseData {
  List<Widget> get getTabWidgets {
    if (userData.value.role == "s") {
      return tabs
          .map((e) =>
              student_course_screen.StudentTabWidget(id: e.id, name: e.name))
          .toList();
    }
  }

  String id;
  String name;
  String teacher;
  List<dynamic> members;
  List<TeacherTabData> tabs;
  TeacherCourseData({this.name, this.teacher, this.members, this.id, this.tabs})
      : super();
}

class TeacherTabData {
  String id;
  String name;
  List<dynamic> contents;
  TeacherTabData({this.id, this.name, this.contents}) : super();
}

// Widget that gets displayed in the StudentHomeScreen Courses Card inside the ListView. If pressed, leads to the page of the course.
class TeacherCourseButtonWidget extends StatefulWidget {
  final String name;
  final String teacher;
  final String id;

  TeacherCourseButtonWidget({this.name, this.teacher, this.id}) : super();
  @override
  _TeacherCourseButtonWidgetState createState() =>
      _TeacherCourseButtonWidgetState();
}

class _TeacherCourseButtonWidgetState extends State<TeacherCourseButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FlatButton(
        onPressed: () {
          student_data.openCourse(widget.id);
        },
        child: Card(
          color: Colors.blue[100],
          elevation: 6.0,
          child: Container(
            child: Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 10.0),
                      Text(widget.name, style: TextStyle(fontSize: 30.0)),
                      SizedBox(width: 4.0),
                      Expanded(
                        child: Container(),
                      ),
                      SizedBox(width: 4.0),
                      IconButton(
                        icon: Icon(Icons.reorder), 
                        onPressed: () {},
                        iconSize: 40.0,
                        ),
                        SizedBox(width: 10.0),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

Future<TeacherCourseData> getCourseDisplayInfoTeacher(String search_id) async {
  dynamic courses = userData.value.courses;
  for (int i = 0; i < courses.length; i++) {
    if (courses[i].id == search_id) {
      return courses[i];
    }
  }
  return TeacherCourseData(
      id: "-00", members: [], teacher: "", name: "Kurs nicht gefunden!");
}
