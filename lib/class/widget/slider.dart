


import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/ip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helper/interfaceUI.dart';

class SliderT {

  /// 이 함수는 보기 및 가이드 입력의 기초 템플릿 위젯입니다.
  /// 라벨과 입력 위젯을 반환합니다.
  /// 가로 사이즈를 설정하지 않을 경우 자동으로 조절됩니다. 다중라인 입력을 지원하지 않습니다.
  static Widget Lit(BuildContext context, {
    required double value,
    required double min,
    required double max,
    double? width,
    String? label,
   }) {

    var f = const Color(0xFF1855a5).withOpacity(0.5);
    //const Color(0xFF009fdf).withOpacity(0.7);
    //const Color(0xFF1855a5).withOpacity(0.5);

    Widget w = SliderTheme(
      data: SliderThemeData(
        // 배경색 설정
        trackHeight: 12, // 슬라이더 바의 높이
        trackShape: RoundedRectSliderTrackShape(), // 슬라이더 바의 모양
        activeTrackColor: f, // 활성화된 슬라이더 바의 색상
        inactiveTrackColor: Colors.grey.withOpacity(0.3), // 비활성화된 슬라이더 바의 색상

        // 슬라이더 버튼 색상 설정
        thumbColor: Colors.transparent, // 슬라이더 버튼의 색상
        overlayColor: Colors.transparent, // 슬라이더 버튼의 오버레이 색상
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0, elevation: 0, pressedElevation: 0), // 슬라이더 버튼의 모양
        overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0), // 슬라이더 버튼의 오버레이 모양
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        onChanged: (double newValue) {},
      ),
    );

    if(width != null) w = Container(width: width, child: w,);

    return w;
  }
}