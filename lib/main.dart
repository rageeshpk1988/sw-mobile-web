import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:provider/provider.dart';

import '/src/home/landing/screens/landing_page_web.dart';
import '/src/login/screens/login_mobile_web.dart';

import '../src/home/landing/screens/landing_page.dart';
//import 'package:sentry_flutter/sentry_flutter.dart';
import '/util/app_theme_cupertino.dart';

import './src/custom_routes.dart';
import './screens/splash_screen.dart';
import './src/intro/intro_screen.dart';
import './src/providers/auth.dart';
import './src/providers_list.dart';
import './util/app_theme.dart';
import 'helpers/constants.dart';
import './helpers/global_variables.dart';

/*
 * - Try auto login , if fails then load introduction page followed by mobile number and 
 * password authentication
 * - If authenticated, load home page 
 *  
 */

//In -app notifications

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  //print('Handling a background message ${message.messageId}');
}

// Global key for our Navigation so that we can push a route w/o context
final GlobalKey<NavigatorState> _navigator = new GlobalKey<NavigatorState>();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title or name
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
//In -app notifications

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  if (kIsWeb) {
    // initialize the facebook javascript SDK
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: "860116448033283",
      cookie: true,
      xfbml: true,
      version: "v14.0",
    );
    //Production
    // await Firebase.initializeApp(
    //     options: FirebaseOptions(
    //         apiKey: "AIzaSyC_UH3IsnpBVPqvPO8y_sN7VOa-MErDV3M",
    //         authDomain: "schoolwizarduat.firebaseapp.com",
    //         databaseURL: "https://schoolwizarduat.firebaseio.com",
    //         projectId: "schoolwizarduat",
    //         storageBucket: "schoolwizarduat.appspot.com",
    //         messagingSenderId: "352565823138",
    //         appId: "1:352565823138:web:c6d142207744a2765239fb",
    //         measurementId: "G-WKEZSBC8S8"));
    //Staging
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDmdUShT5W8xTBdTFdipCIpFeS7a6I5KXg",
            authDomain: "schoowizardqa.firebaseapp.com",
            databaseURL: "https://schoowizardqa.firebaseio.com",
            projectId: "schoowizardqa",
            storageBucket: "schoowizardqa.appspot.com",
            messagingSenderId: "614960272316",
            appId: "1:614960272316:web:f615eeaa4cea3a214411b9",
            measurementId: "G-BHELES4HBK"));
  } else {
    await Firebase.initializeApp();
  }
  //FCM settings
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('notification');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  //This will handle our click if the app is in Foreground
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
  //     onSelectNotification: (String? payload) async {
  //   debugPrint('payload: $payload');
  //   _navigator.currentState!.pushNamed('/' + '$payload');
  // });
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse? payload) async {
    // debugPrint('payload: $payload');
    _navigator.currentState!.pushNamed('/' + '${payload?.payload}');
  });

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  //FCM settings

  // if (kIsWeb) {
  //   //In web we are cleaning the locally stored authdata
  //   SharedPrefData.clearDataPref();
  // }
  runApp(MyApp());

  // await SentryFlutter.init(
  //   (options) {
  //     options.dsn =
  //         'https://9b69ad4b378044ecb8a17159b2f9acf3@o1119741.ingest.sentry.io/6154467';
  //     // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
  //     // We recommend adjusting this value in production.
  //     options.tracesSampleRate = 1.0;
  //   },
  //   appRunner: () => runApp(MyApp()),
  // );

  // or define SENTRY_DSN via Dart environment variable (--dart-define)
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: providersList,
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => kIsWeb || Platform.isAndroid
            ? MaterialApp(
                scrollBehavior: kIsWeb
                    ? NoThumbScrollBehavior().copyWith(scrollbars: false)
                    : null,
                // navigatorObservers: [
                //   SentryNavigatorObserver(),
                // ],
                // builder: (context, child) {
                //   final mediaQueryData = MediaQuery.of(context);
                //   final scale = mediaQueryData.textScaleFactor.clamp(1.0, 1.0);
                //   return MediaQuery(
                //     child: child!,
                //     data:
                //         MediaQuery.of(context).copyWith(textScaleFactor: scale),
                //   );
                // },
                navigatorKey: _navigator,
                debugShowCheckedModeBanner: false,
                supportedLocales: SUPPORTED_LOCALES_LIST,
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  CountryLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                title: GlobalVariables.appTitle,
                theme: AppTheme.lightTheme,
                home: auth.isAuth
                    ? kIsWeb
                        ? LandingPageWeb()
                        : LandingPage()
                    : FutureBuilder(
                        future: auth.tryAutoLogin(),
                        builder: (ctx, authResultSnapshot) =>
                            authResultSnapshot.connectionState ==
                                    ConnectionState.waiting
                                ? SplashScreen()
                                : kIsWeb
                                    ? LoginMobileWeb()
                                    : IntroScreen(),
                      ),
                routes: customRoutes,
              )
            : CupertinoApp(
                // navigatorObservers: [
                //   SentryNavigatorObserver(),
                // ],
                // builder: (context, child) {
                //   final mediaQueryData = MediaQuery.of(context);
                //   final scale = mediaQueryData.textScaleFactor.clamp(1.0, 1.0);
                //   return MediaQuery(
                //     child: child!,
                //     data:
                //         MediaQuery.of(context).copyWith(textScaleFactor: scale),
                //   );
                // },
                navigatorKey: _navigator,
                debugShowCheckedModeBanner: false,
                supportedLocales: SUPPORTED_LOCALES_LIST,
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  DefaultMaterialLocalizations.delegate,
                  DefaultCupertinoLocalizations.delegate,
                  DefaultWidgetsLocalizations.delegate,
                ],
                title: GlobalVariables.appTitle,
                theme: AppThemeCupertino.lightTheme,
                home: auth.isAuth
                    ? LandingPage()
                    : FutureBuilder(
                        future: auth.tryAutoLogin(),
                        builder: (ctx, authResultSnapshot) =>
                            authResultSnapshot.connectionState ==
                                    ConnectionState.waiting
                                ? SplashScreen()
                                : IntroScreen(),
                      ),
                routes: customRoutes,
              ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
      };
}
