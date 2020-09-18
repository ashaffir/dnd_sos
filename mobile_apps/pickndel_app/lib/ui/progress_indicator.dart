import 'package:flutter/material.dart';
import 'package:flutter_colored_progress_indicators/flutter_colored_progress_indicators.dart';

// LOADING INDICATOR
class ColoredProgressDemo extends StatefulWidget {
  final String loaderText;
  ColoredProgressDemo(this.loaderText);
  @override
  _ColoredProgressDemoState createState() => _ColoredProgressDemoState();
}

class _ColoredProgressDemoState extends State<ColoredProgressDemo> {
  Future<void> _refreshState() async {
    await Future.delayed(Duration(seconds: 7));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Text("Scroll from top for Refresh Indicator"),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ColoredRefreshIndicator(
                onRefresh: () => _refreshState(),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          widget.loaderText,
                          textScaleFactor: 2.0,
                          textAlign: TextAlign.center,
                          style: TextStyle(),
                        ),
                        SizedBox(height: 50.0),
                        SizedBox(
                          height: 50.0,
                          width: 50.0,
                          child: CircularProgressIndicator(strokeWidth: 8.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
