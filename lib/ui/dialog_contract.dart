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

  static dynamic showCreateCt(BuildContext context,) async {
    WidgetT.loadingBottomSheet(context);

    var dividHeight = 6.0;
    Map<String, Uint8List> fileByteList = {};
    Map<String, Uint8List> ctFileByteList = {};

    var vatTypeList = [ 0, 1, ];
    var vatTypeNameList = [ '포함', '별도', ];

    var ct = Contract.fromDatabase({});
    Customer currentCs = Customer.fromDatabase({});

    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();

              var allPay = 0, allPayedAmount = 0;

              List<Widget> ctW = [];
              ctW.add(WidgetUI.titleRowNone([ '', '순번', '계약일자', '품목', '', '단위', '단가', '', '메모' ], [ 28, 28, 150, 200, 28, 50, 100, 28, 999 ]),);
              if(ct.contractList.isNotEmpty) ctW.add(WidgetT.dividHorizontal(size: 0.7));
              for(int i = 0; i < ct.contractList.length; i++) {
                Widget w = SizedBox();
                var ctl = ct.contractList[i];
                Item? item = SystemT.getItem(ctl['item'] ?? '');
                var count = int.tryParse(ctl['count'] ?? '') ?? 0;
                var unitPrice = int.tryParse(ctl['unitPrice'] ?? '') ?? 0;
                var totalPrice = 0, vat = 0, supplyPrice = 0;
                if(ct.vatType == 0) { totalPrice = unitPrice * count;  vat = (totalPrice / 11).round(); supplyPrice = totalPrice - vat; }
                if(ct.vatType == 1) { vat = ((unitPrice * count) / 10).round(); totalPrice = unitPrice * count + vat;  supplyPrice = unitPrice * count; }

                w = Container( height: 28,
                    child: Row(
                      children: [
                        TextButton(
                            onPressed: () async {
                            },
                            style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                            child: Container(height: 28, width: 28,
                              child: WidgetT.iconMini(Icons.check_box_outline_blank),)
                        ),
                        WidgetT.excelGrid(label:'${i + 1}', width: 28),
                        WidgetT.excelInput(context, '$i::ctl.계약일자', width: 150,
                          onEdite: (i, data) {
                            ctl['dueAt'] = StyleT.dateEpoch(data).toString();
                          },
                          text: StyleT.dateInputFormatAtEpoch(ctl['dueAt'] ?? ''),
                        ),
                        WidgetT.excelInput(context, '$i::ctl.item', width: 200, index: i,
                          onEdite: (i, data) {
                            ctl['item'] = data;
                          },
                          text: SystemT.getItemName(ctl['item'] ?? ''),),
                        TextButton(
                          onPressed: null,
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, elevation: 0, color: Colors.transparent, strock: 1.4,),
                          child: SizedBox(
                            height: 28, width: 28,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                focusColor: Colors.transparent,
                                focusNode: FocusNode(),
                                autofocus: false,
                                customButton: WidgetT.iconMini(Icons.arrow_drop_down_circle_sharp),
                                items: SystemT.itemMaps.keys.map((item) => DropdownMenuItem<dynamic>(
                                  value: item,
                                  child: Text(
                                    SystemT.getItemName(item),
                                    style: StyleT.titleStyle(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )).toList(),
                                onChanged: (value) async {
                                  ctl['item'] = value;
                                  var ctlItem = SystemT.getItem(value);
                                  if(ctlItem != null) {
                                    ctl['unitPrice'] = ctlItem.unitPrice.toString();
                                  }
                                  print('select item uid: ' + value);
                                  await FunT.setStateDT();
                                },
                                itemHeight: 24,
                                itemPadding: const EdgeInsets.only(left: 16, right: 16),
                                dropdownWidth: 256.7,
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
                                offset: const Offset(-256 + 28, 0),
                              ),
                            ),
                          ),
                        ),
                        WidgetT.excelGrid( text: SystemT.getItemUnit(ctl['item'] ?? ''), width: 50, ),
                        WidgetT.excelInput(context, '$i::단가', width: 100, index: i,
                          onEdite: (i, data) {
                            var a = int.tryParse(data);
                            if(a == null) ctl['unitPrice'] = '';
                            else ctl['unitPrice'] = a.toString();
                          },
                          text: StyleT.krw(unitPrice.toString()), value: unitPrice.toString(),
                        ),
                        TextButton(
                        onPressed: () {
                          if(item == null) return;
                          ctl['unitPrice'] = item.unitPrice.toString();
                          FunT.setStateDT();
                        }, style: StyleT.buttonStyleNone(color: Colors.transparent, padding: 0, elevation: 0),
                            child: WidgetT.iconMini(Icons.link, size: 28)),
                        Expanded(child: WidgetT.excelInput(context, '$i::ctl.memo', index: i,
                          onEdite: (i, data) {
                          ctl['memo'] = data;
                          },
                          text: ctl['memo'], width: 200,),),
                        TextButton(
                            onPressed: () {
                              ct.contractList.removeAt(i);
                              FunT.setStateDT();
                            }, style: StyleT.buttonStyleNone(color: Colors.transparent, padding: 0, elevation: 0),
                            child: WidgetT.iconMini(Icons.delete, size: 28)),
                      ],
                    ));
                ctW.add(w);
                ctW.add(WidgetT.dividHorizontal(size: 0.35));
              }


              var dividCol = SizedBox(height: dividHeight * 8,);
              var gridStyle = StyleT.inkStyle(round: 8, color: Colors.black.withOpacity(0.03), stroke: 0.7, strokeColor: StyleT.titleColor.withOpacity(0.35));

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.titleColor.withOpacity(0.0), width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '계약정보',
                  onSave:  () async {
                    var alert = await DialogT.showAlertDl(context, title: ct.csUid ?? 'NULL');
                    if(alert == false) {
                      WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                      return;
                    }

                    await DatabaseM.updateContract(ct, files: fileByteList, ctFiles: ctFileByteList);
                    WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                    Navigator.pop(context);
                  },),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(dividHeight * 3),
                    width: 1280,
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetT.title('계약상세 정보', size: 14),
                        SizedBox(height: dividHeight,),
                        Container( decoration: gridStyle,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Column(children: [
                              Container( height: 28,
                                child: Row(
                                    children: [
                                      WidgetEX.excelTitle(width: 150, text: '계약명',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'df계약명', width: 300,
                                        onEdite: (i, data) { ct.ctName = data; },
                                        text: ct.ctName,
                                      ),
                                      WidgetT.dividViertical(),
                                      WidgetEX.excelTitle(width: 150, text: '거래처',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'df거래처', width: 250,
                                        onEdite: (i, data) async {
                                        if(ct.csName == data) return;
                                        ct.csName = data;
                                        Customer? cs = await DialogT.selectCS(context);
                                        FunT.setStateD = () { setStateS(() {}); };
                                        if(cs != null) {
                                          ct.csUid = cs.id;
                                          currentCs = cs;
                                        }
                                        },
                                        text: currentCs.businessName,
                                      ),
                                      //WidgetT.excelGrid(width: 250, text: SystemT.getCSName(ct.csUid),),
                                    ]
                                ),
                              ),
                              WidgetT.dividHorizontal(size: 0.35),
                              Container( height: 28,
                                child: Row(
                                    children: [
                                      WidgetEX.excelTitle(width: 150, text: '구매부서',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'df구매부서', width: 300,
                                        onEdite: (i, data) { ct.purchasingDepartment = data; },
                                        text: ct.purchasingDepartment,
                                      ),
                                      WidgetT.dividViertical(),
                                      WidgetEX.excelTitle(width: 150, text: '담당자',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'df담당자', width: 250, label: '담당자',
                                        onEdite: (i, data) { ct.manager = data; },
                                        text: ct.manager,
                                      ),
                                      WidgetT.dividViertical(),
                                      WidgetEX.excelTitle(width: 150, text: '연락처',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'df연락처', width: 250, label: '연락처',
                                        onEdite: (i, data) { ct.managerPhoneNumber = data; },
                                        text: ct.managerPhoneNumber,),
                                    ]
                                ),
                              ),
                              WidgetT.dividHorizontal(size: 0.35),
                              Container( height: 28,
                                child: Row(
                                    children: [
                                      WidgetEX.excelTitle(width: 150, text: '납품지주소',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'df납품지주소', width: 300,
                                        onEdite: (i, data) { ct.workSitePlace = data; },
                                        text: ct.workSitePlace,
                                      ),
                                      WidgetT.dividViertical(),
                                      WidgetEX.excelTitle(width: 150, text: '계약일자',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'df계약일자', width: 250, label: '계약일자',
                                        onEdite: (i, data) { ct.contractAt = StyleT.dateEpoch(data); },
                                        text: StyleT.dateInputFormatAtEpoch(ct.contractAt.toString()),
                                      ),
                                    ]
                                ),
                              ),
                              WidgetT.dividHorizontal(size: 0.35),
                              Container( padding: EdgeInsets.all(0),
                                child: IntrinsicHeight(
                                  child: Row(
                                      children: [
                                        WidgetEX.excelTitle(width: 150, text: '메모',),
                                        WidgetT.dividViertical(),
                                        Expanded(child: WidgetTF.textTitInput(context, '메모', isMultiLine: true, textSize: 12,
                                          onEdite: (i, data) { ct.memo = data; },
                                          text: ct.memo,
                                        ),)
                                      ]
                                  ),
                                ),
                              ),
                              WidgetT.dividHorizontal(size: 0.35),
                              Container(
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        SizedBox(width: dividHeight * 2, height: 32),
                                        WidgetT.text('계약서 첨부파일', size: 10),
                                        SizedBox(width: dividHeight,),
                                        Expanded(
                                            flex: 3,
                                            child: Container( padding: EdgeInsets.all(dividHeight), child:Wrap(
                                              runSpacing: dividHeight, spacing: dividHeight,
                                              children: [
                                                for(int i = 0; i < ct.contractFiles.length; i++)
                                                  InkWell(
                                                      onTap: () async {
                                                        var downloadUrl = ct.contractFiles.values.elementAt(i);
                                                        var fileName = ct.contractFiles.keys.elementAt(i);
                                                        PdfManager.OpenPdf(downloadUrl, fileName);
                                                      },
                                                      child: Container(
                                                          decoration: StyleT.inkStyle(stroke: 0.35, round: 8, color: StyleT.accentLowColor.withOpacity(0.05)),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              SizedBox(width: 6,),
                                                              WidgetT.title(ct.contractFiles.keys.elementAt(i),),
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
                                                for(int i = 0; i < ctFileByteList.length; i++)
                                                  InkWell(
                                                      onTap: () {
                                                        PDFX.showPDFtoDialog(context, data: ctFileByteList.values.elementAt(i), name: ctFileByteList.keys.elementAt(i));
                                                      },
                                                      child: Container(
                                                          decoration: StyleT.inkStyle(stroke: 0.35, round: 8, color: StyleT.accentLowColor.withOpacity(0.05)),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              SizedBox(width: 6,),
                                                              WidgetT.title(ctFileByteList.keys.elementAt(i),),
                                                              TextButton(
                                                                  onPressed: () {
                                                                    ctFileByteList.remove(ctFileByteList.keys.elementAt(i));
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
                                            ), )),
                                        WidgetT.dividViertical(),
                                        SizedBox(width: dividHeight * 2,),
                                        WidgetT.text('추가 첨부파일', size: 10),
                                        SizedBox(width: dividHeight,),
                                        Expanded(
                                            flex: 7,
                                            child: Container(
                                              padding: EdgeInsets.all(dividHeight),
                                              child: Wrap(
                                                runSpacing: dividHeight, spacing: dividHeight * 3,
                                                children: [
                                                  for(int i = 0; i < ct.filesMap.length; i++)
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                            decoration: StyleT.inkStyle(stroke: 0.35, round: 8, color: StyleT.redA.withOpacity(0.05)),
                                                            child: WidgetTF.textInputButton(context, '$i::fx.제목', width: 100, index: i, label: '제목',
                                                                onEdite: (i, data) {
                                                                  if(ct.filesDetail[ct.filesMap.keys.elementAt(i)] == null)
                                                                    ct.filesDetail[ct.filesMap.keys.elementAt(i)] = {};
                                                                  ct.filesDetail[ct.filesMap.keys.elementAt(i)]['title'] = data;
                                                                },
                                                                text: ct.getFileTitle(ct.filesMap.keys.elementAt(i))
                                                            )
                                                        ),
                                                        SizedBox(width: dividHeight * 0.5),
                                                        InkWell(
                                                            onTap: () async {
                                                              var downloadUrl = ct.filesMap.values.elementAt(i);
                                                              var fileName = ct.getFileName(ct.filesMap.keys.elementAt(i));
                                                              PdfManager.OpenPdf(downloadUrl, fileName);
                                                            },
                                                            child: Container(
                                                                decoration: StyleT.inkStyle(stroke: 0.35, round: 8, color: StyleT.accentLowColor.withOpacity(0.05)),
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    SizedBox(width: 6,),
                                                                    WidgetT.title(ct.getFileName(ct.filesMap.keys.elementAt(i)),),
                                                                    TextButton(
                                                                        onPressed: () {
                                                                          WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
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
                                                  for(int i = 0; i < fileByteList.length; i++)
                                                    Row(
                                                      children: [
                                                        Container(
                                                            decoration: StyleT.inkStyle(stroke: 0.35, round: 8, color: StyleT.redA.withOpacity(0.05)),
                                                            child: WidgetTF.textInputButton(context, '$i::fxl.제목', width: 100, index: i, label: '제목',
                                                                onEdite: (i, data) {
                                                                  if(ct.filesDetail[fileByteList.keys.elementAt(i)] == null)
                                                                    ct.filesDetail[fileByteList.keys.elementAt(i)] = {};
                                                                  ct.filesDetail[fileByteList.keys.elementAt(i)]['title'] = data;
                                                                },
                                                                text: ct.getFileTitle(fileByteList.keys.elementAt(i))
                                                            )
                                                        ),
                                                        SizedBox(width: dividHeight * 0.5),
                                                        InkWell(
                                                            onTap: () {
                                                              PDFX.showPDFtoDialog(context, data: fileByteList.values.elementAt(i), name: fileByteList.keys.elementAt(i));
                                                            },
                                                            child: Container(
                                                                decoration: StyleT.inkStyle(stroke: 0.35, round: 8, color: StyleT.accentLowColor.withOpacity(0.05)),
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    SizedBox(width: 6,),
                                                                    WidgetT.title(ct.getFileName(fileByteList.keys.elementAt(i)),),
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
                                                ],
                                              ),)),
                                      ],
                                    ),
                                  )
                              ),
                            ],),
                          ),),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            TextButton(
                                onPressed: () async {
                                  FilePickerResult? result;
                                  try {
                                    result = await FilePicker.platform.pickFiles();
                                  } catch (e) {
                                    WidgetT.showSnackBar(context, text: '파일선택 오류');
                                    print(e);
                                  }
                                  FunT.setStateD = () { setStateS(() {}); };
                                  if(result != null){
                                    WidgetT.showSnackBar(context, text: '파일선택');
                                    if(result.files.isNotEmpty) {
                                      String fileName = result.files.first.name;
                                      print(fileName);
                                      Uint8List fileBytes = result.files.first.bytes!;
                                      ctFileByteList[fileName] = fileBytes;
                                      print(ctFileByteList[fileName]!.length);
                                    }
                                  }
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                                child: Container(
                                    height: 28,
                                    child: Row(
                                      children: [
                                        WidgetT.iconMini(Icons.file_copy_rounded),
                                        WidgetT.title('계약서 파일 선택',),
                                        SizedBox(width: 6,),
                                      ],
                                    ))
                            ),
                            SizedBox(width: dividHeight,),
                            TextButton(
                                onPressed: () async {
                                  FilePickerResult? result;
                                  try {
                                    result = await FilePicker.platform.pickFiles();
                                  } catch (e) {
                                    WidgetT.showSnackBar(context, text: '파일선택 오류');
                                    print(e);
                                  }
                                  FunT.setStateD = () { setStateS(() {}); };
                                  if(result != null){
                                    WidgetT.showSnackBar(context, text: '파일선택');
                                    if(result.files.isNotEmpty) {
                                      String fileName = SystemT.generateRandomString(8); //result.files.first.name;
                                      print(fileName);
                                      Uint8List fileBytes = result.files.first.bytes!;
                                      fileByteList[fileName] = fileBytes;
                                      ct.filesDetail[fileName] = {
                                        'date': DateTime.now().microsecondsSinceEpoch,
                                        'title': '',
                                        'name': result.files.first.name,
                                      };
                                      print(fileByteList[fileName]!.length);
                                    }
                                  }
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                                child: Container(
                                    height: 28,
                                    child: Row(
                                      children: [
                                        WidgetT.iconMini(Icons.file_copy_rounded),
                                        WidgetT.title('파일선택',),
                                        SizedBox(width: 6,),
                                      ],
                                    ))
                            ),
                          ],
                        ),
                        SizedBox(height: dividHeight,),

                        dividCol,
                        WidgetT.title('계약내용', size: 14),
                        SizedBox(height: dividHeight,),
                        Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: ctW,)),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            TextButton(onPressed: () async {
                              ct.contractList.add({ 'dueAt': DateTime.now().microsecondsSinceEpoch.toString(), });
                              FunT.setStateDT();
                            },
                              style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                                  color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                              child: Container(
                                  child: Row(
                                    children: [
                                      WidgetT.iconMini(Icons.add, size: 28),
                                      WidgetT.title('계약 추가',),
                                      SizedBox(width: 6,),
                                    ],
                                  )),),
                            SizedBox(width: dividHeight,),
                            Row(
                              children: [
                                WidgetT.title('부가세 설정', width: 100 ),
                                for(var v in vatTypeList)
                                  Container(
                                    padding: EdgeInsets.only(right: dividHeight),
                                    child: TextButton(
                                        onPressed: () {
                                          ct.vatType = v;
                                          FunT.setStateDT();
                                        },
                                        style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                                            color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                                        child: Container(padding: EdgeInsets.all(0), child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if(ct.vatType != v)
                                              Container( height: 28, width: 28,
                                                child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                                            if(ct.vatType == v)
                                              Container( height: 28, width: 28,
                                                child: WidgetT.iconMini(Icons.check_box),),
                                            WidgetT.title('부가세 ' + vatTypeNameList[v] ),
                                            SizedBox(width: 6,),
                                          ],
                                        ))
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child:TextButton(
                            onPressed:  () async {
                              if(ct.ctName == '') {
                                WidgetT.showSnackBar(context, text: '계약명을 입력해 주세요.'); return;
                              }
                              if(ct.csUid == '') {
                                WidgetT.showSnackBar(context, text: '거래처를 선택해 주세요.'); return;
                              }
                              var alert = await DialogT.showAlertDl(context, title: ct.csUid ?? 'NULL');
                              if(alert == false) {
                                WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                                return;
                              }

                              await DatabaseM.updateContract(ct, files: fileByteList, ctFiles: ctFileByteList);
                              WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                              Navigator.pop(context);
                            },
                            style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                            child: Container(
                                color: StyleT.accentColor.withOpacity(0.5), height: 42,
                                child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    WidgetT.iconMini(Icons.check_circle),
                                    Text('신규 게약 추가', style: StyleT.titleStyle(),),
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