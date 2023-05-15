import 'dart:ui';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../helper/interfaceUI.dart';


class ButtonT extends StatelessWidget {

  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};

  static Widget Icon({IconData? icon, Function? onTap,
    Widget? leaging,
    Color? color,
    Color? background
  }) {
    if(leaging != null) {

    }

    var w = InkWell(
      onTap: () async {
        if(onTap != null) return await onTap();
      },
      child: Container(
        color: background,
        child: Row(
          children: [
            WidgetT.iconMini(icon ?? Icons.question_mark, size: 24, boxSize: 28, color: color),
          ],
        ),
      ),
    );


    return w;
  }


  /// 이 함수는 아이콘과 텍스트가 있는 고정형 위젯입니다.
  static Widget IconText({ String? text, IconData? icon, Function? onTap,
    bool bold=false,
    Color? color,
    EdgeInsets? padding,
    Widget? leaging,
    Color? textColor, }) {
    var w = InkWell(
      onTap: () async {
        if(onTap != null) return await onTap();
      },
      child: Container(
        color: color ?? Colors.grey.withOpacity(0.25),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WidgetT.iconMini(icon ?? Icons.question_mark, size: 24, boxSize: 28),
            TextT.Lit(text: text ?? '텍스트 입력', size: 12, color: textColor, bold: bold),
            SizedBox(width: 6,),
            if(leaging != null) leaging,
          ],
        ),
      ),
    );

    if(padding != null) return Container( padding: padding,  child: w, );

    return w;
  }


  /// 이 함수는 간단한 텍스트 추가 버튼입니다.
  static Widget Text({ String? text, Function? onTap,
    double? size,
    double? height,
    bool bold=false,
    Color? color,
    EdgeInsets? padding,
    Color? textColor, }) {
    var w = InkWell(
      onTap: () async {
        if(onTap != null) return await onTap();
      },
      child: Container(
        color: color ?? Colors.grey.withOpacity(0.25),
        alignment: Alignment.center,
        width: size ?? null, height: size ?? height ?? 28,
        child: TextT.Lit(text: text ?? '텍스트 입력', size: 12, color: textColor, bold: bold),
      ),
    );

    if(padding != null) return Container( padding: padding,  child: w, );

    return w;
  }


  /// 이 함수는 메인메뉴 사이드 탐색버튼 템플릿입니다.
  static Widget InfoMenu(String text, IconData icon, {
    Function? onTap,
    Function? setState,
  }) {
    return InkWell(
        onTap: () async {
          if(onTap != null) await onTap();
          if(setState != null) await setState();
        },
        child: Container(
          height: 36,
          child: Row(
            children: [
              WidgetT.iconNormal(icon,  size: 36),
              SizedBox(width: 6 * 2,),
              WidgetT.text(text, size: 14),
            ],
          ),
        ));
  }


  /// 이 함수는 다이얼로그 액션버튼 템플릿입니다.
  static Widget Action(String text, {
    IconData? icon,
    double? width,
    Color? backgroundColor,
    Function? onTap,
    Function? setState,
    bool expend=false,
  }) {
    var w = InkWell(
        onTap: () async {
          if(onTap != null) await onTap();
        },
        child: Container(
            width: width,
            color: backgroundColor ?? Colors.blue.withOpacity(0.5),
            height: 42,
            child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WidgetT.iconMini(icon ?? Icons.add_box),
                TextT.SubTitle(text: text),
                SizedBox(width: 6,),
              ],
            )
        )
    );

    if(expend) return Expanded(child: w);
    else return w;
  }
  Widget build(context) {
    return Container();
  }
}


