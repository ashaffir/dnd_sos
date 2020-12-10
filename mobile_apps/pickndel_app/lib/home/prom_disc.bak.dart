import 'package:flutter/material.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> prominentDisclosure(BuildContext context) async {
  SharedPreferences localStorage = await SharedPreferences.getInstance();
  final trans = ExampleLocalizations.of(context);
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        trans.use_locaiton,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    // Padding(padding: EdgeInsets.all(10.0)),
                    Spacer(
                      flex: 1,
                    ),

                    SizedBox(child: Text(trans.prominent_message)),
                    Spacer(
                      flex: 1,
                    ),
                    // Padding(padding: EdgeInsets.all(10.0)),
                    Image.asset(
                      'assets/images/map-icon.png',
                      width: MediaQuery.of(context).size.width * 0.30,
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(
                        // width: 320.0,
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: RaisedButton(
                          child: Text(
                            trans.cancel,
                            style: TextStyle(color: Colors.white),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(BUTTON_BORDER_RADIUS),
                              side: BorderSide(color: buttonBorderColor)),
                          onPressed: () {
                            print('DECLINED DISCLOSURE');
                            localStorage.setBool('disclosure', false);

                            Navigator.pop(context, false);
                          },
                          color: Colors.transparent,
                        ),
                      ),
                      Spacer(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: RaisedButton(
                          child: Text(
                            trans.orders_accept,
                            style: TextStyle(color: Colors.white),
                          ),
                          color: pickndellGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(BUTTON_BORDER_RADIUS),
                              side: BorderSide(color: buttonBorderColor)),
                          onPressed: () {
                            print('ACCEPTED DISCLOSURE');
                            localStorage.setBool('disclosure', true);

                            Navigator.pop(context, true);
                          },
                        ),
                      )
                    ])
                  ],
                ),
              ),
            ));
      });
}
