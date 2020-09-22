import 'package:flutter/material.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/finance/bank_details_form.dart';
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
  int group = 1;

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
                Padding(padding: EdgeInsets.only(top: 40)),
                Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 30, right: 30.0)),
                    Text(
                      'Payment Methods',
                      style: intrayTitleStyle,
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 30, right: 30.0)),
                    Radio(
                        value: 1,
                        groupValue: group,
                        onChanged: (T) {
                          setState(() {
                            group = T;
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
                            if (validateEmail(value) != null) {
                              return 'Please enter a valid paypal account';
                            } else {
                              return null;
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
                        groupValue: group,
                        onChanged: (T) {
                          setState(() {
                            group = T;
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
}
