import 'package:flutter/material.dart';

// Reference: https://www.youtube.com/watch?v=DNCV1K5eVMw

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75.0,
      padding: EdgeInsets.only(top: 5, bottom: 30),
      color: Colors.green,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.home,
              size: 44.0,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_active,
              size: 44.0,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/open-orders');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.motorcycle,
              size: 44.0,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/active-orders');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              size: 44.0,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/logout');
            },
          )
        ],
      ),
    );
  }
}
