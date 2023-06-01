import 'dart:developer';
import 'package:evers/class/widget/youtube/meta_data_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// video_list_page
import 'youtube/play_pause_button_bar.dart';
import 'youtube/player_state_section.dart';
import 'youtube/source_input_section.dart';
import 'youtube/video_list_page.dart';


/// YouTube 동영상을 재생하기 위한 스타일 클래스입니다.
class YoutubeStyle {
  final double aspectRatio;
  final double? height;
  final double? width;
  final EdgeInsets padding;

  /// 생성자입니다.
  ///
  /// [aspectRatio]: 비디오 플레이어의 가로 대비 세로 비율을 나타냅니다.
  /// [height]: 비디오 플레이어의 높이를 설정합니다. 설정하지 않으면 자동으로 계산됩니다.
  /// [width]: 비디오 플레이어의 너비를 설정합니다. 설정하지 않으면 자동으로 계산됩니다.
  YoutubeStyle({
    this.aspectRatio = 16 / 9,
    this.height,
    this.width,
    this.padding = const EdgeInsets.all(0),
  });
}




/// YouTube 동영상을 재생하기 위한 파라미터 클래스입니다.
class YoutubeParams {
  final String url;
  final bool mute;
  final bool showControls;
  final bool showFullscreenButton;
  final bool loop;

  /// 생성자입니다.
  ///
  /// [url]: 재생할 YouTube 동영상의 URL을 지정합니다.
  /// [mute]: 음소거 여부를 설정합니다. 기본값은 false입니다.
  /// [showControls]: 동영상 컨트롤러의 표시 여부를 설정합니다. 기본값은 true입니다.
  /// [showFullscreenButton]: 전체 화면 버튼의 표시 여부를 설정합니다. 기본값은 true입니다.
  /// [loop]: 동영상의 반복 재생 여부를 설정합니다. 기본값은 false입니다.
  YoutubeParams({
    required this.url,
    this.mute = false,
    this.showControls = true,
    this.showFullscreenButton = true,
    this.loop = false,
  });
}




/// YouTube 동영상을 재생하는 컨테이너 위젯입니다.
class YoutubeContainer extends StatefulWidget {
  final YoutubeStyle? style;
  final YoutubeParams? params;

  /// 생성자입니다.
  ///
  /// [style]: YouTube 동영상의 스타일을 설정하는 매개변수입니다.
  /// [params]: YouTube 동영상을 재생하기 위한 파라미터를 설정하는 매개변수입니다.
  YoutubeContainer({this.style, this.params});

  @override
  _YoutubeContainerState createState() => _YoutubeContainerState();
}

/// YoutubeContainer 위젯의 상태관리 클래스 입니다.
class _YoutubeContainerState extends State<YoutubeContainer> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.params == null) return;
    YoutubeParams params = widget.params!;

    _controller = YoutubePlayerController(
      params: YoutubePlayerParams(
        showControls: params.showControls,
        mute: params.mute,
        showFullscreenButton: params.showFullscreenButton,
        loop: params.loop,
      ),
    );

    _controller?.setFullScreenListener(
          (isFullScreen) {
        log('${isFullScreen ? 'Entered' : 'Exited'} Fullscreen.');
      },
    );

    initAsync();
  }

  Future<void> initAsync() async {
    _controller?.loadVideo(widget.params!.url);
    setState(() {});
  }

  Widget buildMain({required YoutubeStyle style, required YoutubeParams? params}) {
    if (params == null) return SizedBox();

    Widget youtube = const SizedBox();

    if (_controller != null) {
      youtube = Padding(
        padding: style.padding,
        child: YoutubePlayer(
          controller: _controller!,
          aspectRatio: style.aspectRatio,
        ),
      );
    }

    return youtube;
  }

  @override
  Widget build(BuildContext context) {
    return buildMain(
      style: widget.style ?? YoutubeStyle(),
      params: widget.params,
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }
}
