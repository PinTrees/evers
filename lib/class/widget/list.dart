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
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    double? width,
    double? spacing,
    Widget? spacingWidget,
    bool expand=false,
  }) {
    if(children == null) return SizedBox();

    List<Widget> widgets = [];
    if(spacing != null)
      children.forEach((e) { widgets.add(e); widgets.add(SizedBox(width: spacing,)); });
    else if(spacingWidget != null) {
      children.forEach((e) { widgets.add(e); widgets.add(spacingWidget); });
    }

    else widgets = children;

    Widget w = Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: widgets,
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


