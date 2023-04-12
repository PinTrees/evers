import 'dart:ui';
import 'package:dropdown_button2/dropdown_button2.dart';
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

  static Widget IconText({ String? text, IconData? icon }) {
    return Container(
      color: Colors.grey.withOpacity(0.35),
      child: Row(
        children: [
          WidgetT.iconMini(icon ?? Icons.question_mark, size: 24, boxSize: 28),
          WidgetT.text(text ?? '텍스트 입력', size: 12,),
          SizedBox(width: 6,),
        ],
      ),
    );
  }

  Widget build(context) {
    return Container();
  }
}


