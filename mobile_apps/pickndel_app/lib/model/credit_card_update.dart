import 'package:credit_card_validate/credit_card_validate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/login/profile_update.dart';
import 'package:pickndell/model/credit_card.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';

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
        title: Text(trans.update_credit_card),
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
                        // Image.asset(
                        //   'assets/images/pickndell-logo-white.png',
                        //   width: MediaQuery.of(context).size.width * 0.40,
                        // ),
                        Padding(
                          padding: EdgeInsets.only(top: 40.0),
                        ),

                        //////// FORM //////
                        ///
                        Container(
                          width: 250,
                          child: Column(
                            children: [
                              ///////////////// CARD NUMBER //////////////

                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText: trans.credit_card_number,
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
                                      return trans.credit_card_number_not_valid;
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
                                        ccBrandIcon =
                                            FontAwesomeIcons.ccDiscover;
                                      }
                                    }
                                    setState(() {
                                      brandIcon = ccBrandIcon;
                                    });
                                  },
                                ),
                              ),

                              ///////////////// NAME //////////////
                              Padding(padding: EdgeInsets.only(top: 20.0)),

                              TextFormField(
                                decoration: InputDecoration(
                                    labelText:
                                        " " + trans.credit_card_owner_name,
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
                                    return trans.name_not_valid;
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
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(2),
                                      ],
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
                                          return trans.month_not_valid;
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
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(2),
                                      ],
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
                                          return trans.year_not_valid;
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
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(3),
                                      ],
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
                                          return trans.cvv_number_not_valid;
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
                            trans.update_credit_card,
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
                        Padding(padding: EdgeInsets.only(top: 20)),
                        Divider(color: Colors.white),
                        Padding(padding: EdgeInsets.only(top: 20)),
                        InkWell(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.arrow_back),
                              Padding(padding: EdgeInsets.only(right: 10.0)),
                              Text(trans.back_to_profile),
                            ],
                          ),
                          onTap: () {
                            print('BACK');
                            Navigator.pop(context);
                          },
                        ),
                      ]),
                ))),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    );
  }

  validateCard(String cardNumber) {
    bool isValid =
        CreditCardValidator.isCreditCardValid(cardNumber: cardNumber);
    return isValid;
  }
}
