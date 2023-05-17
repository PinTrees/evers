import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cell_calendar/cell_calendar.dart';
import 'package:cross_file/cross_file.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_cs.dart';
import 'package:evers/class/component/comp_item.dart';
import 'package:evers/class/system.dart';
import 'package:evers/class/system/search.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/pdfx.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/login/auth_service.dart';
import 'package:evers/ui/dialog_item.dart';
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

  /// 이 함수는 계약목록 선택창 위젯을 반환합니다.
  /// 계약 검색창을 표시하려면 반드시 이 함수를 호출해야 합니다.
  static dynamic selectCt(BuildContext context) async {
    var searchInput = TextEditingController();
    List<Contract> contractSearch = [];
    Contract? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.15),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {

              List<Widget> ctWidgets = [];
              for(int i = 0; i < contractSearch.length; i++) {
                var ct = contractSearch[i];
                ctWidgets.add(CompContract.tableUISearch(
                    context, ct, index: i + 1,
                  onTap: () {
                    Navigator.pop(context, ct);
                  }
                ));
                ctWidgets.add(WidgetT.dividHorizontal(size: 0.35));
              }

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.withOpacity(0.7), width: 1.4),
                    borderRadius: BorderRadius.circular(10)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                actionsPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: "계약 선택창"),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(12), width: 600,
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 36,
                                child: TextFormField(
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  textInputAction: TextInputAction.search,
                                  keyboardType: TextInputType.text,
                                  onEditingComplete: () async {
                                    contractSearch = await SystemT.searchCTMeta(searchInput.text,);
                                    setStateS(() {});
                                  },
                                  onChanged: (text) {
                                    setStateS(() {});
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
                            ButtonT.Icon(
                              icon: Icons.search,
                              onTap: () async {
                                contractSearch = await SystemT.searchCTMeta(searchInput.text,);
                                setStateS(() {});
                              }
                            )
                          ],
                        ),
                        SizedBox(height: 6 * 4,),

                        TextT.Title(text: "검색 목록"),
                        SizedBox(height: 6,),
                        CompContract.tableHeaderSearch(),
                        Column(children: ctWidgets,),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });

    return aa;
  }

  /// 이 함수는 거래처 선택창 위젯을 반환합니다.
  /// 거래처 검색창을 표시하려면 반드시 이 함수를 호출해야 합니다.
  static dynamic selectCS(BuildContext context) async {
    var searchInput = TextEditingController();
    List<Customer> customerList = [];
    Customer? result = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.15),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {

              List<Widget> searchCsWidgets = [];
              int index = 0;
              for(var cs in customerList) {
                searchCsWidgets.add(CompCS.tableUISearch(context, cs,
                    index: index++,
                    onTap: () {
                      Navigator.pop(context, cs);
                    }
                ));
                searchCsWidgets.add(WidgetT.dividHorizontal(size: 0.35));
              }

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.withOpacity(0.7), width: 1.4),
                    borderRadius: BorderRadius.circular(10)),
                titlePadding: EdgeInsets.zero,
                actionsPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,

                title: WidgetDT.dlTitle(context, title: "거래처 검색창"),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(18), width: 600,
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 36,
                                child: TextFormField(
                                  autofocus: true,
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  textInputAction: TextInputAction.search,
                                  keyboardType: TextInputType.text,
                                  onEditingComplete: () async {
                                    await SystemT.searchCSMeta(searchInput.text,);
                                    customerList = await Search.searchCS();
                                    setStateS(() {});
                                  },
                                  onChanged: (text) {
                                    setStateS(() {});
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
                              ),
                            ),
                            ButtonT.Icon(
                                icon: Icons.search,
                                onTap: () async {
                                  if(searchInput.text == '') { WidgetT.showSnackBar(context, text: "검색어를 입력해 주세요."); return; }
                                  await SystemT.searchCSMeta(searchInput.text,);
                                  customerList = await Search.searchCS();
                                  setStateS(() {});
                                }
                            )
                          ],
                        ),
                        SizedBox(height: 6 * 4,),

                        TextT.Title(text: "검색 목록"),
                        SizedBox(height: 6,),
                        CompCS.tableHeaderSearch(),
                        Column(children: searchCsWidgets,),
                      ],
                    ),
                  ),
                ),
                actions: [
                ],
              );
            },
          );
        });

    return result;
  }


  /// 이 함수는 품목 검색 및 선택창 위젯을 반환합니다.
  /// 품목 검색창을 표시하려면 반드시 이 함수를 호출해야 합니다.
  static dynamic selectItem(BuildContext context) async {
    var searchInput = TextEditingController();
    List<Item> itemList = [];

    Item? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.15),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {

              List<Widget> searchWidets = [];
              int index = 1;
              for(var item in itemList) {
                searchWidets.add(CompItem.tableUISearch(context, item,
                  index: index++,
                  onTap: () {
                    Navigator.pop(context, item);
                  }
                ));
                searchWidets.add(WidgetT.dividHorizontal(size: 0.35));
              }

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.withOpacity(0.7), width: 1.4),
                    borderRadius: BorderRadius.circular(10)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: "품목 선택창"),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(12), width: 600,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container( height: 36,
                                child: TextFormField(
                                  autofocus: true,
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  textInputAction: TextInputAction.search,
                                  keyboardType: TextInputType.text,
                                  onEditingComplete: () async {
                                    if(searchInput.text == "") { WidgetT.showSnackBar(context, text: "검색어를 입력해 주세요."); return; }
                                    itemList = await SystemT.searchItem(searchInput.text, SystemT.itemMaps.values.toList());
                                    setStateS(() {});
                                  },
                                  onChanged: (text) {
                                    setStateS(() {});
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
                            ButtonT.Icon(
                              icon: Icons.search,
                              onTap: () async {
                                if(searchInput.text == "") { WidgetT.showSnackBar(context, text: "검색어를 입력해 주세요."); return; }
                                itemList = await SystemT.searchItem(searchInput.text, SystemT.itemMaps.values.toList());
                                setStateS(() {});
                              }
                            )
                          ],
                        ),
                        SizedBox(height: 6 * 4,),

                        TextT.Title(text: "품목 검색 목록"),
                        SizedBox(height: 6,),
                        CompItem.tableHeaderSearch(),
                        Column(children: searchWidets,),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
              );
            },
          );
        });
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