import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/user.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../class/Customer.dart';
import '../class/contract.dart';
import '../class/purchase.dart';
import '../class/schedule.dart';
import '../class/system.dart';
import '../class/transaction.dart';
import '../helper/dialog.dart';
import '../helper/firebaseCore.dart';
import '../helper/interfaceUI.dart';
import '../helper/pdfx.dart';
import 'dialog_contract.dart';
import 'dl.dart';
import 'package:http/http.dart' as http;

import 'ux.dart';

class DialogUS extends StatelessWidget {

  static dynamic showAddBookMark(BuildContext context, UserT? org  ) async {
    var dividHeight = 6.0;

    UserT user = UserT.fromDatabase({});
    if(org == null) return;

    var jsonString = jsonEncode(org.toJson());
    var json = jsonDecode(jsonString);
    user = UserT.fromDatabase(json);

    var bookmarkUid = DatabaseM.generateRandomString(8);
    user.bookmark[bookmarkUid.toString()] = {};

    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();

              var gridStyle = StyleT.inkStyle(round: 8, color: Colors.black.withOpacity(0.03), stroke: 0.7, strokeColor: StyleT.titleColor.withOpacity(0.35));

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent, width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '북마크 추가', ),
                content: SingleChildScrollView(
                  child: Container(
                    width: 768,
                    padding: EdgeInsets.all(dividHeight * 3),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            WidgetT.title('사이트 별명', width: 100 ),
                            WidgetT.textInput(context, 'user.bookmark.name', width: 500,
                              onEdite: (i, data) {
                                user.bookmark[bookmarkUid.toString()]['name'] = data;
                              }, text:  user.bookmark[bookmarkUid.toString()]['name'] ?? '',
                            )
                          ],
                        ),
                        SizedBox(height: dividHeight * 3,),
                        Row(
                          children: [
                            WidgetT.title('주소 URL', width: 100 ),
                            WidgetT.textInput(context, 'user.bookmark.url', width: 500,
                              onEdite: (i, data) {
                                user.bookmark[bookmarkUid.toString()]['url'] = data;
                              },
                                text:  user.bookmark[bookmarkUid.toString()]['url'] ?? '',
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child:TextButton(
                            onPressed: () async {
                              if(!await DialogT.showAlertDl(context, text: '북마크를 저장하시겠습니까?')) {
                                WidgetT.showSnackBar(context, text: '저장 취소됨.');
                                return;
                              }

                              WidgetT.loadingBottomSheet(context, text:'로딩중');

                              await UserSystem.updateUser(user);
                              WidgetT.showSnackBar(context, text: '저장됨');
                              /// 로딩 바텀시트 종료, 현재 다이얼로그 종료
                              Navigator.pop(context); Navigator.pop(context);
                            },
                            style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                            child: Container(
                                color: StyleT.accentColor.withOpacity(0.5), height: 42,
                                child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    WidgetT.iconMini(Icons.check_circle),
                                    Text('북마크 저장', style: StyleT.titleStyle(),),
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

    if(aa == null) aa = false;
    return aa;
  }

  Widget build(context) {
    return Container();
  }
}
