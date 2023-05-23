import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helper/interfaceUI.dart';

/// 이 클래스는 텍스트 위젯을 래핑합니다.
/// 사용자 정의 위젯 클래스
class Widgets extends StatelessWidget {

  static Widget LoadingBar() {
    return LinearProgressIndicator(minHeight: 4,);
  }

  static Widget AccessRestriction() {
    return Container(
      width: double.maxFinite,
      height: 512,
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.not_interested_rounded, color: Colors.redAccent,),
              SizedBox(width: 6,),
              TextT.Title(text: "Access Restricted"),
            ],
          ),
          SizedBox(height: 6,),
          /*CachedNetworkImage(
            imageUrl: , fit: BoxFit.cover,
          ),*/
        ],
      ),
    );
  }

  Widget build(context) {
    return Container();
  }
}


