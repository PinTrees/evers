import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/class/widget/youtube/meta_data_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../helper/style.dart';

/// 이 위젯은 이미지 버튼을 생성하기 위한 위젯 클래스 입니다.
/// 이미지는 URL 로 제공되어야 합니다.

class ExcelGridStyle {
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Alignment alignment;
  EdgeInsets? padding;
  bool expand;

  ExcelGridStyle({
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.height,
    this.padding,
    this.width,
    this.expand = false,
  });
}



class ExcelGridText extends StatefulWidget {
  final ExcelGridStyle? style;
  Function? onTap;
  String? label;
  String? text;

  ExcelGridText({this.style, this.onTap,
    this.text,
    this.label,
  });

  @override
  _ExcelGridTextState createState() => _ExcelGridTextState();
}
/// YoutubeContainer 위젯의 상태관리 클래스 입니다.
class _ExcelGridTextState extends State<ExcelGridText> {

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    setState(() {});
  }

  Widget buildMain({required ExcelGridStyle style,}) {
    if(style.padding == null) style.padding = const EdgeInsets.all(6);

    Widget info = TextT.Lit(text: widget.text, size: 14, color: Colors.black);
    if(widget.label != null)
      if(widget.label != "") {
        info = Row(
          children: [
            TextT.Lit(text: widget.label, padding: EdgeInsets.all(6), color: Colors.black,),
            info,
          ],
        );
      }

    Widget w = Container(
      alignment: Alignment.center,
      padding: style.padding,
      child: info,
    );

    if(style.expand) w = Expanded(child: w);
    return w;
  }

  @override
  Widget build(BuildContext context) {
    return buildMain(style: widget.style ?? ExcelGridStyle(),);
  }

  @override
  void dispose() {
    super.dispose();
  }
}


