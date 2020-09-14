import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationStream {
  StreamSubscription<Position> _positionStreamSubscription;

  // void _toggleListening(SendPort sendPort) {  // for isolate
  void toggleListening(bool isTracking) {
    if (isTracking) {
      if (_positionStreamSubscription == null) {
        const LocationOptions locationOptions =
            LocationOptions(accuracy: LocationAccuracy.best);
        final Stream<Position> positionStream =
            Geolocator().getPositionStream(locationOptions);
        _positionStreamSubscription =
            positionStream.listen((Position position) {
          if (_positionStreamSubscription.isPaused) {
            _positionStreamSubscription.resume();
            print('Started!');
            print('You here: $position');
          } else {
            _positionStreamSubscription.pause();
            print('Stopped!');
          }
        });
      }
    }
  }
}
