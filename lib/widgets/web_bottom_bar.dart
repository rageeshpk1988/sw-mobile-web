import 'package:flutter/material.dart';

import '../adaptive/adaptive_theme.dart';
import '../util/ui_helpers.dart';

class WebBottomBar extends StatelessWidget {
  const WebBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth(context) * 0.98,
            height: 34,
            child: TextButton(
              child: Text(
                'Copyright @ SchoolWizard.com 2022',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      AdaptiveTheme.secondaryColor(context))),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
