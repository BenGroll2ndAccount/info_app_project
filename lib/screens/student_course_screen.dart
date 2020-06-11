import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:empty_project_template/services/user_service.dart'
    as user_service;
import 'package:empty_project_template/managers/student_screendata.dart'
    as data;
import 'package:empty_project_template/screens/loading_circ.dart';

ValueNotifier<String> current_tab_open = ValueNotifier("");

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
            AsyncSnapshot<user_service.StudentCourseData> this_course_data) {
          if (this_course_data.connectionState == ConnectionState.done) {
            current_tab_open.value = this_course_data.data.tabs[0].id;
            return Scaffold(
              appBar: AppBar(
                title: Text(this_course_data.data.name),
              ),
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: Container(
                    color: Colors.blue[50],
                    child: Center(
                      child: ValueListenableBuilder(
                        valueListenable: current_tab_open,
                        builder:
                            (BuildContext context, String tabID, Widget foo) {
                          if (tabID == "") {
                            return LoadingCirc();
                          } else {
                            return Column(
                              children: <Widget>[
                                // Row for the Tabs
                                Wrap(
                                  children: this_course_data.data.getTabWidgets,
                                ),
                                Divider(),
                                FutureBuilder(
                                  future: buildTabContentColumn(getTabContents(
                                      current_tab_open.value,
                                      this_course_data.data.tabs)),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<Widget> column_widget) {
                                    if (column_widget.connectionState ==
                                        ConnectionState.done) {
                                      return Expanded(
                                          child: column_widget.data);
                                    } else {
                                      return LoadingCirc();
                                    }
                                  },
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    )),
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

class StudentTabWidget extends StatelessWidget {
  String name;
  String id;
  bool active = false;
  StudentTabWidget({this.name, this.id}) : super();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: FlatButton(
        onPressed: () => current_tab_open.value = id,
        child: ValueListenableBuilder(
            valueListenable: current_tab_open,
            builder: (BuildContext context, String tab, Widget foo) {
              if (tab != "") {
                if (tab.toString() == id.toString()) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.blue[200],
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Text(name),
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Text(name),
                  );
                }
              }
            }),
      ),
    );
  }
}

List<dynamic> getTabContents(String id, List<user_service.StudentTabData> tabs) {
  for (int i = 0; i < tabs.length; i++) {
    if (tabs[i].id == id) {
      return tabs[i].contents;
    }
  }
  return null;
}

Widget buildWidgetFromTabContent(DocumentSnapshot tabContent) {
  if (tabContent["type"] == "message") {
    return MessageWidget(text: tabContent["text"], date: tabContent["date"]);
  }
}

Future<Widget> buildTabContentColumn(List<dynamic> contents) async {
  List<Widget> columnContents = [];
  for (int i = 0; i < contents.length; i++) {
    DocumentSnapshot doc = await Firestore.instance
        .collection("tab-contents")
        .document(contents[i])
        .get();
    columnContents.insert(0, buildWidgetFromTabContent(doc));
  }
  Widget finalWidget = ListView(
    children: columnContents,
  );
  return finalWidget;
}

class MessageWidget extends StatelessWidget {
  final String text;
  final Timestamp date;
  MessageWidget({this.text, this.date}) : super();
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Text(date.toDate().toString()),
          SizedBox(height: 4.0),
          Divider(),
          SizedBox(height: 4.0),
          Text(text),
        ],
      ),
    ));
  }
}
