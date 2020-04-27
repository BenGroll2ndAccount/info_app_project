import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:empty_project_template/constants/decorations.dart' as decorations;
import 'package:empty_project_template/constants/infos.dart' as infos;
import 'package:empty_project_template/managers/role_manager.dart';
import 'package:empty_project_template/services/user_service.dart' as user_service;
import 'package:empty_project_template/screens/loading_circ.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String id = "";
  String password = "";
  bool keepLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyGRG Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      onChanged: (val) => setState(() => id = val),
                      decoration: decorations.personalIdInputDecoration,
                    ),
                  ),
                  infos.InfoButton(
                    header: "Persönliche ID",
                    content: infos.personalIDdescription,
                    size: 25.0,
                  )
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                        decoration: decorations.passwordInputDecoration,
                        onChanged: (val) => setState(() => password = val)),
                  ),
                  infos.InfoButton(
                    header: "Passwort",
                    content: infos.passwordDescription,
                    size: 25.0,
                  )
                ],
              ),
              SizedBox(height: 40.0),
              Row(
                children: <Widget>[
                  Text('Angemeldet bleiben'),
                  Checkbox(
                      value: keepLoggedIn ?? false,
                      onChanged: (val) => setState(() => keepLoggedIn = val)),
                  SizedBox(width: 10.0),
                  infos.InfoButton(
                    header: "Angemeldet bleiben",
                    content: infos.stayLoggedInDescription,
                    size: 20.0,
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  RaisedButton.icon(
                    color: Colors.blueAccent[100],
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      String needed = await user_service
                          .getUserProperty_base(id, "password")
                          .then((value) => value.toString());
                      //Check if credentials given match the
                      if (needed == password) {
                        if (keepLoggedIn) {
                          user_service.writeCredentials(id, password);
                          
                        } else {
                          user_service.deleteCredentialsFile();
                        }
                        String newRole =
                            await user_service.getUserProperty_base(id, "role");
                        user_service.userData.value = user_service.User(
                            id: id, password: password, role: newRole);
                        user_service.isLoggedIn.value = true;
                      } else {
                        showModalBottomSheet(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0)),
                            ),
                            context: context,
                            builder: (builder) {
                              return Padding(
                                padding:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: infos.createInformationList(
                                      "Wrong Password",
                                      "Anscheinend hast du das falsche Passwort oder die falsche ID eingegeben"),
                                ),
                              );
                            });
                      }
                    },
                    label: Text('Anmelden'),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
