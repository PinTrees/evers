import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/ui/dialog_item.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../class/Customer.dart';
import '../../class/contract.dart';
import '../../class/database/item.dart';
import '../../class/database/ledger.dart';
import '../../class/database/process.dart';
import '../../class/purchase.dart';
import '../../class/revenue.dart';
import '../../class/schedule.dart';
import '../../class/system.dart';
import '../../class/system/state.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/excel.dart';
import '../../class/widget/text.dart';
import '../../core/window/ResizableWindow.dart';
import '../../helper/aes.dart';
import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';
import '../../helper/pdfx.dart';
import '../../ui/dialog_contract.dart';
import '../../ui/dialog_pu.dart';
import '../../ui/dialog_revenue.dart';
import '../../ui/dialog_schedule.dart';
import '../../ui/dl.dart';
import '../../ui/ip.dart';
import '../../ui/ux.dart';

class WindowCT extends StatefulWidget {
  Contract org_ct;
  ResizableWindow parent;

  WindowCT({ required this.org_ct, required this.parent }) : super(key: UniqueKey()) { }

  @override
  _WindowCTState createState() => _WindowCTState();
}

class _WindowCTState extends State<WindowCT> {
  var dividHeight = 6.0;
  Map<String, Uint8List> fileByteList = {};
  Map<String, Uint8List> ctFileByteList = {};
  Contract ct = Contract.fromDatabase({});

  List<TS> tslist = [];
  List<Schedule> sch_list = [];
  List<Ledger> ledgerList = [];
  List<Purchase> purList = [];

  var vatTypeNameList = [ '포함', '별도', ];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  void initAsync() async {
    print(widget.org_ct.id);

    ct = await DatabaseM.getContractDoc(widget.org_ct.id);
    if(ct == null) return;

    ledgerList = await DatabaseM.getLedgerRevenueList(ct.csUid);
    purList = await DatabaseM.getPur_withCT(ct.id);
    tslist = await DatabaseM.getTransactionCt(ct.id);
    sch_list = await DatabaseM.getSCH_CT(ct.id);

    setState(() {});
    setState(() {});
  }

  Widget main = SizedBox();

