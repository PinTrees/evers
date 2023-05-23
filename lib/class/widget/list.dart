import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 이 클래스는 텍스트 위젯을 래핑합니다.
/// 사용자 정의 위젯 클래스
class ListBoxT extends StatelessWidget {

  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};

  /// 이 함수는 Widget.Row 의 래핑클래스 입니다.
  static Widget Rows({ BuildContext? context,
    List<Widget>? children,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    double? width,
    double? spacing,
    Widget? spacingWidget,
    EdgeInsets? padding,
    bool expand=false,
  }) {
    if(children == null) return SizedBox();

    List<Widget> widgets = [];
    if(spacing != null)
      children.forEach((e) { widgets.add(e); widgets.add(SizedBox(width: spacing,)); });
    else if(spacingWidget != null) {
      children.forEach((e) { widgets.add(e); widgets.add(spacingWidget); });
      widgets.removeLast();
    }
    else widgets = children;

    Widget w = Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: widgets,
    );

    if(padding != null) {
      w = Padding(padding: padding, child: w,);
    }

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





  /// 이 함수는 Widget.Column 의 래핑클래스 입니다.
  /// spacing 값과 spacing 위젯은 함께 사용될 수 없습니다.
  static Widget Columns({ BuildContext? context,
    List<Widget>? children,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    double? width,
    double? spacing,
    double? spacingStartEnd,
    Widget? spacingWidget,
    EdgeInsets? padding,
    bool expand=false,
  }) {
    if(children == null) return SizedBox();
    List<Widget> widgets = [];


    /// spacing 값과 spacing 위젯은 함께 사용될 수 없습니다.
    /// Column 위젯의 Vertical SizedBox 의 반목 추가자입니다.
    if(spacing != null) {
      children.forEach((e) { widgets.add(e); widgets.add(SizedBox(height: spacing,)); });
    }
    /// 사용자 정의 위젯의 반복 추가자입니다.
    else if(spacingWidget != null) {
      children.forEach((e) { widgets.add(e); widgets.add(spacingWidget); });
      widgets.removeLast();
    }
    /// 사용자 정의 위젯의 반복 추가자입니다.
    else if(spacingStartEnd != null) {
      widgets.add(SizedBox(height: spacingStartEnd,));
      children.forEach((e) { widgets.add(e); widgets.add(SizedBox(height: spacingStartEnd,)); });
    }
    else widgets = children;


    Widget w = Column(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: widgets,
    );

    if(padding != null) w = Padding(padding: padding, child: w,);
    if(width != null)   w = SizedBox(width: width, child: w,);
    if(expand) w = Expanded( child: w );
    return w;
  }
  Widget build(context) {
    return Container();
  }
}


