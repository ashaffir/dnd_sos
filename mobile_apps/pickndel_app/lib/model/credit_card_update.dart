import 'package:credit_card_validate/credit_card_validate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/login/profile_updated.dart';
import 'package:pickndell/model/credit_card.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CreditCardUpdate extends StatefulWidget {
  final UserRepository userRepository;
  final User user;

  CreditCardUpdate({this.userRepository, this.user});

  @override
  _CreditCardUpdateState createState() => _CreditCardUpdateState();
}

class _CreditCardUpdateState extends State<CreditCardUpdate> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  CreditCard _creditCardInfo = CreditCard();
  @override
  void initState() {
    super.initState();
  }

  String creditCardNumber = '';
  IconData brandIcon;
  final TextEditingController cardNumber = TextEditingController();
  final TextEditingController expiryYear = TextEditingController();
  final TextEditingController expiryMonth = TextEditingController();
  final TextEditingController cardHolderName = TextEditingController();
  final TextEditingController cvvCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final trans = ExampleLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Update Credit Card'),
      ),
      body: Container(
        child: Form(
            key: _formKey,
            child: Padding(
                padding: EdgeInsets.only(left: 40.0, right: 40.0, bottom: 40.0),
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/pickndell-logo-white.png',
                          width: MediaQuery.of(context).size.width * 0.40,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                        ),

                        //////// FORM //////
                        ///
                        Container(
                          width: 250,
                          child: Column(
                            children: [
                              ///////////////// CARD NUMBER //////////////

                              TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText: "Credit Card Number",
                                    icon: Icon(Icons.credit_card),
                                    contentPadding: EdgeInsets.only(left: 10),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                controller: cardNumber,
                                validator: (value) {
                                  if (validateCard(value)) {
                                    print('VALID NUMBER');
                                    return null;
                                  } else {
                                    return 'Credit card number is not valid';
                                  }
                                },
                                onChanged: (cardNumber) {
                                  setState(() {
                                    creditCardNumber = cardNumber;
                                  });
                                  String brand =
                                      CreditCardValidator.identifyCardBrand(
                                          cardNumber);
                                  IconData ccBrandIcon;
                                  if (brand != null) {
                                    if (brand == 'visa') {
                                      ccBrandIcon = FontAwesomeIcons.ccVisa;
                                    } else if (brand == 'master_card') {
                                      ccBrandIcon =
                                          FontAwesomeIcons.ccMastercard;
                                    } else if (brand == 'american_express') {
                                      ccBrandIcon = FontAwesomeIcons.ccAmex;
                                    } else if (brand == 'discover') {
                                      ccBrandIcon = FontAwesomeIcons.ccDiscover;
                                    }
                                  }
                                  setState(() {
                                    brandIcon = ccBrandIcon;
                                  });
                                },
                              ),
                              // SizedBox(
                              //   height: 5,
                              // ),
                              // creditCardNumber.length < 13
                              //     ? Text('Please enter atleast 13 characters')
                              //     : CreditCardValidator.isCreditCardValid(
                              //             cardNumber: creditCardNumber)
                              //         ? Text(
                              //             'The credit card number is valid.',
                              //             style: TextStyle(color: Colors.green),
                              //           )
                              //         : Text(
                              //             'The credit card number is invalid.',
                              //             style: TextStyle(color: Colors.red),
                              //           ),

                              ///////////////// NAME //////////////
                              Padding(padding: EdgeInsets.only(top: 20.0)),

                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: "Name",
                                    icon: Icon(Icons.person),
                                    contentPadding: EdgeInsets.only(left: 10),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                controller: cardHolderName,
                                validator: (value) {
                                  if (validateName(value) == null) {
                                    print('VALID NAME');
                                    return null;
                                  } else {
                                    return "Name entered is not valid";
                                  }
                                },
                              ),
                              // Padding(padding: EdgeInsets.only(top: 10.0)),

                              ////////////////// Expiery ////////////
                              Row(
                                children: [
                                  Container(
                                    width: 100,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "MM",
                                        icon: Icon(Icons.date_range),
                                      ),
                                      controller: expiryMonth,
                                      validator: (value) {
                                        if (validateMonth(value) == null) {
                                          print('VALID Month');
                                          return null;
                                        } else {
                                          return "Month not valid";
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(right: 5.0)),
                                  Text('/'),
                                  Padding(padding: EdgeInsets.only(right: 5.0)),
                                  Container(
                                    width: 50,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "YY",
                                      ),
                                      controller: expiryYear,
                                      validator: (value) {
                                        if (validateYear(value) == null) {
                                          print('VALID Year');
                                          return null;
                                        } else {
                                          return 'Not valid';
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 20.0)),
                              Row(
                                children: [
                                  Container(
                                    width: 100,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          labelText: "CVV",
                                          icon: Icon(Icons.security),
                                          contentPadding:
                                              EdgeInsets.only(left: 10),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                      controller: cvvCode,
                                      validator: (value) {
                                        if (validateCvv(value) == null) {
                                          print('VALID CVV NUMBER');
                                          return null;
                                        } else {
                                          return "Name entered is not valid";
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 40.0)),

                        RaisedButton(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            'Update Card',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          color: Colors.green,
                          onPressed: () {
                            if (!_formKey.currentState.validate()) {
                              return;
                            } else {
                              print('Updating Credit Card....');
                              _creditCardInfo.cardNumber = cardNumber.text;
                              _creditCardInfo.ownersName = cardHolderName.text;
                              _creditCardInfo.cvv = cvvCode.text;
                              _creditCardInfo.expiryDate =
                                  expiryYear.text + expiryMonth.text;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ProfileUpdated(
                                      user: widget.user,
                                      updateField: 'credit_card',
                                      creditCardInfo: _creditCardInfo,
                                    );
                                  },
                                ),
                                (Route<dynamic> route) =>
                                    false, // No Back option for this page
                              );
                            }
                          },
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ]),
                ))),
      ),
      bottomNavigationBar: BottomNavBar(
        userRepository: widget.userRepository,
      ),
    );
  }

  validateCard(String cardNumber) {
    bool isValid =
        CreditCardValidator.isCreditCardValid(cardNumber: cardNumber);
    return isValid;
  }
}
