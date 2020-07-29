import 'package:flutter/material.dart';

import 'global.dart';

class OpenOrderWidget extends StatelessWidget {
  final String order_id;
  final String created;
  OpenOrderWidget({this.order_id, this.created});
  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(created),
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(10),
      height: 100,
      decoration: BoxDecoration(
        color: redColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          new BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          // ignore: missing_required_param
          Radio(),
          Column(
            children: <Widget>[
              Text(
                order_id,
                style: darkTodoTitle,
              )
            ],
          )
        ],
      ),
    );
  }
}
