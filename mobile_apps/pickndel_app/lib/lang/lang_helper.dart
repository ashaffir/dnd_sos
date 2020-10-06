import 'package:flutter/material.dart';

String translateCategory(category) {
  // ['מסעדה', 'בגדים', 'נוחות', 'מכולת', 'משרד', 'אחר']
  // 'Restaurant','Clothes','Convenience','Grocery','Office','Other'

  String translated;
  switch (category) {
    case 'Restaurant':
      translated = 'מסעדה';
      break;
    case 'Clothes':
      translated = 'בגדים';
      break;
    case 'Convenience':
      translated = 'נוחות';
      break;
    case 'Grocery':
      translated = 'מכולת';
      break;
    case 'Office':
      translated = 'משרד';
      break;
    case 'Other':
      translated = 'אחר';
      break;
    default:
      translated = 'אחר';
  }
  return translated;
}

String translateVehicle(vehicle) {
  // ['רכב', 'קטנוע', 'אופניים', 'אופנוע', 'משאית']
  // : ['Car', 'Scooter', 'Bicycle', 'Motorcycle', 'Truck'];

  String translated;
  switch (vehicle) {
    case 'Car':
      translated = 'רכב';
      break;
    case 'Scooter':
      translated = 'קטנוע';
      break;
    case 'Bicycle':
      translated = 'אופניים';
      break;
    case 'Motorcycle':
      translated = 'אופנוע';
      break;
    case 'Truck':
      translated = 'משאית';
      break;
    default:
      translated = 'אחר';
  }
  return translated;
}

String translateOrdersList(status) {
  // ['התחיל', 'בעיצומה', 'מתבקש', 'מתבקש מחדש', 'נדחה', 'נמסר']
  // : ['Started', 'In Progress', 'Requested', 'Re-Requested', 'Rejected', 'Delivered'] ;

  String translated;
  switch (status) {
    case 'All Orders':
      translated = 'כל ההזמנות';
      break;
    case 'Requested':
      translated = 'חדש';
      break;
    case 'Re-Requested':
      translated = 'התבקש שוב';
      break;
    case 'Started':
      translated = 'התחיל';
      break;
    case 'In Progress':
      translated = 'בתהליך';
      break;
    case 'Rejected':
      translated = 'נדחה';
      break;
    case 'Delivered':
      translated = 'נמסר';
      break;
    default:
      translated = 'אחר';
  }
  return translated;
}
