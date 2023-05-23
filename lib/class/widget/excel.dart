import 'dart:ui';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helper/interfaceUI.dart';

/// 이 클래스는 텍스트 위젯을 래핑합니다.
/// 사용자 정의 위젯 클래스
class ExcelT extends StatelessWidget {

  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};


  static var deco = BoxDecoration(
    gradient: LinearGradient(
        colors: [
          const Color(0xFFA6886D).withOpacity(0.15),
          const Color(0xFF1855a5).withOpacity(0.15),
        ],
        begin: const FractionalOffset(0.0, 0.0),
        end: const FractionalOffset(1.0, 0.0),
        stops: [0.0, 1.0],
        tileMode: TileMode.clamp),
  );



  static Widget Grid({ Alignment? alignment,
    String? text,
    Color? textColor,
    double? width, double? height, double? textSize,
    BoxDecoration? decoration,
    bool expand = false,
  }) {

    var w = Container(
      width: width ?? double.maxFinite,
      height: height ?? 24,
      decoration: decoration,
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
    bool bold=false,
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
              fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
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
  /// 메테리얼 디자인 3.0 적용됨
  ///
  /// Version 1.0.1
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
        height: isMultiLine ? height : 28,
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
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: StyleT.disableColor.withOpacity(0.0), width: 0.01)),
            focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.35), width: 1.4),),
            filled: true,
            fillColor: StyleT.accentColor.withOpacity(0.07),
            hintText: '...',
            hintStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            contentPadding: EdgeInsets.fromLTRB(8, 8, 8, 8),
          ),
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
      w = Container(
        height: height ?? 28,
        width: width ?? double.maxFinite,
        padding: EdgeInsets.only(left: 3, right: 3),
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
            alignment: alignment ?? Alignment.center,
            decoration: StyleT.inkStyle(color: Colors.grey.withOpacity(0.15), round: 8, stroke: 0.01, strokeColor: Colors.transparent),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 4,),
                TextT.Lit(text: ((text == null) && (text == '')) ? (hint ?? '텍스트 입력') : text!,
                  color: StyleT.titleColor, size: 12,
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
          decoration: WidgetT.textInputDecoration( hintText: hint ?? '...', round: 8),
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






  /// 이 함수는 텍스트 위젯을 반환합니다.
  ///
  static Widget ExcelInput(BuildContext context, String key, {
    int? index,
    Function(int, dynamic)? onEdited,
    Function? setState,
    Alignment? alignment,
    String? text,
    String? lavel,
    String? value,
    Color? textColor,
    double? widthLavel,
    double? width,
    double? height, double? textSize,
    String? hint,
    bool expand=false,
    bool isMultiLine=false}) {


    var w = Row(
      children: [
        ExcelT.Grid(width: widthLavel, text: lavel, alignment: Alignment.center,
            decoration: deco, height: 32
        ),
        WidgetT.dividViertical(),
        ExcelT.LitInput(context, key, width: width,
          onEdited: onEdited,
          setState: setState,
          height: 32,
          text: text, value: value,
        ),
      ],
    );

    return w;
  }




  /// 이 함수는 텍스트 위젯을 반환합니다.
  ///
  static Widget ExcelGrid({
    int? index,
    Alignment? alignment,
    String? text,
    String? lavel,
    Color? textColor,
    double? widthLavel,
    double? width,
    double? height, double? textSize,
    String? hint,
    bool expand=false,
    bool isMultiLine=false}) {

    var w = Row(
      children: [
        ExcelT.Grid(width: widthLavel, text: lavel, alignment: Alignment.center,
          decoration: deco, height: 32
        ),
        WidgetT.dividViertical(),
        ExcelT.Grid(width: width, text: text, alignment: Alignment.center,  height: 32),
      ],
    );

    return w;
  }



  Widget build(context) {
    return Container();
  }
}


