import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:pickndell/api_connection/api_connection.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/finance/bank_details_form.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/login/message_page.dart';
import 'package:pickndell/login/profile_updated_page.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/networking/messaging_widget.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:pickndell/ui/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool showSection = false;

class PaymentsPage extends StatefulWidget {
  final User user;
  final String userCountry;

  PaymentsPage({this.user, this.userCountry});

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
  String country;
  String countryCode;
  double usdIls;
  double usdIlsRate;
  double usdEur;
  double usdEurRate;

  void _getCountry() async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      country = localStorage.getString('country');
    } catch (e) {
      print('*** Error *** Fail getting country code. E: $e');
      country = 'Israel';
    }
    setState(() {
      countryCode = country;
    });
  }

  @override
  void initState() {
    _getCountry();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final trans = ExampleLocalizations.of(context);
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
                  trans.payments,
                  style: whiteTitle,
                ),
                Padding(padding: EdgeInsets.only(top: 40)),
                // if (showSection)
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 4.0)),
                  child: SizedBox(
                    height: 40.0,
                    child: Row(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(left: 30, right: 30.0)),
                        Text(
                          trans.balance,
                          style: whiteTitleH3,
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        widget.userCountry == 'IL'
                            ? Text(
                                widget.user.balance != null
                                    ? ' ${roundDouble(widget.user.balance * widget.user.usdIls, 2)} ₪'
                                    : ' 0.0 ₪',
                                style: whiteTitleH2,
                              )
                            : Text(
                                '\$ ${roundDouble(widget.user.balance, 2)}',
                                // '\$ ',
                                style: whiteTitleH2,
                              ),
                        Spacer(
                          flex: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 20)),
                // Divider(color: Colors.white),
                SizedBox(
                  height: 40.0,
                  child: Row(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(left: 30, right: 30.0)),
                      Text(trans.current_payment_method + ':',
                          style: intrayTitleStyle),
                      Padding(padding: EdgeInsets.only(right: 5.0)),
                      Text(
                          widget.user.preferredPaymentMethod == 'Bank'
                              ? trans.bank
                              : widget.user.preferredPaymentMethod == 'PayPal'
                                  ? trans.paypal
                                  : trans.none,
                          style: TextStyle(
                              color:
                                  widget.user.preferredPaymentMethod != 'None'
                                      ? pickndellGreen
                                      : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                      Padding(padding: EdgeInsets.only(right: 5.0)),
                      QuestionTooltip(
                        tooltipMessage: trans.please_select_payment_method,
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white),
                Padding(padding: EdgeInsets.only(top: 20)),
                Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 30, right: 30.0)),
                    Text(trans.change_payment_method, style: whiteTitleH3),
                  ],
                ),
                ///////////// PayPal Section //////////////
                ///
                Row(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(
                            left: LEFT_MARGINE, right: RIGHT_MARGINE)),
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
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: TextFormField(
                          controller: _paypalAccount,
                          decoration: InputDecoration(
                              // prefixIcon: Icon(Icons.monetization_on),
                              labelText: trans.paypal_account_here),
                          validator: (value) {
                            if (value != null) {
                              if (_group == 1) {
                                if (validateEmail(value) != null) {
                                  return trans.please_enter_valid_paypal;
                                } else {
                                  return null;
                                }
                              }
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 30)),

                ///////////// Bank Section //////////////
                ///

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
                    Text(trans.bank_account),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Padding(padding: EdgeInsets.only(left: 30, right: 30.0)),
                    FlatButton(
                      child: Text(trans.update_bank_details),
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
                        child: _isLoading
                            ? Text(trans.updating + '...')
                            : Text(trans.submit),
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
                                    if (_group == 1) {
                                      print('PAYPAL Selected');
                                      setState(() {
                                        _paypal = _paypalAccount.text;
                                      });
                                      _updatePaymentMethod(
                                          user: widget.user,
                                          group: _group,
                                          paypal: _paypal);
                                    } else {
                                      print(
                                          'BANK DETAILS: ${widget.user.bankDetails}');
                                      if (widget.user.bankDetails == '{}') {
                                        showAlertDialog(
                                            context: context,
                                            okButtontext: trans.close,
                                            title: trans
                                                .please_submit_bank_details);
                                      } else {
                                        print(
                                            'UPDATE BANK DETAILS: ${widget.user.bankDetails}');
                                        _updatePaymentMethod(
                                            user: widget.user, group: _group);
                                      }
                                    }
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
                          Text(trans.back),
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
    final trans = ExampleLocalizations.of(context);
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

        Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (context) => ProfileUpdatedPage(
                    user: widget.user,
                    status: "statusOK",
                    message: trans.payment_method_updated,
                  )),
          (Route<dynamic> route) => false,
        );
      } else {
        print("Failed registration process. Error: $res");
        errorPaymentMethod(context, res);
      }
    } catch (e) {
      print('PAYMENT METHOD: Failed updating the payment method. ERROR: $e');
      Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(
            builder: (context) => MessagePage(
                  user: widget.user,
                  messageType: "Error",
                  content:
                      "We apologize for the inconvenience, but your information was not updated. Please contact PickNdell support or/and try again later.",
                )),
        (Route<dynamic> route) => false,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }
}
