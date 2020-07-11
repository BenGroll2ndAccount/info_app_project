import 'package:flutter/material.dart';
import 'package:empty_project_template/services/user_service.dart'
    as user_service;
import 'package:empty_project_template/screens/loading_circ.dart';
import 'package:empty_project_template/managers/teacher_screendata.dart'
    as data;
import 'package:empty_project_template/screens/teacher_course_screen.dart';  


logout() {
  user_service.isLoggedIn.value = false;
}

class CourseBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
          future:
              user_service.getUserCoursesTeacher(user_service.userData.value.id),
          builder: (BuildContext context, AsyncSnapshot<List> slice) {
            if (slice.connectionState == ConnectionState.done) {
              if (slice.hasData) {
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: slice.data,
                  ),
                ));
              } else {
                return Text("Du unterrichtest noch keine Kurse.");
              }
            } else {
              return LoadingCirc();
            }
          },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Lehrer Schreibtisch'),
            actions: [
              FlatButton(
                child: Icon(Icons.delete_outline),
                onPressed: () {
                  logout();
                },
              )
            ],
          ),
          body: TabBarView(
            children: [
              CourseBuilder(),
              Container(color: Colors.blueAccent),
              Container(color: Colors.red)
            ],
          ),
          bottomNavigationBar: TabBar(
            tabs: [
              Tab(
                text: "Kurse",
              ),
              Tab(
                text: "Kalender",
              ),
              Tab(
                text: "Mensa",
              )
            ],
            labelColor: Colors.lightBlue[300],
            unselectedLabelColor: Colors.lightBlue[100],
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.all(5.0),
            indicatorColor: Colors.blue,
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return false;
  }
}

class ExitDialogPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 1.0,
    );
  }
}

// Once Logged in, this Widget redirects to the appropriate Screen inside your Schreibtisch
class TeacherDirManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: data.current_dir,
        builder: (BuildContext context, String value, Widget child) {
          List<String> command = value.split(" ");
          switch (command[0]) {
            case "Home":
              {
                return HomeScreen();
              }
              break;
            case "Course":
              {
                return CourseInsight(id: command[1]);
              }
              break;
            default:
              {
                return LoadingCirc();
              }
              break;
          }
        });
  }
}

