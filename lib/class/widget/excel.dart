import 'dart:ui';
import 'package:evers/helper/style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helper/interfaceUI.dart';

/// 이 클래스는 텍스트 위젯을 래핑합니다.
/// 사용자 정의 위젯 클래스
class ExcelT extends StatelessWidget {

  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};


  static Widget Grid({ Alignment? alignment,
    String? text,
    Color? textColor,
    double? width, double? height, double? textSize,
    bool expand = false,
  }) {

    var w = Container(
      width: width ?? double.maxFinite,
      height: height ?? 24,
      padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
      alignment: alignment ?? Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 4,),
          Text(
            text ?? '텍스트 추가',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: textSize ?? 12,
              color: textColor ?? StyleT.titleColor,
            ),
          )
        ],
      ),
    );
    if(expand) return Expanded(child: w);
    else return w;
  }



  static Widget LitGrid({ Alignment? alignment,
    String? text,
    Color? textColor,
    double? width,
    double? height,
    double? textSize,
    bool center=false,
    bool multiLine=false,
    bool expand = false,
  }) {

    if(center == true) alignment = Alignment.center;

    var w = Container(
      width: width ?? double.maxFinite,
      height: multiLine ? null : height ?? 24,
      padding: multiLine ? EdgeInsets.all(6) : EdgeInsets.fromLTRB(6, 0, 0, 0),
      alignment: alignment ?? Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 4,),
          Text(
            text ?? '텍스트 추가',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: textSize ?? 10,
              color: textColor ?? StyleT.textColor,
            ),
          )
        ],
      ),
    );
    if(expand) return Expanded(child: w);
    else return w;
  }




  /// 이 함수는 텍스트 위젯을 반환합니다.
  ///
  static Widget LitInput(BuildContext context, String key, {
    int? index,
    Function(int, dynamic)? onEdited,
    Function? setState,
    Alignment? alignment,
    String? text,
    String? value,
    Color? textColor,
    double? width, double? height, double? textSize,
    String? hint,
    bool expand=false,
    bool isMultiLine=false}) {

    if(expand) width = null;

    if(textInputs[key] == null) textInputs[key] = new TextEditingController();
    Widget w = SizedBox();
    if(isActive[key] == true) {
      w = Container(
        width: width ?? double.maxFinite,
        height: isMultiLine ? height : 24,
        child: TextFormField(
          autofocus: true,
          maxLines: isMultiLine ? 10 : 1,
          textInputAction: isMultiLine ? TextInputAction.newline : TextInputAction.search,
          keyboardType: isMultiLine ? TextInputType.multiline : TextInputType.none,
          onEditingComplete: () async {
            isActive[key] = false;
            if(onEdited != null) await onEdited(index ?? 0, textInputs[key]!.text);
            if(setState != null) await setState();
          },
          decoration: WidgetT.textInputDecoration( hintText: hint ?? '...', round: 4),
          controller: textInputs[key],
        ),
      );
      w = Focus(
        onFocusChange: (hasFocus) async {
          if(!hasFocus) {
            isActive[key] = false;
            if(onEdited != null) await onEdited(index ?? 0, textInputs[key]!.text);
          }
          if(setState != null) await setState();
        },
        child: w,
      );
    }
    else {
      w = SizedBox(
        height: height ?? 24,
        child: InkWell(
          onFocusChange: (hasFocus) async {
            isActive[key] = true;
            textInputs[key]!.text = value ?? text ?? '';
            if(setState != null) await setState();
          },
          onTap: () async {
            isActive[key] = true;
            textInputs[key]!.text = value ?? text ?? '';
            if(setState != null) await setState();
          },
          child: Container(
            height: height ?? 24,
            width: width ?? double.maxFinite,
            alignment: alignment ?? Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 4,),
                Text(
                  ((text == null) && (text == '')) ? (hint ?? '텍스트 입력') : text!,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: textSize ?? 12,
                    color: textColor ?? StyleT.titleColor,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    if(expand) return Expanded(child: w);
    return w;
  }






  /// 이 함수는 텍스트 위젯을 반환합니다.
  ///
  static Widget Input(BuildContext context, String key, { int? index,
    Function(int, dynamic)? onEdited,
    Function? setState,
    Alignment? alignment,
    String? text,
    String? value,
    Color? textColor,
    double? width, double? height, double? textSize,
    String? hint,
    bool isMultiLine=false,
    bool expand=false,
  }) {
    if(textInputs[key] == null) textInputs[key] = new TextEditingController();
    Widget w = SizedBox();
    if(isActive[key] == true) {
      w = Container(
        width: width ?? double.maxFinite,
        height: isMultiLine ? height : 24,
        child: TextFormField(
          autofocus: true,
          maxLines: isMultiLine ? 10 : 1,
          textInputAction: isMultiLine ? TextInputAction.newline : TextInputAction.search,
          keyboardType: isMultiLine ? TextInputType.multiline : TextInputType.none,
          onEditingComplete: () async {
            isActive[key] = false;
            if(onEdited != null) await onEdited(index ?? 0, textInputs[key]!.text);
            if(setState != null) await setState();
          },
          decoration: WidgetT.textInputDecoration( hintText: hint ?? '...', round: 4),
          controller: textInputs[key],
        ),
      );
      w = Focus(
        onFocusChange: (hasFocus) async {
          if(!hasFocus) {
            isActive[key] = false;
            if(onEdited != null) await onEdited(index ?? 0, textInputs[key]!.text);
          }
          if(setState != null) await setState();
        },
        child: w,
      );
    }
    else {
      w = SizedBox(
        height: height ?? 24,
        child: InkWell(
          onFocusChange: (hasFocus) async {
            isActive[key] = true;
            textInputs[key]!.text = value ?? text ?? '';
            if(setState != null) await setState();
          },
          onTap: () async {
            isActive[key] = true;
            textInputs[key]!.text = value ?? text ?? '';
            if(setState != null) await setState();
          },
          child: Container(
            height: height ?? 24,
            width: width ?? double.maxFinite,
            alignment: alignment ?? Alignment.center,
            color: Colors.grey.withOpacity(0.15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 4,),
                Text(
                  ((text == null) && (text == '')) ? (hint ?? '텍스트 입력') : text!,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: textSize ?? 12,
                    color: textColor ?? StyleT.titleColor,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    if(expand) return Expanded(child: w);
    else return w;
  }



  static Widget LabelInput(BuildContext context, String key, {
    Function(int, dynamic)? onEdited,
    Function? setState,
    int? index,
    Alignment? alignment,
    String? text,
    String? label,
    String? value,
    double? width,
    double? height,
    double? labelWidth,
    double? textSize,
    double? labelSize,
  }) {
    return Row(
    children: [
      ExcelT.Grid(text: label, textSize: labelSize ?? textSize ?? 10, width: labelWidth,),
      ExcelT.Input(
        context, '${index ?? 0}::${ key }',
        width: width,
        textSize: textSize,
        index: index,
        textColor: StyleT.textColor,
        alignment: Alignment.centerLeft,
        onEdited: onEdited!,
        setState: setState!,
        text: text, value: value,
      ),
    ],
    );
  }

  Widget build(context) {
    return Container();
  }
}


