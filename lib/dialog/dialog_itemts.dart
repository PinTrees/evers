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
import '../helper/dialog.dart';
import '../helper/firebaseCore.dart';
import '../helper/interfaceUI.dart';
import '../helper/pdfx.dart';
import '../class/database/item.dart';

import 'package:http/http.dart' as http;

import '../ui/dialog_contract.dart';
import '../ui/dl.dart';
import '../ui/ux.dart';


class DialogItemTrans extends StatelessWidget {

  static dynamic showCreate(BuildContext context, { String? ctUid }) async {
    var dividHeight = 6.0;

    var vatTypeList = [ 0, 1, ];
    var vatTypeNameList = [ '포함', '별도', ];
    var currentVatType = 0;
    var payment = '매출';
    var payType = '';


    List<ItemTS> itemTsList = [];

    Contract ct = Contract.fromDatabase({});

    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();


              List<Widget> widgetitslist = [];

              itemTsList.forEach((element) {

              });


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
                title: WidgetDT.dlTitle(context, title: '매출 추가', ),
                content: SingleChildScrollView(
                  child: Container(
                    width: 1536,
                    padding: EdgeInsets.all(dividHeight * 3),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetT.title('매출목록', size: StyleT.subTitleSize),
                        SizedBox(height: dividHeight,),
                        Container( child: Column(children: widgetitslist,),),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  FunT.setStateDT();
                                },
                                child: Container(
                                    height: 36, alignment: Alignment.center,
                                    padding: EdgeInsets.all(0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        WidgetT.iconMini(Icons.add_box, size: 28),
                                        WidgetT.title('매출 추가', size: 14),
                                        SizedBox(width: 6,),
                                      ],
                                    ))
                            ),
                            SizedBox(width: dividHeight * 8,),
                            WidgetT.title('부가세', size: 12 ),
                            SizedBox(width: dividHeight,),
                            for(var v in vatTypeList)
                              Container(
                                child: InkWell(
                                    onTap: () {
                                      currentVatType = v;
                                      FunT.setStateDT();
                                    },
                                    child: Container(
                                        height: 36,
                                        padding: EdgeInsets.all(dividHeight), alignment: Alignment.center,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(width: dividHeight,),
                                            WidgetT.titleT('' + vatTypeNameList[v], size: 14,
                                              color: (currentVatType == v) ? StyleT.titleColor : StyleT.textColor.withOpacity(0.35),
                                            ),
                                            SizedBox(width: dividHeight,),
                                          ],
                                        ))
                                ),
                              ),
                          ],
                        ),

                        divCol,
                        WidgetT.title('지불관련', size: StyleT.subTitleSize),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  payment = '매출';
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                                    color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                                child: Container(padding: EdgeInsets.all(0), child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if(payment != '매출')
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                                    if(payment == '매출')
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box),),
                                    WidgetT.title('매출만'),
                                    SizedBox(width: 6,),
                                  ],
                                ))
                            ),
                            SizedBox(width: dividHeight,),
                            TextButton(
                                onPressed: () {
                                  payment = '즉시';
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                                    color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                                child: Container(padding: EdgeInsets.all(0), child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if(payment != '즉시')
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                                    if(payment == '즉시')
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box),),
                                    WidgetT.title('수금추가'),
                                    SizedBox(width: 6,),
                                  ],
                                ))
                            ),

                            if(payment == '즉시')
                              Row(
                                children: [
                                  WidgetT.dropMenuMapD(dropMenuMaps: SystemT.accounts, width: 130, label: '구분',
                                    onEdite: (i, data) {
                                      payType = data;
                                      print('select account: ' + payType);
                                    },
                                    text: (SystemT.accounts[payType] == null) ? '선택안됨' : SystemT.accounts[payType]!.name,
                                  ),
                                  SizedBox(width: dividHeight,),
                                  WidgetT.text('즉시수금 시 적요는 품목명으로 추가됩니다.', size: 10),
                                ],
                              ),
                          ],
                        ),
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
                            /// (***)
                            onPressed: () async {
                              itemTsList.forEach((element) async {
                                /// org값 반드시 첨부
                                await element.update();
                              });
                            },
                            style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                            child: Container(
                                color: StyleT.accentColor.withOpacity(0.5), height: 42,
                                child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    WidgetT.iconMini(Icons.check_circle),
                                    Text('신규 입출기록 추가', style: StyleT.titleStyle(),),
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

  /// 매입 개별 수정 창
  static dynamic showInfoPu(BuildContext context, { Purchase? org }) async {
    var dividHeight = 6.0;
    Map<String, Uint8List> fileByteList = {};
    Contract ct = Contract.fromDatabase({});
    Customer? cs;

    var isContractLinking = false;

    var vatTypeList = [ 0, 1, ];
    var vatTypeNameList = [ '포함', '미포함', ];

    var pu = Purchase.fromDatabase({});
    pu.purchaseAt = DateTime.now().microsecondsSinceEpoch;
    if(org != null) {
      var jsonString = jsonEncode(org.toJson());
      var json = jsonDecode(jsonString);
      pu = Purchase.fromDatabase(json);

      if (pu.csUid != '') cs = await DatabaseM.getCustomerDoc(pu.csUid);
      if (pu.ctUid != '') { ct = await DatabaseM.getContractDoc(pu.ctUid); isContractLinking = true;  }
    }

    Purchase? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();

              List<Widget> widgetsPu = [];
              widgetsPu.add( WidgetUI.titleRowNone([ '', '매출일자', '품목', '단위', '수량', '단가', '공급가액',  'VAT', '합계', '메모', '', ],
                [ 28, 150, 200 + 28 * 2, 50, 100, 100 + 28, 150, 100, 150, 200, 0], ));
              widgetsPu.add(WidgetT.dividHorizontal(size: 0.7));

              var item = SystemT.getItem(pu.item) ?? Item.fromDatabase({});

              var w = Column(
                children: [
                  Container( height: 36,
                    child: Row(
                        children: [
                          WidgetT.title('', width: 28),
                          WidgetT.excelInput(context, 'pu.info::매출일자', width: 150, label: '매출일자',
                            onEdite: (i, data) { pu.purchaseAt = StyleT.dateEpoch(data); },
                            text: StyleT.dateInputFormatAtEpoch(pu.purchaseAt.toString()),
                          ),
                          WidgetT.excelInput(context, 'pu.info::품목', width: 200, label: '품목',
                              onEdite: (i, data) {
                                var item = SystemT.getItem(pu.item);
                                if (item == null) { pu.item = data; return; }
                                if (item.name == data) { return; }
                                pu.item = data;
                              },
                              text: SystemT.getItemName(pu.item), value: SystemT.getItemName(pu.item)),
                          TextButton(
                              onPressed: () async {
                                Item? item = await DialogT.selectItem(context);
                                FunT.setStateD = () { setStateS(() {}); };
                                if(item != null) {
                                  pu.item = item.id;
                                  pu.unitPrice = item.unitPrice;
                                }
                                FunT.setStateDT();
                              },
                              style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                              child: Container( height: 28, width: 28,
                                child: WidgetT.iconMini(Icons.add_box),)
                          ),
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
                                    var item = SystemT.getItem(value);
                                    if(item != null) {
                                      pu.item = item.id;
                                      pu.unitPrice = item.unitPrice;
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
                          WidgetT.excelGrid(label: '단위', text:item.unit, width: 50),
                          WidgetT.excelInput(context, 'pu.info::수량', width: 100, label: '수량',
                              onEdite: (i, data) {
                                pu.count = int.tryParse(data) ?? 0;
                              },
                              text: StyleT.krw(pu.count.toString()), value: pu.count.toString()),
                          WidgetT.excelInput(context, 'pu.info::단가', width: 100, label: '단가',
                            onEdite: (i, data) {
                              pu.unitPrice = int.tryParse(data) ?? 0;
                            },
                            text: StyleT.krwInt(pu.unitPrice), value: pu.unitPrice.toString(),),
                          TextButton(
                            onPressed: () async {
                              pu.unitPrice = item.unitPrice;
                              FunT.setStateDT();
                            },
                            style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                            child: (pu.unitPrice == item.unitPrice) ? WidgetT.iconMini(Icons.link, size: 28) : WidgetT.iconMini(Icons.link_off, size: 28) ,
                          ),
                          WidgetT.excelGrid(width: 150, label: '공급가액', text: StyleT.krw(pu.supplyPrice.toString()),),
                          WidgetT.excelGrid( width: 100, label: 'VAT', text: StyleT.krw(pu.vat.toString()), ),
                          WidgetT.excelGrid(width: 150,label: '합계', text: StyleT.krw(pu.totalPrice.toString()),),
                          WidgetT.excelInput(context, 'pu.info::메모', width: 200, label: '메모',
                            onEdite: (i, data) { pu.memo  = data ?? ''; },
                            text: pu.memo,
                          ),
                          InkWell(
                              onTap: () async {
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
                                    fileByteList[fileName] = fileBytes;
                                    print(fileByteList[fileName]!.length);
                                  }
                                }
                                FunT.setStateDT();
                              },
                              child: Container( height: 36, width: 36,
                                child: WidgetT.iconMini(Icons.file_copy_rounded),)
                          ),
                          InkWell(
                              onTap: () async {
                                if(!await DialogT.showAlertDl(context, text:'삭제하시겠습니까?')) {
                                  WidgetT.showSnackBar(context, text: '취소됨');
                                  return;
                                }

                                WidgetT.loadingBottomSheet(context);
                                await DatabaseM.deletePu(pu);
                                Navigator.pop(context);

                                WidgetT.showSnackBar(context, text: '삭제됨');
                                Navigator.pop(context, pu);
                              },
                              child: Container( height: 36, width: 36,
                                child: WidgetT.iconMini(Icons.delete),)
                          ),
                        ]
                    ),
                  ),
                  WidgetT.dividHorizontal(size: 0.35),
                  Container(
                    height: 36 + dividHeight * 1,
                    child: Row(
                        children: [
                          WidgetT.excelGrid( width: 178, label: '거래명세서 첨부파일', ),
                          WidgetT.dividViertical(),
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
                                    for(int i = 0; i < fileByteList.length; i++)
                                      InkWell(
                                          onTap: () {
                                            PDFX.showPDFtoDialog(context, data: fileByteList.values.elementAt(i), name: fileByteList.keys.elementAt(i));
                                          },
                                          child: Container(
                                              decoration: StyleT.inkStyle(round: 8, stroke: 1,),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  WidgetT.iconMini(Icons.file_copy_rounded, size: 28),
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
                                ),)),
                        ]
                    ),
                  ),
                ],
              );
              widgetsPu.add(w);

              var widgetPU = Container(
                decoration: StyleT.inkStyle(color: Colors.black.withOpacity(0.02), stroke: 2, strokeColor: Colors.grey.withOpacity(0.35)),
                child: Column(children: widgetsPu,  ),
              );

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
                        if(!isContractLinking) Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WidgetT.title('거래처', size: 18),
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
                        if(isContractLinking) Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WidgetT.title('계약명', size: 18),
                            SizedBox(height: dividHeight,),
                            Container(
                                height: 36, width: 250, alignment: Alignment.center,
                                decoration: StyleT.inkStyle(color: Colors.black.withOpacity(0.02), stroke: 2, strokeColor: Colors.grey.withOpacity(0.35)),
                                child: Row( mainAxisSize: MainAxisSize.min,
                                  children: [
                                    WidgetT.title(ct.ctName, width: 250),
                                  ],
                                )),
                          ],
                        ),
                        SizedBox(height: dividHeight * 8,),

                        WidgetT.title('매입정보', size: 18),
                        SizedBox(height: dividHeight,),
                        widgetPU,
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
                            if(cs == null) { WidgetT.showSnackBar(context, text: '거래처를 선택해 주세요.'); return; }
                            if(!await DialogT.showAlertDl(context, text: '매입개별정보를 저장하시겠습니까?')) {
                              WidgetT.showSnackBar(context, text: '저장 취소됨');
                              return;
                            }

                            WidgetT.loadingBottomSheet(context, text: '저장중');
                            await DatabaseM.updatePurchase(pu, org: org, files: fileByteList);

                            WidgetT.showSnackBar(context, text: '저장됨');
                            Navigator.pop(context); Navigator.pop(context, pu);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('매입 저장', style: StyleT.titleStyle(),),
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

  /// 매출 개별 수정 창
  static dynamic showInfoRe(BuildContext context, { Revenue? org }) async {
    var dividHeight = 6.0;
    Contract ct = Contract.fromDatabase({});
    Customer cs = Customer.fromDatabase({});

    Revenue re = Revenue.fromDatabase({});
    Revenue? org_check;
    if(org != null) {
      org_check = await DatabaseM.getResDoc(org.id);
      if(org_check == null) { return; }
      if(org_check.state == 'DEL') { return; }

      var jsonStr = jsonEncode(org_check.toJson());
      var json = jsonDecode(jsonStr);
      re = Revenue.fromDatabase(json);

      cs = await DatabaseM.getCustomerDoc(re.csUid);
      ct = await DatabaseM.getContractDoc(re.ctUid);
    }

    Revenue? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();

              List<Widget> widgetReW = [];
              widgetReW.add(WidgetUI.titleRowNone(['', '순번', '매출일자', '품목', '단위', '수량', '단가', '공급가액', '부가세', '합계', '메모'],
                  [ 6, 28, 150, 200, 50, 100, 100, 100, 100, 100, 999 ]));
              widgetReW.add(WidgetT.dividHorizontal(size: 0.35));

              var curItem = SystemT.getItem(re.item);
              var w = Container( height: 36,
                decoration: StyleT.inkStyleNone(color: Colors.transparent),
                child: Row(
                    children: [
                      WidgetT.title('', width: 6),
                      WidgetT.excelGrid(label:'', width: 28),
                      WidgetT.excelInput(context, 'rev.info::매출일자', width: 150,
                        onEdite: (i, data) { re.revenueAt = StyleT.dateEpoch(data); },
                        text: StyleT.dateInputFormatAtEpoch(re.revenueAt.toString()),
                      ),
                      WidgetT.excelInput(context, 'rev.info::re.item', width: 200,
                        onEdite: (i, data) async {
                          if(data == '') return;

                          re.item = data;
                          var itemList = await SystemT.searchItMeta(data);
                          Item? item = await DialogIT.selectItem(context, itemList);
                          if(item != null) {
                            re.item = item.id;
                          }
                        },
                        text: SystemT.getItemName(re.item),),
                      WidgetT.excelGrid( width: 50, text: (curItem == null) ? '' : curItem.unit),
                      WidgetT.excelInput(context, 'rev.info::re.count', width: 100,
                          onEdite: (i, data) {
                            re.count = int.tryParse(data) ?? 0;
                          },
                          text: StyleT.krw(re.count.toString()), value: re.count.toString() ),
                      WidgetT.excelInput(context, 'rev.info::re.unitPrice', width: 100,
                          onEdite: (i, data) {
                            re.unitPrice = int.tryParse(data) ?? 0;
                          },
                          text: StyleT.krw(re.unitPrice.toString()), value: re.unitPrice.toString()),
                      WidgetT.excelGrid(textLite: true, width: 100, text: StyleT.krw(re.supplyPrice.toString()),),
                      WidgetT.excelGrid(textLite: true,  width: 100,
                        text: StyleT.krw(re.vat.toString(),),
                      ),
                      WidgetT.excelGrid(textLite: true, width: 100,text: StyleT.krw(re.totalPrice.toString()),),
                      Expanded(
                        child: WidgetT.excelInput(context, 'rev.info::메모', width: 200,
                          onEdite: (i, data) { re.memo  = data ?? ''; },
                          text: re.memo,
                        ),
                      ),
                      InkWell(
                          onTap: () async {
                            if(!await DialogT.showAlertDl(context, text: '매출 정보를 삭제하시겠습니까?')) {
                              WidgetT.showSnackBar(context, text:'취소됨');
                              return;
                            }
                            WidgetT.loadingBottomSheet(context, text:'삭제중');
                            var task =  await re.delete();
                            Navigator.pop(context);

                            if(!task) {
                              WidgetT.showSnackBar(context, text: '삭제에 실패했습니다. 나중에 다시 시도하세요.');
                              Navigator.pop(context, re);
                              return;
                            }

                            WidgetT.showSnackBar(context, text: '삭제됨');
                            Navigator.pop(context, re);
                          },
                          child: Container( height: 28, width: 28,
                            child: WidgetT.iconMini(Icons.delete),)
                      ),
                    ]
                ),
              );
              widgetReW.add(w);

              var gridStyle = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.02), stroke: 2, strokeColor: StyleT.titleColor.withOpacity(0.1));

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent, width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '매출 추가', ),
                content: SingleChildScrollView(
                  child: Container(
                    width: 1280,
                    padding: EdgeInsets.all(dividHeight * 3),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container( decoration: gridStyle,
                          child: Column(children: [
                            Container( height: 36,
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    WidgetEX.excelTitle(width: 150, text: '계약명',),
                                    WidgetT.dividViertical(),
                                    if(org_check != null)
                                      WidgetT.excelGrid(width: 250, text: '${cs.businessName} / ${ct.ctName}',),
                                    if(org_check == null)
                                      WidgetT.excelInput(context, 'df거래처', width: 250,
                                        onEdite: (i, data) async {
                                          if(ct.csName == data) return;
                                          ct.csName = data;
                                          var contractList = await SystemT.searchCTMeta(data);

                                          Contract? selectContract = await DialogCT.selectCt(context, contractList: contractList);
                                          FunT.setStateD = () { setStateS(() {}); };

                                          if(selectContract != null) {
                                            ct = selectContract;
                                            cs = await SystemT.getCS(selectContract.csUid);
                                          }
                                        },
                                        text: '${cs.businessName} / ${ct.ctName}', value: '',
                                      ),
                                  ]
                              ),
                            ),
                          ],),),

                        SizedBox(height: 18,),
                        WidgetT.title('매출 상세 정보', size: StyleT.subTitleSize ),
                        SizedBox(height: dividHeight,),
                        Container(decoration: gridStyle, child: Column(children: widgetReW,),),
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
                              if(ct.ctName == '') { WidgetT.showSnackBar(context, text: '계약을 선택해 주세요'); return; }

                              if(!await DialogT.showAlertDl(context, text: '매출 정보를 저장하시겠습니까?')) {
                                WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                                return;
                              }

                              WidgetT.loadingBottomSheet(context, text:'저장중');

                              var task = await re.update(org: org_check);
                              if(task) {
                                Navigator.pop(context);
                                Navigator.pop(context, re);
                                WidgetT.showSnackBar(context, text: '저장에 실패했습니다. 나중에 다시 시도해 주세요');
                                return;
                              }

                              Navigator.pop(context);
                              WidgetT.showSnackBar(context, text: '저장됨');

                              Navigator.pop(context, re);
                            },
                            style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                            child: Container(
                                color: StyleT.accentColor.withOpacity(0.5), height: 42,
                                child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    WidgetT.iconMini(Icons.check_circle),
                                    Text('매출 정보 저장', style: StyleT.titleStyle(),),
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
