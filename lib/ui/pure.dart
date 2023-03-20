import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/cs.dart';
import 'package:evers/ui/ux.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../class/Customer.dart';
import '../class/contract.dart';
import '../class/purchase.dart';
import '../class/system.dart';
import '../class/transaction.dart';
import '../helper/dialog.dart';
import '../helper/firebaseCore.dart';
import '../helper/interfaceUI.dart';
import '../helper/pdfx.dart';
import 'dl.dart';
import 'package:http/http.dart' as http;

import 'ex.dart';

class WidgetPR extends StatelessWidget {

  /// 매입 추가화면 - 부가세 설정은 각 매출문서마다 각각 추가됨
  static dynamic showCreatePu(BuildContext context) async {
    var dividHeight = 6.0;
    var heightSize = 36.0;

    List<Map<String, Uint8List>> fileByteList = [];
    Contract ct = Contract.fromDatabase({});
    Customer? cs;
    bool isAddItem = false;       /// 재고 품목 추가
    bool isCt = false;
    var payment = '매입';
    var payType = '';

    var vatTypeList = [ 0, 1, ];
    var vatTypeNameList = [ '포함', '미포함', ];
    var currentVatType = 0;

    List<Purchase> pus = [];
    var pu = Purchase.fromDatabase({});
    pu.purchaseAt = DateTime.now().microsecondsSinceEpoch;

    pus.add(pu);
    fileByteList.add({});

    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();

              List<Widget> widgetsPu = [];
              widgetsPu.add( WidgetUI.titleRowNone([ '순번', '매입일자', '품목', '단위', '수량', '단가', '공급가액',  'VAT', '합계', '메모', '', ],
                [ 28, 100, 200 + 28 * 2, 50, 80, 80 + 28, 80, 80, 80, 999, 0], background: true),);
              for(int i = 0; i < pus.length; i++) {
                Widget w = SizedBox();
                var pu = pus[i];
                var item = SystemT.getItem(pu.item) ?? Item.fromDatabase({});
                var unitPrice = pu.unitPrice; //int.tryParse((ctl['unitPrice'] != '') ? ctl['unitPrice'] : item?.unitPrice.toString()) ?? 0;

                var fileMap = fileByteList[i] as Map;
                pu.vatType = currentVatType;
                pu.init();
                w = Column(
                  children: [
                    Container(
                      height: heightSize,
                      child: Row(
                          children: [
                            WidgetT.excelGrid(label:'${i + 1}', width: 28),
                            WidgetT.excelInput(context, '$i::매출일자', width: 100,
                              onEdite: (i, data) { pu.purchaseAt = StyleT.dateEpoch(data); },
                              text: StyleT.dateInputFormatAtEpoch(pu.purchaseAt.toString()),
                            ),
                            WidgetT.excelInput(context, '$i::품목', width: 200, index: i,
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
                            WidgetT.excelGrid(text:item.unit, width: 50),
                            WidgetT.excelInput(context, '$i::수량', width: 80,
                                onEdite: (i, data) {
                                  pu.count = int.tryParse(data) ?? 0;
                                },
                                text: StyleT.krw(pu.count.toString()), value: pu.count.toString()),
                            WidgetT.excelInput(context, '$i::단가', width: 80,
                              onEdite: (i, data) {
                                pu.unitPrice = int.tryParse(data) ?? 0;
                              },
                              text: StyleT.krwInt(unitPrice), value: unitPrice.toString(),),
                            TextButton(
                              onPressed: () async {
                                pu.unitPrice = item.unitPrice;
                                FunT.setStateDT();
                              },
                              style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                              child: (pu.unitPrice == item.unitPrice) ? WidgetT.iconMini(Icons.link, size: 28) : WidgetT.iconMini(Icons.link_off, size: 28) ,
                            ),
                            WidgetT.excelGrid(width: 80,  text: StyleT.krw(pu.supplyPrice.toString()),),
                            WidgetT.excelGrid( width: 80,  text: StyleT.krw(pu.vat.toString()), ),
                            WidgetT.excelGrid(width: 80, text: StyleT.krw(pu.totalPrice.toString()),),
                            Expanded(
                              child: WidgetT.excelInput(context, '$i::메모', width: 200, index: i,
                                onEdite: (i, data) { pu.memo  = data ?? ''; },
                                text: pu.memo,
                              ),
                            ),
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
                                      fileByteList[i][fileName] = fileBytes;
                                      print(fileByteList[i][fileName]!.length);
                                    }
                                  }
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                child: Container( height: 28, width: 28,
                                  child: WidgetT.iconMini(Icons.file_copy_rounded),)
                            ),
                            TextButton(
                                onPressed: () async {
                                  //if(await DialogT.showAlertDl(context, text: '삭제하세겠습니까?')) {}
                                  pus.remove(pu);
                                  fileByteList.removeAt(i);
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                child: Container( height: 28, width: 28,
                                  child: WidgetT.iconMini(Icons.cancel),)
                            ),
                          ]
                      ),
                    ),
                    if(fileMap.length > 0)
                      Container( height: 28,
                      decoration: StyleT.inkStyle(color: StyleT.backgroundColor.withOpacity(0.5), stroke: 0.35),
                      child: Row(
                          children: [
                            WidgetT.excelGrid( width: 178, label: '거래명세서 첨부파일', ),
                            WidgetT.dividViertical(height: 28),
                            Expanded(child: Container( padding: EdgeInsets.all(0),  child: Wrap(
                              runSpacing: dividHeight * 2, spacing: dividHeight * 2,
                              children: [
                                for(int i = 0; i < pu.filesMap.length; i++)
                                  TextButton(
                                      onPressed: () async {
                                        var downloadUrl = pu.filesMap.values.elementAt(i);
                                        var fileName = pu.filesMap.keys.elementAt(i);
                                        print(downloadUrl);
                                        var res = await http.get(Uri.parse(downloadUrl));
                                        var bodyBytes = res.bodyBytes;
                                        print(bodyBytes.length);
                                        PDFX.showPDFtoDialog(context, data: bodyBytes, name: fileName);
                                      },
                                      style: StyleT.buttonStyleNone(round: 8, elevation: 18, padding: 0, color: StyleT.accentLowColor.withOpacity(0.35), strock: 1),
                                      child: Container(padding: EdgeInsets.all(0), child: Row(
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
                                for(int i = 0; i < fileMap.length; i++)
                                  TextButton(
                                      onPressed: () {
                                        PDFX.showPDFtoDialog(context, data: fileMap.values.elementAt(i), name: fileMap.keys.elementAt(i));
                                      },
                                      style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                      child: Container(padding: EdgeInsets.all(0), child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          WidgetT.iconMini(Icons.file_copy_rounded, size: 28),
                                          WidgetT.title(fileMap.keys.elementAt(i),),
                                          TextButton(
                                              onPressed: () {
                                                fileMap.remove(fileMap.keys.elementAt(i));
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
                widgetsPu.add(WidgetT.dividHorizontal(size: 0.35));
              }

              var gridStyleT = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.03), stroke: 2, strokeColor: StyleT.titleColor.withOpacity(0.1));
              var btnStyleT = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.1),
                stroke: 0.35,);
              var divHor = Expanded(child: WidgetT.dividHorizontal(size: 0.35, ));
              var dividCol = Column(
                children: [
                  SizedBox(height: dividHeight * 4,),
                  SizedBox(height: dividHeight * 4,),
                ],
              );

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.withOpacity(0), width: 0.01), borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '매입추가', ),
                content: SingleChildScrollView(
                  child: Container(
                    width: 1280,
                    padding: EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetT.title('등록유형', size: 16 ),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  isCt = !isCt;
                                  FunT.setStateDT();
                                },
                                child: Container(padding: EdgeInsets.all(0), child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if(!isCt)
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                                    if(isCt)
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box),),
                                    WidgetT.title('기존 계약에 추가', size: 12),
                                    SizedBox(width: 6,),
                                  ],
                                ))
                            ),
                            SizedBox(width: dividHeight,),
                            InkWell(
                                onTap: () {
                                  isAddItem = !isAddItem;
                                  FunT.setStateDT();
                                },
                                child: Container(padding: EdgeInsets.all(0), child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if(!isAddItem)
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                                    if(isAddItem)
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box),),
                                    WidgetT.title('재고 추가', size: 12),
                                    SizedBox(width: 6,),
                                  ],
                                ))
                            ),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        if(!isCt) Container(
                          height: 36,  width: 500,
                          decoration: gridStyleT,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WidgetEX.excelTitle(text:'거래처',width: 150),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    Customer? c = await DialogT.selectCS(context);
                                    FunT.setStateD = () { setStateS(() {}); };

                                    if(c != null) {
                                      cs = c;
                                      print(c.id + ' : ' + SystemT.getCSName(pu.csUid));
                                    }
                                    await FunT.setStateDT();
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      child: Row( mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(child: SizedBox()),
                                          WidgetT.title('${(cs != null) ? cs!.id : ''}', size: 12,),
                                          WidgetT.text('/', size: 12, width: 20),
                                          WidgetT.title((cs != null) ? cs!.businessName : '', size: 12,),
                                          Expanded(child: SizedBox()),
                                        ],
                                      )),),
                              ),
                            ],
                          ),
                        ),
                        if(isCt) Container(
                          height: 36,  width: 500,
                          decoration: gridStyleT,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WidgetEX.excelTitle(text:'계약명',width: 150),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    Contract? c = await DialogT.selectCt(context);
                                    FunT.setStateD = () { setStateS(() {}); };

                                    if(c != null) {
                                      ct = c;
                                      print(c.id + ' : ' + SystemT.getCSName(pu.csUid));
                                    }
                                    await FunT.setStateDT();
                                  },
                                  child: Container( height: 28, alignment: Alignment.center,
                                      child: Row( mainAxisSize: MainAxisSize.min,
                                        children: [
                                          WidgetT.title(ct.ctName, ),
                                        ],
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),

                        dividCol,

                        Row(
                          children: [
                            WidgetT.title('매입 추가 목록', size: 16),
                            SizedBox(width: dividHeight * 2,),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        Container( child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgetsPu, ),),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  var p = Purchase.fromDatabase({});
                                  p.purchaseAt = DateTime.now().microsecondsSinceEpoch;
                                  pus.add(p);
                                  fileByteList.add({});

                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                                    color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                                child: Container(padding: EdgeInsets.all(0), child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container( height: 28, width: 28,
                                      child: WidgetT.iconMini(Icons.add_box),),
                                    WidgetT.title('매입추가'),
                                    SizedBox(width: 6,),
                                  ],
                                ))
                            ),
                            SizedBox(width: dividHeight,),
                            Row(
                              children: [
                                WidgetT.title('지불관련', width: 100 ),
                                for(var v in vatTypeList)
                                  Container(
                                    padding: EdgeInsets.only(right: dividHeight),
                                    child: TextButton(
                                        onPressed: () {
                                          currentVatType = v;
                                          FunT.setStateDT();
                                        },
                                        style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                                            color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                                        child: Container(padding: EdgeInsets.all(0), child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if(currentVatType != v)
                                              Container( height: 28, width: 28,
                                                child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                                            if(currentVatType == v)
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
                            SizedBox(width: 6,),
                            WidgetT.text('품목 직접 입력시 재고 및 단가 연동 불가.   연동이 필요한 품목은 생산관리에서 추가후 입력해 주세요.', size: 10),
                          ],
                        ),
                        
                        dividCol,

                        WidgetT.title('지불관련', size: 16 ),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  payment = '매입';
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                                    color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if(payment != '매입')
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                                    if(payment == '매입')
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box),),
                                    WidgetT.title('매입만'),
                                    SizedBox(width: 6,),
                                  ],
                                )
                            ),
                            SizedBox(width: dividHeight,),
                            TextButton(
                                onPressed: () {
                                  payment = '즉시';
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                                    color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if(payment != '즉시')
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                                    if(payment == '즉시')
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box),),
                                    WidgetT.title('즉시지불'),
                                    SizedBox(width: 6,),
                                  ],
                                )
                            ),
                            SizedBox(width: dividHeight,),
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
                      Expanded(child:TextButton(
                          onPressed: () async {
                            if(!isCt) {
                              if(cs == null) { WidgetT.showSnackBar(context, text: '거래처를 선택해 주세요.'); return; }
                            }
                            else {
                              if(ct == null) { WidgetT.showSnackBar(context, text: '계약을 선택해 주세요.'); return; }
                              if(ct.ctName  == '') { WidgetT.showSnackBar(context, text: '계약을 선택해 주세요.'); return; }
                            }
                            if(payment == '즉시' && payType == '') { WidgetT.showSnackBar(context, text: '결제방법을 선택해 주세요.'); return;  }
                            for(var pu in pus) {
                              if(isAddItem) {
                                var item = SystemT.getItem(pu.item);
                                if(item == null) {
                                  WidgetT.showSnackBar(context, text: '품목을 재고에 추가할 수 없습니다. 품목을 다시 선택해 주세요.');
                                  return;
                                }
                              }
                            }

                            var alert = await DialogT.showAlertDl(context, title: pu.csUid ?? 'NULL');
                            if(alert == false) {
                              WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                              return;
                            }

                            for(int i = 0; i < pus.length; i++) {
                              var p = pus[i]; var files = fileByteList[i] as Map<String, Uint8List>;

                              if(isCt) {
                                p.ctUid = ct.id;
                                p.csUid = ct.csUid;
                              }
                              else p.csUid = cs!.id;
                              p.vatType = currentVatType;
                              p.isItemTs = isAddItem;

                              /// 매입정보 추가 - 매입데이터 및 거래명세서 파일 데이터
                              await FireStoreT.updatePurchase(p, files: files);
                              /// 지불 정보 문서 추가
                              if(payment == '즉시') await TS.fromPu(p, payType, now: true).update();
                            }

                            //SystemT.contract.add(pu);
                            WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                            Navigator.pop(context);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('매입 추가하기', style: StyleT.titleStyle(),),
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
              tsCW.add(WidgetT.titleRowW([ '수납추가현황', ], [ 999], isTitle: true),);
              tsCW.add(WidgetT.titleRowW([ '', '순번', '거래일자', '구분', '적요', '결제', '금액', '메모', ],
                  [ 28, 28, 150, 100 + 28, 250, 208, 120, 999,]),);
              for(int i = 0; i < tslistCr.length; i++) {
                var tmpTs = tslistCr[i];

                var w = Container( height: 28,
                  decoration: StyleT.inkStyle(stroke: 0.35,),
                  child: Row(
                      children: [
                        TextButton(
                            onPressed: () async {
                              tslistCr.removeAt(i);
                              FunT.setStateDT();
                            },
                            style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                            child: Container( height: 28, width: 28,
                              child: WidgetT.iconMini(Icons.cancel),)
                        ),
                        WidgetT.dividViertical(),
                        WidgetT.title('${i + 1}', width: 28),
                        WidgetT.dividViertical(),
                        WidgetT.excelInput(context, '$i::ts거래일자', width: 150, label: '거래일자',
                          onEdite: (i, data) { tmpTs.transactionAt = StyleT.dateEpoch(data); },
                          text: StyleT.dateInputFormatAtEpoch(tmpTs.transactionAt.toString()),
                        ),
                        WidgetT.dividViertical(),
                        WidgetT.excelGrid(text: (tmpTs.type != 'PU') ? '수입' : '지출', width: 100, label: '구분'),
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
                        ),
                        WidgetT.dividViertical(),
                        WidgetT.excelInput(context, '$i::ts적요', width: 250, index: i, label: '적요',
                          onEdite: (i, data) { tmpTs.summary = data; },
                          text: '${tmpTs.summary}',
                        ),
                        WidgetT.dividViertical(),
                        WidgetT.excelGrid(text:  (SystemT.accounts[tmpTs.account] != null) ? SystemT.accounts[tmpTs.account]!.name : 'NULL', width: 180, label: '결제'),
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
                        ),
                        WidgetT.dividViertical(),
                        WidgetT.excelInput(context, '$i::ts금액', width: 120, label: '금액',
                          onEdite: (i, data) {
                            tmpTs.amount = int.tryParse(data) ?? 0;
                          },
                          text: StyleT.krwInt(tmpTs.amount), value: tmpTs.amount.toString(),),
                        WidgetT.dividViertical(),
                        WidgetT.excelInput(context, '$i::ts메모', width: 250, index: i, label: '메모',
                          onEdite: (i, data) { tmpTs.memo = data;},
                          text: tmpTs.memo,
                        ),
                        WidgetT.dividViertical(),
                        TextButton(
                            onPressed: () {

                            },
                            style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                            child: Container( height: 28, width: 28,
                              child: WidgetT.iconMini(Icons.open_in_new),)
                        ),
                      ]
                  ),
                );
                tsCW.add(w);
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
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
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
                        Container(
                          child: Column(
                            children: [
                              for(var w in tsCW) w,
                            ],
                          ),
                        ),
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
