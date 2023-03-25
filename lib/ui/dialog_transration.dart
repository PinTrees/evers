import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
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

class DialogTS extends StatelessWidget {

  static dynamic showInfoTs(BuildContext context, { TS? org } ) async {
    var dividHeight = 6.0;

    TS ts = TS.fromDatabase({});
    if(org != null) {
      TS? org_check = await FireStoreT.getTsDoc(org.id);
      if(org_check == null) {
        WidgetT.showSnackBar(context, text: '삭제됨');
        return;
      }
      else if(org_check.type == 'DEL'){
        if(org_check == null) {
          WidgetT.showSnackBar(context, text: '삭제됨');
          return;
        }
      }

      var jsonString = jsonEncode(org.toJson());
      var json = jsonDecode(jsonString);
      ts = TS.fromDatabase(json);
    }

    TS? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();

              List<Widget> widgetsTs = [];
              widgetsTs.add(WidgetUI.titleRowNone(['', '수납일자', '구분', '적요', '금액', '계좌', '메모', ],
                  [ 28, 150, 100, 250, 100, 150, 999, ]));
              widgetsTs.add(WidgetT.dividHorizontal(size: 0.7));
              widgetsTs.add(
                  Container( height: 28,
                    decoration: StyleT.inkStyleNone(color: Colors.transparent),
                    child: Row(
                        children: [
                          WidgetT.title('', width: 28),
                          WidgetT.excelInput(context, 'ts.info::수납일자', width: 150,
                            onEdite: (i, data) { ts.transactionAt = StyleT.dateEpoch(data); },
                            text: StyleT.dateInputFormatAtEpoch(ts.transactionAt.toString()),
                          ),
                          WidgetT.dropMenu(text: ts.getType(), dropMenuMaps: { 'PU': '지출', 'RE': '수입' }, width: 100, onEdite: (i, data) {
                            ts.type = data;
                          }),
                          WidgetT.excelInput(context, 'ts.info::summery', width: 250,
                              onEdite: (i, data) {
                                ts.summary= data;
                              },
                              text: ts.summary,
                          ),
                          WidgetT.excelInput(context, 'ts.info::금액', width: 100,
                            onEdite: (i, data) {
                              ts.amount = int.tryParse(data) ?? 0;
                            },
                            text: StyleT.krwInt(ts.amount,), value: ts.amount.toString(),
                          ),
                          WidgetT.dropMenu(text: ts.getAccountName(), dropMenuMaps: SystemT.getAccountDropMenu(), width: 150, onEdite: (i, data) {
                            ts.account = data;
                          }),
                          Expanded(
                            child: WidgetT.excelInput(context, 'ts.info::메모', width: 200,
                              onEdite: (i, data) { ts.memo  = data ?? ''; },
                              text: ts.memo,
                            ),
                          ),
                          InkWell(
                              onTap: () {
                                FunT.setStateDT();
                              },
                              child: Container( height: 28, width: 28,
                                child: WidgetT.iconMini(Icons.delete),)
                          ),
                        ]
                    ),
                  )
              );

              var gridStyle = StyleT.inkStyle(round: 8, color: Colors.black.withOpacity(0.03), stroke: 0.7, strokeColor: StyleT.titleColor.withOpacity(0.35));

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent, width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '수납 정보', ),
                content: SingleChildScrollView(
                  child: Container(
                    width: 1280,
                    padding: EdgeInsets.all(dividHeight * 3),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            WidgetT.title('수납정보', width: 100 ),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        Container(decoration: gridStyle, child: Column(children: widgetsTs,),),
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
                              if(!await DialogT.showAlertDl(context, text: '수납정보를 저장하시겠습니까?')) {
                                WidgetT.showSnackBar(context, text: '저장을 취소했습니다.');
                                return;
                              }
                              if(ts.transactionAt == 0) {
                                WidgetT.showSnackBar(context, text: '날짜를 정확히 입력해 주세요.');
                                return;
                              }

                              WidgetT.loadingBottomSheet(context, text:'로딩중');

                              await ts.update(org: org);
                              WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                              Navigator.pop(context); Navigator.pop(context, ts);
                            },
                            style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                            child: Container(
                                color: StyleT.accentColor.withOpacity(0.5), height: 42,
                                child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    WidgetT.iconMini(Icons.check_circle),
                                    Text('수납 저장', style: StyleT.titleStyle(),),
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

    if(aa == null) aa = null;
    return aa;
  }

  Widget build(context) {
    return Container();
  }
}
