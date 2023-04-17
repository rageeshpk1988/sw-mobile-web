import 'package:flutter/material.dart';
import '../../../util/app_theme.dart';
import '../../../widgets/rounded_button.dart';

class SuggestedParentsScreen extends StatefulWidget {
  static String routeName = '/suggested-parents';
  const SuggestedParentsScreen({Key? key}) : super(key: key);

  @override
  _SuggestedParentsScreenState createState() => _SuggestedParentsScreenState();
}

class _SuggestedParentsScreenState extends State<SuggestedParentsScreen> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/images/sw_appbar_logo.png', height: 25),
          centerTitle: false,
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Suggested Parents',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25)),
              const SizedBox(height: 30),
              SuggestedParentsList
            ],
          ),
        ))));
  }

  Widget SuggestedParentsList = new Container(
    margin: EdgeInsets.symmetric(vertical: 20.0),
    height: 700,
    child: new ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          child: ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Text parent $index'),
            trailing: RoundButton(
                title: 'follow',
                onPressed: () {},
                color: AppTheme.secondaryColor),
          ),
        );
      },
    ),
  );
}
