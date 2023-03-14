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

class WidgetUI extends StatelessWidget {

  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};

  static Widget titleRowNone(List<String> title, List<double> width, {  List<Widget>? leaging, bool background=false, double? padding=6 }) {
    List<Widget> chW = [];

    for(int i = 0; i < title.length; i++) {
      Widget w =  Container( width: width[i], child: WidgetT.titleT(title[i], size: 12, color: StyleT.titleColor.withOpacity(0.9)), alignment: Alignment.center, );
      if(width[i] > 900) {
        w = Expanded(child: w);
      }
      chW.add(w);
    }
    return Container(
        decoration: StyleT.inkStyleNone(color: Colors.transparent),
        child: Container(
          height: 36, color: background ? Colors.grey.withOpacity(0.35) : Colors.transparent,
          padding: EdgeInsets.fromLTRB(padding ?? 0, 0, padding ?? 0, 0),
          child: Row(
            children: chW,
          ),
        )
    );
  }

  Widget build(context) {
    return Container();
  }
}
