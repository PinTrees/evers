import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 이 클래스는 텍스트 위젯을 래핑합니다.
/// 사용자 정의 위젯 클래스
class ListBoxT extends StatelessWidget {

  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};

  /// 이 함수는 텍스트 위젯을 반환합니다.
  ///
  static Widget Rows({ BuildContext? context,
    List<Widget>? children,
    double? width,
    bool expand=false,
  }) {
    Widget w = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children ?? []
    );

    if(width != null) {
      w = SizedBox(width: width, child: w,);
    }

    if(expand) {
      return Expanded(
        child: w,
      );
    }
    return w;
  }

  Widget build(context) {
    return Container();
  }
}


