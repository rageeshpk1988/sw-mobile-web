import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/adaptive/adaptive_theme.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../adaptive/adaptive_custom_appbar.dart';

class CorporateVideoScreen extends StatefulWidget {
  static String routeName = '/corporate-video';
  const CorporateVideoScreen({Key? key}) : super(key: key);

  @override
  State<CorporateVideoScreen> createState() => _CorporateVideoScreenState();
}

class _CorporateVideoScreenState extends State<CorporateVideoScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;
  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  bool _isPlayerReady = false;
  // final List<String> _ids = ['t5MnYKtIPxk'];
  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: 't5MnYKtIPxk',
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
    _playerState = PlayerState.unStarted;
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
  void dispose() {
    //deactivate();
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdaptiveCustomAppBar(
        title: "Corporate Video",
        showShopifyHomeButton: false,
        showShopifyCartButton: false,
        showKycButton: false,
        showProfileButton: false,
        showHamburger: false,
        scaffoldKey: scaffoldKey,
        adResponse: null,
        loginResponse: null,
        updateHandler: null,
        showMascot: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            YoutubePlayerBuilder(
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
                controller: _controller,
                // showVideoProgressIndicator: true,
                progressIndicatorColor: AdaptiveTheme.primaryColor(context),
                progressColors: ProgressBarColors(
                  playedColor: AdaptiveTheme.primaryColor(context),
                  handleColor: AdaptiveTheme.secondaryColor(context),
                ),
                bottomActions: [
                  const SizedBox(width: 14.0),
                  CurrentPosition(),
                  const SizedBox(width: 8.0),
                  ProgressBar(
                    isExpanded: true,
                    colors: ProgressBarColors(
                      playedColor: AdaptiveTheme.primaryColor(context),
                      handleColor: AdaptiveTheme.secondaryColor(context),
                    ),
                  ),
                  RemainingDuration(),
                  const PlaybackSpeedButton(),
                ],
                onReady: () {
                  _controller.addListener(listener);
                },
              ),
              builder: (context, player) {
                return player;
              },
            ),
          ],
        ),
      ),
    );
  }
}
