import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../helper/interfaceUI.dart';

class WidgetEX extends StatelessWidget {

  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};

  static Widget excelTitle({ String? text, String? value,
    double? width, double? height, String? label, Color? color, Color? textColor,  Alignment? alignment }) {
    var w = Container(
      color: Colors.white, //new Color(0xff1855a5).withOpacity(0.5),
      child: Container(
        width: width, height: height, alignment: alignment ?? Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                const Color(0xFFA6886D).withOpacity(0.15),
                const Color(0xFF1855a5).withOpacity(0.15),
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        padding: EdgeInsets.all(6),
        child:  Row(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: (alignment == Alignment.centerLeft) ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            WidgetT.text(label ?? '', size: 10,),
            if(text != null)
              SizedBox(width: 4,),
            WidgetT.titleT(text ?? '', color: textColor),
          ],
        ),
      ),
    );
    return w;
  }

  static Widget excelGrid({ String? text, String? value,
    double? width, double? height, String? label, Color? color, Color? textColor,  Alignment? alignment }) {
    var w = Container(
      width: width, height: height, alignment: alignment ?? Alignment.center,
      color: color ?? Colors.transparent,
      padding: EdgeInsets.all(6),
      child:  Row(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: (alignment == Alignment.centerLeft) ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          WidgetT.text(label ?? '', size: 10,),
          if(text != null)
            SizedBox(width: 4,),
          WidgetT.titleT(text ?? '', color: textColor),
        ],
      ),
    );
    return w;
  }

  static Widget excelButtonIcon({ IconData? icon, Function? onTap,
    double? width, double? height, String? label, Color? color, Color? textColor,  Alignment? alignment }) {
    var w = InkWell(
      onTap: () async {
        if(onTap != null) await onTap();
      },
      child: Container(
        width: width, height: height ?? 32, alignment: alignment ?? Alignment.center,
        padding: EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: (alignment == Alignment.centerLeft) ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            if(icon != null)
              WidgetT.iconMini(icon),
            if(label != null)
              SizedBox(width: 4,),
            if(label != null)
              WidgetT.text(label ?? '', size: 10,),
          ],
        ),
      ),
    );
    return w;
  }

  Widget build(context) {
    return Container();
  }
}
