import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cell_calendar/cell_calendar.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:evers/class/system.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/pdfx.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/login/auth_service.dart';
import 'package:evers/ui/ux.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:textfield_search/textfield_search.dart';
import 'package:url_launcher/url_launcher.dart';

import '../class/database/item.dart';
import '../class/Customer.dart';
import '../class/contract.dart';
import '../class/purchase.dart';
import '../class/revenue.dart';
import '../class/schedule.dart';
import '../class/transaction.dart';
import '../ui/dialog_contract.dart';
import '../ui/dl.dart';
import '../ui/ex.dart';
import '../ui/ip.dart';
import 'aes.dart';
import 'interfaceUI.dart';
import 'pdf_view.dart';
import 'transition.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as en;

class DialogT extends StatelessWidget {

  /// 고정값 변경 불가
  static var strok_1 = 0.7;
  static var strok_2 = 1.4;

  static var allSize = 2700.0;
  static ScrollController titleHorizontalScroll = new ScrollController();

  static Map<String, TextEditingController> textInputs = new Map();
  //static Map<String, FocusNode > textInputFocus = new Map();
  static Map<String, String> textOutput = new Map();
  static Map<String, bool> editInput = {};

  static dynamic showItemSetting(BuildContext context,) async {
    var dividHeight = 6.0;

    Map<dynamic, dynamic> itemGroup = MetaT.itemGroup as Map<dynamic, dynamic>;

    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();

              List<Widget> reW = [];
              for(int i = 0; i < itemGroup.length; i++) {
                Widget w = SizedBox();
                var re = itemGroup.values.elementAt(i);
                var key = itemGroup.keys.elementAt(i);

                w = Container(
                  padding: EdgeInsets.only(bottom: 0),
                  child: TextButton(
                      onPressed: null,
                      style: StyleT.buttonStyleOutline(round: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.35, elevation: 0, padding: 0),
                      child: Container( height: 28,
                        child: Row(
                            children: [
                              WidgetT.excelGrid(label: '${key}', width: 28),
                              WidgetT.dividViertical(),
                              WidgetT.excelInput(context, '$i::품목분류그룹', width: 200, label: '태그', text: re,
                              onEdite: (i, data) { itemGroup[key] = data; } ),
                              /*TextButton(
                                  onPressed: () async {
                                    if(await DialogT.showAlertDl(context, text: '"${re}" 품목 분류 태그를 데이터베이스에서 삭제하시겠습니까?')) {
                                      await FireStoreT.updateItemMetaGP(key, '');
                                    }
                                    FunT.setStateDT();
                                  },
                                  style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                  child: Container( height: 28, width: 28,
                                    child: WidgetT.iconMini(Icons.delete),)
                              ),*/
                            ]
                        ),
                      )),
                );
                reW.add(w);
              }

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.dlColor, width: 0.35),
                    borderRadius: BorderRadius.circular(4)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: Column(
                  children: [
                    Container(
                        padding: EdgeInsets.all(6),
                        child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 28,),
                            WidgetT.title('설정'),
                            Container( height: 28, width: 28,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: StyleT.buttonStyleNone(padding: 0, round: 4, strock: 1.4, elevation: 8,
                                      color: Colors.redAccent.withOpacity(0.5)),
                                  child: WidgetT.iconMini(Icons.cancel,),
                              ),
                            ),
                          ],
                        )
                    ),
                    WidgetT.dividHorizontal(size: 0.7),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetT.title('품목분류태그', width: 100),
                        SizedBox(height: dividHeight,),
                        TextButton(
                            onPressed: null,
                            style: StyleT.buttonStyleOutline(round: 0, color: Colors.transparent, strock: 0.35, elevation: 0, padding: 0),
                            child: Column(
                              children: reW,
                            )
                        ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  WidgetT.dividHorizontal(size: 0.7),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        child:
                        Row(
                          children: [
                            Container( height: 28,
                              child: TextButton(
                                  onPressed: () async {
                                    var alert = await showAlertDl(context, title: '아이템 품목 그룹 태그');
                                    if(alert == false) {
                                      WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                                      return;
                                    }

                                    await DatabaseM.updateItemMetaGP('', '', groupAll: itemGroup);
                                    WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                                    Navigator.pop(context);
                                  },
                                  style: StyleT.buttonStyleOutline(padding: 0, round: 4, strock: 1.4, elevation: 8,
                                      color: StyleT.accentColor.withOpacity(0.5)),
                                  child: Row( mainAxisSize: MainAxisSize.min,
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
                    ],
                  )
                ],
              );
            },
          );
        });

    if(aa == null) aa = false;
    return aa;
  }

  static dynamic selectCt(BuildContext context) async {
    var searchInput = TextEditingController();
    List<Contract> contractSearch = [];
    //var _dragging = false;
    //List<XFile> _list = [];
    //late DropzoneViewController controller;
    Contract? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade700, width: 1.4),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: Column(
                  children: [
                    Container(padding: EdgeInsets.all(8), child: Text('계약처 선택창', style: StyleT.titleStyle(bold: true))),
                    WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container( height: 36, width: 500,
                                child: TextFormField(
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  textInputAction: TextInputAction.search,
                                  keyboardType: TextInputType.text,
                                  onEditingComplete: () async {
                                    contractSearch = await SystemT.searchCTMeta(searchInput.text,);
                                    FunT.setStateDT();
                                  },
                                  onChanged: (text) {
                                    FunT.setStateDT();
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(0),
                                        borderSide: BorderSide(
                                            color: StyleT.accentLowColor, width: 2)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      borderSide: BorderSide(
                                          color: StyleT.accentColor, width: 2),),
                                    filled: true,
                                    fillColor: StyleT.accentColor.withOpacity(0.07),
                                    suffixIcon: Icon(Icons.keyboard),
                                    hintText: '',
                                    contentPadding: EdgeInsets.all(6),
                                  ),
                                  controller: searchInput,
                                ),
                              ),),
                          ],
                        ),
                        SizedBox(height: 18,),
                        for(var cs in contractSearch)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context, cs);
                                },
                                style: StyleT.buttonStyleOutline(round: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 1.4, elevation: 0, padding: 0),
                                child: Container( height: 32,
                                  child: Row(
                                      children: [
                                        WidgetT.text('${cs.id}', size: 10, width: 120),
                                        WidgetT.dividViertical(),
                                        WidgetT.title('${cs.csName} / ${cs.ctName}', size: 12, width: 200),
                                        WidgetT.dividViertical(),
                                        WidgetT.title('${cs.manager}', size: 12, width: 150),
                                        WidgetT.dividViertical(),
                                        WidgetT.title('${cs.managerPhoneNumber}', size: 12, width: 100),
                                        WidgetT.dividViertical(),
                                        WidgetT.title('${cs.contractList.length}', size: 12, width: 100),
                                      ]
                                  ),
                                )),
                          ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        child:
                        Row(
                          children: [
                            Container( height: 28,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: StyleT.buttonStyleOutline(padding: 0, round: 0, strock: 1.4, elevation: 8,
                                      color: Colors.redAccent.withOpacity(0.5)),
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.iconMini(Icons.cancel),
                                      Text('닫기', style: StyleT.titleStyle(),),
                                      SizedBox(width: 12,),
                                    ],
                                  )
                              ),
                            ),
                            SizedBox(width:  8,),
                           /* Container( height: 28,
                              child: TextButton(
                                  onPressed: () async {
                                  },
                                  style: StyleT.buttonStyleOutline(padding: 0, round: 0, strock: 1.4, elevation: 8,
                                      color: StyleT.accentColor.withOpacity(0.5)),
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.iconMini(Icons.save),
                                      Text('계약추가', style: StyleT.titleStyle(),),
                                      SizedBox(width: 12,),
                                    ],
                                  )
                              ),
                            ),*/
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              );
            },
          );
        });

    return aa;
  }

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
  static dynamic showCreateCS(BuildContext context) async {
    var dividHeight = 6.0;
    //var _dragging = false;
    //List<XFile> _list = [];
    //late DropzoneViewController controller;
    Map<String, Uint8List> fileByteList = {};

    Customer cs = Customer.fromDatabase({});
    cs.bsType = '사업자';

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
                    side: BorderSide(color: Colors.grey.shade700, width: 1.4),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: Column(
                  children: [
                    Container(padding: EdgeInsets.all(8), child: Text('고객 추가', style: StyleT.titleStyle(bold: true))),
                    WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            WidgetT.dropMenu(dropMenus: ['개인', '사업자',], width: 130, label: '구분',
                              onEdite: (i, data) { cs.bsType = data; },
                              text: cs.bsType,
                            ),
                            WidgetT.dropMenu(dropMenus: ['매입', '매출', '매입/매출'], width: 130, label: '거래처분류',
                              onEdite: (i, data) { cs.csType = data; },
                              text: cs.csType,
                            ),
                          ],
                        ),
                        SizedBox(height: 18,),
                        WidgetT.textInput(context, '상호명', width: 250, label: '상호명',
                          onEdite: (i, data) { cs.businessName = data; },
                          text: cs.businessName,
                        ),
                        SizedBox(height: dividHeight,),
                        WidgetT.textInput(context, '대표이름', width: 250, label: '대표이름',
                          onEdite: (i, data) { cs.representative = data; },
                          text: cs.representative,
                        ),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            WidgetT.textInput(context, '사업자등록번호1', width: 100, label: '사업자등록번호',
                              onEdite: (i, data) { cs.businessRegistrationNumber['0'] = data; },
                              text: cs.businessRegistrationNumber['0'],
                            ),
                            SizedBox(width: dividHeight,),
                            WidgetT.textInput(context, '사업자등록번호2', width: 100,
                              onEdite: (i, data) { cs.businessRegistrationNumber['1'] = data; },
                              text: cs.businessRegistrationNumber['1'],
                            ),
                            SizedBox(width: dividHeight,),
                            WidgetT.textInput(context, '사업자등록번호3', width: 100,
                              onEdite: (i, data) { cs.businessRegistrationNumber['2'] = data; },
                              text: cs.businessRegistrationNumber['2'],
                            ),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            WidgetT.textInput(context, '팩스번호1', width: 100, label: '팩스번호',
                              onEdite: (i, data) { cs.faxNumber['0'] = data; },
                              text: cs.faxNumber['0'],
                            ),
                            SizedBox(width: dividHeight,),
                            WidgetT.textInput(context, '팩스번호2', width: 100,
                              onEdite: (i, data) { cs.faxNumber['1'] = data; },
                              text: cs.faxNumber['1'],
                            ),
                            SizedBox(width: dividHeight,),
                            WidgetT.textInput(context, '팩스번호3', width: 100,
                              onEdite: (i, data) { cs.faxNumber['2'] = data; },
                              text: cs.faxNumber['2'],
                            ),
                          ],
                        ),
                        SizedBox(height: 18,),
                        Row(
                          children: [
                            WidgetT.textInput(context, '전화번호1', width: 130, label: '전화번호',
                              onEdite: (i, data) { cs.companyPhoneNumber = data; },
                              text: cs.companyPhoneNumber,
                            ),
                            WidgetT.textInput(context, '모바일전화번호', width: 130, label: '모바일',
                              onEdite: (i, data) { cs.phoneNumber = data; },
                              text: cs.phoneNumber,
                            ),
                          ],
                        ),
                        SizedBox(height: 18,),
                        WidgetT.textInput(context, '담당자', width: 250, label: '담당자',
                          onEdite: (i, data) { cs.manager = data; },
                          text: cs.manager,
                        ),
                        SizedBox(height: dividHeight,),
                        WidgetT.textInput(context, '담당자이메일', width: 250, label: '이메일',
                          onEdite: (i, data) { cs.email = data; },
                          text: cs.email,
                        ),
                        SizedBox(height: dividHeight,),
                        WidgetT.textInput(context, '주소', width: 250, label: '주소',
                          onEdite: (i, data) { cs.address = data; },
                          text: cs.address,
                        ),
                        SizedBox(height: dividHeight,),
                        WidgetT.textInput(context, '홈페이지', width: 250, label: '홈페이지',
                          onEdite: (i, data) { cs.website = data; },
                          text: cs.website,
                        ),
                        SizedBox(height: 18,),
                        WidgetT.textInput(context, '업태', width: 200, label: '업태',
                          onEdite: (i, data) { cs.businessType = data; },
                          text: cs.businessType,
                        ),
                        SizedBox(height: dividHeight,),
                        WidgetT.textInput(context, '종목', width: 300 + dividHeight + 2, label: '종목 ( , , )',
                            onEdite: (i, data) { cs.businessItem = data.toString().split(','); },
                            text: cs.businessItem.join(', '), value: cs.businessItem.join(',')
                        ),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            WidgetT.textInput(context, '은행', width: 125 + dividHeight * 0.5, label: '계좌은행명',
                              onEdite: (i, data) { cs.account['bank'] = data; },
                              text: cs.account['bank'],
                            ),
                            WidgetT.textInput(context, '예금주', width: 125 + dividHeight * 0.5, label: '예금주',
                              onEdite: (i, data) { cs.account['user'] = data; },
                              text: cs.account['user'],
                            ),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        WidgetT.textInput(context, '계좌번호', width: 300 + dividHeight * 2, label: '계좌번호',
                          onEdite: (i, data) { cs.account['number'] = data; },
                          text: cs.account['number'],
                        ),
                         SizedBox(height: 18,),

                        WidgetT.title('메모', ),
                        SizedBox(height: 2,),
                        Row(
                          children: [
                            Expanded(child: WidgetT.textInput(context, '메모', width: 250, height: 128, isMultiLine: true,
                              onEdite: (i, data) { cs.account['memo'] = data; },
                              text: cs.account['memo'],
                            ),)
                          ],
                        ),
                        SizedBox(height: 18,),
                        Row(
                          children: [
                            WidgetT.title('파일 첨부',),
                            SizedBox(width: 12,),
                            TextButton(onPressed: () async {
                              FilePickerResult? result;
                              try {
                                result = await FilePicker.platform.pickFiles();
                              } catch (e) {
                                print(e);
                                WidgetT.showSnackBar(context, text: '파일 첨부 오류');
                              }
                              if( result != null && result.files.isNotEmpty ){
                                String fileName = result.files.first.name;
                                print(fileName);
                                Uint8List fileBytes = result.files.first.bytes!;
                                fileByteList[fileName] = fileBytes;
                                print(fileByteList[fileName]!.length);
                                FunT.setStateDT();
                              }
                            },
                              style: StyleT.buttonStyleOutline(padding: 0, round: 0, elevation: 8, strock: 1, color: StyleT.accentColor.withOpacity(0.5)),
                              child: Container(
                                  child: Row(
                                    children: [
                                      WidgetT.iconMini(Icons.file_copy_rounded),
                                      WidgetT.title('선택',),
                                      SizedBox(width: 4,),
                                    ],
                                  )),)
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        Container(
                          height: 128, width: 458, color: StyleT.accentLowColor.withOpacity(0.07),
                          padding: EdgeInsets.all(dividHeight),
                          child: Wrap(
                            runSpacing: dividHeight, spacing: dividHeight,
                            children: [
                              for(int i = 0; i < fileByteList.length; i++)
                                TextButton(
                                    onPressed: () {
                                      PDFX.showPDFtoDialog(context, data: fileByteList.values.elementAt(i), name: fileByteList.keys.elementAt(i));
                                    },
                                    style: StyleT.buttonStyleOutline(round: 0, elevation: 8, padding: 0, color: StyleT.accentLowColor.withOpacity(0.5), strock: 1),
                                    child: Container(padding: EdgeInsets.all(0), child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(width: 6,),
                                        WidgetT.title(fileByteList.keys.elementAt(i),),
                                        TextButton(
                                            onPressed: () {
                                              fileByteList.remove(fileByteList.keys.elementAt(i));
                                              FunT.setStateDT();
                                            },
                                            style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                            child: Container( height: 28, width: 28,
                                            child: WidgetT.iconMini(Icons.cancel),)
                                        ),
                                      ],
                                    ))
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: dividHeight,),
                     /*   DropTarget(
                          onDragDone: (detail) {
                            _list.addAll(detail.files);
                            setStateS(() {});
                          },
                          onDragEntered: (detail) {
                            _dragging = true;
                            setStateS(() {});
                          },
                          onDragExited: (detail) {
                            _dragging = false;
                            setStateS(() {});
                          },
                          child: Container(
                            height: 128, width: 458, padding: EdgeInsets.all(dividHeight),
                            color: _dragging ? Colors.blue.withOpacity(0.4) : StyleT.accentColor.withOpacity(0.07),
                            child: _list.isEmpty
                                ? const Center(child: Text("Drop here"))
                                : Wrap(
                              runSpacing: 6, spacing: 6,
                                  children: [
                                    for(var f in _list)
                                      TextButton(
                                        onPressed: () {
                                          PDFX.showPDFtoDialog(context, path: f.path, name: f.name);
                                        },
                                          style: StyleT.buttonStyleOutline(padding: 0, color: StyleT.accentLowColor, strock: 1),
                                          child: Container(padding: EdgeInsets.all(6), child: WidgetT.textLight(f.name,))
                                      ),
                                  ],
                                ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        child:
                        Row(
                          children: [
                            Container( height: 28,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: StyleT.buttonStyleOutline(padding: 0, round: 0, strock: 1.4, elevation: 8,
                                      color: Colors.redAccent.withOpacity(0.5)),
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.iconMini(Icons.cancel),
                                      Text('취소', style: StyleT.titleStyle(),),
                                      SizedBox(width: 12,),
                                    ],
                                  )
                              ),
                            ),
                            SizedBox(width:  8,),
                            Container( height: 28,
                              child: TextButton(
                                  onPressed: () async {
                                    var alert = await showAlertDl(context, title: cs.businessName ?? 'NULL');
                                    if(alert == false) {
                                      WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                                      return;
                                    }

                                    await DatabaseM.updateCustomer(cs, files: fileByteList,);
                                    WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                                    Navigator.pop(context);
                                  },
                                  style: StyleT.buttonStyleOutline(padding: 0, round: 0, strock: 1.4, elevation: 8,
                                      color: StyleT.accentColor.withOpacity(0.5)),
                                  child: Row( mainAxisSize: MainAxisSize.min,
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
                    ],
                  )
                ],
              );
            },
          );
        });

    if(aa == null) aa = false;
    return aa;
  }
  static dynamic selectCS(BuildContext context) async {
    var searchInput = TextEditingController();
    List<Customer> customerSearch = [];
    Customer? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade700, width: 1.4),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: Column(
                  children: [
                    Container(padding: EdgeInsets.all(8), child: Text('거래처 선택창', style: StyleT.titleStyle(bold: true))),
                    WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container( height: 36, width: 500,
                                child: TextFormField(
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  textInputAction: TextInputAction.search,
                                  keyboardType: TextInputType.text,
                                  onEditingComplete: () async {
                                    customerSearch = await SystemT.searchCSMeta(searchInput.text,);
                                    FunT.setStateDT();
                                  },
                                  onChanged: (text) {
                                    FunT.setStateDT();
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(0),
                                        borderSide: BorderSide(
                                            color: StyleT.accentLowColor, width: 2)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      borderSide: BorderSide(
                                          color: StyleT.accentColor, width: 2),),
                                    filled: true,
                                    fillColor: StyleT.accentColor.withOpacity(0.07),
                                    suffixIcon: Icon(Icons.keyboard),
                                    hintText: '',
                                    contentPadding: EdgeInsets.all(6),
                                  ),
                                  controller: searchInput,
                                ),
                              ),),
                          ],
                        ),
                        SizedBox(height: 18,),
                        for(var cs in customerSearch)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context, cs);
                                },
                                style: StyleT.buttonStyleOutline(round: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 1.4, elevation: 0, padding: 0),
                                child: Container( height: 32,
                                  child: Row(
                                      children: [
                                        WidgetT.text('${cs.id}', size: 10, width: 120),
                                        WidgetT.dividViertical(),
                                        WidgetT.title('${cs.businessName}', size: 12, width: 200),
                                        WidgetT.dividViertical(),
                                        WidgetT.title('${cs.representative}', size: 12, width: 150),
                                        WidgetT.dividViertical(),
                                        WidgetT.title('${cs.companyPhoneNumber}', size: 12, width: 100),
                                        WidgetT.dividViertical(),
                                        WidgetT.title('${cs.phoneNumber}', size: 12, width: 100),
                                      ]
                                  ),
                                )),
                          ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        child:
                        Row(
                          children: [
                            Container( height: 28,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: StyleT.buttonStyleOutline(padding: 0, round: 0, strock: 1.4, elevation: 8,
                                      color: Colors.redAccent.withOpacity(0.5)),
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.iconMini(Icons.cancel),
                                      Text('닫기', style: StyleT.titleStyle(),),
                                      SizedBox(width: 12,),
                                    ],
                                  )
                              ),
                            ),
                            SizedBox(width:  8,),
                            /* Container( height: 28,
                              child: TextButton(
                                  onPressed: () async {
                                  },
                                  style: StyleT.buttonStyleOutline(padding: 0, round: 0, strock: 1.4, elevation: 8,
                                      color: StyleT.accentColor.withOpacity(0.5)),
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.iconMini(Icons.save),
                                      Text('계약추가', style: StyleT.titleStyle(),),
                                      SizedBox(width: 12,),
                                    ],
                                  )
                              ),
                            ),*/
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              );
            },
          );
        });

    return aa;
  }


  /// 품목 선택 다이얼로그
  static dynamic selectItem(BuildContext context) async {
    var searchInput = TextEditingController();
    List<Item> items = [];

    Item? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade700, width: 1.4),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: Column(
                  children: [
                    Container(padding: EdgeInsets.all(8), child: Text('거래처 선택창', style: StyleT.titleStyle(bold: true))),
                    WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container( height: 36, width: 500,
                                child: TextFormField(
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  textInputAction: TextInputAction.search,
                                  keyboardType: TextInputType.text,
                                  onEditingComplete: () async {
                                    items = await SystemT.searchItem(searchInput.text, SystemT.items.toList());
                                    FunT.setStateDT();
                                  },
                                  onChanged: (text) {
                                    FunT.setStateDT();
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(0),
                                        borderSide: BorderSide(
                                            color: StyleT.accentLowColor, width: 2)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      borderSide: BorderSide(
                                          color: StyleT.accentColor, width: 2),),
                                    filled: true,
                                    fillColor: StyleT.accentColor.withOpacity(0.07),
                                    suffixIcon: Icon(Icons.keyboard),
                                    hintText: '',
                                    contentPadding: EdgeInsets.all(6),
                                  ),
                                  controller: searchInput,
                                ),
                              ),),
                          ],
                        ),
                        SizedBox(height: 18,),
                        for(var itemT in items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context, itemT);
                                },
                                style: StyleT.buttonStyleOutline(round: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 1.4, elevation: 0, padding: 0),
                                child: Container( height: 28,
                                  child: Row(
                                      children: [
                                        WidgetT.text('${itemT.id}', size: 10, width: 80),
                                        WidgetT.dividViertical(),
                                        WidgetT.excelGrid(text: MetaT.itemGroup[itemT.group], width: 150, label: '분류'),
                                        WidgetT.dividViertical(),
                                        WidgetT.excelGrid(text: '${itemT.name}', width: 250, label: '품명'),
                                        WidgetT.dividViertical(),
                                        WidgetT.excelGrid(text: StyleT.krwInt(SystemT.getInventoryItemCount(itemT.id)) + itemT.unit, width: 120, label: '재고량',),
                                        WidgetT.dividViertical(),
                                        WidgetT.excelGrid(text: StyleT.krwInt(SystemT.getInventoryItemCount(itemT.id) * itemT.unitPrice) + '원' , width: 120, label: '금액',),
                                        WidgetT.dividViertical(),
                                      ]
                                  ),
                                )),
                          ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        child:
                        Row(
                          children: [
                            Container( height: 28,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: StyleT.buttonStyleOutline(padding: 0, round: 0, strock: 1.4, elevation: 8,
                                      color: Colors.redAccent.withOpacity(0.5)),
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.iconMini(Icons.cancel),
                                      Text('닫기', style: StyleT.titleStyle(),),
                                      SizedBox(width: 12,),
                                    ],
                                  )
                              ),
                            ),
                            SizedBox(width:  8,),
                            /* Container( height: 28,
                              child: TextButton(
                                  onPressed: () async {
                                  },
                                  style: StyleT.buttonStyleOutline(padding: 0, round: 0, strock: 1.4, elevation: 8,
                                      color: StyleT.accentColor.withOpacity(0.5)),
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.iconMini(Icons.save),
                                      Text('계약추가', style: StyleT.titleStyle(),),
                                      SizedBox(width: 12,),
                                    ],
                                  )
                              ),
                            ),*/
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              );
            },
          );
        });

    print(aa?.name);
    return aa;
  }

  static dynamic showUserInfo(BuildContext context,) async {
    var dividHeight = 6.0;
    if(FirebaseAuth.instance.currentUser == null) return;

    var user = FirebaseAuth.instance.currentUser!;

    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade700, width: 1.4),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: Column(
                  children: [
                    SizedBox(height: 8,),
                    WidgetT.text('유저 정보', size: 10),
                    WidgetT.title('${user.email}'),
                    SizedBox(height: 8,),
                    WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(onPressed: () async {
                          FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                          FunT.setStateDT();

                          context.pop();
                          context.push('/work/u');
                        },
                          style: StyleT.buttonStyleOutline(padding: 0, round: 0, elevation: 8, strock: 1, color: StyleT.accentColor.withOpacity(0.5)),
                          child: Container(
                            padding: EdgeInsets.all(6),
                              child: Row(
                                children: [
                                  WidgetT.iconMini(Icons.file_copy_rounded),
                                  WidgetT.title('로그아웃',),
                                  SizedBox(width: 4,),
                                ],
                              )),
                        ),
                        SizedBox(height: dividHeight,),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        child:
                        Row(
                          children: [
                            Container( height: 28,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: StyleT.buttonStyleOutline(padding: 0, round: 0, strock: 1.4, elevation: 8,
                                      color: Colors.redAccent.withOpacity(0.5)),
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.iconMini(Icons.cancel),
                                      Text('취소', style: StyleT.titleStyle(),),
                                      SizedBox(width: 12,),
                                    ],
                                  )
                              ),
                            ),
                            SizedBox(width:  8,),
                            Container( height: 28,
                              child: TextButton(
                                  onPressed: null,
                                  style: StyleT.buttonStyleOutline(padding: 0, round: 0, strock: 1.4, elevation: 8,
                                      color: StyleT.accentColor.withOpacity(0.5)),
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.iconMini(Icons.save),
                                      Text('확인', style: StyleT.titleStyle(),),
                                      SizedBox(width: 12,),
                                    ],
                                  )
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              );
            },
          );
        });

    if(aa == null) aa = false;
    return aa;
  }

  static dynamic showAlertDl(BuildContext context, { String? title, String? text }) async {
    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.15),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 36,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: StyleT.dlColor.withOpacity(0), width: 0.01),
                borderRadius: BorderRadius.circular(0)),

            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.all(28),
            title: WidgetDT.dlTitleLow(context, title: '알림'),
            content: Text(text ?? '\"$title.json\" 을(를) 시스템에 저장하시겠습니까?', style: StyleT.titleStyle()),
            actionsPadding: EdgeInsets.zero,
            actions: <Widget>[
              Row(
                children: [
                  Expanded(child: TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                      child: Container(
                          color: StyleT.redA.withOpacity(0.5), height: 42,
                          child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              WidgetT.iconMini(Icons.cancel),
                              Text('취소', style: StyleT.titleStyle(),),
                              SizedBox(width: 6,),
                            ],
                          )
                      )
                  ),),
                  Expanded(child:TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);
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
              )
            ],
          );
        });

    if(aa == null) aa = false;
    return aa;
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
            contentPadding:  EdgeInsets.all(18),
            title: Container(padding: EdgeInsets.all(18), child: Text('중요 알림', style: StyleT.titleStyle(color: Colors.red, bold: true))),
            content: Text('현재 최신버전이 아닙니다.'
                '\n버전을 업데이트 해 주세요. (폴더를 복사)'
                '\nZ:태기측량/태기측량 시스템 프로그램/(버전코드)', style: StyleT.titleStyle()),
            actionsPadding: EdgeInsets.all(14),
            actions: <Widget>[
              Row(
                children: [
                  TextButton(
                    child: Text('취소', style: StyleT.titleStyle(bold: true),),
                    onPressed: () {
                      if(!force) {
                        Navigator.pop(context);
                        return;
                      }
                    },
                    style: StyleT.buttonStyleOutline(elevation: 0, color: Colors.redAccent.withOpacity(0.5) , strock: 1.4),
                  ),
                  Expanded(child:Container()),
                  TextButton(
                    child: Text('확인', style: StyleT.titleStyle(bold: true,),),
                    onPressed: () {
                      if(!force) {
                        Navigator.pop(context);
                        return;
                      }
                    },
                    style: StyleT.buttonStyleOutline(elevation: 0, color: Colors.blue.withOpacity(0.5) , strock: 1.4),
                  ),
                ],
              )
            ],
          );
        });

    if(aa == null) aa = false;
    return aa;
  }

  Widget build(context) {
    return Container();
  }
}