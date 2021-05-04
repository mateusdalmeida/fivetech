import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  double position;
  @override
  void initState() {
    position = -50;
    Future.delayed(const Duration(milliseconds: 0), () {
      setState(() => position = 64);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    return Scaffold(
      body: Container(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: Image.asset(darkModeOn
                        ? "assets/splashDark/splashDark.png"
                        : "assets/splash/splash.png"),
                  )),
              AnimatedPositioned(
                left: 0,
                right: 0,
                bottom: position,
                duration: Duration(milliseconds: 300),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          )),
    );
  }
}
