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
  String get usernmane => "Username";
  String get password => "password";
  String get login => "Login";
  String get logout => "Logout";
  String get got_to_profile => "Go to Profile";
  String get forgot_password => "Forgot your password";
  String get create_account => "Create a new account";
  String get alert_email => "Please enter a valid email";
  String get alert_password => "Please enter password";
  String get logging_in => "Logging in...";
  String get loading_account => "Loading account";
  String get loading_orders => "Loading orders";
  String get sender_account => "Sender Account";
  String get courier_account => "Courier Account";
  String get account_status => "Account Status";
  String get active => "Active";
  String get pending_approval => "Pending Approval";
  String get profile_not_complete => "Profile Not Complete";
  String get your_account_not_approved_yet =>
      "Your account is not approved yet";
  String get your_account_reviewed =>
      "Your account is being reviewed. We will notify you once approved";
  String get complete_profile => "Please complete your profile first";
  String get edit_profile => "Edit Profile";
  String get long_press_on => "Long press on";
  String get for_more_info => "for more information";
  String get upload_photo => "Upload Photo";
  String get back_to_dashboard => "Back to dashboard";
  String get back_to_profile => "Back to profile";
  String get change_the_name => "Change the name";
  String get change_the_email => "Change the email";
  String get change_the_category => "Change the category";
  String get change_the_vehicle => "Change the vehicle";
  String get enter_with_country_code => "Enter phone with country code, e.g.";
  String get enter_here => "Enter here";
  String get update => "Update";
  String get name_not_valid => "Name entered is not valid";
  String get month_not_valid => "Month not valid";
  String get year_not_valid => "Year not valid";
  String get cvv_number_not_valid => "CVV not valid";
  String get home_title => "Profile";
  String get home_courier_profile => "Courier Profile";
  String get home_sender_profile => "Sender Profile";
  String get home_name => "Name";
  String get home_phone => "Phone";
  String get home_courier_rating => "Courier Rating";
  String get home_sender_rating => "Sender Rating";
  String get home_unrated => "Unrated";
  String get home_vehicle => "Vehicle";
  String get category => "Category";
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
  String get orders_cancel => "Close";
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
      "Please switch to Available status before accepting orders";
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
  String get orders_empty_list => "Order list is Empty";
  String get orders_creating_new_order => "Creating a new order";
  String get order_new_order_confirmation => "New Order Confirmation";
  String get orders_order_cost => "Order Cost";
  String get orders_confirm_order => "Confirm Order";
  String get orders_confirming_order => "Confirming order";
  String get orders_order_confirmed => "Order Confirmed";
  String get orders_order_created => "Order Created";
  String get order_confirm_archive => "Confirm Cancellation";
  String get orders_order_delivery => "Order Delivery";
  String get orders_error => "Error";
  String get messages_register_title => "Confirmation";
  String get messages_register_thanks => "Thank you";
  String get messages_register_activation =>
      "We have sent you an activation email. Please check your email box and to activate your account";
  String get messages_register_pickup => "Pickup address";
  String get messages_register_drop => "Dropoff address";
  String get messages_register_button => "Go to Login";
  String get messages_push_accept => "Accept";
  String get messages_push_ignore => "Ignore";
  String get messages_select_pickup_address => "Please select a pickup address";
  String get messages_select_dropoff_address =>
      "Please select a dropoff address";
  String get messages_package_type => "Please choose the package type";
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
  String get order_cenceled_successfuly =>
      "Your order was cancelled successfully";
  String get order_delivered => "Order Delivered";
  String get orders_update_error =>
      "There was an error updating this order. Please try again later";
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
  String get your_level => "Your PickNdell Level";
  String get level_tooltip =>
      "The level of the account defines the number of concurrent deliveries you are entitled to do \n Rookie - 1 \n Advanced - 10 \n Expert - Unlimited";
  String get daily_earnings => "Daily Earnings";
  String get daily_cost => "Daily Cost";
  String get new_order => "Create a New Order";
  String get credit_card => "Credit Card";
  String get update_credit_card => "Update Credit Card";
  String get credit_card_number => "Credit Card Number";
  String get credit_card_number_not_valid => "Credit card number is not valid";
  String get restaurant => "Restaurant";
  String get package_type => "Package Type";
  String get urgency => "Urgency";
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
      case 'usernmane':
        return usernmane;
      case 'password':
        return password;
      case 'login':
        return login;
      case 'logout':
        return logout;
      case 'got_to_profile':
        return got_to_profile;
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
      case 'loading_account':
        return loading_account;
      case 'loading_orders':
        return loading_orders;
      case 'sender_account':
        return sender_account;
      case 'courier_account':
        return courier_account;
      case 'account_status':
        return account_status;
      case 'active':
        return active;
      case 'pending_approval':
        return pending_approval;
      case 'profile_not_complete':
        return profile_not_complete;
      case 'your_account_not_approved_yet':
        return your_account_not_approved_yet;
      case 'your_account_reviewed':
        return your_account_reviewed;
      case 'complete_profile':
        return complete_profile;
      case 'edit_profile':
        return edit_profile;
      case 'long_press_on':
        return long_press_on;
      case 'for_more_info':
        return for_more_info;
      case 'upload_photo':
        return upload_photo;
      case 'back_to_dashboard':
        return back_to_dashboard;
      case 'back_to_profile':
        return back_to_profile;
      case 'change_the_name':
        return change_the_name;
      case 'change_the_email':
        return change_the_email;
      case 'change_the_category':
        return change_the_category;
      case 'change_the_vehicle':
        return change_the_vehicle;
      case 'enter_with_country_code':
        return enter_with_country_code;
      case 'enter_here':
        return enter_here;
      case 'update':
        return update;
      case 'name_not_valid':
        return name_not_valid;
      case 'month_not_valid':
        return month_not_valid;
      case 'year_not_valid':
        return year_not_valid;
      case 'cvv_number_not_valid':
        return cvv_number_not_valid;
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
      case 'category':
        return category;
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
      case 'orders_creating_new_order':
        return orders_creating_new_order;
      case 'order_new_order_confirmation':
        return order_new_order_confirmation;
      case 'orders_order_cost':
        return orders_order_cost;
      case 'orders_confirm_order':
        return orders_confirm_order;
      case 'orders_confirming_order':
        return orders_confirming_order;
      case 'orders_order_confirmed':
        return orders_order_confirmed;
      case 'orders_order_created':
        return orders_order_created;
      case 'order_confirm_archive':
        return order_confirm_archive;
      case 'orders_order_delivery':
        return orders_order_delivery;
      case 'orders_error':
        return orders_error;
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
      case 'messages_select_pickup_address':
        return messages_select_pickup_address;
      case 'messages_select_dropoff_address':
        return messages_select_dropoff_address;
      case 'messages_package_type':
        return messages_package_type;
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
      case 'order_cenceled_successfuly':
        return order_cenceled_successfuly;
      case 'order_delivered':
        return order_delivered;
      case 'orders_update_error':
        return orders_update_error;
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
      case 'your_level':
        return your_level;
      case 'level_tooltip':
        return level_tooltip;
      case 'daily_earnings':
        return daily_earnings;
      case 'daily_cost':
        return daily_cost;
      case 'new_order':
        return new_order;
      case 'credit_card':
        return credit_card;
      case 'update_credit_card':
        return update_credit_card;
      case 'credit_card_number':
        return credit_card_number;
      case 'credit_card_number_not_valid':
        return credit_card_number_not_valid;
      case 'restaurant':
        return restaurant;
      case 'package_type':
        return package_type;
      case 'urgency':
        return urgency;
      default:
        throw Exception('Message $key doesn\'t exist in $this');
    }
  }
}
