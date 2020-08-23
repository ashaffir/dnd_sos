// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
import 'package:i69n/i69n.dart' as i69n;
import 'translations.i69n.dart';

String get _languageCode => 'he';
String get _localeName => 'he';

String _plural(int count,
        {String zero,
        String one,
        String two,
        String few,
        String many,
        String other}) =>
    i69n.plural(count, _languageCode,
        zero: zero, one: one, two: two, few: few, many: many, other: other);
String _ordinal(int count,
        {String zero,
        String one,
        String two,
        String few,
        String many,
        String other}) =>
    i69n.ordinal(count, _languageCode,
        zero: zero, one: one, two: two, few: few, many: many, other: other);
String _cardinal(int count,
        {String zero,
        String one,
        String two,
        String few,
        String many,
        String other}) =>
    i69n.cardinal(count, _languageCode,
        zero: zero, one: one, two: two, few: few, many: many, other: other);

class Translations_he extends Translations {
  const Translations_he();
  String get loginPageTitle => "כניסה ל PickNdell";
  String get email => "דוא״ל";
  String get password => "סיסמא";
  String get login => "הכנס";
  String get forgot_password => "?שכחת את הסיסמא";
  String get create_account => "צור חשבון";
  String get alert_email => "אנא הכנס דואל חוקי";
  String get alert_password => "אנא הכנס סיסמה";
  String get logging_in => "מתחבר...";
  String get home_title => "עמוד פרופיל";
  String get home_courier_profile => "פרופיל שליח";
  String get home_sender_profile => "פרופיל שולח";
  String get home_name => "שם";
  String get home_vehicle => "כלי רכב";
  String get home_sender_type => "תחום";
  String get home_active_orders => "הזמנות פעילות";
  String get home_status => "סטטוס זמינות";
  String get home_available => "זמין";
  String get home_unavailable => "אינו זמין";
  String get orders_title_open => "הזמנות";
  String get orders_title_active => "הזמנות פעילות";
  String get orders_title_business => "הזמנות פתוחות";
  String get orders_title_rejected => "הזמנות מחייבות את תשומת לבך";
  String get orders_created => "התחיל";
  String get orders_update => "עודכן";
  String get orders_cancel => "בטל";
  String get orders_cancel_delivery => "בטל משלוח";
  String get orders_cancel_confirm => "אשר את הביטול";
  String get orders_owner => "שולח";
  String get orders_accept => "אשר";
  String get orders_accpeted_order => "אשר הזמנה";
  String get orders_make_delivery => "בצע משלוח";
  String get orders_fare => "דמי נסיעה";
  String get orders_confirm_button => "אשר";
  String get orders_confirm => "האם אתה בטוח";
  String get orders_confirm_delivery => "אשר את המסירה";
  String get orders_confirm_broadcast => "אשר שידור ההזמנה";
  String get orders_pick_up => "אשר את האיסוף";
  String get orders_report_pickup => "דווח על איסוף";
  String get orders_from => "כתובת איסוף";
  String get orders_to => "כתובת מסירה";
  String get orders_delivery_to => "משלוח אל";
  String get orders_report_delivered => "דווח נמסר";
  String get orders_alert_tracking_title => "המעקב אינו פעיל";
  String get orders_alert_tracking_content =>
      "אנא עבור למצב זמין לפני שתקבל הזמנות";
  String get orders_message_pickup => "סע לכתובת האיסוף";
  String get orders_call_sender => "התקשר לשולח";
  String get orders_call_courier => "התקשר לשליח";
  String get orders_status_waiting_pickup => "מחכה לאיסוף";
  String get orders_status_waiting_allocaiton => "חדש. ממתין להקצאת שליח";
  String get orders_status_waiting_delivery => "נאסף. ממתין למסירה";
  String get orders_status_rejected => "מסירה שנדחתה";
  String get orders_request_courier => "בקש שליח";
  String get orders_check => "אנא בדוק";
  String get orders_empty_list => "רשימת ההזמנות ריקה";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'loginPageTitle':
        return loginPageTitle;
      case 'email':
        return email;
      case 'password':
        return password;
      case 'login':
        return login;
      case 'forgot_password':
        return forgot_password;
      case 'create_account':
        return create_account;
      case 'alert_email':
        return alert_email;
      case 'alert_password':
        return alert_password;
      case 'logging_in':
        return logging_in;
      case 'home_title':
        return home_title;
      case 'home_courier_profile':
        return home_courier_profile;
      case 'home_sender_profile':
        return home_sender_profile;
      case 'home_name':
        return home_name;
      case 'home_vehicle':
        return home_vehicle;
      case 'home_sender_type':
        return home_sender_type;
      case 'home_active_orders':
        return home_active_orders;
      case 'home_status':
        return home_status;
      case 'home_available':
        return home_available;
      case 'home_unavailable':
        return home_unavailable;
      case 'orders_title_open':
        return orders_title_open;
      case 'orders_title_active':
        return orders_title_active;
      case 'orders_title_business':
        return orders_title_business;
      case 'orders_title_rejected':
        return orders_title_rejected;
      case 'orders_created':
        return orders_created;
      case 'orders_update':
        return orders_update;
      case 'orders_cancel':
        return orders_cancel;
      case 'orders_cancel_delivery':
        return orders_cancel_delivery;
      case 'orders_cancel_confirm':
        return orders_cancel_confirm;
      case 'orders_owner':
        return orders_owner;
      case 'orders_accept':
        return orders_accept;
      case 'orders_accpeted_order':
        return orders_accpeted_order;
      case 'orders_make_delivery':
        return orders_make_delivery;
      case 'orders_fare':
        return orders_fare;
      case 'orders_confirm_button':
        return orders_confirm_button;
      case 'orders_confirm':
        return orders_confirm;
      case 'orders_confirm_delivery':
        return orders_confirm_delivery;
      case 'orders_confirm_broadcast':
        return orders_confirm_broadcast;
      case 'orders_pick_up':
        return orders_pick_up;
      case 'orders_report_pickup':
        return orders_report_pickup;
      case 'orders_from':
        return orders_from;
      case 'orders_to':
        return orders_to;
      case 'orders_delivery_to':
        return orders_delivery_to;
      case 'orders_report_delivered':
        return orders_report_delivered;
      case 'orders_alert_tracking_title':
        return orders_alert_tracking_title;
      case 'orders_alert_tracking_content':
        return orders_alert_tracking_content;
      case 'orders_message_pickup':
        return orders_message_pickup;
      case 'orders_call_sender':
        return orders_call_sender;
      case 'orders_call_courier':
        return orders_call_courier;
      case 'orders_status_waiting_pickup':
        return orders_status_waiting_pickup;
      case 'orders_status_waiting_allocaiton':
        return orders_status_waiting_allocaiton;
      case 'orders_status_waiting_delivery':
        return orders_status_waiting_delivery;
      case 'orders_status_rejected':
        return orders_status_rejected;
      case 'orders_request_courier':
        return orders_request_courier;
      case 'orders_check':
        return orders_check;
      case 'orders_empty_list':
        return orders_empty_list;
      default:
        return super[key];
    }
  }
}
