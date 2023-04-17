import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../../adaptive/adaptive_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '/helpers/url_launcher.dart';

import '../../src/login/screens/login_mobile.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../util/app_theme.dart';
import '../../helpers/global_variables.dart';

class IntroScreen extends StatefulWidget {
  static String routeName = '/intro';
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final title1 = 'Analyse your child\'s potential and interests.';

  final title2 = '1000\'s of programs and scholarship for your kids.';

  final title3 = 'Connect and interact with teachers and other parents.';

  final body1 =
      'Help in determining the distinct and elusive characteristic of the child. Provides a streamlined custom program to enhance the gifted aptitudes';

  final body2 =
      'Renders them with the right program to improve their inborn abilities. Provides them accessibility to the wide spectrum of opportunities';

  final body3 =
      'Impasses the mentors to provide a deeper insight on the growth of the child. Assistance to nurture the child with the accurate supervision';
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;
  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;

  bool _isPlayerReady = false;
  final List<String> _ids = ['sAyDP4xVTGo'];
  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: _ids.first,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: true,
        enableCaption: true,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
    if (_controller.value.isFullScreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var appLocalization = AppLocalizations.of(context)!;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    Widget _bodyWidget(String imageUrl) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              imageUrl,
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.75,
            ),
            /*Positioned(
              bottom: 30,
              child: InkWell(
                child: Text(
                  GlobalVariables.website,
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  UrlLauncher.launchURL(GlobalVariables.websiteUrl);
                },
              ),
            ),*/
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IntroductionScreen(
          globalBackgroundColor: Colors.white,
          scrollPhysics: BouncingScrollPhysics(),
          controlsPadding: EdgeInsets.all(10.0),

          pages: [
            PageViewModel(

              decoration: PageDecoration(pageColor: Colors.white),
              title: '',
              bodyWidget: _bodyWidget('assets/images/splash1.png'),
              //useScrollView: false,
            ),
            PageViewModel(
              decoration: PageDecoration(pageColor: Colors.white),
              title: '',
              bodyWidget: _bodyWidget('assets/images/splash2.png'),
              //useScrollView: false,
            ),
            PageViewModel(
              decoration: PageDecoration(pageColor: Colors.white),
              title: '',
              bodyWidget: _bodyWidget('assets/images/splash3.png'),
              // useScrollView: false,
            ),
            PageViewModel(
              decoration: PageDecoration(pageColor: Colors.white,fullScreen: true),
              title: '',
              body: '',
              image: YoutubePlayerBuilder(
                onEnterFullScreen: () {
                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);
                },
                onExitFullScreen: () {
                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);
                  // Future.delayed(const Duration(seconds: 1), () {
                  //   _controller.play();
                  // });
                  // Future.delayed(const Duration(seconds: 5), () {
                  //   SystemChrome.setPreferredOrientations(
                  //       DeviceOrientation.values);
                  // });
                },
                player: YoutubePlayer(
                  aspectRatio: 9/16,
                  controller: _controller,
                  //showVideoProgressIndicator: true,
                  progressIndicatorColor: AdaptiveTheme.primaryColor(context),
                  progressColors: ProgressBarColors(
                    playedColor: AdaptiveTheme.primaryColor(context),
                    handleColor: AdaptiveTheme.secondaryColor(context),
                  ),
                  bottomActions: [
                    const SizedBox(width: 14.0),
                    CurrentPosition(),
                    const SizedBox(width: 8.0),
                    ProgressBar(isExpanded: true,colors: ProgressBarColors(
                      playedColor: AdaptiveTheme.primaryColor(context),
                      handleColor: AdaptiveTheme.secondaryColor(context),
                    ),),
                    RemainingDuration(),
                    const PlaybackSpeedButton(),


                  ],
                  onReady: () {
                    _controller.addListener(listener);
                    // _controller.play();
                  },
                ),
                builder: (context, player) {
                  return  Align(alignment: Alignment(0.0, -0.4),child: SizedBox(height:MediaQuery.of(context).size.height * 0.80 ,width:MediaQuery.of(context).size.width * 0.95 ,child: player));
                },
              ),
              /*footer: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 150),
                  _pageFooter(),
                ],
              ),*/
              //useScrollView: false,
            ),
          ],

          onDone: () {},
          done: _doneButton(context),
          showNextButton: false,
          isBottomSafeArea: true,
          // globalHeader: Image.asset('assets/images/sw_appbar_logo.png'),
          dotsDecorator: DotsDecorator(
            activeColor: AppTheme.secondaryColor,
          ),
          onChange: (index) => deactivate(),
        ),
      ),
    );
  }

  Widget _pageFooter() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const SizedBox(height: 10),
      Image.asset('assets/images/Mascot.png', width: 55, height: 42),
      /*const SizedBox(height: 20),
      InkWell(
        child: Text(
          GlobalVariables.website,
          style: TextStyle(color: Colors.blue),
        ),
        onTap: () {
          UrlLauncher.launchURL(GlobalVariables.websiteUrl);
        },
      ),*/
    ],
  );

  Widget _doneButton(BuildContext context) => FloatingActionButton(
    onPressed: () {
      deactivate();
      // Navigator.of(context).pushNamed(LoginWithPassword.routeName);
      Navigator.of(context).pushNamed(LoginMobile.routeName);
    },
    child: Icon(
      Icons.done,
      color: Colors.white,
    ),
    mini: true,
    backgroundColor: AdaptiveTheme.primaryColor(context),
  );
}
