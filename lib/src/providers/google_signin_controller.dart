import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../src/models/socialaccesstoken_request.dart';
import '../../util/dialogs.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn(scopes: ['email']);
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;


  // apple sign in function
  Future appleLogin(BuildContext context) async {
    try {
      final appleUser =  await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      if (appleUser == null) return;
     // _user = googleUser;

      //final googleAuth = await googleUser.authentication;
      final oAuthProvider = OAuthProvider('apple.com');

      final credential = oAuthProvider.credential(
        idToken: appleUser.identityToken,
        accessToken: appleUser.authorizationCode,
      );
      print(appleUser.authorizationCode);
      print(appleUser.identityToken);
      print(appleUser.toString());

      await FirebaseAuth.instance.signInWithCredential(credential);
      final appleLoginResultJson = json.encode({
        "email": appleUser.email,
        "name": "${appleUser.givenName} ${appleUser.familyName}",
        "token": appleUser.identityToken,
      });
      var appleLoginResult =
      SocialAdRequest.fromJson(json.decode(appleLoginResultJson));
      return appleLoginResult;
      //notifyListeners();
    } on FirebaseAuthException catch (e) {
      var content = '';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          content = 'This account exists with a different sign in provider';
          break;
        case 'invalid-credential':
          content = 'Unknown error has occurred';
          break;
        case 'operation-not-allowed':
          content = 'This operation is not allowed';
          break;
        case 'user-disabled':
          content = 'The user you tried to log into is disabled';
          break;
        case 'user-not-found':
          content = 'The user you tried to log into was not found';
          break;
      }

      await Dialogs().ackAlert(context, 'Apple login failed', content);
    } catch (e) {
      await Dialogs().ackAlert(context, 'Apple login failed', 'Sign in not completed');
    }
  }


// google sign in function
  Future googleLogin(BuildContext context) async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // print(googleAuth.accessToken);
      // print(googleAuth.idToken);
      // print(googleUser.toString());

      await FirebaseAuth.instance.signInWithCredential(credential);
      final googleLoginResultJson = json.encode({
        "email": googleUser.email,
        "name": googleUser.displayName,
        "token": googleAuth.accessToken,
      });
      var googleLoginResult =
          SocialAdRequest.fromJson(json.decode(googleLoginResultJson));
      return googleLoginResult;
      //notifyListeners();
    } on FirebaseAuthException catch (e) {
      var content = '';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          content = 'This account exists with a different sign in provider';
          break;
        case 'invalid-credential':
          content = 'Unknown error has occurred';
          break;
        case 'operation-not-allowed':
          content = 'This operation is not allowed';
          break;
        case 'user-disabled':
          content = 'The user you tried to log into is disabled';
          break;
        case 'user-not-found':
          content = 'The user you tried to log into was not found';
          break;
      }

      await Dialogs().ackAlert(context, 'Google login failed', content);
    } catch (e) {
      await Dialogs().ackAlert(context, 'Google login failed', e.toString());
    }
  }

  //google sign out- for used emails
  Future googleSignOut() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }

  // apple sign out - for used emails
   appleSignOut() {
    FirebaseAuth.instance.signOut();
  }


// facebook sign in function
  Future facebookLogin(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );
      //final userData = await FacebookAuth.instance.getUserData();
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        final userData = await FacebookAuth.instance.getUserData();
        //final AccessToken accessToken = result.accessToken!;
        // print(userData.toString());
        // print(accessToken.toString());
        // print(result.accessToken!.token);
        await FirebaseAuth.instance.signInWithCredential(credential);
        final facebookLoginResultJson = json.encode({
          "email": userData['email'],
          "name": userData['name'],
          "token": result.accessToken!.token,
        });
        var facebookLoginResult =
            SocialAdRequest.fromJson(json.decode(facebookLoginResultJson));
        return facebookLoginResult;
      }

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      var content = '';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          content = 'This account exists with a different sign in provider';
          break;
        case 'invalid-credential':
          content = 'Unknown error has occurred';
          break;
        case 'operation-not-allowed':
          content = 'This operation is not allowed';
          break;
        case 'user-disabled':
          content = 'The user you tried to log into is disabled';
          break;
        case 'user-not-found':
          content = 'The user you tried to log into was not found';
          break;
      }

      await Dialogs().ackAlert(context, 'Facebook login failed', content);
    } catch (e) {
      await Dialogs().ackAlert(context, 'Facebook login failed', e.toString());
    }
  }
}

//


