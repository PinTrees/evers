import 'package:evers/class/Customer.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_re.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_cs.dart';
import 'package:evers/page/window/window_ledger_revenue_create.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_re_create.dart';
import 'package:evers/page/window/window_re_create_ct.dart';
import 'package:evers/page/window/window_sch_create.dart';
import 'package:evers/page/window/window_ts_create.dart';
import 'package:evers/ui/ex.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../class/contract.dart';
import '../../class/database/item.dart';
import '../../class/database/ledger.dart';
import '../../class/purchase.dart';
import '../../class/revenue.dart';
import '../../class/schedule.dart';
import '../../class/system.dart';
import '../../class/system/state.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/button/button_file.dart';
import '../../class/widget/excel.dart';
import '../../class/widget/text.dart';
import '../../class/widget/textInput.dart';
import '../../core/window/window_base.dart';
import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';
import '../../helper/pdfx.dart';
import '../../ui/dialog_revenue.dart';
import '../../ui/dialog_schedule.dart';
import '../../ui/ip.dart';
import '../../ui/ux.dart';

class WindowCT extends WindowBaseMDI {
  Contract org_ct;

  WindowCT({ required this.org_ct, }) {}

  @override
  _WindowCTState createState() => _WindowCTState();
}

class _WindowCTState extends State<WindowCT> {
  var dividHeight = 6.0;
  Map<String, Uint8List> fileByteList = {};
  Map<String, Uint8List> ctFileByteList = {};
  Contract ct = Contract.fromDatabase({});
  Customer cs = Customer.fromDatabase({});

  int schListIndex = 0;

  List<TS> tsList = [];
  List<Ledger> ledgerList = [];
  List<Purchase> purList = [];
  List<Revenue> revList = [];
  List<Schedule> schList = [];

  var vatTypeNameList = [ '포함', '별도', ];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  dynamic initAsync() async {
    print(widget.org_ct.id);

    ct = await DatabaseM.getContractDoc(widget.org_ct.id);
    if(ct == null) return;
    
    cs = await DatabaseM.getCustomerDoc(ct.csUid) ?? Customer.fromDatabase({});

    ledgerList = await DatabaseM.getLedgerRevenueList(ct.csUid);
    purList = await DatabaseM.getPur_withCT(ct.id);
    tsList = await DatabaseM.getTransactionCt(ct.id);
    schList = await DatabaseM.getSCH_CT(ct.id);
    revList = await DatabaseM.getRevenueOnlyContract(ct.id);

    await ct.updateInit();

    setState(() {});
  }

  Widget main = SizedBox();

