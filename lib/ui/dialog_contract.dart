import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/database/ledger.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/revenue.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/pdfx.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/login/auth_service.dart';
import 'package:evers/ui/dialog_revenue.dart';
import 'package:evers/ui/dialog_schedule.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../class/Customer.dart';
import 'package:http/http.dart' as http;

import '../class/schedule.dart';
import '../class/system.dart';
import '../class/transaction.dart';
import '../class/widget/button.dart';
import '../helper/aes.dart';
import '../helper/dialog.dart';
import '../helper/interfaceUI.dart';
import 'dl.dart';
import 'ex.dart';
import 'ip.dart';
import 'ux.dart';
import '../class/database/item.dart';

class DialogCT extends StatelessWidget {

  static var strok_1 = 0.7;
  static var strok_2 = 1.4;

  static var allSize = 2700.0;
  static ScrollController titleHorizontalScroll = new ScrollController();

  static Map<String, TextEditingController> textInputs = new Map();
  static Map<String, String> textOutput = new Map();
  static Map<String, bool> editInput = {};


  /// 이 함수는 계약 정보를 다이얼로그에 표시하고 작업 결과를 반환합니다.
  ///
  /// @return pu 계약정보를 작성했을경우 작성기록이 반환됩니다.
  ///            계약정보를 작성하지 않았거나 데이터베이스 기록이 실패했을 경우 null 이 반환됩니다.
  ///
  /// @Create YM
  /// @Version 1.0.0



  static dynamic selectCt(BuildContext context, { List<Contract>? contractList, }) async {
    var searchInput = TextEditingController();
    List<Contract> contractSearch = [];
    if(contractList != null) {
      contractSearch = contractList;
    }
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

  Widget build(context) {
    return Container();
  }
}