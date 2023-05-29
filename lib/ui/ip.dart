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
import 'dl.dart';

class WidgetTF extends StatelessWidget {

  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};

  static Widget textTitInput(BuildContext context, String key, {int? index, Function(int, dynamic)? onEdite, Function? setState,
    String? text, String? value, double? textSize, double? height, String? hint, bool? first=false, bool isMultiLine=false, String? label, double? labelSize}) {
    if(textInputs[key] == null) textInputs[key] = new TextEditingController();
    isActive[key] = true;
    textInputs[key]!.text = value ?? text ?? '';

    //if(label != null) WidgetT.title(label, size: 12,),

    Widget w = SizedBox();
    if(isActive[key] == true) {
      w = IntrinsicWidth(
        child: Container(
          //padding: EdgeInsets.all(6),
          child: TextFormField(
            autofocus: false,
            cursorColor: new Color(0xff009fdf).withOpacity(0.7),
            cursorWidth: 4.0,
            cursorRadius: Radius.elliptical(8, 8),
            style: TextStyle(color: StyleT.textColor.withOpacity(0.9), fontSize: textSize ?? 12, fontWeight: FontWeight.normal),
            maxLines: isMultiLine ? null : 1,
            textInputAction: isMultiLine ? TextInputAction.newline : TextInputAction.search,
            keyboardType: isMultiLine ? TextInputType.multiline : TextInputType.none,
            onEditingComplete: () async {
              isActive[key] = false;
              if(onEdite != null) onEdite(index ?? 0, textInputs[key]!.text);
              await FunT.setStateDT();
            },
            decoration: textInputDecoration( hintText: hint ?? '...', round: 4),
            controller: textInputs[key],
          ),
        ),
      );
      w = Focus(
        onFocusChange: (hasFocus) async {
          if(!hasFocus) {
            isActive[key] = false;
            if(onEdite != null) onEdite(index ?? 0, textInputs[key]!.text);
          }
          await FunT.setStateDT();
        },
        child: w,
      );
    }
    /*else {
      text = text ?? '';
      var textW = WidgetT.titleBox(text!, size: textSize);
      if(text == '') text = '...';

      w = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(label != null) WidgetT.text(label, size: 12),
          TextButton(
            onFocusChange: (hasFocus) async {
              isActive[key] = true;
              textInputs[key]!.text = value ?? text ?? '';
              await FunT.setStateDT();
            },
            onPressed: () async {
              isActive[key] = true;
              textInputs[key]!.text = value ?? text ?? '';
              await FunT.setStateDT();
            },
            style: StyleT.buttonStyleNone(elevation: 0, padding: 0, color: Colors.transparent, strock: 0.7, round: 0),
            child: WidgetT.titleBox(text ?? '...', size: textSize),
          ),
        ],
      );
    }*/
    return w;
  }

  static Widget textInput(BuildContext context, String key, {int? index, Function(int, dynamic)? onEdite, Function? setState,
    String? text, String? value, double? textSize,  double? width, double? height, String? hint, bool? first=false,
    bool isMultiLine=false, String? label, double? labelSize}) {
    if(textInputs[key] == null) textInputs[key] = new TextEditingController();
    isActive[key] = true;
    textInputs[key]!.text = value ?? text ?? '';

    //if(label != null) WidgetT.title(label, size: 12,),

    Widget w = SizedBox();
    if(isActive[key] == true) {
      w = Container( height: 28, width: width ?? 100,
        child: TextFormField(
          autofocus: false,
          cursorColor: new Color(0xff009fdf).withOpacity(0.7),
          cursorWidth: 4.0,
          cursorRadius: Radius.elliptical(8, 8),
          style: TextStyle(color: StyleT.textColor.withOpacity(0.9), fontSize: textSize ?? 12, fontWeight: FontWeight.normal),
          maxLines: isMultiLine ? null : 1,
          textInputAction: isMultiLine ? TextInputAction.newline : TextInputAction.search,
          keyboardType: isMultiLine ? TextInputType.multiline : TextInputType.none,
          onEditingComplete: () async {
            isActive[key] = false;
            if(onEdite != null) onEdite(index ?? 0, textInputs[key]!.text);
            await FunT.setStateDT();
          },
          decoration: textInputDecoration( hintText: hint ?? '...', round: 4),
          controller: textInputs[key],
        ),
      );
    }
    return w;
  }

  static Widget textInputButton(BuildContext context, String key, {int? index, Function(int, dynamic)? onEdite, Function? setState,
    String? text, String? value, double? textSize,  double? width, double? height, String? hint, bool? first=false,
    bool isMultiLine=false, String? label, double? labelSize}) {
    return TextButton(
    onPressed: () async {
      var fun = FunT.setStateD;
      var data = await showTextInput(context, key, text ?? '');
      FunT.setStateD = fun;

      if(data != null) {
        print(data);
        if(onEdite != null) await onEdite(index ?? 0, data);
        await FunT.setStateDT();
      }
    }, child: Row(
      children: [
        WidgetT.text(text ?? 'null', size: 10),
      ],
    ));
  }

  static dynamic showTextInput(BuildContext context, String key, String text ) async {
    var dividHeight = 6.0;

    var inputText = text;
    String? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();
              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.dlColor, width: 0.35),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '입력', ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(dividHeight * 3),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetT.textInput(context, '텍스트공용입력창', width: 250,
                          onEdite: (i, data) {
                            inputText = data;
                          },
                          text: inputText,
                        ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  Row(
                    children: [
                      Expanded(child:TextButton(
                          onPressed: () async {
                            Navigator.pop(context, inputText);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('입력 완료', style: StyleT.titleStyle(),),
                                  SizedBox(width: 6,),
                                ],
                              )
                          )
                      ),),
                    ],
                  ),
                ],
              );
            },
          );
        });

    if(aa == null) aa = '';
    return aa;
  }

  static InputDecoration textInputDecoration({ String? hintText, double round=0.0, Color? backColor, double? textSize}) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(0), borderSide: BorderSide(color: Colors.transparent, width: 0) ), //BorderSide(color: StyleT.disableColor.withOpacity(0.7), width: 0)),
      focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(0), borderSide: BorderSide(color: Colors.transparent, width: 0)), //BorderSide(color: StyleT.accentColor, width: 0),),
      filled: true,
      isDense: true,
      fillColor: Colors.transparent,//backColor ?? StyleT.accentColor.withOpacity(0.07),
      hintText: hintText ?? '',
      hintStyle: TextStyle(fontSize: textSize, fontWeight: FontWeight.normal),
      contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 12),
    );
  }

  Widget build(context) {
    return Container();
  }
}
