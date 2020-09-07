class CreditCard {
  String cardNumber;
  String expiryDate;
  String ownersName;
  String cvv;

  CreditCard({this.cardNumber, this.cvv, this.expiryDate, this.ownersName});

  CreditCard.fromJson(Map<String, dynamic> json)
      : cardNumber = json['cardNumber'],
        expiryDate = json['expiryDate'],
        ownersName = json['ownersName'],
        cvv = json['cvv'];

  Map<String, dynamic> toJson() => {
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'ownersName': ownersName,
        'cvv': cvv,
      };
}
