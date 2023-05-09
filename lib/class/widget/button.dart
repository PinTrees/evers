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
            WidgetT.iconMini(icon ?? Icons.question_mark, size: 24, boxSize: 28),
          ],
        ),
      ),
    );


    return w;
  }
  static Widget IconText({ String? text, IconData? icon, Function? onTap,
    bool bold=false,
    Color? color,
    EdgeInsets? padding,
    Color? textColor, }) {
    var w = InkWell(
      onTap: () async {
        if(onTap != null) return await onTap();
      },
      child: Container(
        color: color ?? Colors.grey.withOpacity(0.35),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WidgetT.iconMini(icon ?? Icons.question_mark, size: 24, boxSize: 28),
            TextT.Lit(text: text ?? '텍스트 입력', size: 12, color: textColor, bold: bold),
            SizedBox(width: 6,),
          ],
        ),
      ),
    );

    if(padding != null) return Container( padding: padding,  child: w, );

    return w;
  }

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

  Widget build(context) {
    return Container();
  }
}


