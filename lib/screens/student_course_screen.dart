import 'package:flutter/material.dart';
import 'package:empty_project_template/services/user_service.dart'
    as user_service;
import 'package:empty_project_template/managers/student_screendata.dart'
    as data;
import 'package:empty_project_template/screens/loading_circ.dart';

class CourseInsight extends StatefulWidget {
  final String id;
  CourseInsight({this.id}) : super();
  @override
  _CourseInsightState createState() => _CourseInsightState();
}

class _CourseInsightState extends State<CourseInsight> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return data.closeCourse();
      },
      child: FutureBuilder(
        future: user_service.getCourseDisplayInfoStudent(widget.id),
        builder: (BuildContext context,
            AsyncSnapshot<user_service.CourseData> this_course_data) {
          if (this_course_data.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: Text(this_course_data.data.name),
              ),
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: Container(
                  color: Colors.blue[50],
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        // Row for the Tabs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: this_course_data.data.getTabWidgets,
                        )
                      ],

                    ),
                  )
                ),
              ),
            );
          } else {
            return LoadingCirc();
          }
        },
      ),
    );
  }
}
