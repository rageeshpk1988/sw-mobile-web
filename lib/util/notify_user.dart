//Notifications to user

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotifyUser {
  void showSnackBar(String content, BuildContext ctx) {
    if (kIsWeb || Platform.isAndroid) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(content, textAlign: TextAlign.center),
          duration: Duration(seconds: 4),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: content,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        //timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        //fontSize: 16.0,
      );
    }
  }

  Widget showPasswordPolicyText() {
    Row _buildRow(String title) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '* ',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildRow('Password must have minimum 6 characters'),
          _buildRow(
              'Password must contain one Uppercase, one Lowercase and one Number'),
          _buildRow('Password must contain a Special character'),
        ],
      ),
    );
  }
}
