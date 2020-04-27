import 'package:flutter/material.dart';
import 'package:empty_project_template/services/user_service.dart' as user_service;
import 'package:empty_project_template/screens/loading_circ.dart';
import 'package:empty_project_template/managers/student_screendata.dart' as data;

logout() {
  user_service.isLoggedIn.value = false;
}

class CourseBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: user_service.getUserCourses(user_service.userData.value.id),
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
            user_service.getUserCourses('000').then((value) => print(value));
            return Text("Empty Slice");
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
        return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Schüler Schreibtisch'),
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
                ],
              ),
              bottomNavigationBar: TabBar(
                tabs: [
                  Tab(
                    text: "Kurse",
                    ),
                  Tab(
                    text: "Kalender",
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
          );
    ;
  }
}

class DirManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: data.current_dir,
        builder: (BuildContext context, String value, Widget child) {
          switch (value) {
            case "Home":
              {
                return HomeScreen();
              }
              break;
            case "Course":
              {
                return Container();
              }
              break;
            default:
              {
                print(value);
                return LoadingCirc();
              }
              break;
          }
        });
  }
}
