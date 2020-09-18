import 'package:flutter/material.dart';
import 'package:pickndell/common/global.dart';

class BottmNavigation extends StatefulWidget {
  final userType;

  BottmNavigation({this.userType});

  @override
  _BottmNavigationState createState() => _BottmNavigationState();
}

class _BottmNavigationState extends State<BottmNavigation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: BottomAppBar(
          color: bottomNavigationBarColor,
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.home),
                color: Colors.white,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications_active,
                  // size: 44.0,
                ),
                onPressed: () {
                  if (widget.userType == 'courier') {
                    Navigator.pushReplacementNamed(context, '/open-orders');
                  } else {
                    Navigator.pushReplacementNamed(context, '/rejected-orders');
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.dashboard,
                  // size: 44.0,
                ),
                onPressed: () {
                  if (widget.userType == 'courier') {
                    Navigator.pushReplacementNamed(context, '/active-orders');
                  } else {
                    Navigator.pushReplacementNamed(context, '/business-orders');
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  // size: 44.0,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/logout');
                },
              )
            ],
          )),
    );
  }
}
