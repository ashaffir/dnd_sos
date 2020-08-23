import 'dart:async';

import 'package:pickndell/location/location_stream.dart';
import 'package:pickndell/repository/location_repository.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../dao/user_dao.dart';
import '../model/user_model.dart';
import '../ui/bottom_nav_bar.dart';
import 'dart:isolate';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Isolate Section
  ///////////////

  Isolate _isolate;
  bool _running = false;
  static int _counter = 0;
  String notification = "";
  ReceivePort _receivePort;

  void _start() async {
    _running = true;
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_checkTimer, _receivePort.sendPort);
    // _isolate = await Isolate.spawn(_toggleListening, _receivePort.sendPort);
    _receivePort.listen(_handleMessage, onDone: () {
      print("done!");
    });
  }

  void _stop() {
    if (_isolate != null) {
      setState(() {
        _running = false;
        notification = '';
      });
      _receivePort.close();
      _isolate.kill(priority: Isolate.immediate);
      _isolate = null;
    }
  }

  void _handleMessage(dynamic data) {
    print('RECEIVED: ' + data);
    setState(() {
      notification = data;
    });
  }

  static void _checkTimer(SendPort sendPort) async {
    Timer.periodic(new Duration(seconds: 1), (Timer t) {
      // _counter++;
      // _getCurrentLocaiton();
      String msg = 'notification ' + _counter.toString();
      print('SEND: ' + msg);
      sendPort.send(msg);
    });
  }

  // Stream Section
  ///////////////

  StreamSubscription<Position> _positionStreamSubscription;
  final List<Position> _positions = <Position>[];

  // void _toggleListening(SendPort sendPort) {  // for isolate
  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      const LocationOptions locationOptions =
          LocationOptions(accuracy: LocationAccuracy.best);
      final Stream<Position> positionStream =
          Geolocator().getPositionStream(locationOptions);
      _positionStreamSubscription = positionStream.listen(
          (Position position) => setState(() => print('You here: $position')));
      _positionStreamSubscription.pause();
    }

    setState(() {
      if (_positionStreamSubscription.isPaused) {
        _positionStreamSubscription.resume();
        print('Started!');
      } else {
        _positionStreamSubscription.pause();
        print('Stopped!');
      }
    });
  }

  //Simple location retrieval section
  /////////////////

  // Future<dynamic> _getCurrentLocaiton() async {
  static void _getCurrentLocaiton() async {
    LocationRepository updateLocation = LocationRepository();

    // Position position = await Geolocator()
    //     .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    // updateLocation.updateUserLocation(position);
    // print("Position: $position");

    // return position;
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UserDao().getUser(0),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          return getHomePage(snapshot.data);
        } else {
          print("No data");
        }
        return CircularProgressIndicator();
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // build(context);
  }

  Widget getHomePage(User currentUser) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/pickndel-logo-1.png',
                width: MediaQuery.of(context).size.width * 0.70,
                // height: MediaQuery.of(context).size.height * 0.50,
                // width: 300,
              ),
              Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Text(
                  'Welcome: ${currentUser.userId}',
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Text(
                  'Courier: ${currentUser.isEmployee}',
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(34.0, 20.0, 0.0, 0.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.width * 0.16,
                  child: RaisedButton(
                    child: Text(
                      'Get Location',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    onPressed: () {
                      // Enable tracking = Available state
                      _getCurrentLocaiton(); //Getting location upon pressing button
                      // _running
                      // ? _stop()
                      // : _start(); // Starts Isolate (background)
                      // _toggleListening(); // Start listening to a stream (not background)
                      // LocationStream().toggleListening(true);
                    },
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
      // resizeToAvoidBottomPadding: false,
    );
  }
}
