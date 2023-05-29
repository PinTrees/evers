import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/dialog_item.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../class/Customer.dart';
import '../class/contract.dart';
import '../class/purchase.dart';
import '../class/revenue.dart';
import '../class/schedule.dart';
import '../class/system.dart';
import '../class/transaction.dart';
import '../class/widget/button.dart';
import '../class/widget/excel.dart';
import '../class/widget/text.dart';
import '../helper/dialog.dart';
import '../helper/interfaceUI.dart';

import 'package:http/http.dart' as http;

import '../ui/dl.dart';
import '../ui/ux.dart';


class DialogTag extends StatelessWidget {

  static dynamic createTag(BuildContext context, { String? ctUid }) async {
    var dividHeight = 6.0;
    var inputTag = '';

    String? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();



              var gridStyle = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.02), stroke: 2, strokeColor: StyleT.titleColor.withOpacity(0.1));
              var divCol = SizedBox(height:  dividHeight * 8,);

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent, width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '공정 단계 추가', ),
                content: SingleChildScrollView(
                  child: Container(
                    width: 300,
                    padding: EdgeInsets.all(dividHeight * 3),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextT.Title(text:'신규 공정 단계 입력',),
                        SizedBox(height: dividHeight,),
                        Container( child: Column(children: [
                          ExcelT.Input(context, 'new.tag.asd',
                            width: 250,
                            onEdited: (i, data) {
                              inputTag = data;
                            },
                            setState: () { setStateS(() {}); },
                            text: inputTag, value: inputTag,
                          )
                        ],),),
                        SizedBox(height: dividHeight,),
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
                              var alt = await DialogT.showAlertDl(context, text: '공정 단계를 추가하시겠습니까?.');
                              if(!alt) { WidgetT.showSnackBar(context, text: "취소됨"); return; }
                              await MetaT.addProcessType(inputTag);
                              Navigator.pop(context, inputTag);
                            },
                            style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                            child: Container(
                                color: StyleT.accentColor.withOpacity(0.5), height: 42,
                                child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    WidgetT.iconMini(Icons.check_circle),
                                    Text('공정 단계 추가', style: StyleT.titleStyle(),),
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
    return aa;
  }

  Widget build(context) {
    return Container();
  }
}
