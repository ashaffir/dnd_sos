import 'package:flutter/material.dart';
import 'package:pickndell/localizations.dart';

class EmptyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translations = ExampleLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            translations.orders_empty_list,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
