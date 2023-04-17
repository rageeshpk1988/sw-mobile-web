import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../adaptive/adaptive_circular_progressInd.dart';

class VideoFromNetwork extends StatefulWidget {
  final String videoUrl;
  VideoFromNetwork({Key? key, required this.videoUrl}) : super(key: key);
  @override
  _VideoFromNetworkState createState() => _VideoFromNetworkState();
}

class _VideoFromNetworkState extends State<VideoFromNetwork> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        // setState(() {});
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

  }

  @override
  void dispose() {
    _controller.pause();
      deactivate();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (VisibilityInfo info) {
        //debugPrint("${info.visibleFraction} of my widget is visible");
        if (info.visibleFraction == 0) {
          //if (info.visibleFraction < 1) {
          if (_controller.value.isPlaying) _controller.pause();
        } else {
          //_controller.play();
        }
      },
      child: SizedBox(
        height: 250,
        width: size.width * 0.90,
        child: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayerWidget(controller: _controller),
                )
              : Container(
                  child: Center(
                    child: AdaptiveCircularProgressIndicator(),
                  ),
                ),
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoPlayerWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  @override
  void dispose() {
    super.dispose();
    //widget.controller.pause();
    //widget.controller.dispose(); //jk for testing
  }

  @override
  Widget build(BuildContext context) => widget.controller.value.isInitialized
      ? Container(alignment: Alignment.topCenter, child: buildVideo())
      : Container(
          height: 250,
          child: Center(child: AdaptiveCircularProgressIndicator()),
        );

  Widget buildVideo() => Stack(
        children: <Widget>[
          buildVideoPlayer(),
          Positioned.fill(
              child: BasicOverlayWidget(controller: widget.controller)),
        ],
      );

  Widget buildVideoPlayer() => AspectRatio(
        aspectRatio: widget.controller.value.aspectRatio,
        child: VideoPlayer(widget.controller),
      );
}

class BasicOverlayWidget extends StatefulWidget {
  final VideoPlayerController controller;

  const BasicOverlayWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  State<BasicOverlayWidget> createState() => _BasicOverlayWidgetState();
}

class _BasicOverlayWidgetState extends State<BasicOverlayWidget> {
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(
            () {
              widget.controller.value.isPlaying
                  ? widget.controller.pause()
                  : widget.controller.play();
            },
          );
        },
        child: Stack(
          children: <Widget>[
            buildPlay(),
            Positioned(bottom: 0, left: 0, right: 0, child: buildIndicator()),
          ],
        ),
      );

  Widget buildIndicator() => VideoProgressIndicator(
        widget.controller,
        allowScrubbing: true,
        // padding: EdgeInsets.only(top: 20.0),
        // colors: VideoProgressColors(
        //     backgroundColor: Colors.red,
        //     bufferedColor: Colors.black,
        //     playedColor: Colors.blueAccent),
      );

  Widget buildPlay() {
    return widget.controller.value.isPlaying
        ? Container(
            alignment: Alignment.center,
            child: Icon(Icons.pause, color: Colors.black12, size: 50),
          )
        : Container(
            alignment: Alignment.center,
            color: Colors.black26,
            child: Icon(Icons.play_arrow, color: Colors.white, size: 50),
          );
  }
}
