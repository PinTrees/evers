import 'dart:developer';
import 'package:evers/class/widget/youtube/meta_data_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';



/// YouTube 동영상을 재생하기 위한 스타일 클래스입니다.
class VideoStyle {
  final double aspectRatio;
  final double? height;
  final double? width;
  final EdgeInsets padding;

  /// 생성자입니다.
  ///
  /// [aspectRatio]: 비디오 플레이어의 가로 대비 세로 비율을 나타냅니다.
  /// [height]: 비디오 플레이어의 높이를 설정합니다. 설정하지 않으면 자동으로 계산됩니다.
  /// [width]: 비디오 플레이어의 너비를 설정합니다. 설정하지 않으면 자동으로 계산됩니다.
  VideoStyle({
    this.aspectRatio = 16 / 9,
    this.height,
    this.width,
    this.padding = const EdgeInsets.all(0),
  });
}




/// YouTube 동영상을 재생하기 위한 파라미터 클래스입니다.
class VideoParams {
  final String url;
  final bool mute;
  final bool autoPlay;

  /// 생성자입니다.
  ///
  /// [url]: 재생할 YouTube 동영상의 URL을 지정합니다.
  /// [mute]: 음소거 여부를 설정합니다. 기본값은 false입니다.
  /// [showControls]: 동영상 컨트롤러의 표시 여부를 설정합니다. 기본값은 true입니다.
  /// [showFullscreenButton]: 전체 화면 버튼의 표시 여부를 설정합니다. 기본값은 true입니다.
  /// [loop]: 동영상의 반복 재생 여부를 설정합니다. 기본값은 false입니다.
  VideoParams({
    required this.url,
    this.mute = true,
    this.autoPlay = true,
  });
}




/// YouTube 동영상을 재생하는 컨테이너 위젯입니다.
class VideoContainer extends StatefulWidget {
  final VideoStyle? style;
  final VideoParams? params;

  /// 생성자입니다.
  ///
  /// [style]: YouTube 동영상의 스타일을 설정하는 매개변수입니다.
  /// [params]: YouTube 동영상을 재생하기 위한 파라미터를 설정하는 매개변수입니다.
  VideoContainer({this.style, this.params});

  @override
  _VideoContainerState createState() => _VideoContainerState();
}

/// YoutubeContainer 위젯의 상태관리 클래스 입니다.
class _VideoContainerState extends State<VideoContainer> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.params == null) return;
    VideoParams params = widget.params!;

    _controller = VideoPlayerController.network(params.url)
      ..initialize().then((_) {
        if(params.mute) _controller!.setVolume(0);
        if(params.autoPlay) _controller!.play();
        setState(() {});
      });
  }

  Widget buildMain({required VideoStyle style, required VideoParams? params}) {
    if (params == null) return SizedBox();

    Widget video = const SizedBox();
    if (_controller != null) {
      video = _controller!.value.isInitialized ?
      Container(
        padding: style.padding,
        child: AspectRatio(
          aspectRatio: style.aspectRatio ?? _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      ) : Container();
    }

    return video;
  }

  @override
  Widget build(BuildContext context) {
    return buildMain(
      style: widget.style ?? VideoStyle(),
      params: widget.params,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
