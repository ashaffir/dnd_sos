# bloc_login

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# Reference:
* Login: https://dev.to/amartyadev/flutter-app-authentication-with-django-backend-1-21cp

# REFERENCE: Push notification
* Firebase cloud messageing (FCM, push notification) installation notes:
- Video: https://www.youtube.com/watch?v=PrnxksGQ210
- firebase_messaging flutter plugin: https://pub.dev/packages/firebase_messaging
- firebase messaging with flutter tutorial: https://www.djamware.com/post/5e4b26e26cdeb308204b427f/flutter-tutorial-firebase-cloud-messaging-fcm-push-notification
- Issue with the Java application class: https://stackoverflow.com/questions/59446933/pluginregistry-cannot-be-converted-to-flutterengine 

* Apple:
Name:pickndellNotifications
Key ID:CBXY3M57V2
Services:Apple Push Notifications service (APNs), DeviceCheck, ClassKit Catalog

App ID Prefix
9949TZ449H (Team ID)
Description
PickNdell iOS app
Bundle ID
com.actappon.pickndell (explicit)

# REFERENCE: icon change: https://www.youtube.com/watch?v=elBYrfnJEHo
- In addition to the replacement of the image in the yaml file run:

> flutter pub run flutter_launcher_icons:main

# REFERENCE: name change
> flutter pub run flutter_launcher_name:main

# REFERENCE: Login page with BLOC: 
- https://medium.com/flutter-community/flutter-login-tutorial-with-flutter-bloc-ea606ef701ad

# REFERENCE: build apk with Andtoid Studio
- https://www.youtube.com/watch?v=qBEOC5-58s8
- SDK change: https://www.youtube.com/watch?v=7THufyK-V0Y

Build commands:
> flutter clean
> flutter build apk --split-per-abi

# REFERENCE: Android app deployment on to the Google Play
- https://flutter.dev/docs/deployment/android
- Change app version: https://stackoverflow.com/questions/53570575/flutter-upgrade-the-version-code-for-play-store
- https://www.youtube.com/watch?v=7MrXU-fhacU

# REFERENCE: Languages/localization/translations
- https://medium.com/flutter-community/yet-another-localization-approach-in-flutter-477cf058ba41
- Procedure for adding translated text (after the setup in the source code):
* Make sure the hot-builder is running (dynamically updates the changes in the Yaml files):
> flutter packages pub run build_runner watch --delete-conflicting-outputs

* Text direction: 
- Directionality widget (https://stackoverflow.com/questions/50535185/right-to-left-rtl-in-flutter)

* Add the key for the translated text in each Yaml file (each language)
* Add the pointer to that key in the code (instead of the text, e.g. translation.loginPageTitle)
* Restart the app

# REFERENCE: Google maps autocomplete
- https://developers.google.com/places/web-service/autocomplete
- Flutter plugin: https://pub.dev/packages/google_maps_flutter
- Google coordinates: https://medium.com/@usamasiddiqui766/google-places-autocomplete-suggestions-in-flutter-469fd65f4492
- AutoComplete: https://www.youtube.com/watch?v=rJOkoAmC5GY
- Plugin for search: https://www.youtube.com/watch?v=sco5RsYgpwc (???)

# REFERENCE: NGROK alternative: 
- https://localtunnel.github.io/www/
- Install:
npm install -g localtunnel
- Run: 
lt --port 8000

# REFERENCE: uploading images to the server
- https://stackoverflow.com/questions/49125191/how-to-upload-images-and-file-to-a-server-in-flutter
- https://stackoverflow.com/questions/51161862/how-to-send-an-image-to-an-api-in-dart-flutter
- Getting the profile pic: https://stackoverflow.com/questions/51338041/how-to-save-image-file-in-flutter-file-selected-using-image-picker-plugin

# REFERENCE: Bottom naviagation bar with hedged area
- https://medium.com/coding-with-flutter/flutter-bottomappbar-navigation-with-fab-8b962bb55013

# REFERENCE: Timer/Duration/Delays
- https://stackoverflow.com/questions/49471063/how-to-run-code-after-some-delay-in-flutter