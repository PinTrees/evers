import 'dart:ui';
import 'package:evers/helper/style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 이 클래스는 텍스트 위젯을 래핑합니다.
/// 사용자 정의 위젯 클래스
class TextT extends StatelessWidget {

  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};

  /// 이 함수는 텍스트 위젯을 반환합니다.
  ///
  static Widget OnTap({ BuildContext? context, String? text, Function? onTap, double? width,
  bool expand=false}) {
    var w = RichText(
      text: TextSpan(
          children: [
            TextSpan(
                text: text ?? '텍스트 추가',
                recognizer: TapGestureRecognizer()..onTapDown = (details) async {
                  if(onTap != null)  {
                    return await onTap();
                  }
                },
                style: TextStyle(color: Colors.blue, fontSize: 10, decoration: TextDecoration.underline, fontWeight: FontWeight.w900)),
          ]
      ),
    );

    if(expand) {
      return Expanded(
        child: Container( alignment: Alignment.center, child: w, ),
      );
    }

    if(width == null) return Container( alignment: Alignment.center, child: w, );
    else return Container(
        width: width,
      alignment: Alignment.center,
        child: w,
    );
  }


  static Widget Lit({
    BuildContext? context,
    String? text,
    double? width,
    bool expand=false}) {
    var w = Text(
        text ?? '',
        style: TextStyle(color: StyleT.textColor, fontSize: 10, fontWeight: FontWeight.w900),
    );

    if(expand) {
      return Expanded(
        child: Container( alignment: Alignment.center, child: w, ),
      );
    }

    if(width == null) return Container( alignment: Alignment.center, child: w, );
    else return Container(
      width: width,
      alignment: Alignment.center,
      child: w,
    );
  }

  Widget build(context) {
    return Container();
  }
}


