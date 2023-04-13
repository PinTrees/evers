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
      TS? org_check = await DatabaseM.getTsDoc(org.id);
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

  /// 수납 추가화면
  static dynamic showCreateTS(BuildContext context) async {
    var dividHeight = 6.0;
    Contract ct = Contract.fromDatabase({});
    Customer? cs;
    bool isCt = false;
    bool isNoCs = false;

    List<TS> tslistCr = [];
    tslistCr.add(TS.fromDatabase({ 'transactionAt': DateTime.now().microsecondsSinceEpoch, 'type': 'PU' }));

    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();

              List<Widget> tsCW = [];
              tsCW.add(WidgetT.title('수납추가 현황', size: StyleT.subTitleSize));
              tsCW.add(SizedBox(height: dividHeight,));
              tsCW.add(WidgetUI.titleRowNone([ '', '순번', '거래일자', '구분', '적요', '결제', '금액', '메모', ],
                  [ 28, 28, 150, 100 + 28, 250, 208, 120, 999,], background: true),);
              for(int i = 0; i < tslistCr.length; i++) {
                var tmpTs = tslistCr[i];

                var w = Container( height: 28,
                  //decoration: StyleT.inkStyle(stroke: 0.35,),
                  child: Row(
                      children: [
                        InkWell(
                            onTap: () async {
                              tslistCr.removeAt(i);
                              FunT.setStateDT();
                            },
                            child: Container( height: 28, width: 28,
                              child: WidgetT.iconMini(Icons.cancel),)
                        ),
                        WidgetT.title('${i + 1}', size: 10, width: 28),
                        WidgetT.excelInput(context, '$i::ts거래일자', width: 150,
                          onEdite: (i, data) { tmpTs.transactionAt = StyleT.dateEpoch(data); },
                          text: StyleT.dateInputFormatAtEpoch(tmpTs.transactionAt.toString()),
                        ),
                        WidgetT.excelGrid(text: (tmpTs.type != 'PU') ? '수입' : '지출', width: 100, ),
                        SizedBox(
                          height: 28, width: 28,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              focusColor: Colors.transparent,
                              focusNode: FocusNode(),
                              autofocus: false,
                              customButton: WidgetT.iconMini(Icons.arrow_drop_down_circle_sharp),
                              items: ['수입', '지출'].map((item) => DropdownMenuItem<dynamic>(
                                value: item,
                                child: Text(
                                  item,
                                  style: StyleT.titleStyle(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )).toList(),
                              onChanged: (value) async {
                                if(value == '수입') tmpTs.type = 'RE';
                                else if(value == '지출') tmpTs.type = 'PU';
                                else tmpTs.type = 'ETC';
                                await FunT.setStateDT();
                              },
                              itemHeight: 24,
                              itemPadding: const EdgeInsets.only(left: 16, right: 16),
                              dropdownWidth: 100 + 28,
                              dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
                              dropdownDecoration: BoxDecoration(
                                border: Border.all(
                                  width: 1.7,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                borderRadius: BorderRadius.circular(0),
                                color: Colors.white.withOpacity(0.95),
                              ),
                              dropdownElevation: 0,
                              offset: const Offset(-128 + 28, 0),
                            ),
                          ),
                        ),
                        WidgetT.excelInput(context, '$i::ts적요', width: 250, index: i,
                          onEdite: (i, data) { tmpTs.summary = data; },
                          text: '${tmpTs.summary}',
                        ),
                        WidgetT.excelGrid(text:  (SystemT.accounts[tmpTs.account] != null) ? SystemT.accounts[tmpTs.account]!.name : 'NULL', width: 180,),
                        SizedBox(
                          height: 28, width: 28,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              focusColor: Colors.transparent,
                              focusNode: FocusNode(),
                              autofocus: false,
                              customButton: WidgetT.iconMini(Icons.arrow_drop_down_circle_sharp),
                              items: SystemT.accounts.keys.map((item) => DropdownMenuItem<dynamic>(
                                value: item,
                                child: Text(
                                  (SystemT.accounts[item] != null) ? SystemT.accounts[item]!.name : 'NULL',
                                  style: StyleT.titleStyle(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )).toList(),
                              onChanged: (value) async {
                                tmpTs.account = value;
                                await FunT.setStateDT();
                              },
                              itemHeight: 24,
                              itemPadding: const EdgeInsets.only(left: 16, right: 16),
                              dropdownWidth: 180 + 28,
                              dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
                              dropdownDecoration: BoxDecoration(
                                border: Border.all(
                                  width: 1.7,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                borderRadius: BorderRadius.circular(0),
                                color: Colors.white.withOpacity(0.95),
                              ),
                              dropdownElevation: 0,
                              offset: const Offset(-208 + 28, 0),
                            ),
                          ),
                        ),
                        WidgetT.excelInput(context, '$i::ts금액', width: 120,
                          onEdite: (i, data) {
                            tmpTs.amount = int.tryParse(data) ?? 0;
                          },
                          text: StyleT.krwInt(tmpTs.amount), value: tmpTs.amount.toString(),),
                        WidgetT.excelInput(context, '$i::ts메모', width: 250, index: i,
                          onEdite: (i, data) { tmpTs.memo = data;},
                          text: tmpTs.memo,
                        ),
                        InkWell(
                            onTap: () {

                            },
                            child: Container( height: 28, width: 28,
                              child: WidgetT.iconMini(Icons.open_in_new),)
                        ),
                      ]
                  ),
                );
                tsCW.add(w);
                tsCW.add(WidgetT.dividHorizontal(size: 0.35));
              }

              var gridStyleT = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.03), stroke: 2, strokeColor: StyleT.titleColor.withOpacity(0.1));
              var btnStyleT = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.1),
                stroke: 0.35,);

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.dlColor, width: 0.35),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '수납추가', ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(18), width: 1280,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            WidgetT.title('등록유형', width: 100 ),
                            Container(
                              padding: EdgeInsets.only(right: dividHeight),
                              child: TextButton(
                                  onPressed: () {
                                    isCt = !isCt;
                                    FunT.setStateDT();
                                  },
                                  style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                                      color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                                  child: Container(padding: EdgeInsets.all(0), child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if(!isCt)
                                        Container( height: 28, width: 28,
                                          child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                                      if(isCt)
                                        Container( height: 28, width: 28,
                                          child: WidgetT.iconMini(Icons.check_box),),
                                      WidgetT.title('기존 계약에 추가'),
                                      SizedBox(width: 6,),
                                    ],
                                  ))
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: dividHeight),
                              child: TextButton(
                                  onPressed: () {
                                    isNoCs = !isNoCs;
                                    FunT.setStateDT();
                                  },
                                  style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                                      color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                                  child: Container(padding: EdgeInsets.all(0), child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if(!isNoCs)
                                        Container( height: 28, width: 28,
                                          child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                                      if(isNoCs)
                                        Container( height: 28, width: 28,
                                          child: WidgetT.iconMini(Icons.check_box),),
                                      WidgetT.title('일회성 거래 (거래처 없음)'),
                                      SizedBox(width: 6,),
                                    ],
                                  ))
                              ),
                            ),
                            WidgetT.text('(추후 거래기록 수정을 통해 거래처 수정이 가능합니다.)', size: 10),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        if(!isNoCs && !isCt) Row(
                          children: [
                            WidgetT.title('거래처', width: 100),
                            TextButton(
                              onPressed: () async {
                                Customer? c = await DialogT.selectCS(context);
                                FunT.setStateD = () { setStateS(() {}); };

                                if(c != null) {
                                  cs = c;
                                }
                                await FunT.setStateDT();
                              },
                              style: StyleT.buttonStyleOutline(padding: 0, round: 0, elevation: 0, strock: 1.4, color: StyleT.backgroundColor.withOpacity(0.5)),
                              child: Container( height: 28, alignment: Alignment.center,
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.text('${(cs != null) ? cs!.id : ''}', size: 10, width: 120),
                                      WidgetT.dividViertical(height: 28),
                                      WidgetT.title((cs != null) ? cs!.businessName : '', width: 250),
                                    ],
                                  )),),
                          ],
                        ),
                        if(!isNoCs && isCt) Row(
                          children: [
                            WidgetT.title('계약명', width: 100),
                            TextButton(
                              onPressed: () async {
                                Contract? c = await DialogT.selectCt(context);
                                FunT.setStateD = () { setStateS(() {}); };

                                if(c != null) {
                                  ct = c;
                                  cs = await SystemT.getCS(ct.csUid);
                                }
                                await FunT.setStateDT();
                              },
                              style: StyleT.buttonStyleOutline(padding: 0, round: 0, elevation: 0, strock: 1.4, color: StyleT.backgroundColor.withOpacity(0.5)),
                              child: Container( height: 28, alignment: Alignment.center,
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.text('${ct.id}', size: 10, width: 120),
                                      WidgetT.dividViertical(height: 28),
                                      WidgetT.title(ct.ctName, width: 250),
                                    ],
                                  )),),
                          ],
                        ),
                        SizedBox(height: dividHeight * 8,),

                        for(var w in tsCW) w,

                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            TextButton(
                                onPressed: () async {
                                  tslistCr.add(TS.fromDatabase({ 'transactionAt': DateTime.now().microsecondsSinceEpoch, 'type': 'PU' }));
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                                child: Container(padding: EdgeInsets.all(0), child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    Container( height: 28, width: 28,
                                      child: WidgetT.iconMini(Icons.add_box),),
                                    WidgetT.title('지급추가' ),
                                    SizedBox(width: 6,),
                                  ],
                                ))
                            ),
                            SizedBox(width: 6,),
                            TextButton(
                                onPressed: () async {
                                  tslistCr.add(TS.fromDatabase({ 'transactionAt': DateTime.now().microsecondsSinceEpoch, 'type': 'RE' }));
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                                child: Container(padding: EdgeInsets.all(0), child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container( height: 28, width: 28,
                                      child: WidgetT.iconMini(Icons.add_box),),
                                    WidgetT.title('수입추가' ),
                                    SizedBox(width: 6,),
                                  ],
                                ))
                            ),
                          ],
                        ),
                        SizedBox(height: dividHeight * 8,),
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
                            if(isNoCs == true) cs = null;
                            if(!isNoCs && cs == null) { WidgetT.showSnackBar(context, text: '거래처를 선택해 주세요.'); return; }
                            if(!isNoCs && isCt && ct == null) { WidgetT.showSnackBar(context, text: '계약을 선택해 주세요.'); return; }

                            if(tslistCr.length < 1) { WidgetT.showSnackBar(context, text: '최소 1개 이상의 거래기록을 입력 후 시도해주세요.'); return; }
                            for(var t in tslistCr) {
                              if(t.amount < 1) { WidgetT.showSnackBar(context, text: '하나 이상의 거래데이터의 금액이 비정상 적입니다. ( 0원 )'); return; }
                              if(t.transactionAt == 0) {WidgetT.showSnackBar(context, text: '날짜를 정확히 입력해 주세요.'); return; }
                            }


                            var alert = await DialogT.showAlertDl(context, title: '수납현황' ?? 'NULL');
                            if(alert == false) {
                              WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                              return;
                            }

                            for(var ts in tslistCr) {
                              if(isNoCs) {
                                await ts.update();
                              } else {
                                ts.csUid = cs!.id;
                                if(isCt) { ts.csUid = ct!.csUid; ts.ctUid = ct!.id; }
                                await ts.update();
                              }
                            }

                            WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                            Navigator.pop(context);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('수납 추가하기', style: StyleT.titleStyle(),),
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
