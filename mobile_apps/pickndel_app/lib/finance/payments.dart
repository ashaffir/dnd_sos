import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:pickndell/api_connection/api_connection.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/finance/bank_details_form.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/login/message_page.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/networking/messaging_widget.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';

class PaymentsPage extends StatefulWidget {
  final User user;

  PaymentsPage({this.user});

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _paypalAccount = TextEditingController();
  bool checkboxValue = false;
  int _group = 1;
  String _paypal;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                MessagingWidget(),
                Padding(padding: EdgeInsets.only(top: 40)),
                Text(
                  'Payments',
                  style: whiteTitle,
                ),
                Padding(padding: EdgeInsets.only(top: 40)),
                Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 30, right: 30.0)),
                    Text(
                      'Balance',
                      style: whiteTitleH3,
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Text(
                      '\$ 344',
                      style: whiteTitleH2,
                    ),
                    Spacer(
                      flex: 2,
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.only(bottom: 20)),
                Divider(color: Colors.white),
                Padding(padding: EdgeInsets.only(top: 30)),
                Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 30, right: 30.0)),
                    Text('Current payment method:', style: intrayTitleStyle),
                    Padding(padding: EdgeInsets.only(right: 5.0)),
                    Text('Bank', style: whiteTitleH4),
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 10)),
                Divider(color: Colors.white),
                Padding(padding: EdgeInsets.only(top: 20)),
                Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 30, right: 30.0)),
                    Text('Change Payment Method', style: whiteTitleH3),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 30, right: 30.0)),
                    Radio(
                        value: 1,
                        groupValue: _group,
                        onChanged: (T) {
                          setState(() {
                            _group = T;
                          });
                        }),
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        controller: _paypalAccount,
                        decoration: InputDecoration(
                            // prefixIcon: Icon(Icons.monetization_on),
                            labelText: 'PayPal Account Here'),
                        validator: (value) {
                          if (value != null) {
                            if (_group == 1) {
                              if (validateEmail(value) != null) {
                                return 'Please enter a valid paypal account';
                              } else {
                                return null;
                              }
                            }
                          }
                        },
                      ),
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 30)),
                Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 30, right: 30.0)),
                    Radio(
                        value: 2,
                        groupValue: _group,
                        onChanged: (T) {
                          setState(() {
                            _group = T;
                          });
                        }),
                    Text('Bank Account'),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Padding(padding: EdgeInsets.only(left: 30, right: 30.0)),
                    FlatButton(
                      child: Text('Update Bank Details'),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(BUTTON_BORDER_RADIUS),
                          side: BorderSide(color: buttonBorderColor)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BankDetailsForm(
                                    user: widget.user,
                                  )),
                        );
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                ),
                Row(
                  children: <Widget>[
                    Spacer(
                      flex: 2,
                    ),
                    FlatButton(
                        child:
                            _isLoading ? Text('Updating...') : Text('Submit'),
                        color: _isLoading ? Colors.grey : pickndellGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(BUTTON_BORDER_RADIUS),
                            side: BorderSide(color: buttonBorderColor)),
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (!_formKey.currentState.validate()) {
                                  return;
                                } else {
                                  if (_isLoading) {
                                    return null;
                                  } else {
                                    setState(() {
                                      _paypal = _paypalAccount.text;
                                    });
                                    print('PAYPAL: $_paypal');
                                    _updatePaymentMethod(
                                        user: widget.user,
                                        group: _group,
                                        paypal: _paypal);
                                  }
                                }
                              }),
                    Spacer(
                      flex: 1,
                    ),
                  ],
                ),
                Divider(color: Colors.white),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 30.0, left: LEFT_MARGINE),
                    ),
                    InkWell(
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.arrow_back),
                          Padding(padding: EdgeInsets.only(right: 10.0)),
                          Text('Back'),
                        ],
                      ),
                      onTap: () {
                        print('BACK');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    ));
  }

  void errorPaymentMethod(BuildContext context, res) {
    final trans = ExampleLocalizations.of(context);
    Flushbar(
      backgroundColor: Colors.red[600],
      margin: EdgeInsets.all(10),
      borderRadius: 8,
      title: "Error Updating payment method",
      message: "Reason" + '. $res',
      icon: Icon(
        Icons.info_outline,
        size: 28,
        color: Colors.white,
      ),
      duration: Duration(seconds: 5),
    )..show(context);
  }

  void _updatePaymentMethod({User user, int group, String paypal}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var res = await updatePaymentMethod(
          user: user,
          paymentMethod: group == 1 ? "paypal" : "bank",
          paypalAccount: paypal);
      if (res['response'] == "OK") {
        print('Sucess updating preferred payment method: $res');

        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => MessagePage(
                      user: widget.user,
                      messageType: "statusOK",
                      content: "Preferred payment method updated",
                    )));
      } else {
        print("Failed registration process. Error: $res");
        errorPaymentMethod(context, res);
      }
    } catch (e) {
      print('PAYMENT METHOD: Failed updating the payment method. ERROR: $e');
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => MessagePage(
                    user: widget.user,
                    messageType: "Error",
                    content:
                        "We apologize for the inconvenience, but your information was not updated. Please contact PickNdell support or/and try again later.",
                  )));
    }

    setState(() {
      _isLoading = false;
    });
  }
}
