import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/revenue.dart';
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
import '../helper/aes.dart';
import '../helper/dialog.dart';
import '../helper/interfaceUI.dart';
import 'cs.dart';
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

  /// 계약 상세 화면, 매출 매입 리스트 뷰어 필수
  static dynamic showInfoCt(BuildContext context, Contract original) async {
    WidgetT.loadingBottomSheet(context);

    var dividHeight = 6.0;
    var heightSized = 36.0;
    var titleSize = 16.0;
    //var _dragging = false;
    //List<XFile> _list = [];
    //late DropzoneViewController controller;
    Map<String, Uint8List> fileByteList = {};

    Map<String, Uint8List> ctFileByteList = {};

    var vatTypeList = [ 0, 1, ];
    var vatTypeNameList = [ '포함', '별도', ];
    var currentVatType = 0;

    //await original.update();
    var jsonString = jsonEncode(original.toJson());
    var json = jsonDecode(jsonString);

    List<TS> tslist = [];
    List<TS> tslistCr = [];
    List<Schedule> sch_list = [];
    /// 추후 toCopy Function 생성 필요
    var ct = Contract.fromDatabase(json);
    await ct.update();

    tslist = await FireStoreT.getTransactionCt(ct.id);
    sch_list = await FireStoreT.getSCH_CT(ct.id);

    Navigator.pop(context);

    late Function setData;
    // ignore: use_build_context_synchronously
    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              setData = FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();

              var allPay = 0, allPayedAmount = 0;

              List<Widget> reW = [];
              reW.add(WidgetUI.titleRowNone([ '', '순번', '매출일자', '품목', '단위', '수량', '단가', '공급가액', 'VAT', '합계', '메모', '' ],
                  [ 32, 28, 100, 999, 50, 80, 80, 80, 80, 80, 999, 32 ], background: true),);
              for(int i = 0; i < ct.revenueList.length; i++) {
                Widget w = SizedBox();
                var re = ct.revenueList[i];
                var item = SystemT.getItem(re.item) ?? Item.fromDatabase({});

                re.init();
                allPay += re.totalPrice;

                w = Container(
                  height: heightSized,
                  child: Row(
                      children: [
                        InkWell(
                            onTap: () async {
                              re.selectIsTaxed = !re.selectIsTaxed;
                              FunT.setStateDT();
                            },
                            child: WidgetT.iconMini(re.selectIsTaxed ? Icons.check_box : Icons.check_box_outline_blank, size: 32),
                        ),
                        WidgetT.excelGrid(label: '${i + 1}', width: 28),
                        WidgetT.excelGrid(textLite: true, width: 100, text: StyleT.dateInputFormatAtEpoch(re.revenueAt.toString()),),
                        Expanded(child: WidgetT.excelGrid( width: 250, text: SystemT.getItemName(re.item),)),
                        WidgetT.excelGrid(textLite: true, text:item.unit, width: 50),
                        WidgetT.excelGrid(textLite: true, width: 80,  text: StyleT.krw(re.count.toString()),),
                        WidgetT.excelGrid(textLite: true,width: 80,  text: StyleT.krw(re.unitPrice.toString()),),
                        WidgetT.excelGrid(textLite: true,width: 80, text: StyleT.krw(re.supplyPrice.toString()),),
                        WidgetT.excelGrid(textLite: true, width: 80,  text: StyleT.krw(re.vat.toString()), ),
                        WidgetT.excelGrid(textLite: true, width: 80, text: StyleT.krw(re.totalPrice.toString()),),
                        Expanded(child: WidgetT.excelGrid( textLite: true,width: 200, text: re.memo,),),
                        InkWell(
                          onTap: () async {
                            var data = await DialogRE.showInfoRe(context, org: re);
                            FunT.setStateD = setData;

                            WidgetT.loadingBottomSheet(context, text:'로딩중');
                            if(data != null) {
                              await ct.update();
                            }
                            Navigator.pop(context);
                            FunT.setStateDT();
                          },
                            child: WidgetT.iconMini(Icons.create, size: 32),
                        )
                      ]
                  ),
                );
                reW.add(w);
                reW.add(WidgetT.dividHorizontal(size: 0.35));
              }

              List<Widget> ctW = [];
              ctW.add(WidgetUI.titleRowNone([ '', '순번', '매출일자', '품목', '단위', '단가', '메모' ], [ 28, 28, 150, 200 + 28 * 2, 50, 120, 999 ], background: true),);
              for(int i = 0; i < ct.contractList.length; i++) {
                Widget w = SizedBox();
                var ctl = ct.contractList[i];
                Item? ctlItem = SystemT.getItem(ctl['item'] ?? '');
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
                        WidgetT.excelGrid(width: 150,
                          text: StyleT.dateInputFormatAtEpoch(ctl['dueAt'] ?? ''),
                        ),
                        WidgetT.excelGrid(width: 200 + 28 * 2, text: SystemT.getItemName(ctl['item'] ?? ''),),
                        WidgetT.excelGrid( text: SystemT.getItemUnit(ctl['item'] ?? ''), width: 50, ),
                        WidgetT.excelGrid( width: 120,  text: StyleT.krw(unitPrice.toString()), value: unitPrice.toString(),),
                        /*WidgetT.dividViertical(height: 28),
                            WidgetT.excelGrid(width: 80, label: '계약수량 ' + StyleT.krw(count.toString()),),
                            WidgetT.dividViertical(height: 28),
                            WidgetT.excelGrid(width: 80, label: '매출수량 ' + StyleT.krw(ct.getItemRevenueCount(ctl['id'] ?? '').toString()),),
                            WidgetT.dividViertical(height: 28),
                            WidgetT.excelGrid(width: 80, label: '잔량 ' + StyleT.krw(ct.getItemCountRevenue(ctl['id'] ?? '').toString()),),
                            WidgetT.dividViertical(height: 28),
                            WidgetT.excelGrid(width: 150, label: '공급가액 ' +  StyleT.krw(supplyPrice.toString()),),
                            WidgetT.dividViertical(height: 28),
                            WidgetT.excelGrid(width: 100,label: '부가세 ' + StyleT.krw(vat.toString()),),
                            WidgetT.dividViertical(height: 28),
                            WidgetT.excelGrid(width: 100, label: '합계 ' + StyleT.krw(totalPrice.toString())),*/
                        Expanded(child: WidgetT.excelGrid( text: ctl['memo'], width: 200,),),
                      ],
                    ));
                ctW.add(w);
                ctW.add(WidgetT.dividHorizontal(size: 0.35));
              }

              List<Widget> tsW = [];
              tsW.add(WidgetUI.titleRowNone([ '', '순번', '거래일자', '구분', '적요', '결제', '금액', '메모', ], [ 28, 28, 150, 100, 250, 180 + 28, 120, 999,], background: true),);
              for(int i = 0; i < tslist.length; i++) {
                var tmpTs = tslist[i];
                if(tmpTs.type == 'PU') continue;
                allPayedAmount += tmpTs.amount;

                var w = Container(
                  height: heightSized,
                  child: Row(
                      children: [
                        WidgetT.title('', width: 28),
                        WidgetT.title('${i + 1}', width: 28),
                        WidgetT.excelGrid(text: StyleT.dateFormatAtEpoch(tmpTs.transactionAt.toString()), width: 150, ),
                        WidgetT.excelGrid(text: (tmpTs.type != 'PU') ? '수입' : '지출', width: 100, ),
                        WidgetT.excelGrid(width: 250,  text: '${tmpTs.summary}',),
                        WidgetT.excelGrid(text: '${SystemT.getAccountName(tmpTs.account)}', width: 180 + 28,),
                        WidgetT.excelGrid(text: StyleT.krwInt(tmpTs.amount), width: 120,
                            textColor: (tmpTs.type != 'PU') ? Colors.blue.withOpacity(0.5) : Colors.red.withOpacity(0.2)),
                        Expanded(child: WidgetT.excelGrid(width: 250,text: tmpTs.memo,),),
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
                tsW.add(w);
                tsW.add(WidgetT.dividHorizontal(size: 0.35));
              }

              List<Widget> tsCW = [];
              for(int i = 0; i < tslistCr.length; i++) {
                var tmpTs = tslistCr[i];

                var w = Container(
                  height: 28,
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
                        WidgetT.title('${i + 1}', width: 28),
                        WidgetT.excelInput(context, '$i::ts거래일자', width: 150, label: '거래일자',
                          onEdite: (i, data) { tmpTs.transactionAt = StyleT.dateEpoch(data); },
                          text: StyleT.dateInputFormatAtEpoch(tmpTs.transactionAt.toString()),
                        ),
                        WidgetT.excelGrid(text: (tmpTs.type != 'PU') ? '수입' : '지출', width: 100, label: '구분'),
                        WidgetT.excelInput(context, '$i::ts적요', width: 250, index: i, label: '적요',
                          onEdite: (i, data) { tmpTs.summary = data; },
                          text: '${tmpTs.summary}',
                        ),
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
                        WidgetT.excelInput(context, '$i::ts금액', width: 120, label: '금액',
                          onEdite: (i, data) {
                            tmpTs.amount = int.tryParse(data) ?? 0;
                          },
                          text: StyleT.krwInt(tmpTs.amount), value: tmpTs.amount.toString(),),
                        WidgetT.excelInput(context, '$i::ts메모', width: 250, index: i, label: '메모',
                          onEdite: (i, data) { tmpTs.memo = data;},
                          text: tmpTs.memo,
                        ),
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
                tsCW.add(WidgetT.dividHorizontal(size: 0.35));
              }

              List<Widget> tsAllW = [];
              tsAllW.add( WidgetUI.titleRowNone([ '총매출금액', '총수금금액', '미수금', ], [ 999, 999, 999, ], background: true),);
              tsAllW.add( Container( height: 28,
                child: Row(
                    children: [
                      Expanded(child: WidgetT.excelGrid(text: StyleT.krwInt(allPay), width: 250)),
                      Expanded(child: WidgetT.excelGrid(width: 250,text: StyleT.krwInt(allPayedAmount), )),
                      Expanded(child: WidgetT.excelGrid( width: 250, text: StyleT.krwInt(allPay - allPayedAmount),)),
                    ]
                ),
              ));

              List<Widget> schW = [];
              schW.add(WidgetUI.titleRowNone([ '', '순번', '일정시간', '태그', '메모', ], [ 28, 28, 150, 150, 999, ], background: true),);
              for(int i = 0; i < sch_list.length; i++) {
                var sch = sch_list[i];

                var w = Column(
                  children: [
                    Container(
                      child: IntrinsicHeight(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: heightSized,),
                              WidgetT.title('', width: 28),
                              WidgetT.excelGrid(label:'${i + 1}', width: 28),
                              WidgetT.excelGrid(textLite: true, text: StyleT.dateFormatAtEpoch(sch.date.toString()), width: 150, ),
                              WidgetT.excelGrid(textLite: false, text: StyleT.getSCHTag(sch.type), width: 150,),
                              Expanded(child: WidgetT.excelGrid(textLite: true, width: 250,
                                alignment: Alignment.centerLeft, text: sch.memo,),),
                              InkWell(
                                  onTap: () async {
                                    var data = await DialogSHC.showSCHEdite(context, sch);
                                    FunT.setStateD = setData;

                                    if(data != null) {
                                      sch_list = await FireStoreT.getSCH_CT(ct.id);
                                      FunT.setStateDT();
                                    }
                                  },
                                  child: Container( height: 28, width: 28,
                                    child: WidgetT.iconMini(Icons.create),)
                              ),
                            ]
                        ),
                      ),
                    ),
                    if(sch.filesMap.isNotEmpty)
                      Container(
                        height: heightSized,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 32, width: 32,),
                            WidgetT.text('첨부파일',),
                            SizedBox(width: 32,),
                            Expanded(
                              child: Row(
                                children: [
                                  for(int i = 0; i < sch.filesMap.length; i++)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                            onTap: () async {
                                              var downloadUrl = sch.filesMap.values.elementAt(i);
                                              var fileName = sch.filesMap.keys.elementAt(i);
                                              var ens = ENAES.fUrlAES(downloadUrl);

                                              var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName';
                                              print(url);
                                              await launchUrl( Uri.parse(url),
                                                webOnlyWindowName: true ? '_blank' : '_self',
                                              );
                                            },
                                            child: Container(
                                                height: 24,
                                                decoration: StyleT.inkStyle(stroke: 0.35, round: 8, color: StyleT.accentLowColor.withOpacity(0.05)),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    SizedBox(width: 6,),
                                                    WidgetT.title(sch.filesMap.keys.elementAt(i), size: 12),
                                                    InkWell(
                                                        onTap: () {
                                                          WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
                                                          FunT.setStateDT();
                                                        },
                                                        child: Container( height: 24, width: 24,
                                                          child: WidgetT.iconMini(Icons.cancel),)
                                                    ),
                                                  ],
                                                ))
                                        ),
                                        SizedBox(width: dividHeight*2,),
                                      ],
                                    ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                  ],
                );
                schW.add(w);
                schW.add(WidgetT.dividHorizontal(size: 0.35));
              }

              var divHor = Expanded(
                child: Row(
                  children: [
                    SizedBox(width: dividHeight * 2,),
                    WidgetT.dividViertical(size: 4, height: 24),
                    SizedBox(width: dividHeight * 2,),
                    Expanded(child: WidgetT.dividHorizontal(size: 0.15,)),
                    SizedBox(width: dividHeight * 2,),
                    WidgetT.dividViertical(size: 4, height: 24),
                  ],
                ),
              );
              var dividCol = Column(
                children: [
                  SizedBox(height: dividHeight * 4,),
                  SizedBox(height: dividHeight * 4,),
                ],
              );
              var btnStyle =  StyleT.buttonStyleOutline(round: 8, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7);
              var gridStyle = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.00), stroke: 0.01, strokeColor: StyleT.titleColor.withOpacity(0.0));
              var gridStyleT = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.03), stroke: 2, strokeColor: StyleT.titleColor.withOpacity(0.1));
              var btnStyleT = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.1),
                  stroke: 0.35,);

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.titleColor.withOpacity(0.0), width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '계약정보',),
                content: SingleChildScrollView(
                  child: Container(
                    width: 1536 + dividHeight * 4,
                    padding: EdgeInsets.all(dividHeight * 3),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetT.title('계약상세 정보', size: titleSize),
                        SizedBox(height: dividHeight,),
                        Container( decoration: gridStyleT,
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
                                      WidgetT.excelGrid(width: 250, text: SystemT.getCSName(ct.csUid),),
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
                                                        var ens = ENAES.fUrlAES(downloadUrl);

                                                        var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName';
                                                        print(url);
                                                        await launchUrl( Uri.parse(url),
                                                          webOnlyWindowName: true ? '_blank' : '_self',
                                                        );
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
                                                              var ens = ENAES.fUrlAES(downloadUrl);

                                                              var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName';
                                                              print(url);
                                                              await launchUrl( Uri.parse(url),
                                                                webOnlyWindowName: true ? '_blank' : '_self',
                                                              );
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
                                style: btnStyle,
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
                                style: btnStyle,
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
                        WidgetT.title('계약내용', size: titleSize),
                        SizedBox(height: dividHeight,),
                        Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: ctW,)),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  FunT.setStateDT();
                                },
                                style: btnStyle,
                                child: Container(padding: EdgeInsets.all(0), child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if(ct.vatType != 0)
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                                    if(ct.vatType == 0)
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box),),
                                    WidgetT.title('부가세 ' + vatTypeNameList[ct.vatType] ),
                                    SizedBox(width: 6,),
                                  ],
                                ))
                            ),
                          ],
                        ),

                        dividCol,
                        Row(
                          children: [
                            WidgetT.title('스케쥴 및 메모', size: titleSize),
                            divHor
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: schW,)),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            TextButton(onPressed: () async {
                              await DialogSHC.showSCHCreate(context, ctUid: ct.id);
                              sch_list = await FireStoreT.getSCH_CT(ct.id);
                              FunT.setStateD = () { setStateS(() {}); };
                              FunT.setStateDT();
                            },
                              style: btnStyle,
                              child: Container( height: 28,
                                  child: Row(
                                    children: [
                                      WidgetT.iconMini(Icons.schedule),
                                      WidgetT.title('일정추가',),
                                      SizedBox(width: dividHeight,),
                                    ],
                                  )),),
                          ],
                        ),

                        dividCol,
                        Row(
                          children: [
                            WidgetT.title('매입 / 매출 목록', size: titleSize),
                            divHor
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: reW,)),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            InkWell(
                                onTap: () async {
                                  var data = await DialogRE.showCreateRe(context, ctUid: ct.id);
                                  FunT.setStateD = setData;
                                  WidgetT.loadingBottomSheet(context, text:'로딩중');
                                  if(data != null) {
                                    await ct.update();
                                  }
                                  Navigator.pop(context);
                                  FunT.setStateDT();
                                },
                                child: Container(
                                  height: 32,
                                    decoration: btnStyleT,
                                    padding: EdgeInsets.all(0), child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container( height: 28, width: 28,
                                      child: WidgetT.iconMini(Icons.add_box),),
                                    WidgetT.title('매출추가' ),
                                    SizedBox(width: 6,),
                                  ],
                                ))
                            ),
                            SizedBox(width: dividHeight * 8,),
                            InkWell(
                                onTap: () async {
                                  WidgetT.loadingBottomSheet(context, text: '저장중');
                                  for(var re in ct.revenueList) {
                                    if(re.isTaxed != re.selectIsTaxed) {
                                      re.isTaxed = re.selectIsTaxed;
                                      await re.update();
                                    }
                                  }
                                  Navigator.pop(context);
                                  FunT.setStateDT();
                                },
                                child: Container(
                                  height: 32,
                                    decoration: btnStyleT,
                                    padding: EdgeInsets.all(0), child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    WidgetT.iconMini(Icons.pending_actions, size: 32),
                                    WidgetT.title('세금계산서마감'),
                                    SizedBox(width: 6,),
                                  ],
                                ))
                            ),
                            SizedBox(width: dividHeight,),
                            InkWell(
                                onTap: () async {
                                  launchUrl(Uri.parse('https://www.hometax.go.kr/websquare/websquare.html?w2xPath=/ui/pp/index.xml'));
                                  FunT.setStateDT();
                                },
                                child: Container(
                                    height: 32,
                                    decoration: btnStyleT,
                                    padding: EdgeInsets.all(0), child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    WidgetT.iconMini(Icons.open_in_new, size: 32),
                                    WidgetT.title('홈택스 바로가기' ),
                                    SizedBox(width: 6,),
                                  ],
                                ))
                            ),
                          ],
                        ),

                        dividCol,
                        WidgetT.title('수금현황', size: titleSize),
                        SizedBox(height: dividHeight,),
                        Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: tsW,)),
                        if(tslistCr.length > 0)
                          Column(
                            children: [
                              SizedBox(height: dividHeight * 2,),
                              Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: tsCW,)),
                            ],
                          ),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            TextButton(
                                onPressed: () async {
                                  tslistCr.add(TS.fromDatabase({ 'transactionAt': DateTime.now().microsecondsSinceEpoch, 'type': 'RE' }));
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleOutline(round: 8, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                                child: Container(padding: EdgeInsets.all(0), child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    Container( height: 28, width: 28,
                                      child: WidgetT.iconMini(Icons.add_box),),
                                    WidgetT.title('수금추가' ),
                                    SizedBox(width: 6,),
                                  ],
                                ))
                            ),
                            SizedBox(width: 6,),
                            if(tslistCr.length > 0) Container( padding: EdgeInsets.only(right: dividHeight * 2),
                              child: TextButton(
                                  onPressed: () async {
                                    var alert = await DialogT.showAlertDl(context, text: '수금 목록을 저장하시겠습니까?');
                                    if(alert == false) {
                                      WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                                      return;
                                    }

                                    WidgetT.loadingBottomSheet(context, text:'로딩중');

                                    for(var ts in tslistCr) {
                                      ts.ctUid = ct.id;
                                      ts.csUid = ct.csUid;
                                      await ts.update();
                                    }

                                    tslist = await FireStoreT.getTransactionCt(ct.id);

                                    Navigator.pop(context);
                                    FunT.setStateDT();
                                  },
                                  style: StyleT.buttonStyleOutline(round: 8, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                                  child: Container(padding: EdgeInsets.all(0), child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.save),),
                                      WidgetT.title('수금저장' ),
                                      SizedBox(width: 6,),
                                    ],
                                  ))
                              ),
                            ),
                          ],
                        ),

                        dividCol,
                        WidgetT.title('금액현황', size: titleSize),
                        SizedBox(height: dividHeight,),
                        Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: tsAllW,)),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: [
                  Row(
                    children: [
                      Expanded(child:TextButton(
                          onPressed: () async {
                            var alert = await DialogT.showAlertDl(context, title: ct.csUid ?? 'NULL');
                            if(alert == false) {
                              WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                              return;
                            }

                            /*for(var p in reCreate) {
                              p.ctUid = ct.id;
                              p.csUid = ct.csUid;
                              //p.vatType = currentVatType;

                              await FireStoreT.updateRevenue(p);
                              /// 지불 정보 문서 추가
                              //if(payment == '즉시') await FireStoreT.updateTransaction(TS.fromPu(p, payType));
                              /// 아이템 이동 거래 문서 추가
                              //if(isAddItem) await FireStoreT.updateItemTS(ItemTS.fromPu(p), DateTime.fromMicrosecondsSinceEpoch(p.purchaseAt));
                            }
                            for(var ts in tslistCr) {
                              ts.ctUid = ct.id;
                              ts.csUid = ct.csUid;
                              await FireStoreT.updateTransaction(ts);
                            }*/

                            await FireStoreT.updateContract(ct, files: fileByteList, ctFiles: ctFileByteList);
                            original.fromJson(ct.toJson());
                            WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                            Navigator.pop(context);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('계약정보 저장', style: StyleT.titleStyle(),),
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

  static dynamic showCreateCt(BuildContext context,) async {
    WidgetT.loadingBottomSheet(context);

    var dividHeight = 6.0;
    //var _dragging = false;
    //List<XFile> _list = [];
    //late DropzoneViewController controller;
    Map<String, Uint8List> fileByteList = {};
    Map<String, Uint8List> ctFileByteList = {};

    var vatTypeList = [ 0, 1, ];
    var vatTypeNameList = [ '포함', '별도', ];
    //var currentVatType = 0;

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

                    await FireStoreT.updateContract(ct, files: fileByteList, ctFiles: ctFileByteList);
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
                                        var cs_list = await SystemT.searchCSMeta(data);

                                        Customer? cs = await DialogCS.selectCS(context, cs_list);
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
                                                        var ens = ENAES.fUrlAES(downloadUrl);

                                                        var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName';
                                                        print(url);
                                                        await launchUrl( Uri.parse(url),
                                                          webOnlyWindowName: true ? '_blank' : '_self',
                                                        );
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
                                                              var ens = ENAES.fUrlAES(downloadUrl);

                                                              var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName';
                                                              print(url);
                                                              await launchUrl( Uri.parse(url),
                                                                webOnlyWindowName: true ? '_blank' : '_self',
                                                              );
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

                              await FireStoreT.updateContract(ct, files: fileByteList, ctFiles: ctFileByteList);
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

  /*static dynamic showCreateCtttt(BuildContext context, { Customer? css, }) async {
    var dividHeight = 6.0;
    //var _dragging = false;
    //List<XFile> _list = [];
    //late DropzoneViewController controller;
    Map<String, Uint8List> fileByteList = {};
    Map<String, Uint8List> ctFileByteList = {};

    var vatTypeList = [ 0, 1, ];
    var vatTypeNameList = [ '포함', '미포함', ];

    Contract ct = Contract.fromDatabase({});
    ct.contractList.add({});
    if(css != null) {
      //ct.c
    }

    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();

              List<Widget> ctW = [];
              for(int i = 0; i < ct.contractList.length; i++) {
                Widget w = SizedBox();
                var ctl = ct.contractList[i] as Map;
                if(ctl['unitPrice'] == null) ctl['unitPrice'] = '';
                if(ctl['count'] == null) ctl['count'] = '0';
                if(ctl['item'] == null) ctl['item'] = '';

                Item? ctlItem = SystemT.getItem(ctl['item'] ?? '');

                var count = int.tryParse(ctl['count']) ?? 0;
                var unitPrice = int.tryParse((ctl['unitPrice'] != '') ? ctl['unitPrice'] :
                (ctlItem != null) ? ctlItem?.unitPrice.toString() : '0') ?? 0;
                var totalPrice = 0, vat = 0, supplyPrice = 0;
                var isUnitLink = (ctl['unitPrice'] != '');

                if(ct.vatType == 0) { totalPrice = unitPrice * count;  vat = (totalPrice / 11).round(); supplyPrice = totalPrice - vat; }
                if(ct.vatType == 1) { vat = ((unitPrice * count) / 10).round(); totalPrice = unitPrice * count + vat;  supplyPrice = unitPrice * count; }

                w = Container( padding: EdgeInsets.only(bottom: 6),
                  child: TextButton(
                      onPressed:null,
                      style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                      child: Row(
                        children: [
                          WidgetT.title('${i + 1}', width: 28),
                          WidgetT.dividViertical(height: 28),
                          WidgetT.excelGrid(width: 200, label: '품목', text: SystemT.getItemName(ctl['item'] ?? ''),),
                          TextButton(
                              onPressed: () async {
                                Item? item = await selectItem(context);
                                FunT.setStateD = () { setStateS(() {}); };
                                if(item != null) {
                                  ctlItem = item;
                                  ctl['item'] = item.id;
                                  ctl['unitPrice'] = '';
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
                                    ctl['item'] = value;
                                    ctlItem = SystemT.getItem(value);
                                    if(ctlItem != null) {
                                      ctl['unitPrice'] = '';
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
                          WidgetT.dividViertical(height: 28),
                          WidgetT.excelGrid( text: SystemT.getItemUnit(ctl['item'] ?? ''), width: 50, label: '단위'),
                          WidgetT.dividViertical(height: 28),
                          WidgetT.excelInput(context, '$i::수량', width: 100, index: i, label: '수량',
                            onEdite: (i, data) {
                              var a = int.tryParse(data);
                              if(a == null) ctl['count'] = '0';
                              else ctl['count'] = a.toString();
                            },
                            text: StyleT.krw(count.toString()), value: count.toString(),
                          ),
                          WidgetT.dividViertical(height: 28),
                          WidgetT.excelInput(context, '$i::단가', width: 100, index: i, label: '단가',
                            onEdite: (i, data) {
                              var a = int.tryParse(data);
                              if(a == null) ctl['unitPrice'] = '';
                              else ctl['unitPrice'] = a.toString();
                            },
                            text: StyleT.krw(unitPrice.toString()), value: unitPrice.toString(),
                          ),
                          TextButton(
                              onPressed: () async {
                                if(ctl['unitPrice'] == '') ctl['unitPrice'] = ctlItem?.unitPrice.toString();
                                else ctl['unitPrice'] = '';
                                FunT.setStateDT();
                              },
                              style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                              child: Container( height: 28, width: 28,
                                child: isUnitLink ? WidgetT.iconMini(Icons.link_off) : WidgetT.iconMini(Icons.link),)
                          ),
                          WidgetT.dividViertical(height: 28),
                          WidgetT.excelInput(context, '$i::공급가액', width: 150, index: i, label: '공급가액',
                            onEdite: (i, data) {
                              var a = int.tryParse(data);
                              if(a == null) ct.contractList[i]['supplyPrice'] = '0';
                              else ct.contractList[i]['supplyPrice'] = a.toString();
                            },
                            text: StyleT.krw(supplyPrice.toString()), value: supplyPrice.toString(),),
                          WidgetT.dividViertical(height: 28),
                          WidgetT.excelInput(context, '$i::부가세', width: 100, index: i, label: 'VAT',
                            onEdite: (i, data) {
                              var a = int.tryParse(data);
                              if(a == null) ctl['vat'] = '0';
                              else ctl['vat'] = a.toString();
                            },
                            text: StyleT.krw(vat.toString()), value: vat.toString(),
                          ),
                          WidgetT.dividViertical(height: 28),
                          WidgetT.excelInput(context, '$i::합계', width: 150, index: i, label: '합계',
                            onEdite: (i, data) {
                              var a = int.tryParse(data);
                              if(a == null) ctl['totalPrice'] = '0';
                              else ctl['totalPrice'] = a.toString();
                            },
                            text: StyleT.krw(totalPrice.toString()), value: totalPrice.toString(),
                          ),
                          WidgetT.dividViertical(height: 28),
                          TextButton(
                              onPressed: () {
                                ct.contractList.removeAt(i);
                                FunT.setStateDT();
                              },
                              style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                              child: Container( height: 28, width: 28,
                                child: WidgetT.iconMini(Icons.cancel),)
                          ),
                        ],
                      )
                  ),
                );
                ctW.add(w);
              }

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
                    Container(padding: EdgeInsets.all(8), child: Text('계약정보', style: StyleT.titleStyle(bold: true))),
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
                            WidgetT.title('거래처', width: 100),
                            TextButton(
                              onPressed: () async {
                                Customer? c = await selectCS(context);
                                FunT.setStateD = () { setStateS(() {}); };

                                if(c != null) {
                                  ct.csUid = c.id;
                                  print(c.id + ' : ' + SystemT.getCSName(ct.csUid));
                                }
                                await FunT.setStateDT();
                              },
                              style: StyleT.buttonStyleOutline(padding: 0, round: 0, elevation: 0, strock: 1.4, color: StyleT.backgroundColor.withOpacity(0.5)),
                              child: Container( height: 28, alignment: Alignment.center,
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.text('${ct.csUid}', size: 10, width: 120),
                                      WidgetT.dividViertical(height: 28),
                                      WidgetT.title(SystemT.getCSName(ct.csUid) ?? '', width: 250),
                                    ],
                                  )),),
                          ],
                        ),
                        SizedBox(height: 18,),
                        WidgetT.textInput(context, '계약명', width: 250, label: '계약명',
                          onEdite: (i, data) { ct.ctName = data; },
                          text: ct.ctName,
                        ),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            WidgetT.textInput(context, '구매부서', width: 250, label: '구매부서',
                              onEdite: (i, data) { ct.purchasingDepartment = data; },
                              text: ct.purchasingDepartment,
                            ),
                            SizedBox(width: dividHeight,),
                            WidgetT.textInput(context, '담당자', width: 100, label: '담당자', labelSize: 60,
                              onEdite: (i, data) { ct.manager = data; },
                              text: ct.manager,
                            ),
                          ],
                        ),
                        SizedBox(height: 18,),
                        Row(
                          children: [
                            WidgetT.textInput(context, '납품지주소', width: 250, label: '납품지주소',
                              onEdite: (i, data) { ct.workSitePlace = data; },
                              text: ct.workSitePlace,
                            ),
                            SizedBox(width: dividHeight,),
                            WidgetT.textInput(context, '연락처', width: 100, label: '연락처', labelSize: 60,
                              onEdite: (i, data) { ct.managerPhoneNumber = data; },
                              text: ct.managerPhoneNumber,
                            ),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            //WidgetT.title('세부사항', width: 100 ),
                            WidgetT.textInput(context, '계약일자', width: 150, label: '계약일자',
                              onEdite: (i, data) { ct.contractAt = StyleT.dateEpoch(data); },
                              text: StyleT.dateInputFormatAtEpoch(ct.contractAt.toString()),
                            ),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            WidgetT.title('계약서 첨부', width: 100),
                            TextButton(onPressed: () async {
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
                              style: StyleT.buttonStyleOutline(padding: 0, round: 0, elevation: 8, strock: 1, color: StyleT.accentColor.withOpacity(0.5)),
                              child: Container(
                                  child: Row(
                                    children: [
                                      WidgetT.iconMini(Icons.file_copy_rounded),
                                      WidgetT.title('선택',),
                                      SizedBox(width: 4,),
                                    ],
                                  )),),
                            SizedBox(width: 18,),
                            for(int i = 0; i < ct.contractFiles.length; i++)
                              TextButton(
                                  onPressed: () async {
                                    var downloadUrl = ct.contractFiles.values.elementAt(i);
                                    var fileName = ct.contractFiles.keys.elementAt(i);
                                    print(downloadUrl);
                                    var res = await http.get(Uri.parse(downloadUrl));
                                    var bodyBytes = res.bodyBytes;
                                    print(bodyBytes.length);
                                    PDFX.showPDFtoDialog(context, data: bodyBytes, name: fileName);
                                    *//* final storageRef = FirebaseStorage.instance.ref();
                                          final islandRef = storageRef.child("customer/${cs.id}/${cs.filesMap.keys.elementAt(i)}");
                                          try {
                                            const oneMegabyte = 2048 * 2048;
                                            final Uint8List? data = await islandRef.getData(oneMegabyte);
                                            print(data!.length);
                                            //PDFX.showPDFtoDialog(context, data: data, name: fileByteList.keys.elementAt(i));
                                          } on FirebaseException catch (e) {
                                            print(e);
                                          }*//*
                                  },
                                  style: StyleT.buttonStyleOutline(round: 0, elevation: 8, padding: 0, color: StyleT.accentLowColor.withOpacity(0.5), strock: 1),
                                  child: Container(padding: EdgeInsets.all(0), child: Row(
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
                              TextButton(
                                  onPressed: () {
                                    PDFX.showPDFtoDialog(context, data: ctFileByteList.values.elementAt(i), name: ctFileByteList.keys.elementAt(i));
                                  },
                                  style: StyleT.buttonStyleOutline(round: 0, elevation: 8, padding: 0, color: StyleT.accentLowColor.withOpacity(0.5), strock: 1),
                                  child: Container(padding: EdgeInsets.all(0), child: Row(
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
                        ),
                        SizedBox(height: 18,),
                        SizedBox(height: 2,),
                        Row(
                          children: [
                            WidgetT.title('메모', width: 100 ),
                            Expanded(child: WidgetT.textInput(context, '메모', width: 250, height: 64, isMultiLine: true,
                              onEdite: (i, data) { ct.memo = data; },
                              text: ct.memo,
                            ),)
                          ],
                        ),


                        SizedBox(height: 18,),
                        Row(
                          children: [
                            WidgetT.title('계약내용',),
                            SizedBox(width: 12,),
                            TextButton(onPressed: () async {
                              ct.contractList.add({});
                              FunT.setStateDT();
                            },
                              style: StyleT.buttonStyleOutline(round: 0, elevation: 8, padding: 0,
                                  color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                              child: Container(
                                  child: Row(
                                    children: [
                                      WidgetT.iconMini(Icons.add, size: 28),
                                      WidgetT.title('추가',),
                                      SizedBox(width: 6,),
                                    ],
                                  )),),

                            Row(
                              children: [
                                WidgetT.title('지불관련', width: 100 ),
                                for(var v in vatTypeList)
                                  Container(
                                    padding: EdgeInsets.only(right: dividHeight),
                                    child: TextButton(
                                        onPressed: () {
                                          ct.vatType = v;
                                          FunT.setStateDT();
                                        },
                                        style: StyleT.buttonStyleOutline(round: 0, elevation: 8, padding: 0,
                                            color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
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
                        SizedBox(height: dividHeight,),
                        Column(
                          children: [
                            for(var w in ctW) w,
                          ],
                        ),

                        SizedBox(height: 18,),
                        Row(
                          children: [
                            WidgetT.title('파일첨부',),
                            SizedBox(width: 12,),
                            TextButton(onPressed: () async {
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
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 100, color: StyleT.accentLowColor.withOpacity(0.07),
                                padding: EdgeInsets.all(dividHeight),
                                child: Wrap(
                                  runSpacing: dividHeight, spacing: dividHeight,
                                  children: [
                                    for(int i = 0; i < ct.filesMap.length; i++)
                                      TextButton(
                                          onPressed: () async {
                                            var downloadUrl = ct.filesMap.values.elementAt(i);
                                            var fileName = ct.filesMap.keys.elementAt(i);
                                            print(downloadUrl);
                                            var res = await http.get(Uri.parse(downloadUrl));
                                            var bodyBytes = res.bodyBytes;
                                            print(bodyBytes.length);
                                            PDFX.showPDFtoDialog(context, data: bodyBytes, name: fileName);
                                          },
                                          style: StyleT.buttonStyleOutline(round: 0, elevation: 8, padding: 0, color: StyleT.accentLowColor.withOpacity(0.5), strock: 1),
                                          child: Container(padding: EdgeInsets.all(0), child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(width: 6,),
                                              WidgetT.title(ct.filesMap.keys.elementAt(i),),
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                ],
              );
            },
          );
        });

    if(aa == null) aa = false;
    return aa;
  }*/

  Widget build(context) {
    return Container();
  }
}