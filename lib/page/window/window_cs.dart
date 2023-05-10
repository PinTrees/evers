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
import '../../class/database/process.dart';
import '../../class/purchase.dart';
import '../../class/system.dart';
import '../../class/system/state.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
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
import '../../ui/dl.dart';
import '../../ui/ip.dart';
import '../../ui/ux.dart';

class WindowCS extends StatefulWidget {
  Customer org_cs;
  ResizableWindow parent;

  WindowCS({ required this.org_cs, required this.parent }) : super(key: UniqueKey()) { }

  @override
  _WindowCSState createState() => _WindowCSState();
}

class _WindowCSState extends State<WindowCS> {
  var dividHeight = 6.0;

  Map<String, Uint8List> fileByteList = {};
  List<Purchase> purs = [];
  Customer cs = Customer.fromDatabase({});

  var pageLimit = 10;
  var puIndex = 0;
  var tsIndex = 0;

  List<Contract> contractList = [];
  List<TS> tsList = [];

  List<ProcessItem> processingList = [];
  List<ProcessItem> outputList = [];

  Map<String, double> usedAmount = {};
  Map<String, ItemCount> outputAmount = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  void initAsync() async {
    //WidgetT.loadingBottomSheet(context, text: 'data loading ...');
    await widget.org_cs.update();

    purs = await widget.org_cs.getPurchase();
    purs.sort((a, b) => b.purchaseAt.compareTo(a.purchaseAt) );

    var jsonString = jsonEncode(widget.org_cs.toJson());
    var json = jsonDecode(jsonString);
    cs = Customer.fromDatabase(json);

    if(cs.state == 'DEL') {
      //Navigator.pop(context);
      WidgetT.showSnackBar(context, text: '삭제되었습니다.');
      return;
    }

    contractList = await DatabaseM.getCtWithCs(cs.id);
    tsList = await cs.getTransaction();

    processingList = await DatabaseM.getProcessItemGroupByCsUid(cs.id);
    outputList = await DatabaseM.getProcessItemGroupByCsUid(cs.id, isOutput: true);

    for(var data in outputList) {
      var item = SystemT.getItem(data.itUid);
      if(item == null) continue;

      /// 작업 완료 품목 물량 통합관리
      if(outputAmount.containsKey(item.id)) outputAmount[item.id]!.incrementCount(data.amount);
      else outputAmount[item.id] = ItemCount.fromData(item, data.amount);

      /// 작업에 소모된 수량을 확인하여 통합
      if(usedAmount.containsKey(data.prUid)) usedAmount[data.prUid] = usedAmount[data.prUid]! + data.usedAmount;
      else usedAmount[data.prUid] = data.usedAmount;
    }

    setState(() {});
    //Navigator.pop(context);
  }

  Widget main = SizedBox();

  Widget mainBuild() {
    int index = 1;
    int startIndex = 0;

    List<Widget> puW = [];
    puW.add(Purchase.OnTabelHeader());
    startIndex = puIndex * pageLimit;
    for(int i = startIndex; i < startIndex + pageLimit; i++) {
      if(i >= purs.length) break;

      var pu = purs[i];
      var item = SystemT.getItem(pu.item);

      var w = pu.OnTableUI(context,
          setState: () { setState(() {}); }, index: i + 1,
          itemName: item != null ? item.name : '', itemUnit: item!=null? item.unit : '');
      puW.add(w);
      puW.add(WidgetT.dividHorizontal(size: 0.35));
    }
    puW.add(SizedBox(height: dividHeight,));
    puW.add(ListBoxT.Rows(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        for(int i = 0; i < (purs.length / pageLimit).ceil(); i++)
          ButtonT.Text(
              size: 28,
              text: (i + 1).toString(),
              onTap: () {
                setState(() {  puIndex = i; });
              }
          )
      ],
    ));

