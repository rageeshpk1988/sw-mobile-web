import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '/util/ui_helpers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../util/app_theme.dart';

class WebIntroScreen extends StatefulWidget {
  static String routeName = '/intro';
  const WebIntroScreen({Key? key}) : super(key: key);

  @override
  _WebIntroScreenState createState() => _WebIntroScreenState();
}

class _WebIntroScreenState extends State<WebIntroScreen> {
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;
  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;

  bool _isPlayerReady = false;
  final List<String> _ids = ['t5MnYKtIPxk'];
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
        forceHD: false,
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
    var deviceSize = MediaQuery.of(context).size;
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    // ]);

    Widget _bodyWidget(String imageUrl) {
      return Image.asset(
        imageUrl,
        width: deviceSize.width * (screenWidth(context) > 400 ? 0.20 : 0.50),
        height: deviceSize.height * (screenWidth(context) > 400 ? 0.40 : 0.15),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IntroductionScreen(
          globalBackgroundColor: Colors.white,
          scrollPhysics: BouncingScrollPhysics(),

          //controlsPadding: EdgeInsets.all(10.0),

          pages: [
            PageViewModel(
              decoration: PageDecoration(pageColor: Colors.white),
              title: '',
              bodyWidget: _bodyWidget('assets/images/splash1_web.png'),
              // useScrollView: false,
            ),
            PageViewModel(
              decoration: PageDecoration(pageColor: Colors.white),
              title: '',
              bodyWidget: _bodyWidget('assets/images/splash2_web.png'),
              //useScrollView: false,
            ),
            PageViewModel(
              decoration: PageDecoration(pageColor: Colors.white),
              title: '',
              bodyWidget: _bodyWidget('assets/images/splash3_web.png'),
              //useScrollView: false,
            ),
            // PageViewModel(
            //   title: '',
            //   body: '',
            //   image: YoutubePlayerBuilder(
            //     onEnterFullScreen: () {
            //       SystemChrome.setPreferredOrientations(
            //           [DeviceOrientation.portraitUp]);
            //     },
            //     onExitFullScreen: () {
            //       SystemChrome.setPreferredOrientations(
            //           [DeviceOrientation.portraitUp]);
            //       // Future.delayed(const Duration(seconds: 1), () {
            //       //   _controller.play();
            //       // });
            //       // Future.delayed(const Duration(seconds: 5), () {
            //       //   SystemChrome.setPreferredOrientations(
            //       //       DeviceOrientation.values);
            //       // });
            //     },
            //     player: YoutubePlayer(
            //       controller: _controller,
            //       showVideoProgressIndicator: true,
            //       progressIndicatorColor: AppTheme.primaryColor,
            //       progressColors: ProgressBarColors(
            //         playedColor: AppTheme.primaryColor,
            //         handleColor: AppTheme.secondaryColor,
            //       ),
            //       bottomActions: [
            //         const SizedBox(width: 14.0),
            //         CurrentPosition(),
            //         const SizedBox(width: 8.0),
            //         ProgressBar(isExpanded: true),
            //         RemainingDuration(),
            //         const PlaybackSpeedButton(),
            //       ],
            //       onReady: () {
            //         _controller.addListener(listener);
            //       },
            //     ),
            //     builder: (context, player) {
            //       return const Text('hello');
            //     },
            //   ),
            //   // footer: Column(
            //   //   mainAxisSize: MainAxisSize.min,
            //   //   mainAxisAlignment: MainAxisAlignment.end,
            //   //   children: [
            //   //     // const SizedBox(height: 100),
            //   //     _pageFooter(),
            //   //   ],
            //   // ),
            //   //useScrollView: false,
            // ),
          ],
          onDone: () {},
          showDoneButton: false,
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

  // Widget _pageFooter() => Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         const SizedBox(height: 10),
  //         Image.asset('assets/images/Mascot.png', width: 55, height: 42),
  //         const SizedBox(height: 20),
  //         InkWell(
  //           child: Text(
  //             GlobalVariables.website,
  //             style: TextStyle(color: Colors.blue),
  //           ),
  //           onTap: () {
  //             UrlLauncher.launchURL(GlobalVariables.websiteUrl);
  //           },
  //         ),
  //       ],
  //     );
}
