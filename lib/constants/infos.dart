import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// To easily build and insert Infobuttons everywhere
class InfoButton extends StatelessWidget {
  String header;
  String content;
  double size;
  InfoButton({this.header, this.content, this.size}) : super();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: FloatingActionButton(
        elevation: 1.0,
        onPressed: () {
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0)),
              ),
              context: context,
              builder: (builder) {
                return Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: createInformationList(header, content),
                  ),
                );
              });
        },
        child: Center(
          child: Text(
            "?",
            style: TextStyle(fontSize: size),
          ),
        ),
      ),
    );
  }
}

// Actually creating the list of widgets
List<Widget> createInformationList(String header, String content) {
  return [
    Text(
      '$header',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 30.0,
      ),
    ),
    SizedBox(height: 30.0),
    Text(
      '$content',
      maxLines: 100,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20.0),
    ),
  ];
}
// ------------------------ Ab hier werden vorgefertigte Beschreibungen für die Infocards gespeichert ----------------

const personalIDdescription =
    "Das ist deine persönliche Id, die einzigartig ist, um dich von anderen Nutzern zu unterscheiden. Sie besteht aus drei Zahlen(0 - 9) und/oder Buchstaben(A - F). Sie ist nicht veränderbar, spielt für dich aber auch nach dem Anmelden keine große Rolle mehr ( Trotzdem irgendwo aufheben !).";

const passwordDescription =
    "Dies ist dein Passwort, mit dem du dich bei MyGRG anmelden kannst. Es wird dir vorgegeben, aber sobald du dich einmal eingeloggt hast kannst du es nach belieben in den Account Einstellungen ändern.";

const stayLoggedInDescription =
    " Mit dieser Option kannst du festlegen, wie du dich in Zukunft anmelden musst. Machst du den Haken in die Box, so übernehmen wir ab jetzt für dich deine Anmeldung und beim starten der App gelangst du direkt in deinen Schreibtisch. Lässt du die Box frei, so musst du dich beim starten der App jedes mal neu mit ID und Passwort anmelden. ( Ausloggen löscht automatisch die Daten für's angemeldet bleiben ). Du kannst diese Option auch jeder Zeit in den Account Einstellungen ändern.";

