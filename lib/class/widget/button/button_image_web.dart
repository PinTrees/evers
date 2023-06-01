import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/widget/youtube/meta_data_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../helper/style.dart';



class ButtonImageStyle {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Alignment alignment;

  ButtonImageStyle({
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.height,
    this.width,
  });
}




class ButtonTParams {
  final Function? onTap;

  ButtonTParams({
    this.onTap,

  });
}




/// YouTube 동영상을 재생하는 컨테이너 위젯입니다.
class ButtonImage extends StatefulWidget {
  final ButtonImageStyle? style;
  final ButtonTParams? params;

  /// 생성자입니다.
  ///
  /// [style]: YouTube 동영상의 스타일을 설정하는 매개변수입니다.
  /// [params]: YouTube 동영상을 재생하기 위한 파라미터를 설정하는 매개변수입니다.
  ButtonImage({this.style, this.params});

  @override
  _ButtonImageState createState() => _ButtonImageState();
}

/// YoutubeContainer 위젯의 상태관리 클래스 입니다.
class _ButtonImageState extends State<ButtonImage> {

  @override
  void initState() {
    super.initState();
    if (widget.params == null) return;

    initAsync();
  }

  Future<void> initAsync() async {
    setState(() {});
  }

  Widget buildMain({required ButtonImageStyle style, required ButtonTParams? params}) {
    if (params == null) return const SizedBox();

    var w = TextButton(
        onPressed: () async {
          if(params.onTap != null) await params.onTap!();
        },
        style: StyleT.buttonStyleNone(elevation: 0, color: Colors.transparent,),
        child: Container(
          height: style.height, width: style.width,
        child: CachedNetworkImage(imageUrl: style.imageUrl, fit: style.fit,),
        ),
    );

    return w;
  }

  @override
  Widget build(BuildContext context) {
    return buildMain(
      style: widget.style ?? ButtonImageStyle(imageUrl: ""),
      params: widget.params,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
