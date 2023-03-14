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
import 'dl.dart';
import 'package:http/http.dart' as http;

import 'ux.dart';

class DialogAC extends StatelessWidget {

  /// 계좌 추가 가능
  static dynamic showAccountDl(BuildContext context, { Account? account_org }) async {
    var dividHeight = 6.0;
    Account account = Account.fromDatabase({});

    if(account_org != null) {
      var jsonString = jsonEncode(account_org.toJson());
      var json = jsonDecode(jsonString);
      account = Account.fromDatabase(json);
    }

    var type = [ '카드', '계좌', '현금' ];

    bool? aa = await showDialog(
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
                    side: BorderSide(color: Colors.grey.shade700, width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '결제 정보', ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(18),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            WidgetT.dropMenu(dropMenus: type, width: 130, label: '구분',
                              onEdite: (i, data) {
                                account.type = data;
                                print(account.type);
                              },
                              text: account.type,
                            ),
                          ],
                        ),
                        SizedBox(height: 18,),
                        WidgetT.textInput(context, '계좌이름', width: 250, label: '계좌이름',
                          onEdite: (i, data) { account.name = data; },
                          text: account.name,
                        ),
                        SizedBox(height: dividHeight,),
                        WidgetT.textInput(context, '계좌번호', width: 250, label: '계좌번호',
                          onEdite: (i, data) { account.account = data; },
                          text: account.account,
                        ),
                        SizedBox(height: dividHeight,),
                        WidgetT.textInput(context, '대조기준', width: 250, label: '잔고시작점',
                          onEdite: (i, data) { account.balanceStartAt = int.tryParse(data) ?? 0; },
                          text: StyleT.krwInt(account.balanceStartAt),
                        ),
                        SizedBox(height: 18,),
                        WidgetT.textInput(context, '예금주', width: 150, label: '예금주',
                          onEdite: (i, data) {
                            account.user = data;
                          },
                          text: account.user,
                          value: account.user,
                        ),
                        SizedBox(height: 18,),
                        Row(
                          children: [
                            WidgetT.title('메모', width: 100 ),
                            Expanded(
                              child: WidgetT.textInput(context, '메모', height: 64, isMultiLine: true,
                                onEdite: (i, data) { account.memo = data; },
                                text: account.memo,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
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
                            if(account.name == '') {
                              WidgetT.showSnackBar(context, text: '결제계좌 이름을 입력해 주세요.'); return;
                            }

                            var alert = await DialogT.showAlertDl(context, title: account.name ?? 'NULL');
                            if(alert == false) {
                              WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                              return;
                            }

                            await FireStoreT.updateAccount(account);
                            WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                            Navigator.pop(context);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('결제정보 저장', style: StyleT.titleStyle(),),
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