    List<Widget> tsWidgets = [];
    startIndex = tsIndex * pageLimit; index = 1;
    for(int i = startIndex; i < startIndex + pageLimit; i++) {
      if(i >= tsList.length) break;

      var ts = tsList.elementAt(i);
      tsWidgets.add(CompTS.tableUI(context, ts, index: index++, refresh: () { initAsync(); }));
      tsWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }
    tsWidgets.add(SizedBox(height: dividHeight,));
    tsWidgets.add(ListBoxT.Rows(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        for(int i = 0; i < (tsList.length / pageLimit).ceil(); i++)
          ButtonT.Text(
              size: 28,
              text: (i + 1).toString(),
              onTap: () {
                setState(() {  tsIndex = i; });
              }
          )
      ],
    ));

    List<Widget> outputWidgets = [];
    for(var data in outputAmount.values) {
      outputWidgets.add(data.OnTableUI());
      outputWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }

    List<Widget> processingWidgets = [];
    for(var prs in processingList) {
      Item? item = SystemT.getItem(prs.itUid);
      processingWidgets.add(prs.OnTableUI(
        context: context,
        cs: cs,
        item: item,
        usedAmount: usedAmount[prs.id] ?? 0.0,
      ));
      processingWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }

    List<Widget> widgetsCt = [];
    index = 1;
    contractList.forEach((ct) {
      var w = CompContract.tableUI(context, ct, index: index++,
        onTap: () async {
          /// 윈도우창 요청
          var parent = UIState.mdiController!.createWindow(context);
          var page = WindowTS(cs: cs, refresh: initAsync, parent: parent,);
          UIState.mdiController!.addWindow(context, widget: page, resizableWindow: parent);
        }
      );
      widgetsCt.add(w);
      widgetsCt.add(WidgetT.dividHorizontal(size: 0.35));
    });

    var gridStyle = StyleT.inkStyle(round: 8, color: Colors.black.withOpacity(0.03), stroke: 0.7, strokeColor: StyleT.titleColor.withOpacity(0.35));

    return main = Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextT.Title(text: '거래처 상세 정보',),
                  SizedBox(height: dividHeight,),
                  Container( decoration: gridStyle,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        children: [
                          Container( height: 28,
                            child: Row(
                                children: [
                                  WidgetEX.excelTitle(width: 150, text: '구분',),
                                  WidgetT.dividViertical(),
                                  WidgetT.dropMenu(dropMenus: ['개인', '사업자',], width: 250,
                                    onEdite: (i, data) { cs.bsType = data; },
                                    text: cs.bsType,
                                  ),

                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '거래처분류',),
                                  WidgetT.dividViertical(),
                                  WidgetT.dropMenu(dropMenus: ['매입', '매출', '매입/매출'], width: 250,
                                    onEdite: (i, data) { cs.csType = data; },
                                    text: cs.csType,
                                  ),
                                ]
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( height: 28,
                            child: Row(
                                children: [
                                  WidgetEX.excelTitle(width: 150, text: '상호명',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, 'cs상호명', width: 250,
                                    onEdite: (i, data) { cs.businessName = data; },
                                    text: cs.businessName,
                                  ),

                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '대표이름',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, 'cs대표이름', width: 250,
                                    onEdite: (i, data) { cs.representative = data; },
                                    text: cs.representative,
                                  ),
                                ]
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( height: 28,
                            child: Row(
                                children: [
                                  WidgetEX.excelTitle(width: 150, text: '사업자등록번호',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '사업자등록번호1', width: 70,
                                    onEdite: (i, data) { cs.businessRegistrationNumber['0'] = data; },
                                    text: cs.businessRegistrationNumber['0'],
                                  ),
                                  WidgetT.title('ㅡ', width: 20,),
                                  WidgetT.excelInput(context, '사업자등록번호2', width: 70,
                                    onEdite: (i, data) { cs.businessRegistrationNumber['1'] = data; },
                                    text: cs.businessRegistrationNumber['1'],
                                  ),
                                  WidgetT.title('ㅡ', width: 20,),
                                  WidgetT.excelInput(context, '사업자등록번호3', width: 70,
                                    onEdite: (i, data) { cs.businessRegistrationNumber['2'] = data; },
                                    text: cs.businessRegistrationNumber['2'],
                                  ),

                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '팩스번호',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '팩스번호1', width: 70,
                                    onEdite: (i, data) { cs.faxNumber['0'] = data; },
                                    text: cs.faxNumber['0'],
                                  ),
                                  WidgetT.title('ㅡ', width: 20,),
                                  WidgetT.excelInput(context, '팩스번호2', width: 70,
                                    onEdite: (i, data) { cs.faxNumber['1'] = data; },
                                    text: cs.faxNumber['1'],
                                  ),
                                  WidgetT.title('ㅡ', width: 20,),
                                  WidgetT.excelInput(context, '팩스번호3', width: 70,
                                    onEdite: (i, data) { cs.faxNumber['2'] = data; },
                                    text: cs.faxNumber['2'],
                                  ),
                                ]
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( height: 28,
                            child: Row(
                                children: [
                                  WidgetEX.excelTitle(width: 150, text: '담당자',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '담당자', width: 250,
                                    onEdite: (i, data) { cs.manager = data; },
                                    text: cs.manager,
                                  ),
                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '전화번호',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '전화번호1', width: 250,
                                    onEdite: (i, data) { cs.companyPhoneNumber = data; },
                                    text: cs.companyPhoneNumber,
                                  ),
                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '모바일',),
                                  WidgetT.excelInput(context, '모바일전화번호', width: 250,
                                    onEdite: (i, data) { cs.phoneNumber = data; },
                                    text: cs.phoneNumber,
                                  ),
                                ]
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( height: 28,
                            child: Row(
                                children: [
                                  WidgetEX.excelTitle(width: 150, text: '이메일',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '담당자이메일', width: 250,
                                    onEdite: (i, data) { cs.email = data; },
                                    text: cs.email,
                                  ),
                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '홈페이지',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '홈페이지', width: 250,
                                    onEdite: (i, data) { cs.website = data; },
                                    text: cs.website,
                                  ),
                                ]
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( padding: EdgeInsets.all(0),
                            child: IntrinsicHeight(
                              child: Row(
                                  children: [
                                    WidgetEX.excelTitle(width: 150, text: '주소',),
                                    WidgetT.dividViertical(),
                                    Expanded(child: WidgetTF.textTitInput(context, '주소', isMultiLine: true, textSize: 12,
                                      onEdite: (i, data) { cs.address = data; },
                                      text: cs.address,
                                    ),)
                                  ]
                              ),
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
                                      onEdite: (i, data) { cs.memo = data; },
                                      text: cs.memo,
                                    ),)
                                  ]
                              ),
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( height: 28,
                            child: Row(
                                children: [
                                  WidgetEX.excelTitle(width: 150, text: '업태',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '업태', width: 250,
                                    onEdite: (i, data) { cs.businessType = data; },
                                    text: cs.businessType,
                                  ),
                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '종목 ( , , )',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '종목', width: 400,
                                      onEdite: (i, data) { cs.businessItem = data.toString().split(','); },
                                      text: cs.businessItem.join(', '), value: cs.businessItem.join(',')
                                  ),
                                ]
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( height: 28,
                            child: Row(
                                children: [
                                  WidgetEX.excelTitle(width: 150, text: '은행',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '은행', width: 250,
                                    onEdite: (i, data) { cs.account['bank'] = data; },
                                    text: cs.account['bank'],
                                  ),
                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '계좌번호',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '계좌번호', width: 250,
                                    onEdite: (i, data) { cs.account['number'] = data; },
                                    text: cs.account['number'],
                                  ),

                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '예금주',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '예금주', width: 250,
                                    onEdite: (i, data) { cs.account['user'] = data; },
                                    text: cs.account['user'],
                                  ),
                                ]
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container(
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    SizedBox(width: dividHeight * 2, height: 28,),
                                    WidgetT.text('첨부파일', size: 10),
                                    SizedBox(width: dividHeight,),
                                    Expanded(
                                        flex: 7,
                                        child: Container(
                                          padding: EdgeInsets.all(dividHeight),
                                          child: Wrap(
                                            runSpacing: dividHeight, spacing: dividHeight * 3,
                                            children: [
                                              for(int i = 0; i < cs.filesMap.length; i++)
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    InkWell(
                                                        onTap: () async {
                                                          var downloadUrl = cs.filesMap.values.elementAt(i);
                                                          var fileName = cs.filesMap.keys.elementAt(i);
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
                                                                WidgetT.title(cs.filesMap.keys.elementAt(i),),
                                                                TextButton(
                                                                    onPressed: () {
                                                                      WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
                                                                      setState(() {});
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
                                                                WidgetT.title(fileByteList.keys.elementAt(i),),
                                                                TextButton(
                                                                    onPressed: () {
                                                                      fileByteList.remove(fileByteList.keys.elementAt(i));
                                                                      setState(() {});
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
                  Row(children: [
                    TextButton(onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles();
                      if( result != null && result.files.isNotEmpty ){
                        String fileName = result.files.first.name;
                        fileByteList[fileName] = result.files.first.bytes!;
                        setState(() {});
                      }
                    },
                      style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                      child: Container( height: 28,
                          child: Row(
                            children: [
                              WidgetT.iconMini(Icons.file_copy_rounded),
                              WidgetT.title('첨부파일추가',),
                              SizedBox(width: dividHeight,),
                            ],
                          )),),
                  ],),
                  SizedBox(height: dividHeight * 8,),

                  TextT.Title(text: '생산관리 - 거래처 연결품목 재고관리',),
                  SizedBox(height: dividHeight,),
                  ItemCount.OnTableHeader(),
                  Column(children: outputWidgets,),
                  SizedBox(height: dividHeight * 8,),

                  TextT.Title(text: '생산관리 - 공정관리',),
                  SizedBox(height: dividHeight,),
                  ProcessItem.onTableHeader(),
                  Column(children: processingWidgets,),
                  SizedBox(height: dividHeight * 8,),

                  TextT.Title(text: '매입목록',),
                  SizedBox(height: dividHeight,),
                  Container(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: puW,)),

                  TextT.Title(text: '수납목록',),
                  SizedBox(height: dividHeight,),
                  CompTS.tableHeader(),
                  Column(children: tsWidgets,),
                  SizedBox(height: dividHeight * 4,),

                  WidgetT.title('계약목록', size: 14),
                  SizedBox(height: dividHeight,),
                  CompContract.tableHeader(),
                  Column(children: widgetsCt,),
                ],)
            ),
          ),

          /// action
          Row(
            children: [
              Expanded(
                child:InkWell(
                    onTap: () async {
                      var result = await DialogRE.showCreateRe(context);
                      if(result != null) return;
                    },
                    child: Container(
                        color: Colors.blue.withOpacity(0.5), height: 42,
                        child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WidgetT.iconMini(Icons.output),
                            Text('신규 매출 등록', style: StyleT.titleStyle(),),
                            SizedBox(width: 6,),
                          ],
                        )
                    )
                ),),
              Expanded(
                child:InkWell(
                    onTap: () async {
                      var result = await DialogPU.showCreateNormalPuWithCS(context, cs);
                      if(result != null) {
                        purs = await DatabaseM.getPur_withCS(cs.id);
                      };
                    },
                    child: Container(
                        color: Colors.red.withOpacity(0.5), height: 42,
                        child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WidgetT.iconMini(Icons.input),
                            Text('신규 매입 등록', style: StyleT.titleStyle(),),
                            SizedBox(width: 6,),
                          ],
                        )
                    )
                ),),
              Expanded(
                child:InkWell(
                    onTap: () async {
                      WidgetT.showSnackBar(context, text: "품목에 대한매입은 계약을 비워둘 수 없습니다. 계약화면에서 추가해주세요.");
                    },
                    child: Container(
                        color: Colors.blueGrey.withOpacity(0.5), height: 42,
                        child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WidgetT.iconMini(Icons.input),
                            Text('신규 품목 매입 등록', style: StyleT.titleStyle(),),
                            SizedBox(width: 6,),
                          ],
                        )
                    )
                ),),
              Expanded(
                child:InkWell(
                    onTap: () async {
                      /// 수납등록 윈도우창 표시
                      var parent = UIState.mdiController!.createWindow(context);
                      var page = WindowTS(cs: cs, refresh: initAsync, parent: parent,);
                      UIState.mdiController!.addWindow(context, widget: page, resizableWindow: parent);
                    },
                    child: Container(
                        color: StyleT.accentOver.withOpacity(0.5), height: 42,
                        child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WidgetT.iconMini(Icons.monetization_on_sharp),
                            Text('신규 수납 등록', style: StyleT.titleStyle(),),
                            SizedBox(width: 6,),
                          ],
                        )
                    )
                ),),
            ],
          ),
          Row(
            children: [
              Expanded(
                child:TextButton(
                    onPressed: () async {
                      if(cs.businessName == '') {
                        WidgetT.showSnackBar(context, text:'상호명을 입력해 주세요.'); return;
                      }

                      var alert = await DialogT.showAlertDl(context, title: cs.businessName ?? 'NULL');
                      if(alert == false) {
                        WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                        return;
                      }

                      await DatabaseM.updateCustomer(cs, files: fileByteList,);
                      WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                      widget.parent.onCloseButtonClicked!();
                    },
                    style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                    child: Container(
                        color: StyleT.accentColor.withOpacity(0.5), height: 42,
                        child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WidgetT.iconMini(Icons.check_circle),
                            Text('거래처 저장', style: StyleT.titleStyle(),),
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
