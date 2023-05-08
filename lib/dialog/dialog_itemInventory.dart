import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/database/process.dart';
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
import '../helper/firebaseCore.dart';
import '../helper/interfaceUI.dart';
import '../helper/pdfx.dart';
import '../class/database/item.dart';

import 'package:http/http.dart' as http;

import '../ui/cs.dart';
import '../ui/dialog_contract.dart';
import '../ui/dl.dart';
import '../ui/ux.dart';


class DialogItemInven extends StatelessWidget {

  /// 매입 개별 수정 창
  static dynamic showInfo(BuildContext context, { ItemTS? org }) async {
    var dividHeight = 6.0;

    if(org == null) return;
    ItemTS pu = org;

    Contract? ct = await DatabaseM.getContractDoc(pu.ctUid == '' ? 'ㅡ' : pu.ctUid);
    Customer? cs = await DatabaseM.getCustomerDoc(pu.csUid == '' ? 'ㅡ' : pu.csUid);

    /// 해당 매입품목에 대한 전체 공정목록
    List<ProcessItem> processList = await DatabaseM.getItemProcessPu(pu.rpUid == '' ? '-' : pu.rpUid);

    /// 출고된 공정목록
    List<ProcessItem> outputList = processList.where((e) => e.isOutput).toList();

    /// 각 공정에대한 중간자재 출고품목 통합목록
    Map<String, ProcessItem> outputMap = {};
    /// 각 공정에 대한 원자재 사용량
    Map<String, double> amountMap = {};

    processList.forEach((e) {
      if(e.prUid == '') return;
      if(amountMap.containsKey(e.prUid)) {
        amountMap[e.prUid] = amountMap[e.prUid]! + e.usedAmount.abs();
      } else {
        amountMap[e.prUid] = e.usedAmount.abs();
      }
    });
    outputList.forEach((e) {
      if(outputMap.containsKey(e.itUid)) {
        outputMap[e.itUid]!.amount += e.amount.abs();
      } else {
        outputMap[e.itUid] = ProcessItem.fromDatabase(e.toJson());
      }
    });

    ItemTS? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();

              List<Widget> widgetsPu = [];
              widgetsPu.add( WidgetUI.titleRowNone(['매출일자', '품목', '단위', '수량', '단가', '메모', '저장위치', ],
                [ 150, 200, 50, 100, 100, 999, 200, 150, 200, 0],lite: true, background: true ));

              var item = SystemT.getItem(pu.itemUid) ?? Item.fromDatabase({});
              var w = Column(
                children: [
                  Container( height: 28,
                    child: Row(
                        children: [
                          ExcelT.LitGrid(text: StyleT.dateInputFormatAtEpoch(pu.date.toString()), width: 150, center: true),
                          ExcelT.LitGrid(text: SystemT.getItemName(pu.itemUid), width: 200, center: true),
                          ExcelT.LitGrid(text: item.unit, width: 50),
                          ExcelT.LitGrid(text: StyleT.krwInt(pu.amount.toInt()), width: 100, center: true),
                          ExcelT.LitGrid(text: StyleT.krwInt(pu.unitPrice), width: 100, center: true),
                          ExcelT.LitGrid(text: pu.memo, width: 200, expand: true, center: true),
                          ExcelT.LitGrid(text: pu.storageLC, width: 200, expand: true),
                        ]
                    ),
                  ),
                  Container(
                    height: 28 + dividHeight,
                    child: Row(
                        children: [
                          WidgetT.excelGrid( width: 178, label: '첨부파일', ),
                          Expanded(
                              child: Container( padding: EdgeInsets.all(6),
                                child: Wrap(
                                  runSpacing: dividHeight, spacing: dividHeight,
                                  children: [
                                    SizedBox(width: dividHeight, height: 36,),
                                    for(int i = 0; i < pu.filesMap.length; i++)
                                      InkWell(
                                          onTap: () async {
                                            var downloadUrl = pu.filesMap.values.elementAt(i);
                                            var fileName = pu.filesMap.keys.elementAt(i);
                                            print(downloadUrl);
                                            var res = await http.get(Uri.parse(downloadUrl));
                                            var bodyBytes = res.bodyBytes;
                                            print(bodyBytes.length);
                                            PDFX.showPDFtoDialog(context, data: bodyBytes, name: fileName);
                                          },
                                          child: Container(
                                              decoration: StyleT.inkStyle(round: 8, stroke: 1,),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  WidgetT.iconMini(Icons.cloud_done, size: 28),
                                                  WidgetT.title(pu.filesMap.keys.elementAt(i),),
                                                  TextButton(
                                                      onPressed: () {
                                                        //pu.filesMap.remove(pu.filesMap.keys.elementAt(i));
                                                        //FunT.setStateDT();
                                                      },
                                                      style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                                      child: Container( height: 28, width: 28,
                                                        child: WidgetT.iconMini(Icons.cancel),)
                                                  ),
                                                ],
                                              ))
                                      ),
                                  ],
                                ),)),
                        ]
                    ),
                  ),
                  WidgetT.dividHorizontal(size: 0.35),
                ],
              );
              widgetsPu.add(w);

              List<Widget> outputWidgets = [];
              List<Widget> processingWidgets = [];
              outputWidgets.add(WidgetUI.titleRowNone(['순번', '품목명', '가공공정', '상태', '가공가능수량'],
                  [ 28, 200, 100, 100, 200], background: true, lite: true));
              processingWidgets.add(ProcessItem.onTableHeader());

              var usedCount = 0.0;
              processList.forEach((e) { usedCount += e.amount.abs(); });

              /// 기초 품목에 대한 가공가능목록 생성
              var am = amountMap.containsKey(pu.id) ? amountMap[pu.id] : 0;
              if(pu.amount - am!.abs() > 0) {
                outputWidgets.add(InkWell(
                  onTap: () async {
                    var process = ProcessItem.fromDatabase({});
                    process.id = pu.id; 
                    process.amount = (pu.amount - usedCount);
                    process.rpUid = pu.rpUid;
                    process.itUid = pu.itemUid;

                    var result = await selectProcess(context, process: process);

                    if(result != null) {
                      processList = await DatabaseM.getItemProcessPu(pu.rpUid);
                      outputList = processList.where((e) => e.isOutput).toList();

                      processList.forEach((e) {
                        if(e.prUid == '') return;
                        if(amountMap.containsKey(e.prUid)) {
                          amountMap[e.prUid] = amountMap[e.prUid]! + e.usedAmount.abs();
                        } else {
                          amountMap[e.prUid] = e.usedAmount.abs();
                        }
                      });
                      outputList.forEach((e) {
                        if(outputMap.containsKey(e.itUid)) {
                          outputMap[e.itUid]!.amount += e.amount.abs();
                        } else {
                          outputMap[e.itUid] = ProcessItem.fromDatabase(e.toJson());
                        }
                      });

                      setStateS(() {});
                    }
                  },
                  child: Container(
                    height: 28,
                    child: Row(
                      children: [
                        ExcelT.LitGrid(text: "-", width: 28),
                        ExcelT.LitGrid(text: item.name, width: 200, center: true),
                        ExcelT.LitGrid(text: '미가공', width: 100, center: true),
                        ExcelT.LitGrid(text: '완료', width: 100, center: true),
                        ExcelT.LitGrid(text: StyleT.krwInt((pu.amount - usedCount).toInt()), width: 200, center: true),
                      ],
                    ),
                  ),
                ));
                outputWidgets.add(WidgetT.dividHorizontal(size: 0.35));
              }

              outputMap.values.forEach((e) {
                var it = SystemT.getItem(e.itUid) ?? Item.fromDatabase({});
                outputWidgets.add(e.OnTableUI(
                  context: context,
                  item: it,
                  onTap: () async {
                    /// 신규 품목 가공창 표시
                    var process = ProcessItem.fromDatabase({});
                    process.amount = (e.amount - (amountMap.containsKey(e.id) ? amountMap[e.id]! : 0.0));
                    process.rpUid = pu.rpUid;
                    process.itUid = e.itUid;

                    var result = await selectProcess(context, process: process);

                    if(result != null) {
                      processList = await DatabaseM.getItemProcessPu(pu.rpUid);
                      outputList = processList.where((e) => e.isOutput).toList();

                      processList.forEach((e) {
                        if(e.prUid == '') return;
                        if(amountMap.containsKey(e.prUid)) {
                          amountMap[e.prUid] = amountMap[e.prUid]! + e.usedAmount.abs();
                        } else {
                          amountMap[e.prUid] = e.usedAmount.abs();
                        }
                      });
                      outputList.forEach((e) {
                        if(outputMap.containsKey(e.itUid)) {
                          outputMap[e.itUid]!.amount += e.amount.abs();
                        } else {
                          outputMap[e.itUid] = ProcessItem.fromDatabase(e.toJson());
                        }
                      });
                      setStateS(() {});
                    }
                  },
                  setState: () { setStateS(() {}); },
                ));
                outputWidgets.add(WidgetT.dividHorizontal(size: 0.35));
              });
              for(var e in processList) {
                if(e.isOutput) continue;

                var it = SystemT.getItem(e.itUid) ?? Item.fromDatabase({});
                processingWidgets.add(e.OnTableUI(item: it,
                  context: context,
                  setState: () { setStateS(() {}); },
                  usedAmount: amountMap.containsKey(e.id) ? amountMap[e.id] : 0.0,
                  onTap: () async {

                  },
                ));
                processingWidgets.add(WidgetT.dividHorizontal(size: 0.35));
              }

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent, width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '매입 개별 상세 정보', ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(18),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WidgetT.title('거래처', size: 16),
                            SizedBox(height: dividHeight,),
                            Container(
                                height: 36, width: 250, alignment: Alignment.center,
                                decoration: StyleT.inkStyle(color: Colors.black.withOpacity(0.02), stroke: 2, strokeColor: Colors.grey.withOpacity(0.35)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    WidgetT.title((cs != null) ? cs!.businessName : '', ),
                                  ],
                                )),
                          ],
                        ),
                        SizedBox(height: dividHeight * 8,),

                        WidgetT.title('품목매입정보', size: 16),
                        SizedBox(height: dividHeight,),
                        Column(children: widgetsPu, ),
                        SizedBox(height: dividHeight * 8,),

                        TextT.Title(text: '가공가능한 목록',),
                        SizedBox(height: dividHeight,),
                        Column(children: outputWidgets, ),
                        SizedBox(height: dividHeight * 8,),

                        TextT.Title(text: '가공중인 목록',),
                        SizedBox(height: dividHeight,),
                        Column(children: processingWidgets, ),
                        SizedBox(height: dividHeight * 8,),

                        Row(
                          children: [
                            TextT.Title(text: '품목가공로그',),
                            SizedBox(width: 6,),
                            TextT.Lit(text: '해당 품목에 대한 모든 가공공정의 로그 목록입니다.', size: 10,)
                          ],
                        ),
                        SizedBox(height: dividHeight,),


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
                            Navigator.pop(context);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('확인', style: StyleT.titleStyle(),),
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

  static dynamic createOutputItem(BuildContext context, { ProcessItem? process }) async {
    var dividHeight = 6.0;
    if(process == null) return null;

    ProcessItem inputProcess = ProcessItem.fromDatabase({});
    inputProcess.date = DateTime.now().microsecondsSinceEpoch;
    var usedAmount = 0.0;
    var startAmount = process.amount;

    ProcessItem? ret = await showDialog(
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
                    side: BorderSide(color: Colors.transparent, width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '공정완료입력창', ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(18),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextT.Title(text: '공정완료 수량 및 품목 입력',),
                        SizedBox(height: dividHeight,),
                        Column(children: [
                          WidgetUI.titleRowNone([ '공정완료일', '완성된 품목 수량', '가공완료품목', '사용된 작업물 수량', '현재 남은 공정수량' ],
                              [ 150, 100, 250, 100, 250 ], lite: true, background: true),
                          Row(
                            children: [
                              ExcelT.Input(context, 'out.process.date',
                                width: 150,
                                onEdited: (i, data) {
                                  var date = DateTime.tryParse(data.toString()) ?? DateTime.now();
                                  inputProcess.date = date.microsecondsSinceEpoch;
                                },
                                setState: () { setStateS(() {}); },
                                text: DateStyle.dateYearMD(inputProcess.date),
                                value: DateStyle.dateYearMD(inputProcess.date),
                              ),
                              ExcelT.Input(context, 'out.process.out.amount', width: 100,
                                onEdited: (i, data) {
                                  inputProcess.amount = double.tryParse(data) ?? 0;
                                  if(inputProcess.amount > process.amount)
                                    inputProcess.amount = process.amount;
                                },
                                setState: () { setStateS(() {}); },
                                text: inputProcess.amount.toString(), value: inputProcess.amount.toString(),
                              ),

                              /// 품목선택 드롭다운 메뉴
                              SizedBox(
                                height: 28, width: 250,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    focusColor: Colors.transparent,
                                    focusNode: FocusNode(),
                                    autofocus: false,
                                    customButton: TextT.Lit(text: SystemT.itemMaps[inputProcess.itUid] == null ? '선택안됨':
                                    SystemT.itemMaps[inputProcess.itUid]!.name,
                                      width: 250,
                                    ),
                                    items: SystemT.itemMaps.keys.map((item) => DropdownMenuItem<dynamic>(
                                      value: item,
                                      child: Text(
                                        SystemT.itemMaps[item]!.name.toString(),
                                        style: StyleT.titleStyle(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )).toList(),
                                    onChanged: (value) async {
                                      inputProcess.itUid = value;
                                      setStateS(() {});
                                    },
                                    itemHeight: 28,
                                    itemPadding: const EdgeInsets.only(left: 16, right: 16),
                                    dropdownWidth: 250,
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
                                    offset: const Offset(0, 0),
                                  ),
                                ),
                              ),
                              ExcelT.Input(context, 'process.use.amount', width: 100,
                                onEdited: (i, data) {
                                  usedAmount = double.tryParse(data) ?? 0;
                                  process.amount = startAmount - usedAmount.abs();
                                },
                                setState: () { setStateS(() {}); },
                                text: usedAmount.abs().toString(), value: usedAmount.abs().toString(),
                              ),
                              ExcelT.LitGrid(text: StyleT.krwInt(process.amount.toInt()), width: 250, center: true),
                            ],
                          )
                        ],),
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
                            if(inputProcess.amount <= 0) {
                              WidgetT.showSnackBar(context, text: '가공완료수량은 0일 수 없습니다.');
                              return;
                            }
                            if(inputProcess.itUid == '') {
                              WidgetT.showSnackBar(context, text: '가공완료품목은 비워둘 수 없습니다.');
                              return;
                            }
                            if(usedAmount.abs() <= 0) {
                              WidgetT.showSnackBar(context, text: '가공사용수량은 0일 수 없습니다.');
                              return;
                            }


                            var alt = await DialogT.showAlertDl(context, text: '공정을 완료하시겠습니까?');
                            if(!alt) {  WidgetT.showSnackBar(context, text: '취소됨'); return; }

                            WidgetT.loadingBottomSheet(context);
                            setStateS(() {});

                            /// 최상위 부모 매입정보 상속
                            inputProcess.prUid = process.id;
                            inputProcess.rpUid = process.rpUid;
                            inputProcess.isOutput = true;
                            inputProcess.usedAmount = usedAmount;

                            var result = await inputProcess.update();
                            if(!result) WidgetT.showSnackBar(context, text: 'The request to write to the server for path "/purchase/:pid/item-process/:psid" failed.');
                            else WidgetT.showSnackBar(context, text: '저장됨');


                            Navigator.pop(context);
                            Navigator.pop(context, inputProcess);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('공정완료 저장', style: StyleT.titleStyle(),),
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
    return ret;
  }

  /// 공정 선택 창
  static dynamic selectProcess(BuildContext context, { ProcessItem? process }) async {
    var dividHeight = 6.0;
    if(process == null) return;

    ProcessItem inputProcess = ProcessItem.fromDatabase({});
    inputProcess.date = DateTime.now().microsecondsSinceEpoch;

    Item? item = SystemT.getItem(process.itUid);
    if(item == null) return null;

    ProcessItem? ret = await showDialog(
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
                    side: BorderSide(color: Colors.transparent, width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '공정입력창', ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(18),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextT.Title(text: '현재 가공 품목',),
                        SizedBox(height: dividHeight,),
                        TextT.Lit(text: item.name, size: 12),
                        SizedBox(height: dividHeight * 2,),

                        TextT.Title(text: '공정 및 수량 입력',),
                        SizedBox(height: dividHeight,),
                        Column(children: [
                          WidgetUI.titleRowNone([ '가공일', '가공 공정', '가공할 수량', '가공가능 최대수량' ], [ 150, 250, 250, 250 ], lite: true, background: true),
                          Row(
                            children: [
                              ExcelT.Input(context, 'process.date',
                                width: 150,
                                onEdited: (i, data) {
                                  var date = DateTime.tryParse(data.toString()) ?? DateTime.now();
                                  inputProcess.date = date.microsecondsSinceEpoch;
                                },
                                setState: () { setStateS(() {}); },
                                text: DateStyle.dateYearMD(inputProcess.date),
                                value: DateStyle.dateYearMD(inputProcess.date),
                              ),
                              WidgetT.dropMenu(dropMenuMaps:  MetaT.processType,
                                dropMenus: MetaT.processType.keys.toList(), width: 250,
                                onEdite: (i, data) {
                                  inputProcess.type = data;
                                  setStateS(() {});
                                },
                                text: (MetaT.processType[inputProcess.type] == null) ?
                                '선택안됨' : MetaT.processType[inputProcess.type].toString(),
                              ),
                              ExcelT.Input(context, 'process.amount', width: 250,
                                onEdited: (i, data) {
                                  inputProcess.amount = double.tryParse(data) ?? 0;
                                  if(inputProcess.amount > process.amount)
                                    inputProcess.amount = process.amount;
                                },
                                setState: () { setStateS(() {}); },
                                text: inputProcess.amount.toString(), value: inputProcess.amount.toString(),
                              ),
                              ExcelT.LitGrid(text: StyleT.krwInt(process.amount.toInt()), width: 250, center: true),
                            ],
                          )
                        ],),
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
                            if(inputProcess.amount <= 0) {
                              WidgetT.showSnackBar(context, text: '가공수량은 0일 수 없습니다.');
                              return;
                            }
                            if(inputProcess.type == '') {
                              WidgetT.showSnackBar(context, text: '가공공정은 비워둘 수 없습니다.');
                              return;
                            }

                            var alt = await DialogT.showAlertDl(context, text: '공정을 저장하시겠습니까?');
                            if(!alt) {  WidgetT.showSnackBar(context, text: '취소됨'); return; }

                            /// 최상위 부모 매입정보 상속
                            inputProcess.prUid = process.id;
                            inputProcess.rpUid = process.rpUid;
                            inputProcess.itUid = process.itUid;

                            var result = await inputProcess.update();
                            if(!result) WidgetT.showSnackBar(context, text: 'The request to write to the server for path "/purchase/:pid/item-process/:psid" failed.');
                            else WidgetT.showSnackBar(context, text: '저장됨');

                            Navigator.pop(context, inputProcess);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('가공 저장', style: StyleT.titleStyle(),),
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
    return ret;
  }

  Widget build(context) {
    return Container();
  }
}
