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
    bool expand=false,
    bool enable=true,
    /*bool center=false,*/
  }) {
    Widget w = RichText(
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

    if(!enable) {
      w = Lit(text: text, width: width);
    }

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
    double? size,
    Color? color,
    bool bold=false,
    Alignment? alignment,
    bool expand=false,}) {
    var w = Text(
        text ?? '',
        style: TextStyle(color: color ?? StyleT.textColor, fontSize: size ?? 10, fontWeight: bold ? FontWeight.w900 : FontWeight.w500),
    );

    if(expand) {
      return Expanded(
        child: Container( alignment: alignment ?? Alignment.center, child: w, ),
      );
    }

    if(width == null) return w;
    else return Container(
      width: width,
      alignment: alignment ?? Alignment.center,
      child: w,
    );
  }


  static Widget Title({
    BuildContext? context,
    String? text,
    double? width,
    bool expand=false}) {
    var w = Text(
      text ?? '',
      style: TextStyle(color: StyleT.titleColor, fontSize: 16, fontWeight: FontWeight.w900),
    );

    if(expand) {
      return Expanded(
        child: Container( alignment: Alignment.center, child: w, ),
      );
    }

    if(width == null) return w;
    else return Container(
      width: width,
      alignment: Alignment.center,
      child: w,
    );
  }




  static Widget SubTitle({
    BuildContext? context,
    String? text,
    String? more,
    double? width,
    bool expand=false}) {
    Widget w = Text(
      text ?? '',
      style: TextStyle(color: StyleT.titleColor, fontSize: 14, fontWeight: FontWeight.w900),
    );

    if(more != null) w = Row( children: [ w, const SizedBox(width: 6 * 3,), Lit(text: more), ],);

    if(expand) {
      return Expanded(
        child: Container( alignment: Alignment.center, child: w, ),
      );
    }

    if(width == null) return w;
    else return Container(
      width: width,
      alignment: Alignment.center,
      child: w,
    );
  }




  static Widget TitleMain({
    BuildContext? context,
    String? text,
    double? width,
    bool expand=false}) {
    var w = Text(
      text ?? '',
      style: TextStyle(color: StyleT.titleColor, fontSize: 24, fontWeight: FontWeight.w900),
    );

    if(expand) {
      return Expanded(
        child: Container( alignment: Alignment.center, child: w, ),
      );
    }

    if(width == null) return w;
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


