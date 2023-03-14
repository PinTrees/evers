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

class WidgetDT extends StatelessWidget {

  static Widget dlTitle(BuildContext context, {String? title, String? subTitle, Function? onSave, bool full=true, bool close=true}) {
    return Material(
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                const Color(0xFF009fdf).withOpacity(0.35),
                const Color(0xFF1855a5).withOpacity(0.35),
                //StyleT.subTabBarColor.withOpacity(0.1),
                //StyleT.subTabBarColor.withOpacity(0.5),
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 6 * 3,),
            Expanded(
              child: Container( height: 44, alignment: Alignment.centerLeft,
                child: Column( mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetT.title(title ?? '타이틀', size: 14 ),
                    WidgetT.text(subTitle ?? title ?? '타이틀', size: 10),
                  ],
                ),
              ),
            ),
            if(onSave != null)
              Container( height: 32, width: 32,
                child: TextButton(
                    onPressed: () async {
                      if(onSave != null) await onSave();
                    },
                    style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 1, elevation: 0,
                        color: StyleT.accentColor.withOpacity(0.1)),
                    child: WidgetT.iconMini(Icons.save),
                ),
              ),
            if(full)
              Container( height: 32, width: 32,
              child: TextButton(
                onPressed: () {
                  //Navigator.pop(context);
                },
                style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 1, elevation: 0,
                    color: Colors.black.withOpacity(0.1)),
                child: WidgetT.iconMini(Icons.fullscreen),
              ),
            ),
          if(close)
            Container( height: 32, width: 32,
              child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 1, elevation: 0,
                      color: Colors.redAccent.withOpacity(0.5)),
                  child: WidgetT.iconMini(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
  static Widget dlTitleLow(BuildContext context, {String? title, Function? onSave, bool full=true,}) {
    return Material(
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                const Color(0xFF009fdf).withOpacity(0.35),
                const Color(0xFF1855a5).withOpacity(0.35),
                //const Color(0xFF009fdf).withOpacity(0.5),
                //const Color(0xFF1855a5).withOpacity(0.5),
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 36 * 2,),
            Expanded(
              child: Container( height: 32, alignment: Alignment.center,
                child: Column( mainAxisSize: MainAxisSize.min,
                  children: [
                    WidgetT.title(title ?? '타이틀', ),
                  ],
                ),
              ),
            ),
            if(onSave != null)
              Container( height: 32, width: 32,
                child: TextButton(
                  onPressed: () async {
                    if(onSave != null) await onSave();
                  },
                  style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 1, elevation: 0,
                      color: StyleT.accentColor.withOpacity(0.1)),
                  child: WidgetT.iconMini(Icons.save),
                ),
              ),
            if(full)
              Container( height: 32, width: 32,
                child: TextButton(
                  onPressed: () {
                    //Navigator.pop(context);
                  },
                  style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 1, elevation: 0,
                      color: Colors.black.withOpacity(0.1)),
                  child: WidgetT.iconMini(Icons.fullscreen),
                ),
              ),
            Container( height: 32, width: 32,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 1, elevation: 0,
                    color: Colors.redAccent.withOpacity(0.5)),
                child: WidgetT.iconMini(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget dlBtBar(BuildContext context, { Function? onSave, }) {
    return Material(
      elevation: 18,
      child: Container(
        color: Colors.white,
      /*  decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                const Color(0xFF009fdf).withOpacity(0.5),
                const Color(0xFF1855a5).withOpacity(0.5),
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),*/
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container( height: 32,
              child: TextButton(
                onPressed: () async {
                  if(onSave != null) await onSave();
                },
                style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 1, elevation: 0,
                    color: StyleT.accentColor.withOpacity(0.5)),
                child:  Row( mainAxisSize: MainAxisSize.min,
                  children: [
                    WidgetT.iconMini(Icons.save),
                    Text('저장하기', style: StyleT.titleStyle(),),
                    SizedBox(width: 12,),
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  static dynamic showAlertDlVersion(BuildContext context, { String? title, bool force=true }) async {
    bool aa = await showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.85),
            elevation: 4,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(0.0)),
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.all(18),
            title: WidgetDT.dlTitle(context, title: '알림', close: false ),
            content: Text('웹사이트 최신버전이 게시되었습니다.\n중요 사항이 수정되어 이전 버전의 접속을 차단합니다.\n\n사이트에 변경사항이 반영될 때 까지 기다려 주세요.\n\n새로고침', style: StyleT.titleStyle()),
          );
        });

    if(aa == null) aa = false;
    return aa;
  }

  Widget build(context) {
    return Container();
  }
}