  Widget mainBuild() {
    var allPay = 0, allPayedAmount = 0;

    /// 매입 UI
    List<Widget> purWidgets = [];
    purWidgets.add(Purchase.OnTabelHeader());
    for(int i = 0; i < purList.length; i++) {
      var pu = purList[i];
      var item = SystemT.getItem(pu.item) ?? Item.fromDatabase({});
      pu.init();
      allPay += pu.totalPrice;

      var w = pu.OnTableUI(
        context,
        index: i + 1,
        setState: () { setState(() {}); },
        itemName: item.name,
        itemUnit: item.unit,
      );
      purWidgets.add(w);
      purWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }

    /// 매출
    List<Widget> reW = [];
    reW.add(Revenue.buildTitleUI());
    for(int i = 0; i < ct.revenueList.length; i++) {
      Widget w = SizedBox();
      var re = ct.revenueList[i];
      var item = SystemT.getItem(re.item) ?? Item.fromDatabase({});

      re.init();
      allPay += re.totalPrice;

      w = re.buildUsAsync(
        item,
        state: () { setState(() {}); },
        onEdite:  () async {
          var data = await DialogRE.showInfoRe(context, org: re);

          WidgetT.loadingBottomSheet(context, text:'로딩중');
          if(data != null) {
            await ct.updateInit();
          }
          Navigator.pop(context);
          setState(() {});
        },
      );

      reW.add(w);
      reW.add(WidgetT.dividHorizontal(size: 0.35));
    }

    int ledgerIndex = 0;
    List<Widget> ledgerWidgets = [];
    ledgerWidgets.add(Row(
        children: [
          Expanded(child: Ledger.onTableHeader()),
          ButtonT.Icon( icon: Icons.refresh,
              onTap: () async {
                WidgetT.loadingBottomSheet(context);
                ledgerList = await DatabaseM.getLedgerRevenueList(ct.csUid);
                Navigator.pop(context);
                setState(() {});
              }),
        ]
    ));
    ledgerList.forEach((e) {
      ledgerWidgets.add(e.onTableUI(index: ledgerIndex++));
      ledgerWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    });

    /// 계약
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
              Expanded(child: WidgetT.excelGrid( text: ctl['memo'], width: 200,),),
            ],
          ));
      ctW.add(w);
      ctW.add(WidgetT.dividHorizontal(size: 0.35));
    }

    /// 결재
    List<Widget> tsW = [];
    tsW.add(CompTS.tableHeader());
    for(int i = 0; i < tslist.length; i++) {
      var tmpTs = tslist[i];
      if(tmpTs.type == 'PU') continue;
      allPayedAmount += tmpTs.amount;

      tsW.add(CompTS.tableUI(context, tmpTs, index: i + 1, setState: (){ setState(() {}); }, refresh: initAsync));
      tsW.add(WidgetT.dividHorizontal(size: 0.35));
    }

    /// 결재
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

    /// 일정
    List<Widget> schW = [];

    schW.add(Schedule.buildTitle());
    for(int i = 0; i < sch_list.length; i++) {
      var sch = sch_list[i];
      var w = sch.buildUIAsync(index: i + 1, onEdite: () async {
        var data = await DialogSHC.showSCHEdite(context, sch);
        if(data != null) {
        }
      });
      schW.add(w);
      schW.add(WidgetT.dividHorizontal(size: 0.35));
    }


    var dividCol =  SizedBox(height: dividHeight * 8,);
    var btnStyle =  StyleT.buttonStyleOutline(round: 8, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7);
    var gridStyle = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.00), stroke: 0.01, strokeColor: StyleT.titleColor.withOpacity(0.0));
    var gridStyleT = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.03), stroke: 2, strokeColor: StyleT.titleColor.withOpacity(0.1));
    var btnStyleT = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.1), stroke: 0.35,);

    var ctInfoWidget = Container(
      decoration: gridStyleT,
      child: Column(children: [
        Container( height: 28,
          child: ListBoxT.Rows(
              spacingWidget: WidgetT.dividViertical(),
              children: [
                ExcelT.ExcelInput(context, 'df계약명',
                  lavel: "계약명", widthLavel: 150, width: 300,
                  onEdited: (i, data) { ct.ctName = data; },
                  setState: () { setState(() {}); },
                  text: ct.ctName,
                ),
                ExcelT.ExcelGrid(
                  lavel: "거래처", widthLavel: 150, width: 250,
                  text: SystemT.getCSName(ct.csUid),
                ),
              ]
          ),
        ),
        WidgetT.dividHorizontal(size: 0.35),
        Container( height: 28,
          child: ListBoxT.Rows(
              spacingWidget: WidgetT.dividViertical(),
              children: [
                ExcelT.ExcelInput(context, 'df구매부서',
                  lavel: "구매부서", widthLavel: 150, width: 300,
                  setState: () { setState(() {}); },
                  onEdited: (i, data) { ct.purchasingDepartment = data; },
                  text: ct.purchasingDepartment,
                ),
                ExcelT.ExcelInput(context, 'df담당자',
                  lavel: "담당자", widthLavel: 150, width: 250,
                  setState: () { setState(() {}); },
                  onEdited: (i, data) { ct.manager = data; },
                  text: ct.manager,
                ),
                ExcelT.ExcelInput(context, 'df연락처',
                  lavel: "연락처", widthLavel: 150, width: 250,
                  setState: () { setState(() {}); },
                  onEdited: (i, data) { ct.managerPhoneNumber = data; },
                  text: ct.managerPhoneNumber,
                ),
              ]
          ),
        ),
        WidgetT.dividHorizontal(size: 0.35),
        Container( height: 28,
          child: ListBoxT.Rows(
              spacingWidget: WidgetT.dividViertical(),
              children: [
                ExcelT.ExcelInput(context, 'df납품지주소',
                  lavel: "납품지주소", widthLavel: 150, width: 300,
                  setState: () { setState(() {}); },
                  onEdited: (i, data) { ct.workSitePlace = data; },
                  text: ct.workSitePlace, ),
                ExcelT.ExcelInput(context, 'df계약일자',
                  lavel: "계약일자", widthLavel: 150, width: 250,
                  setState: () { setState(() {}); },
                  onEdited: (i, data) { ct.contractAt = StyleT.dateEpoch(data); },
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
                    setState: () { setState(() {}); },
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
                            ButtonT.IconText(
                              icon: Icons.file_copy_rounded,
                              text: ct.contractFiles.keys.elementAt(i),
                              onTap: () async {
                                var downloadUrl = ct.contractFiles.values.elementAt(i);
                                var fileName = ct.contractFiles.keys.elementAt(i);
                                var ens = ENAES.fUrlAES(downloadUrl);

                                var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName';
                                await launchUrl( Uri.parse(url),     webOnlyWindowName: true ? '_blank' : '_self', );
                              },
                              leaging: TextButton(
                                  onPressed: () {
                                    //fileByteList.remove(fileByteList.keys.elementAt(i));
                                    setState(() {});
                                  },
                                  style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                  child: Container( height: 28, width: 28,
                                    child: WidgetT.iconMini(Icons.cancel),)
                              ),
                            ),
                          for(int i = 0; i < ctFileByteList.length; i++)
                            ButtonT.IconText(
                              icon: Icons.file_copy_rounded,
                              text: ctFileByteList.keys.elementAt(i),
                              onTap: () async {
                                PDFX.showPDFtoDialog(context, data: ctFileByteList.values.elementAt(i), name: ctFileByteList.keys.elementAt(i));
                              },
                              leaging: TextButton(
                                  onPressed: () {
                                    ctFileByteList.remove(ctFileByteList.keys.elementAt(i));
                                    setState(() {});
                                  },
                                  style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                  child: Container( height: 28, width: 28,
                                    child: WidgetT.iconMini(Icons.cancel),)
                              ),
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
                              ButtonT.IconText(
                                icon: Icons.file_copy_rounded,
                                text: ct.getFileName(ct.filesMap.keys.elementAt(i)),
                                onTap: () async {
                                  var downloadUrl = ct.filesMap.values.elementAt(i);
                                  var fileName = ct.getFileName(ct.filesMap.keys.elementAt(i));
                                  var ens = ENAES.fUrlAES(downloadUrl);
                                  var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName';
                                  await launchUrl( Uri.parse(url),     webOnlyWindowName: true ? '_blank' : '_self', );
                                  },
                                leaging: TextButton(
                                    onPressed: () {
                                      WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
                                      FunT.setStateDT();
                                    },
                                    style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                    child: Container( height: 28, width: 28,
                                      child: WidgetT.iconMini(Icons.cancel),)
                                ),
                              ),
                            for(int i = 0; i < fileByteList.length; i++)
                              ButtonT.IconText(
                                icon: Icons.file_copy_rounded,
                                text: ct.getFileName(fileByteList.keys.elementAt(i)),
                                onTap: () async {
                                  PDFX.showPDFtoDialog(context, data: fileByteList.values.elementAt(i), name: fileByteList.keys.elementAt(i));
                                },
                                leaging: TextButton(
                                    onPressed: () {
                                      ctFileByteList.remove(ctFileByteList.keys.elementAt(i));
                                      setState(() {});
                                    },
                                    style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                    child: TextButton(
                                        onPressed: () {
                                          fileByteList.remove(fileByteList.keys.elementAt(i));
                                          FunT.setStateDT();
                                        },
                                        style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                        child: Container( height: 28, width: 28,
                                          child: WidgetT.iconMini(Icons.cancel),)
                                    ),
                                ),
                              ),
                          ],
                        ),)),
                ],
              ),
            )
        ),
      ],),);

    return main = Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(18),
              child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextT.Title(text:'계약상세 정보' ),
                  SizedBox(height: dividHeight,),
                  ctInfoWidget,
                  //ctInfoWiwwwdget,
                  SizedBox(height: dividHeight,),
                  Row(
                    children: [
                      ButtonT.IconText(
                        icon: Icons.file_copy_rounded,
                        text: '계약서 파일 선택',
                        onTap: () async {
                          FilePickerResult? result;
                          try {
                            result = await FilePicker.platform.pickFiles();
                          } catch (e) {
                            WidgetT.showSnackBar(context, text: '파일선택 오류');
                            print(e);
                          }
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
                          setState(() {});
                        }
                      ),
                      SizedBox(width: dividHeight,),
                      ButtonT.IconText(
                          icon: Icons.file_copy_rounded,
                          text: '파일 선택',
                          onTap: () async {
                            FilePickerResult? result;
                            try {
                              result = await FilePicker.platform.pickFiles();
                            } catch (e) {
                              WidgetT.showSnackBar(context, text: '파일선택 오류');
                              print(e);
                            }
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
                            setState(() {});
                          }
                      ),
                    ],
                  ),
                  SizedBox(height: dividHeight,),

                  dividCol,
                  TextT.Title(text:'계약내용' ),
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
                  TextT.Title(text:'스케쥴 및 메모' ),
                  SizedBox(height: dividHeight,),
                  Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: schW,)),
                  SizedBox(height: dividHeight,),
                  Row(
                    children: [
                      TextButton(onPressed: () async {
                        await DialogSHC.showSCHCreate(context, ctUid: ct.id);
                        sch_list = await DatabaseM.getSCH_CT(ct.id);
                        setState(() {});
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
                  TextT.Title(text:'매입 목록' ),
                  SizedBox(height: dividHeight,),
                  Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: purWidgets,)),

                  dividCol,
                  Row(
                    children: [
                      TextT.Title(text:'매출 목록' ),
                      SizedBox(width: 6,),

                      ButtonT.IconText(icon: Icons.open_in_new_sharp, text: "출고원장 작업창으로 이동", onTap: () async {
                        var url = Uri.base.toString().split('/work').first + '/printform/releaserevenue/${ ct.id }';
                        await launchUrl( Uri.parse(url), webOnlyWindowName: true ? '_blank' : '_self');
                        FunT.setStateMain();
                      }),
                    ],
                  ),
                  SizedBox(height: dividHeight,),
                  Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: reW,)),
                  SizedBox(height: dividHeight,),
                  Row(
                    children: [
                      ButtonT.IconText(
                        icon: Icons.add_box,
                        text: '매출추가',
                        onTap: () async {
                          var data = await DialogRE.showCreateRe(context, ctUid: ct.id);
                          WidgetT.loadingBottomSheet(context, text:'로딩중');
                          if(data != null) {
                            await ct.updateInit();
                          }
                          Navigator.pop(context);
                          setState(() {});
                        }
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
                  TextT.Title(text: '출고원장'),
                  SizedBox(height: dividHeight,),
                  Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:ledgerWidgets,)),


                  dividCol,
                  TextT.Title(text: '수납목록'),
                  SizedBox(height: dividHeight,),
                  Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: tsW,)),
                  SizedBox(height: dividHeight,),
                  Row(
                    children: [
                      ButtonT.IconText(
                        icon: Icons.add_box,
                        text: '수금추가',
                        onTap: () {
                          WidgetT.showSnackBar(context, text: '하단 버튼으로 변경 예정이며 제거될 버튼입니다.');
                        }
                      ),
                    ],
                  ),

                  dividCol,
                  TextT.Title(text: '금엑현황'),
                  SizedBox(height: dividHeight,),
                  Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: tsAllW,)),
                ],
              ),
            ),
          ),

          /// action
          Row(
            children: [
              Expanded(child:TextButton(
                  onPressed: () async {
                    var alert = await DialogT.showAlertDl(context, title: ct.csUid ?? 'NULL');
                    if(alert == false) {
                      WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                      return;
                    }

                    var data = await DatabaseM.updateContract(ct, files: fileByteList, ctFiles: ctFileByteList);
                    if(data == null) { WidgetT.showSnackBar(context, text: 'Database Error'); return; }
                    WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                    Navigator.pop(context);
                  },
                  style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                  child: Container(
                      color: StyleT.accentColor.withOpacity(0.5), height: 42,
                      child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WidgetT.iconMini(Icons.save),
                          Text('계약저장', style: StyleT.titleStyle(),),
                          SizedBox(width: 6,),
                        ],
                      )
                  )
              ),),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return mainBuild();
  }
}