  Widget mainBuild() {
    var allPay = 0, allPayedAmount = 0;

    /// 매입 UI
    List<Widget> purWidgets = [];
    purWidgets.add(CompPU.tableHeader());
    for(int i = 0; i < purList.length; i++) {
      var pu = purList[i];
      pu.init();
      allPay += pu.totalPrice;

      var w = CompPU.tableUI(
        context, pu,
        index: i + 1,
        setState: () { setState(() {}); },
        refresh: () { initAsync(); }
      );

      purWidgets.add(w);
      purWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }

    /// 매출
    List<Widget> reW = [];
    reW.add(Revenue.buildTitleUI());
    for(int i = 0; i < revList.length; i++) {
      var re = revList[i];
      re.init();
      allPay += re.totalPrice;

      reW.add(CompRE.tableUI(context, re,
          refresh: () async { await initAsync(); },
          setState: () { setState(() {}); }
      ));
      reW.add(WidgetT.dividHorizontal(size: 0.35));
    }

    int ledgerIndex = 0;
    List<Widget> ledgerWidgets = [ Ledger.onTableHeader(), ];
    ledgerList.forEach((e) {
      ledgerWidgets.add(e.onTableUI(context, index: ledgerIndex++,
          refresh: () async {
            await initAsync();
          }
      ));
      ledgerWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    });


    /// 계약
    List<Widget> ctW = [];
    ctW.add(WidgetUI.titleRowNone([ '', '순번', '매출일자', '품목', '단위', '단가', '메모' ], [ 28, 28, 150, 200 + 28 * 2, 50, 120, 999 ], background: true, lite: true),);
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
    for(int i = 0; i < tsList.length; i++) {
      var tmpTs = tsList[i];
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

    /// 일정 테이블 위젯 목록
    List<Widget> schTableWidgetList = [];
    schTableWidgetList.add(Schedule.buildTitle());

    int startIndex = schListIndex * PageInfo.pageLimit;
    for(int i = startIndex; i < startIndex + PageInfo.pageLimit; i++) {
      if(i >= schList.length) break;
      var sch = schList[i];
      var w = sch.buildUIAsync(index: i + 1, onEdite: () async {
        var data = await DialogSHC.showSCHEdite(context, sch);
        if(data != null) {
        }
      });
      schTableWidgetList.add(w);
      schTableWidgetList.add(WidgetT.dividHorizontal(size: 0.35));
    }
    schTableWidgetList.add(SizedBox(height: dividHeight,));
    schTableWidgetList.add(ListBoxT.Rows(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        for(int i = 0; i < (schList.length / PageInfo.pageLimit).ceil(); i++)
          ButtonT.Text(
              size: 28, text: (i + 1).toString(),
              onTap: () {
                setState(() {  schListIndex = i; });
              }
          )
      ],
    ));



    var dividCol =  SizedBox(height: dividHeight * 8,);
    var btnStyle =  StyleT.buttonStyleOutline(round: 8, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7);
    var gridStyle = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.00), stroke: 0.01, strokeColor: StyleT.titleColor.withOpacity(0.0));
    var gridStyleT = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.03), stroke: 2, strokeColor: StyleT.titleColor.withOpacity(0.1));

    var csWidget = ListBoxT.Columns(
        children: [
          ListBoxT.Rows(
            spacing: 6,
            children: [
              TextT.SubTitle(text: "거래처 ${ cs.businessName }", ),
              ButtonT.IconText(
                  icon: Icons.open_in_new_sharp, text: "거래처 바로가기",
                  onTap: () async {
                    UIState.OpenNewWindow(context, WindowCS(org_cs: cs, refresh: () { initAsync(); },));
                  }
              ),
              if(cs.businessName == "")
              ButtonT.IconText(
                  icon: Icons.change_circle_rounded, text: "거래처 등록",
                  onTap: () async {
                    var select = await DialogT.selectCS(context);
                    if(select != null) {
                      cs = select;
                      ct.csUid = cs.id;
                      await DatabaseM.updateContract(ct);
                      setState(() {});
                    }
                  }
              )
            ]
          )
        ]
    );
    var ctInfoWidget = Container(
      decoration: gridStyleT,
      padding: EdgeInsets.only(left: 6, right: 6),
      child: ListBoxT.Columns(
        spacingStartEnd: 6,
        children: [
          InputWidget.LitText(context, 'df계약명',
            label: "계약명", width: 250,
            onEdited: (i, data) { ct.ctName = data; },
            setState: () { setState(() {}); },
            text: ct.ctName,
          ),
          ListBoxT.Rows(
              spacing: 6,
              children: [
                InputWidget.LitText(context, 'df구매부서',
                  label: "구매부서", width: 250,
                  setState: () { setState(() {}); },
                  onEdited: (i, data) { ct.purchasingDepartment = data; },
                  text: ct.purchasingDepartment,
                ),
                InputWidget.LitText(context, 'df담당자',
                  label: "담당자", width: 150,
                  setState: () { setState(() {}); },
                  onEdited: (i, data) { ct.manager = data; },
                  text: ct.manager,
                ),
                InputWidget.LitText(context, 'df연락처',
                  label: "연락처",  width: 150,
                  setState: () { setState(() {}); },
                  onEdited: (i, data) { ct.managerPhoneNumber = data; },
                  text: ct.managerPhoneNumber,
                ),
              ]
          ),
          InputWidget.LitText(context, 'df납품지주소',
            label: "납품지주소",  width: 400,
            setState: () { setState(() {}); },
            onEdited: (i, data) { ct.workSitePlace = data; },
            text: ct.workSitePlace, ),
          InputWidget.LitText(context, 'input::메모',
            label: "메모", expand: true, isMultiLine: true,
            onEdited: (i, data) { ct.memo = data; },
            setState: () { setState(() {}); },
            text: ct.memo,
          ),
          InputWidget.LitText(context, 'df계약일자',
            label: "계약일자", width: 150 ,
            setState: () { setState(() {}); },
            onEdited: (i, data) { ct.contractAt = StyleT.dateEpoch(data); },
            text: StyleT.dateInputFormatAtEpoch(ct.contractAt.toString()),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextT.SubTitle(text: '계약서 첨부파일'),
              SizedBox(height: dividHeight,),
              Wrap(
                runSpacing: dividHeight, spacing: dividHeight,
                children: [
                  for(int i = 0; i < ct.contractFiles.length; i++)
                    ButtonFile(
                      fileName: ct.contractFiles.keys.elementAt(i),
                      fileUrl: ct.contractFiles.values.elementAt(i),
                      onDelete: () { setState(() {}); },
                    ),
                  for(int i = 0; i < ctFileByteList.length; i++)
                    ButtonFile(
                      fileName: ctFileByteList.keys.elementAt(i),
                      onDelete: () {
                        ctFileByteList.remove(ctFileByteList.keys.elementAt(i));
                        setState(() {});
                      },
                    ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextT.SubTitle(text: '추가 첨부파일'),
              SizedBox(height: dividHeight,),
              Wrap(
                runSpacing: dividHeight, spacing: dividHeight,
                children: [
                  for(int i = 0; i < ct.filesMap.length; i++)
                    ButtonFile(
                      fileName: ct.getFileName(ct.filesMap.keys.elementAt(i)),
                      fileUrl:  ct.filesMap.values.elementAt(i),
                      onDelete: () {
                        WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
                        setState(() {});
                      },
                    ),
                  for(int i = 0; i < fileByteList.length; i++)
                    ButtonFile(
                      fileName: ct.getFileName(fileByteList.keys.elementAt(i)),
                      onDelete: () {
                        fileByteList.remove(fileByteList.keys.elementAt(i));
                        setState(() {});
                      },
                    ),
                ],
              ),
            ],
          ),
        ],),);


    return main = Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildAppbar(),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(18),
              child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: dividHeight,),
                  csWidget,
                  dividCol,

                  TextT.SubTitle(text:'계약상세 정보' ),
                  SizedBox(height: dividHeight,),
                  ctInfoWidget,
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
                  TextT.SubTitle(text:'계약내용' ),
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
                  ListBoxT.Rows(
                      spacing: 6,
                      children: [
                        TextT.SubTitle(text:'일정 및 메모' ),
                        ButtonT.IconText(icon: Icons.add_box, text: "일정 추가",
                            onTap: () async {
                              UIState.OpenNewWindow(context, WindowSchCreate(refresh: () async { await initAsync(); }, ct: ct,));
                            }
                        ),
                      ]
                  ),
                  SizedBox(height: dividHeight,),
                  Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: schTableWidgetList,)),
                  SizedBox(height: dividHeight,),

                  dividCol,
                  ListBoxT.Rows(
                    spacing: 6,
                      children: [
                        TextT.SubTitle(text:'매입 목록' ),
                        ButtonT.IconText(icon: Icons.add_box, text: "매입 추가 (재고 미반영)",
                            onTap: () async {
                              UIState.OpenNewWindow(context, WindowPUCreate(refresh: () async { await initAsync(); }, ct: ct,));
                            }
                        ),
                        ButtonT.IconText(icon: Icons.add_box, text: "품목 매입 추가 (재고 반영)",
                            onTap: () async {
                              UIState.OpenNewWindow(context, WindowPUCreate(refresh: () async { await initAsync(); }, ct: ct, isItemPurchase: true,));
                            }
                        ),
                      ]
                  ),
                  SizedBox(height: dividHeight,),
                  Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: purWidgets,)),

                  dividCol,
                  ListBoxT.Rows(
                    spacing: 6,
                    children: [
                      TextT.SubTitle(text:'매출 목록' ),
                      ButtonT.IconText(icon: Icons.add_box, text: "매출 추가", onTap: () {
                        UIState.OpenNewWindow(context, WindowReCreateWithCt(ct: ct, refresh: () { initAsync(); }));
                      }),
                      ButtonT.IconText(icon: Icons.open_in_new_sharp, text: "세금계산서 관리",
                          onTap: () async {
                            for(var re in ct.revenueList) {
                              if(re.isTaxed != re.selectIsTaxed) {
                                re.isTaxed = re.selectIsTaxed;
                                await re.update();
                              }
                            }
                            setState(() {});
                      }),
                      ButtonT.IconText(icon: Icons.open_in_new_sharp, text: "홈택스 바로가기",
                          onTap: () async {
                            launchUrl(Uri.parse('https://www.hometax.go.kr/websquare/websquare.html?w2xPath=/ui/pp/index.xml'));
                          }),
                    ],
                  ),
                  SizedBox(height: dividHeight,),
                  Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: reW,)),
                  SizedBox(height: dividHeight,),

                  dividCol,
                  ListBoxT.Rows(
                      spacing: 6,
                      children: [
                      TextT.SubTitle(text: '출고원장'),
                      ButtonT.IconText(icon: Icons.add_box, text: "출고원장 생성", onTap: () {
                        UIState.OpenNewWindow(context, WindowLedgerReCreate(refresh: () { initAsync(); }, contract: ct,));
                      }),
                    ]
                  ),
                  SizedBox(height: dividHeight,),
                  Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:ledgerWidgets,)),


                  dividCol,
                  ListBoxT.Rows(
                    spacing: 6,
                    children: [
                      TextT.SubTitle(text: '수납목록'),
                      ButtonT.IconText(icon: Icons.add_box, text: "계약 수납 추가", onTap: () {
                        UIState.OpenNewWindow(context, WindowTsCreateCt(ct: ct, refresh: () { initAsync(); }));
                      }),
                    ]
                  ),
                  SizedBox(height: dividHeight,),
                  Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: tsW,)),
                  SizedBox(height: dividHeight,),

                  dividCol,
                  TextT.SubTitle(text: '금엑현황'),
                  SizedBox(height: dividHeight,),
                  Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: tsAllW,)),
                ],
              ),
            ),
          ),

          /// action
          buildAction(),
        ],
      ),
    );
  }




  Widget buildAppbar() {
    return Material(
      elevation: 18,
      child: Container(
        height: 48,
        padding: EdgeInsets.all(6),
        color: Colors.black.withOpacity(0.9),
        child: ListBoxT.Rows(
            spacing: 6 * 2,
            children: [
              ButtonT.Text(
                  text: cs.businessName + " / " + ct.ctName + " 계약 정보", textSize: 16, color: Colors.transparent, textColor: Colors.white
              ),
              Expanded(child: SizedBox()),
              ButtonT.AppbarAction("신규 매출 등록", Icons.output,
                onTap: () async {
                  UIState.OpenNewWindow(context, WindowReCreateWithCt(refresh: () async { await initAsync(); }, ct: ct,));
                },
              ),
              ButtonT.AppbarAction("신규 매입 등록", Icons.input,
                onTap: () async {
                  UIState.OpenNewWindow(context, WindowPUCreate(refresh: () async { await initAsync(); }, ct: ct,));
                },
              ),
              ButtonT.AppbarAction("신규 품목 매입 등록", Icons.icecream_sharp,
                onTap: () async {
                  UIState.OpenNewWindow(context, WindowPUCreate(refresh: () async { await initAsync(); }, ct: ct, isItemPurchase: true,));
                },
              ),
              ButtonT.AppbarAction("신규 일정 등록", Icons.schedule,
                onTap: () async {
                  UIState.OpenNewWindow(context, WindowSchCreate(refresh: () async { await initAsync(); }, ct: ct,));
                },
              ),
              ButtonT.AppbarAction("출고원장 생성", Icons.padding_outlined,
                onTap: () async {
                  UIState.OpenNewWindow(context, WindowLedgerReCreate(refresh: () { initAsync(); }, contract: ct,));
                },
              ),
              ButtonT.AppbarAction("새탭으로 열기", Icons.open_in_new_sharp ,
                  onTap: () {
                    Messege.show(context, "기능을 개발중입니다.");
                  }
              ),
            ]
        ),
      ),
    );
  }


  Widget buildAction() {

    var saveWidget = ButtonT.Action(
      context, "계약 저장",
      expend: true,
      altText: "변경된 계약 정보를 저장하시겠습니까? ",
      icon: Icons.save, backgroundColor: StyleT.accentColor.withOpacity(0.5),
      onTap: () async {
        ct.csUid = cs.id;
        var data = await DatabaseM.updateContract(ct, files: fileByteList, ctFiles: ctFileByteList);
        if(data == null) return Messege.toReturn(context, "Database Error", false);
        widget.parent.onCloseButtonClicked!();
      },
    );

    return Column(
      children: [
        Row(
          children: [
            saveWidget,
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return mainBuild();
  }
}
