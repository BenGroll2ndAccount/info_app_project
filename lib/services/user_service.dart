import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:empty_project_template/managers/student_screendata.dart'
    as student_data;

ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

ValueNotifier<User> userData = ValueNotifier<User>(User());

class User {
  String id;
  String password;
  String role;
  List<CourseData> courses;
  User({this.id, this.password, this.role, this.courses});
}

// Return reference to credentials.txt
Future<File> get _credentialsDocumentReference async {
  String path =
      await getApplicationDocumentsDirectory().then((value) => value.path);
  return File('$path/credentials.txt');
}

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

Future getUserProperty_base(id, prop) {
  return Firestore.instance
      .collection('users')
      .document(id)
      .get()
      .then((value) {
    return value[prop];
  });
}

void deleteCredentialsFile() {
  credentialsExist.then((value) {
    if (value) {
      _credentialsDocumentReference.then((value) => value.delete());
    }
  });
}

Future<List<Widget>> getUserCourses(uid) async {
  dynamic courses = await Firestore.instance
      .collection('users')
      .document('000')
      .get()
      .then((value) => value['courses']);
  var coursesnew = [];
  for (int i = 0; i < courses.length; i++) {
    DocumentSnapshot newdata = await Firestore.instance
        .collection('courses')
        .document(courses[i])
        .get();
    coursesnew.add(newdata);
  }
  List<CourseData> coursesData = coursesnew
      .map((e) => CourseData(
          members: e["members"], teacher: e["teacher"], name: e["name"]))
      .toList();
  User current_data = userData.value;
  userData.value = User(
      id: current_data.id,
      password: current_data.password,
      role: current_data.role,
      courses: coursesData);

  List<CourseButtonWidget> widgets = coursesData
      .map((e) => CourseButtonWidget(
            name: e.name,
            teacher: e.teacher,
          ))
      .toList();
  return widgets;
}

class CourseData {
  String id;
  String name;
  String teacher;
  List<dynamic> members;
  CourseData({this.name, this.teacher, this.members}) : super();
}

class CourseButtonWidget extends StatefulWidget {
  final String name;
  final String teacher;

  CourseButtonWidget({this.name, this.teacher}) : super();
  @override
  _CourseButtonWidgetState createState() => _CourseButtonWidgetState();
}

class _CourseButtonWidgetState extends State<CourseButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FlatButton(
        onPressed: () {
          student_data.current_dir.value = "Course";
          if (userData.value.role == "s") {
          } else if (userData.value.role == "t") {
          } else if (userData.value.role == "d") {}
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
