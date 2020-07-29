### Course 1 Quiz: https://www.youtube.com/watch?v=x0uinJvhNxI
### Course 2: https://www.youtube.com/watch?v=6ZCz6Ylqk3A

#### Start at 1:23

Dev training: https://dartpad.dev/

## Project directories:
idea - holds the configuration for Android Studio (not need to be touched if we are not working with Android Studio)
.vscode - cofigurations for the VSCODE IDE
android - very important. This is where all the build app will be. This is a passive folder (n need to touch)
build - passive. All deloyment files will be there
ios - for the most, passive. managed by the Flutter SDK
lib - important!! This is where we are writing and putting source files
test - testing files

- pubspec - where 3rd party packages will be mentioned (files, images, fonts, versions...)


- Widgets are the basic building blocks and component of the Flutter app.
# Widgets sometimes contain other widgets (Widget tree)
# A page is also a widget, referred to as Scaffold
# There are different types of widgets:
## Visual (Button, Text, Card...)
## Invisable (Row, Column, ListView,...)
## Container()

# The widgets need to be a stand alone unit, thus everything that belogs to a particular
# widget needs to go to the same class, data, functions...

# State
## Stateless widget: changes the UI according to external data that it is given.
## Statefull widget: changes the UI accodring to the external data it is given and accoerind to an internal state.
i.e. stateful widget is when we are planning to do manipulations to the data getting into that widget (counter, logic, conditions...).
- The sate does not change while there is a re-build of the widget
- The widget has to have a "state" statement

A stateless widget has to be with a constructor that initiates with the input values.

# Syntax & and convensions
- To signal the builder about a private property, method or object, i.e that needs to be 
    accessed only from that file, you can add a leading _ to the name of that class/var/fucntion
- One widget per file
- Add "final" before attributes/vars that are not supposed to change after initialization, i.e. after the widget is live (displaying)

# Shortcuts (keys)
- create (for state)
- st (to start writing a widget)

#  Get acquianted with the Flutter widget catalog: https://flutter.dev/docs/development/ui/widgets

# Refactor widgets with a "refactor command" 
Stand on the widget and ^-shift-R

# Images files locations are defined in the pubspec.yaml file

# Adding packages to pubspec.yaml
- Notice that the indent is important
- the '-' is also important
- To install new dependencies: flutter pub get

# Design and layout good practice: 
https://www.youtube.com/watch?v=-MBWdZ1u8tQ

# Parsing JSON:
- https://stackoverflow.com/questions/51854891/error-listdynamic-is-not-a-subtype-of-type-mapstring-dynamic
- https://medium.com/flutter-community/parsing-complex-json-in-flutter-747c46655f51
