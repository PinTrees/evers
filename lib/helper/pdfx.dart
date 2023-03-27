import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:internet_file/internet_file.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:printing/printing.dart';
import 'package:quick_notify/quick_notify.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import '../helper/interfaceUI.dart';
import '../helper/style.dart';
import '../ui/dl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFX extends StatelessWidget {

  /* static dynamic dialogCt(BuildContext context, Contract p,
      { bool endVisible=false, Function? fun, Function(bool)? saveFun, Function? setFun,
        bool viewShort=false, Color? color}) async {

    p.addresses.add('');
    p.clients.add({});
    p.useType.add('');

    var height1 = 28.0;
    var widthPay = 200.0;
    var widthManager = 150.0;
    var widthAddress = 600.0;
    var widthDateF = 50.0;
    var widthClientN = 250.0;
    var widthClientPN = 350.0;

    var pYear = ' - ', pMonth = ' - ';
    if(p.getContractAtsFirst() != null) {
      pYear = p.getContractAtsFirst()!.year.toString();
      pMonth = p.getContractAtsFirst()!.month.toString();
    }

    bool aa = await showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              return AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.9),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade400, width: 1.4),
                    borderRadius: BorderRadius.circular(8)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: Container(padding: EdgeInsets.all(12), child: Text('계약현황 문서 추가', style: StyleT.titleStyle(bold: true))),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded( //width: 550 + 28.7,
                              child: TextButton(
                                onPressed: null,
                                style: StyleT.buttonStyleOutline(padding: 0, elevation: 0, strock: 1.4, color: color ?? Colors.white.withOpacity(0.5)),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container( width: widthDateF, alignment: Alignment.center,
                                            child: Row(
                                              children: [
                                                Expanded(child: SizedBox()),
                                                Text(pYear, style: StyleT.titleStyle(),),
                                                Text('년', style: StyleT.textStyle(),),
                                                Expanded(child: SizedBox()),
                                                WidgetHub.dividVerticalLow(height: height1),
                                              ],
                                            ),
                                          ),
                                          Container( width: widthDateF, alignment: Alignment.center,
                                            child: Row(
                                              children: [
                                                Expanded(child: SizedBox()),
                                                Text(pMonth, style: StyleT.titleStyle(),),
                                                Text('월', style: StyleT.textStyle(),),
                                                Expanded(child: SizedBox()),
                                                WidgetHub.dividVerticalLow(height: height1),
                                              ],
                                            ),
                                          ),
                                          excelGridButton(fun: () async {
                                            if(setFun != null) await setFun();
                                            setStateS(() {});
                                          }, icon: Icons.calendar_month),
                                          excelGridEditor(context,setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                              width: widthManager, alignment: Alignment.centerLeft, isManager: true,
                                              set: (index, data) {
                                                p.managerUid = data;
                                              }, key: 'ct.manager', text: '${SystemT.getManagerName(p.managerUid)}',
                                              label: '실무자'),
                                          excelGridEditor(context,setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                              set: (index, data) {
                                                p.landType = data;
                                              }, val: p.landType ?? '', width: 150,
                                              key: 'ct.landType', text: p.landType, label: '지목'),
                                        ],
                                      ),
                                      WidgetHub.dividHorizontalLow(),
                                      WidgetHub.dividHorizontalLow(),
                                      Container( width: widthClientN + widthClientPN,
                                        child: Row(
                                          children: [
                                            Expanded(child: excelGrid(label: '소재지',)),
                                            excelGridButton(fun: () async {
                                              p.addresses.add('');
                                              if(setFun != null) await setFun();
                                              setStateS(() {});
                                            }, icon: Icons.add),
                                          ],
                                        ),
                                      ),
                                      WidgetHub.dividHorizontalLow(),
                                      for(int i = 0; i < p.addresses.length; i++)
                                        Container(
                                          height: height1, width: widthAddress,
                                          alignment: Alignment.center,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: excelGridEditor(context, isAddress: true, width: widthAddress - 28,
                                                    setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                                    set: (index, data) {
                                                      p.addresses[index] = data;
                                                    }, val: p.addresses[i] ?? '', key: '$i::ct.addresses',
                                                    text: p.addresses[i], label: '소재지'),
                                              ),
                                              excelGridButton(fun: () async {
                                                if(p.addresses.length <= 1) p.addresses[0] = '';
                                                else p.addresses.removeAt(i);

                                                if(setFun != null) await setFun();
                                                setStateS(() {});
                                              }, icon: Icons.delete),
                                            ],
                                          ),
                                        ),
                                      WidgetHub.dividHorizontalLow(),
                                      WidgetHub.dividHorizontalLow(),

                                      Container( width: widthClientN + widthClientPN,
                                        child: Row(
                                          children: [
                                            Expanded(child: excelGrid(label: '신청인',)),
                                            excelGridButton(fun: () async {
                                              p.clients.add({});
                                              if(setFun != null) await setFun();
                                              setStateS(() {});
                                            }, icon: Icons.add),
                                          ],
                                        ),
                                      ),
                                      WidgetHub.dividHorizontalLow(),
                                      for(int i = 0; i < p.clients.length; i++)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: height1, width: widthClientN + widthClientPN,
                                              alignment: Alignment.center,
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded( flex: 3,
                                                    child: excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                                        set: (index, data) {
                                                      p.clients[index]['name'] = data;
                                                    }, val: p.clients[i]['name'] ?? '',  key: '$i::pm.clients.name', text: p.clients[i]['name'], label: '신청인'),
                                                  ),
                                                  Expanded( flex: 7,
                                                    child: excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                                        set: (index, data) {
                                                      p.clients[index]['phoneNumber'] = data;
                                                    }, val: p.clients[i]['phoneNumber'] ?? '', key: '$i::pm.clients.phoneNumber', text: p.clients[i]['phoneNumber'], label: '연락처'),
                                                  ),
                                                  excelGridButton(fun: () async {
                                                    p.clients.removeAt(i);
                                                    if(setFun != null) await setFun();
                                                    setStateS(() {});
                                                  }, icon: Icons.delete),
                                                ],
                                              ),
                                            ),
                                            WidgetHub.dividHorizontalLow(),
                                          ],
                                        ),

                                      WidgetHub.dividHorizontalLow(),
                                      excelGrid(label: '계약 정보', width: widthPay * 5 ),
                                      WidgetHub.dividHorizontalLow(),
                                      Row(
                                        children: [
                                          excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                              set: (index, data) {
                                            p.downPayment = int.tryParse(data) ?? 0;
                                          }, val: (p.downPayment == 0) ? '' : p.downPayment.toString(), width: widthPay,
                                              key: 'ct.downPayment', text: StyleT.intNumberF(p.downPayment), label: '계약금'),
                                          excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                              set: (index, data) {
                                            p.middlePayments.clear();
                                            for(var d in data.split('/'))
                                              p.middlePayments.add(int.tryParse(d.toString().trim()) ?? 0);
                                          }, val: p.getMiddlePaysToEdite(), width: widthPay * 2,
                                              key: 'ct.middlePayments', text: p.getMiddlePaysToString(),
                                              label: '중도금 ( / / )'),
                                          excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                              set: (index, data) {
                                            p.balance = int.tryParse(data) ?? 0;
                                          }, val: (p.balance == 0) ? '' : p.balance.toString(), width: widthPay,
                                              key: 'ct.balance', text: StyleT.intNumberF(p.balance), label: '잔금'),
                                          excelGrid(width: widthPay, label: '총용역비용', text: '${StyleT.intNumberF(p.getAllPay())}'),
                                        ],
                                      ),
                                      WidgetHub.dividHorizontalLow(),
                                      Row(
                                          children: [
                                            excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                                isDropMenu: true, dropMenus: ['포함', '미포함'],
                                                set: (index, data) {
                                                  if(data == '포함') p.isVAT = true;
                                                  else p.isVAT = false;
                                                },
                                                key: 'ct.isVAT',
                                                width: widthPay,
                                                text: p.isVAT ? '포함' : '미포함',
                                                label: '부가세'),
                                            excelGridEditor(context,setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                                width: widthPay * 2, alignment: Alignment.centerLeft,
                                                set: (index, data) {
                                                  p.thirdParty = data.split(',');
                                                }, val: p.thirdParty.join(','),
                                                key: 'ct.thirdParty', text: p.thirdParty.join(',  '), label: '타사업무내용 ( , , )'),
                                          ]
                                      ),
                                      WidgetHub.dividHorizontalLow(),
                                      Row(
                                          children: [
                                            excelGrid(width: widthPay, label: '미수금', text: '- ${StyleT.intNumberF(p.getAllPay() - p.getAllCfPay())}'),
                                            excelGridEditor(context,setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                                alignment: Alignment.centerLeft,
                                                set: (index, data) {
                                                  p.useType = data.split(',');
                                                }, val: p.useType.join(','), width: widthPay * 3,
                                                key: 'ct.useType', text: p.useType.join(',  '), label: '사업목적 ( , , )'),
                                          ]
                                      ),
                                      WidgetHub.dividHorizontalLow(),
                                      Row(
                                        children: [
                                          excelGridEditor(context, isDate: true, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                              set: (index, data) {
                                            p.contractAt = data ?? '';
                                          }, val: p.contractAt, width: widthPay,
                                              key: 'ct.contractAt', text: p.contractAt, label: '계약일'),
                                          excelGridEditor(context, isDate: true, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                              set: (index, data) {
                                            p.takeAt = data ?? '';
                                          }, val: p.takeAt, width: widthPay,
                                              key: 'ct.takeAt', text: p.takeAt, label: '업무배당일'),
                                          excelGridEditor(context, isDate: true, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                              set: (index, data) {
                                            p.applyAt = data ?? '';
                                          }, val: p.applyAt, width: widthPay,
                                              key: 'ct.applyAt', text: p.applyAt, label: '접수일'),
                                          excelGridEditor(context, isDate: true, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                              set: (index, data) {
                                            p.permitAt = data ?? '';
                                          }, val: p.permitAt, width: widthPay,
                                              key: 'ct.permitAt', text: p.permitAt, label: '허가일'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height:  8,),
                        TextButton(
                          onPressed: null,
                          style: StyleT.buttonStyleOutline(padding: 0, elevation: 0, strock: 1.4, color: color ?? Colors.white.withOpacity(0.5)),
                          child: Container( width: 1000,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: excelGrid(label: '입금 내역 정보',),),
                                    excelGridButton(fun: () async {
                                      p.confirmDeposits.add({});
                                      if(setFun != null) await setFun();
                                      setStateS(() {});
                                    }, icon: Icons.add),
                                  ],
                                ),
                                WidgetHub.dividHorizontalLow(),
                                for(int i = 0; i < p.confirmDeposits.length; i++)
                                  Row(
                                    children: [
                                      excelGridEditor(context, isDate: true, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                          set: (index, data) {
                                            p.confirmDeposits[i]['date'] = data;
                                          }, val: p.confirmDeposits[i]['date'], width: 150,
                                          key: '$i::ct.confirmDeposits.date', text: p.confirmDeposits[i]['date'], label: '입금날짜'),
                                      excelGridEditor(context, isDropMenu: true, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                          dropMenus: [ '-81', '-51', '카드결제', '기타' ],
                                          set: (index, data) {
                                            p.confirmDeposits[i]['account'] = data;
                                          }, val: p.confirmDeposits[i]['account'], width: 100,
                                          key: '$i::ct.confirmDeposits.account', text: p.confirmDeposits[i]['account'], label: '계좌'),
                                      excelGridEditor(context, isDropMenu: true, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                          dropMenus: [ '계약금', '중도금', '잔금', '기타' ],
                                          set: (index, data) {
                                            p.confirmDeposits[i]['type'] = data;
                                          }, val: p.confirmDeposits[i]['type'], width: 100,
                                          key: '$i::ct.confirmDeposits.type', text: p.confirmDeposits[i]['type'], label: '분류'),
                                      excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                          set: (index, data) {
                                            p.confirmDeposits[i]['balance'] = int.tryParse(data) ?? 0;
                                          }, val: p.confirmDeposits[i]['balance'].toString(), width: widthPay,
                                          key: '$i::ct.confirmDeposits.balance', text: StyleT.intNumberF(p.confirmDeposits[i]['balance']), label: '금액'),
                                      excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                          set: (index, data) {
                                            p.confirmDeposits[i]['uid'] = data;
                                          }, val: p.confirmDeposits[i]['uid'], width: 150,
                                          key: '$i::ct.confirmDeposits.uid', text: p.confirmDeposits[i]['uid'], label: '입금자'),
                                      Expanded(
                                        child: excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                            set: (index, data) {
                                              p.confirmDeposits[i]['desc'] = data;
                                            }, val: p.confirmDeposits[i]['desc'],
                                            key: '$i::ct.confirmDeposits.desc', text: p.confirmDeposits[i]['desc'], label: '입금내용'),
                                      ),
                                      excelGridButton(fun: () async {
                                        p.confirmDeposits.removeAt(i);
                                        if(setFun != null) await setFun();
                                        setStateS(() {});
                                      }, icon: Icons.delete),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height:  8,),
                        TextButton(
                          onPressed: null,
                          style: StyleT.buttonStyleOutline(padding: 0, elevation: 0, strock: 1.4,
                              color: color ?? Colors.white.withOpacity(0.5)),
                          child: Container(
                            width: 1000,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: excelGrid(label: '타사업무내용 및 특이사항',)),
                                    Expanded(child: excelGrid(label: '비고', )),
                                  ],
                                ),
                                WidgetHub.dividHorizontalLow(),
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: excelGridEditor(context,setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                            multiLine: true,
                                            set: (index, data) {
                                              p.thirdPartyDetails = data;
                                            }, val: p.thirdPartyDetails,
                                            key: 'ct.thirdPartyDetails', text: p.thirdPartyDetails, label: '내용'),
                                      ),
                                      Expanded(
                                        child: excelGridEditor(context,setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                            multiLine: true,
                                            set: (index, data) {
                                              p.desc = data;
                                            }, val: p.desc,
                                            key: 'ct.desc', text: p.desc, label: '내용'),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  Container(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container( height: 28,
                          child: TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                              style: StyleT.buttonStyleOutline(padding: 0, strock: 1.4, elevation: 0,
                                  color: Colors.redAccent.withOpacity(0.5)),
                              child: Row( mainAxisSize: MainAxisSize.min,
                                children: [
                                  iconStyleMini(icon: Icons.cancel),
                                  Text('취소', style: StyleT.titleStyle(),),
                                  SizedBox(width: 12,),
                                ],
                              )
                          ),
                        ),
                        SizedBox(width: 8,),
                        //Expanded(child:Container()),
                        Container( height: 28,
                          child: TextButton(
                              onPressed: () async {
                                if(saveFun != null) {
                                  await saveFun(false);
                                }
                                setStateS(() {});
                                Navigator.pop(context, true);
                              },
                              style: StyleT.buttonStyleOutline(padding: 0, strock: 1.4, elevation: 0, color: StyleT.accentColor.withOpacity(0.5)),
                              child: Row( mainAxisSize: MainAxisSize.min,
                                children: [
                                  iconStyleMini(icon: Icons.save),
                                  Text('저장하기', style: StyleT.titleStyle(),),
                                  SizedBox(width: 12,),
                                ],
                              )
                          ),
                        ),
                        SizedBox(width: 8,),
                        //Expanded(child:Container()),
                        Container( height: 28,
                          child: TextButton(
                              onPressed: () async {
                                if(saveFun != null) {
                                  await saveFun(true);
                                }
                                setStateS(() {});
                                Navigator.pop(context, true);
                              },
                              style: StyleT.buttonStyleOutline(padding: 0, strock: 1.4, elevation: 0, color: StyleT.accentLowColor.withOpacity(0.5)),
                              child: Row( mainAxisSize: MainAxisSize.min,
                                children: [
                                  iconStyleMini(icon: Icons.save_as),
                                  Text('업무배당 자동 추가', style: StyleT.titleStyle(),),
                                  SizedBox(width: 12,),
                                ],
                              )
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        });

    if(aa == null) aa = false;
    return aa;
  }

  static dynamic dialogWm(BuildContext context, WorkManagement p,
      { bool endVisible=false, Function? fun, Function()? saveFun, Function? setFun,
        bool viewShort=false, Color? color}) async {

    p.addresses.add('');
    p.clients.add({});

    var height1 = 28.0;
    var widthDateAt = 200.0;
    var widthPay = 200.0;
    var widthAddress = 500.0;
    var widthClient = 350.0;
    var widthManager = 150.0;
    var widthDateF = 50.0;

    bool aa = await showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              return AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.9),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade400, width: 1.4),
                    borderRadius: BorderRadius.circular(8)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: Container(padding: EdgeInsets.all(12), child: Text('업무관리 추가', style: StyleT.titleStyle(bold: true))),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: null,
                          style: StyleT.buttonStyleOutline(padding: 0, elevation: 0, strock: 1.4, color: color ?? Colors.white.withOpacity(0.5)),
                          child:  Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            color: p.isSupplement ? Colors.red.withOpacity(0.03) : Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: height1,
                                  alignment: Alignment.center,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container( width: widthDateF, alignment: Alignment.center,
                                        child: Row(
                                          children: [
                                            Expanded(child: SizedBox()),
                                            Text('${p.getTaskAt()!.year}', style: StyleT.titleStyle(),),
                                            Text('년', style: StyleT.textStyle(),),
                                            Expanded(child: SizedBox()),
                                            WidgetHub.dividVerticalLow(height: height1),
                                          ],
                                        ),
                                      ),
                                      Container( width: widthDateF, alignment: Alignment.center,
                                        child: Row(
                                          children: [
                                            Expanded(child: SizedBox()),
                                            Text('${p.getTaskAt()!.month}', style: StyleT.titleStyle(),),
                                            Text('월', style: StyleT.textStyle(),),
                                            Expanded(child: SizedBox()),
                                            WidgetHub.dividVerticalLow(height: height1),
                                          ],
                                        ),
                                      ),
                                      excelGridEditor(context,setFun: () { if(setFun != null) setFun(); setStateS(() {}); }, width: widthManager,
                                          alignment: Alignment.centerLeft, isManager: true,
                                          set: (index, data) {
                                            p.managerUid = data;
                                            setStateS(() {});
                                          }, key: 'pm.manager', text: '${SystemT.getManagerName(p.managerUid)}',
                                          label: '실무자'),
                                    ],
                                  ),
                                ),
                                WidgetHub.dividHorizontalLow(),
                                WidgetHub.dividHorizontalLow(),
                                Container( width: 600,
                                  child: Row(
                                    children: [
                                      Expanded(child: excelGrid(label: '소재지'),),
                                      excelGridButton(fun: () async {
                                        p.addresses.add('');
                                        if(setFun != null) await setFun();
                                        setStateS(() {});
                                      }, icon: Icons.add),
                                    ],
                                  ),
                                ),
                                WidgetHub.dividHorizontalLow(),
                                for(int i = 0; i < p.addresses.length; i++)
                                  Container(
                                    height: height1, width: 600,
                                    alignment: Alignment.center,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: excelGridEditor(context, isAddress: true, width: widthAddress - 28.7,
                                              setFun: () { if(setFun != null) setFun(); setStateS(() {}); }, set: (index, data) {
                                                p.addresses[index] = data;
                                              }, val: p.addresses[i] ?? '', key: '$i::pm.addresses',
                                              text: p.addresses[i], label: '소재지'),
                                        ),
                                        excelGridButton(fun: () async {
                                          p.addresses.removeAt(i);
                                          if(setFun != null) await setFun();
                                          setStateS(() {});
                                        }, icon: Icons.delete),
                                      ],
                                    ),
                                  ),
                                WidgetHub.dividHorizontalLow(),
                                WidgetHub.dividHorizontalLow(),
                                Container( width: 600,
                                  child: Row(
                                    children: [
                                      Expanded(child: excelGrid(label: '신청인',)),
                                      excelGridButton(fun: () async {
                                        p.clients.add({});
                                        if(setFun != null) await setFun();
                                        setStateS(() {});
                                      }, icon: Icons.add),
                                    ],
                                  ),
                                ),
                                WidgetHub.dividHorizontalLow(),
                                for(int i = 0; i < p.clients.length; i++)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: height1, width: 600,
                                        alignment: Alignment.center,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded( flex: 3,
                                              child: excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                                  set: (index, data) {
                                                    p.clients[index]['name'] = data;
                                                  }, val: p.clients[i]['name'] ?? '',  key: '$i::pm.clients.name', text: p.clients[i]['name'], label: '신청인'),
                                            ),
                                            Expanded( flex: 7,
                                              child: excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                                  set: (index, data) {
                                                    p.clients[index]['phoneNumber'] = data;
                                                  }, val: p.clients[i]['phoneNumber'] ?? '', key: '$i::pm.clients.phoneNumber', text: p.clients[i]['phoneNumber'], label: '연락처'),
                                            ),
                                            excelGridButton(fun: () async {
                                              p.clients.removeAt(i);
                                              if(setFun != null) await setFun();
                                              setStateS(() {});
                                            }, icon: Icons.delete),
                                          ],
                                        ),
                                      ),
                                      WidgetHub.dividHorizontalLow(),
                                    ],
                                  ),
                                WidgetHub.dividHorizontalLow(),
                                excelGridEditor(context,setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                    alignment: Alignment.center,
                                    set: (index, data) {
                                      p.useType = data.split(',');
                                    }, val: p.useType.join(','), width: 600,
                                    key: 'ct.useType', text: p.useType.join(',  '), label: '사업목적 ( , , )'),
                                WidgetHub.dividHorizontalLow(),
                                WidgetHub.dividHorizontalLow(),
                                Container(
                                  height: height1,
                                  alignment: Alignment.center,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); }, isDate:true, set: (index, data) {
                                        p.workAts['survey'] = data;
                                      }, val: p.workAts['survey'] ?? '', width: widthDateAt, key: 'wm.workAts.survey', text: p.workAts['survey'], label: '측량일'),
                                      excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); }, isDate:true, set: (index, data) {
                                        p.workAts['design'] = data;
                                      }, val: p.workAts['design'] ?? '', width: widthDateAt, key: 'wm.workAts.design', text: p.workAts['design'], label: '설계'),
                                      excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); }, isDate:true, set: (index, data) {
                                        p.workAts['doc'] = data;
                                      }, val: p.workAts['doc'] ?? '', width: widthDateAt, key: 'wm.workAts.doc', text: p.workAts['doc'], label: '문서'),
                                    ],
                                  ),
                                ),
                                WidgetHub.dividHorizontalLow(),
                                Container(
                                  height: height1,
                                  alignment: Alignment.center,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); }, set: (index, data) {
                                        p.workAts['survey_name'] = data;
                                      }, val: p.workAts['survey_name'] ?? '', width: widthDateAt, key: 'wm.workAts.survey_name',
                                          text: p.workAts['survey_name'], label: '측량자'),
                                      excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); }, set: (index, data) {
                                        p.workAts['design_name'] = data;
                                      }, val: p.workAts['design_name'] ?? '', width: widthDateAt, key: 'wm.workAts.design_name',
                                          text: p.workAts['design_name'], label: '설계자'),
                                      excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); }, set: (index, data) {
                                        p.workAts['doc_name'] = data;
                                      }, val: p.workAts['doc_name'] ?? '', width: widthDateAt, key: 'wm.workAts.doc_name',
                                          text: p.workAts['doc_name'], label: '문서작성자'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8,),
                        TextButton(
                          onPressed: null,
                          style: StyleT.buttonStyleOutline(padding: 0, elevation: 0, strock: 1.4, color: color ?? Colors.white.withOpacity(0.5)),
                          child:  Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            color: p.isSupplement ? Colors.red.withOpacity(0.03) : Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container( width: 600,
                                  child: Row(
                                    children: [
                                      Expanded(child: excelGrid(label: '업무 배당 마감일',)),
                                      excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); },
                                          isDropMenu: true, dropMenus: ['필요', '없음'],
                                          set: (index, data) {
                                            if(data == '필요') p.isSupplement = true;
                                            else p.isSupplement = false;
                                          },
                                          key: 'ct.isVAT',
                                          width: widthPay,
                                          text: p.isSupplement ? '필요' : '없음',
                                          label: '보완'),
                                    ],
                                  ),
                                ),
                                WidgetHub.dividHorizontalLow(),
                                if(p.isSupplement)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      WidgetHub.dividHorizontalLow(),
                                      Container(
                                        height: height1,
                                        alignment: Alignment.center,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); }, isDate:true, set: (index, data) {
                                              p.supplementAt = data;
                                            }, val: p.supplementAt ?? '', width: widthDateAt, key: 'wm.supplementAt',
                                                text: p.supplementAt, label: '보완일'),
                                            excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); }, isDate:true, set: (index, data) {
                                              p.supplementOverAt = data;
                                            }, val: p.supplementOverAt ?? '', width: widthDateAt, key: 'wm.supplementOverAt',
                                                text: p.supplementOverAt, label: '보완마감일'),
                                            Container( width: widthDateAt, alignment: Alignment.center,
                                              color: (p.getSupplementOverAmount() > -3 && p.getSupplementOverAmount() < 3) ?
                                              Colors.red.withOpacity(0.15) : null,
                                              child: (p.getSupplementOverAmount() > -3) ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Expanded(child: SizedBox()),
                                                  Text('마감까지  ', style: StyleT.textStyle(),),
                                                  Text('${p.getSupplementOverAmount()}일', style: StyleT.titleStyle(),),
                                                  Expanded(child: SizedBox()),
                                                  WidgetHub.dividVerticalLow(height: height1),
                                                ],
                                              ) : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Expanded(child: SizedBox()),
                                                  Text('마감일  ', style: StyleT.textStyle(),),
                                                  Text('${p.getSupplementOverAmount().abs()}일 지남', style: StyleT.titleStyle(),),
                                                  Expanded(child: SizedBox()),
                                                  WidgetHub.dividVerticalLow(height: height1),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      WidgetHub.dividHorizontalLow(),
                                      excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); }, multiLine: true, set: (index, data) {
                                        p.supplementDesc = data;
                                      }, val: p.supplementDesc ?? '', width: 600, key: 'wm.supplementDesc',
                                          text: p.supplementDesc, label: '보완내용'),
                                    ],
                                  ),
                                if(!p.isSupplement)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      WidgetHub.dividHorizontalLow(),
                                      Container(
                                        height: height1,
                                        alignment: Alignment.center,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); }, isDate:true, set: (index, data) {
                                              p.taskAt = data;
                                            }, val: p.taskAt ?? '', width: widthDateAt, key: 'wm.taskAt', text: p.taskAt, label: '업무배당일'),
                                            excelGridEditor(context, setFun: () { if(setFun != null) setFun(); setStateS(() {}); }, isDate:true, set: (index, data) {
                                              p.taskOverAt = data;
                                            }, val: p.taskOverAt ?? '', width: widthDateAt, key: 'wm.taskOverAt', text: p.taskOverAt, label: '업무마감일'),
                                            Container( width: widthDateAt, alignment: Alignment.center,
                                              color: (p.getTaskOverAmount() > -3 && p.getTaskOverAmount() < 3) ?
                                              Colors.red.withOpacity(0.15) : null,
                                              child: (p.getTaskOverAmount() > -3) ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Expanded(child: SizedBox()),
                                                  Text('마감까지  ', style: StyleT.textStyle(),),
                                                  Text('${p.getTaskOverAmount()}일', style: StyleT.titleStyle(),),
                                                  Expanded(child: SizedBox()),
                                                  WidgetHub.dividVerticalLow(height: height1),
                                                ],
                                              ) : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Expanded(child: SizedBox()),
                                                  Text('마감일  ', style: StyleT.textStyle(),),
                                                  Text('만료', style: StyleT.titleStyle(),),
                                                  Expanded(child: SizedBox()),
                                                  WidgetHub.dividVerticalLow(height: height1),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  Container(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container( height: 28,
                          child: TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                              style: StyleT.buttonStyleOutline(padding: 0, strock: 1.4, elevation: 0,
                                  color: Colors.redAccent.withOpacity(0.5)),
                              child: Row( mainAxisSize: MainAxisSize.min,
                                children: [
                                  iconStyleMini(icon: Icons.cancel),
                                  Text('취소', style: StyleT.titleStyle(),),
                                  SizedBox(width: 12,),
                                ],
                              )
                          ),
                        ),
                        SizedBox(width: 8,),
                        //Expanded(child:Container()),
                        Container( height: 28,
                          child: TextButton(
                              onPressed: () async {
                                if(saveFun != null) {
                                  await saveFun();
                                }
                                setStateS(() {});
                                Navigator.pop(context);
                              },
                              style: StyleT.buttonStyleOutline(padding: 0, strock: 1.4, elevation: 0, color: StyleT.accentColor.withOpacity(0.5)),
                              child: Row( mainAxisSize: MainAxisSize.min,
                                children: [
                                  iconStyleMini(icon: Icons.save),
                                  Text('저장하기', style: StyleT.titleStyle(),),
                                  SizedBox(width: 12,),
                                ],
                              )
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        });

    if(aa == null) aa = false;
    return aa;
  }
*/
  static dynamic showPDFtoDialog(BuildContext context, { String? path='', String? name='', Uint8List? data}) async {
    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: true,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                scrollable: true,
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.titleColor.withOpacity(0.9), width: 0.7),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: 'PDF 뷰어 시스템', ),
                content: Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: 1280,
                        height: 2048,
                        child: PdfViewer.openData(
                          data!,
                          params: PdfViewerParams(
                            layoutPages: (viewSize, pages) {
                              List<Rect> rect = [];
                              final viewWidth = viewSize.width;
                              final viewHeight = viewSize.height;
                              final maxHeight = pages.fold<double>(0.0, (maxHeight, page) => max(maxHeight, page.height));
                              final ratio = viewHeight / maxHeight;
                              var top = 0.0;
                              for (var page in pages) {
                                final width = page.width * ratio;
                                final height = page.height * ratio;
                                final left = viewWidth > viewHeight ? (viewWidth / 2) - (width / 2) : 0.0;
                                rect.add(Rect.fromLTWH(left, top, width, height));
                                top += height + 8 /* padding */;
                              }
                              return rect;
                            },
                          ),
                        ),
                      )
                    ),
                  ],
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  Row(
                    children: [
                      Expanded(child:TextButton(
                          onPressed: () async {
                            await Printing.layoutPdf(onLayout: (format) async => data);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentLowColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('다운로드', style: StyleT.titleStyle(),),
                                  SizedBox(width: 6,),
                                ],
                              )
                          )
                      ),),
                      Expanded(child:TextButton(
                          onPressed: () async {
                            await Printing.layoutPdf(onLayout: (format) async => data);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('인쇄', style: StyleT.titleStyle(),),
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

class WidgetP extends StatelessWidget {

  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};

  static Widget titleRowW(List<String> title, List<double> width, { Color? color,  bool isTitle=false, bool isM=false, List<Widget>? leaging }) {
    List<Widget> chW = [];

    for(int i = 0; i < title.length; i++) {
      if(i != 0) chW.add(WidgetT.dividViertical(height: 28));
      var w = WidgetT.excelGrid(label:title[i], width: width[i]);
      if(isTitle) w = WidgetT.excelGrid(text:title[i], width: null, alignment: Alignment.centerLeft);
      if(width[i] > 900 && isTitle == false) {
        w = Expanded(child: w);
      }
      chW.add(w);
    }

    var grc = [
      const Color(0xFF1855a5).withOpacity(0.35),
      const Color(0xFF000000).withOpacity(0.5),
    ];
    if(isM) grc = [
      const Color(0xFF1855a5).withOpacity(0.35),
      const Color(0xFF000000).withOpacity(0.5),
    ];

    if(isTitle || isM) {
      if(leaging != null) {
        chW.add(SizedBox(width: 18,));
        for(int i = 0; i < leaging.length; i++) {
          chW.add(leaging[i]);
          chW.add(SizedBox(width: 18,));
        }
      }
      return Column(
        children: [
          Container(
              decoration: StyleT.inkStyle(stroke: 0.35, color: Colors.transparent),
              child: Container( height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: grc,
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: Row(
                  children: chW,
                ),
              )
          ),
          WidgetT.dividHorizontal(size: 2)
        ],
      );
    }

    return Container(
        decoration: StyleT.inkStyle(stroke: 0.35, color: StyleT.backgroundLowColor.withOpacity(0.5)),
        child: Container( height: 28,
          child: Row(
            children: chW,
          ),
        )
    );
  }

  static pw.Widget excelGrid({ String? text, bool textLite=false, String? value,
    double? width, double? height, String? label, Color? color, Color? textColor, double? textSize }) {
    var w = pw.Container(
      width: width, height: height, alignment: pw.Alignment.center,
      color: PdfColor.fromRYB(0, 0, 0, 0),
      padding: pw.EdgeInsets.all(6),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          WidgetP.text(label ?? '', size: 10,),
          if(text != null)
            pw.SizedBox(width: 4,),

          if(!textLite)
            title(text ?? '', size: textSize),
          if(textLite)
            WidgetP.text(text ?? '', size:textSize ?? 12),
        ],
      ),
    );
    return w;
  }

  static pw.Widget title(String text, { double? size, bool bold=true, double? width }) {
    var w = pw.Text(text, style: pw.TextStyle(font: StyleT.font,
        fontSize: size ?? 10, color: PdfColor.fromInt(StyleT.titleColor.value)));
    if(width != null) return pw.Container(padding: pw.EdgeInsets.zero, alignment: pw.Alignment.center, width: width, child: w,);
    return w;
  }
  static pw.Widget text(String text, { double? size, double? width }) {
    var w = pw.Text(text, style: pw.TextStyle(font: StyleT.font,
        fontSize: size ?? 10, color: PdfColor.fromInt(StyleT.titleColor.value)));
    if(width != null) return pw.Container(padding: pw.EdgeInsets.zero, alignment: pw.Alignment.center, width: width, child: w,);
    return w;
  }

  static pw.Widget dividViertical({double? height, double? size}) {
    return pw.Container(height: height, width: 1, color: PdfColor.fromHex('#333333'),);
  }
  static pw.Widget dividHorizontal({double? width, double? size}) {
    return pw.Container(height: 1, width: size, color: PdfColor.fromHex('#333333'),);
  }

  Widget build(context) {
    return Container();
  }
}
