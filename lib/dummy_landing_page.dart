import 'package:flutter/material.dart';

class DummyLandingPage extends StatefulWidget {
  DummyLandingPage({Key? key}) : super(key: key);

  @override
  State<DummyLandingPage> createState() => _DummyLandingPageState();
}

class _DummyLandingPageState extends State<DummyLandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Text('This is a Test Landing page')],
      ),
    );
  }
}
