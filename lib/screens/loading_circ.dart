// The widget that gets displayed if your app is loading ( Waiting for Future )
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingCirc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: SpinKitThreeBounce(
          color: Colors.blue[200],
          size: 50.0,
        )
      )
    );
  }
}