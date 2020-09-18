// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
import 'package:i69n/i69n.dart' as i69n;

String get _languageCode => 'en';
String get _localeName => 'en';

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

class Translations implements i69n.I69nMessageBundle {
  const Translations();
  String get loginPageTitle => "PickNdell Login";
  String get email => "email";
  String get password => "password";
  String get login => "Login";
  String get logout => "Logout";
  String get forgot_password => "Forgot your password";
  String get create_account => "Create a new account";
  String get alert_email => "Please enter a valid email";
  String get alert_password => "Please enter password";
  String get logging_in => "Logging in...";
  String get home_title => "Profile";
  String get home_courier_profile => "Courier Profile";
  String get home_sender_profile => "Sender Profile";
  String get home_name => "Name";
  String get home_phone => "Phone";
  String get home_courier_rating => "Your Courier Rating";
  String get home_sender_rating => "Sender Rating";
  String get home_unrated => "Unrated";
  String get home_vehicle => "Vehicle";
  String get home_sender_cat => "Category";
  String get home_active_orders => "Current Active Orders";
  String get home_status => "Availability Status";
  String get home_available => "Available";
  String get home_unavailable => "Unavailable";
  String get orders_title_open => "Open Orders";
  String get orders_title_active => "Active Orders";
  String get orders_title_business => "Current Open Orders";
  String get orders_title_rejected => "Orders Require Your Attention";
  String get orders_created => "Created";
  String get orders_update => "Updated";
  String get orders_cancel => "Cancel";
  String get orders_cancel_delivery => "Cancel Delivery";
  String get orders_cancel_confirm => "Confirm Cancellation";
  String get orders_owner => "Owner";
  String get orders_accept => "Accept";
  String get orders_accpeted_order => "Accepted Order";
  String get orders_make_delivery => "Make Delivery";
  String get orders_fare => "Fare";
  String get orders_confirm_button => "Confirm";
  String get orders_confirm => "Are you sure";
  String get orders_confirm_delivery => "Confirm Delivery";
  String get orders_confirm_broadcast => "Confirm Broadcast Order";
  String get orders_pick_up => "Confirm Pick Up";
  String get orders_report_pickup => "Report Pickup";
  String get orders_from => "From";
  String get orders_to => "To";
  String get orders_delivery_to => "Delivery to";
  String get orders_report_delivered => "Report Delivered";
  String get orders_alert_tracking_title => "Tracking is off";
  String get orders_alert_tracking_content =>
      "Please switch to Available status before accepting orders. You can find the switch on the profile page";
  String get orders_message_pickup => "Go to pickup";
  String get orders_call_sender => "Call Sender";
  String get orders_call_courier => "Call Courier";
  String get orders_status_waiting_pickup => "Waiting for pick up";
  String get orders_status_waiting_allocaiton =>
      "New. Waiting for courier allocation";
  String get orders_status_waiting_delivery => "Picked up. Waiting Delivery";
  String get orders_status_rejected => "Rejected Order";
  String get orders_request_courier => "Request Courier";
  String get orders_check => "Please check";
  String get orders_empty_list => "This list is Empty";
  String get messages_register_title => "Confirmation";
  String get messages_register_thanks => "Thank you";
  String get messages_register_activation =>
      "We have sent you an activation email. Please check your email box and to activate your account";
  String get messages_register_pickup => "Pickup address";
  String get messages_register_drop => "Dropoff address";
  String get messages_register_button => "Go to Login";
  String get messages_push_accept => "Accept";
  String get messages_push_ignore => "Ignore";
  String get order_a_updating => "Updating Orders Table";
  String get order_a_accepted => "Order Accepted";
  String get order_a_go_to => "Go to pick up";
  String get order_a_not_available => "This order is no longer available";
  String get order_p_picked => "Order Picked Up";
  String get order_p_report =>
      "You have reported that the order was picked up by a courier";
  String get order_p_problem => "There was a problem updating this order";
  String get order_p_update_pnd => "Please contact PickNdell support";
  String get order_cancel_message => "Order Canceled";
  String get order_delivered => "Order Delivered";
  String get register_join => "Join PickNdel";
  String get register_form => "Registration Form";
  String get register_as => "Registration as";
  String get register_alert_as => "Please choose a registration type";
  String get register_confirm_pass => "confirm password";
  String get register_terms => "I accept PickNdell terms";
  String get register_alert_terms => "Please accept PickNdell terms";
  String get register_creating => "Creating";
  String get register_create => "Create account";
  String get register_already_have => "Already have an Account";
  String get register_err => "Error";
  String get register_alert_fields => "Please fill out all fields";
  String get profile_title => "Edit Profile";
  String get profile_submit => "Submit Update";
  String get profile_update_in_progress => "Update in progress";
  String get profile_delete_account => "Delete my Account";
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
      case 'logout':
        return logout;
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
      case 'home_phone':
        return home_phone;
      case 'home_courier_rating':
        return home_courier_rating;
      case 'home_sender_rating':
        return home_sender_rating;
      case 'home_unrated':
        return home_unrated;
      case 'home_vehicle':
        return home_vehicle;
      case 'home_sender_cat':
        return home_sender_cat;
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
      case 'messages_register_title':
        return messages_register_title;
      case 'messages_register_thanks':
        return messages_register_thanks;
      case 'messages_register_activation':
        return messages_register_activation;
      case 'messages_register_pickup':
        return messages_register_pickup;
      case 'messages_register_drop':
        return messages_register_drop;
      case 'messages_register_button':
        return messages_register_button;
      case 'messages_push_accept':
        return messages_push_accept;
      case 'messages_push_ignore':
        return messages_push_ignore;
      case 'order_a_updating':
        return order_a_updating;
      case 'order_a_accepted':
        return order_a_accepted;
      case 'order_a_go_to':
        return order_a_go_to;
      case 'order_a_not_available':
        return order_a_not_available;
      case 'order_p_picked':
        return order_p_picked;
      case 'order_p_report':
        return order_p_report;
      case 'order_p_problem':
        return order_p_problem;
      case 'order_p_update_pnd':
        return order_p_update_pnd;
      case 'order_cancel_message':
        return order_cancel_message;
      case 'order_delivered':
        return order_delivered;
      case 'register_join':
        return register_join;
      case 'register_form':
        return register_form;
      case 'register_as':
        return register_as;
      case 'register_alert_as':
        return register_alert_as;
      case 'register_confirm_pass':
        return register_confirm_pass;
      case 'register_terms':
        return register_terms;
      case 'register_alert_terms':
        return register_alert_terms;
      case 'register_creating':
        return register_creating;
      case 'register_create':
        return register_create;
      case 'register_already_have':
        return register_already_have;
      case 'register_err':
        return register_err;
      case 'register_alert_fields':
        return register_alert_fields;
      case 'profile_title':
        return profile_title;
      case 'profile_submit':
        return profile_submit;
      case 'profile_update_in_progress':
        return profile_update_in_progress;
      case 'profile_delete_account':
        return profile_delete_account;
      default:
        throw Exception('Message $key doesn\'t exist in $this');
    }
  }
}
