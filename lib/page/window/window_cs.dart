import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_process.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/user.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/core/database/database_search.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/json.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_pu_create.dart';
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


/*enum CustomerMenu {
  //all("all", '전체보기', Icons.calendar_month),
  newTap('newTap', '새탭에서 보기', Icons.calendar_view_week ),
  //repu('repu', '매입매출만 보기', Icons.calendar_view_day);
*//*
  const CustomerMenu(this.code, this.displayName, this.icon);
  final String code;
  final String displayName;
  final IconData icon;

  factory CustomerMenu.getByCode(String code){
    return CustomerMenu.values.firstWhere((value)
    => value.code == code,
        orElse: () => CustomerMenu.month
    );
  }*//*
}*/



class WindowCS extends WindowBaseMDI {
  Function? refresh;
  Customer org_cs;

  WindowCS({ required this.org_cs,
    this.refresh,
  }) { }

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
    await widget.org_cs.update();
    await DatabaseSearch.setSelect_CS(widget.org_cs.id);

    cs = Customer.fromDatabase(JsonManager.toJsonObject(widget.org_cs));
    purs = await widget.org_cs.getPurchase();
    purs.sort((a, b) => b.purchaseAt.compareTo(a.purchaseAt) );


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

    UserSystem.userData.init();
    //FunT.CallFunction(widget.refresh);
    setState(() {});
  }

  Widget main = SizedBox();



  /// 이 함수는 매인 위젯 빌더입니다.
  Widget mainBuild() {
    int index = 1;
    int startIndex = 0;

    List<Widget> puW = [];
    puW.add(CompPU.tableHeader());
    startIndex = puIndex * pageLimit;
    for(int i = startIndex; i < startIndex + pageLimit; i++) {
      if(i >= purs.length) break;

      var pu = purs[i];
      var item = SystemT.getItem(pu.item);

      puW.add(CompPU.tableUI(context, pu,
        setState: () { setState(() {}); }, index: i + 1,));
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
      var w = CompProcess.tableUI(
          context, prs, usedAmount[prs.id] ?? 0,
        cs: cs,
        setState: () { setState(() {}); },
        refresh: () { initAsync(); }
      );
      processingWidgets.add(w);
      processingWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }

    List<Widget> widgetsCt = [];
    index = 1;
    contractList.forEach((ct) {
      var w = CompContract.tableUI(context, ct, index: index++,
          onTap: () async { }
      );
      widgetsCt.add(w);
      widgetsCt.add(WidgetT.dividHorizontal(size: 0.35));
    });


    List<Widget> inputOutputWidgets = [];
    var purchaseAmount = 0;
    var purTsAmount = 0;

    var revenueAmount = 0;
    var revTsAmount = 0;

    purs.forEach((e) { purchaseAmount += e.totalPrice; });
    tsList.forEach((e) { if(e.type == 'RE') revTsAmount += e.amount;
      else purTsAmount += e.amount; });

    inputOutputWidgets.add(ExcelT.ExcelGrid(lavel: "총 매입금", text: StyleT.krwInt(purchaseAmount), width: 150, widthLavel: 150));
    inputOutputWidgets.add(ExcelT.ExcelGrid(lavel: "총 지출금", text: StyleT.krwInt(purTsAmount), width: 150, widthLavel: 150));
    inputOutputWidgets.add(ExcelT.ExcelGrid(lavel: "총 매출액", text: StyleT.krwInt(0), width: 150, widthLavel: 150));
    inputOutputWidgets.add(ExcelT.ExcelGrid(lavel: "총 수입금", text: StyleT.krwInt(revTsAmount), width: 150, widthLavel: 150));

    var gridStyle = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.03), stroke: 1.4, strokeColor: StyleT.titleColor.withOpacity(0.15));

    return main = Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildAppbar(),

          Expanded(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextT.Title(text: '거래처 상세 정보',),
                    SizedBox(height: dividHeight,),
                    Container(
                      padding: const EdgeInsets.only(top: 6, right: 6),
                      decoration: gridStyle,
                      child: ListBoxT.Columns(
                        spacing: 6,
                        children: [
                          ListBoxT.Rows(
                            spacing: 6 * 4,
                            children: [
                              InputWidget.DropButtonT<String>(dropMenuMaps: { '개인':'개인', '사업자':'사업자' },  width: 250,
                                label: "구분",
                                labelText: (item) { return item; },
                                onEditeKey: (i, data) { cs.bsType = data; },
                                setState: () { setState(() {}); },
                                text: cs.bsType,
                              ),
                              InputWidget.DropButtonT<String>(dropMenuMaps: { '매입':'매입', '매출':'매출', '매입/매출':'매입/매출' }, width: 250,
                                label: "거래처 분류",
                                labelText: (item) { return item; },
                                onEditeKey: (i, data) { cs.csType = data; },
                                setState: () { setState(() {}); },
                                text: cs.csType,
                              ),
                            ]
                          ),
                          InputWidget.LitText(context, "cs상호명",
                            label: "상호명", width: 250,
                            onEdited: (i, data) { cs.businessName = data; },
                            setState: () { setState(() {}); },
                            text: cs.businessName,
                          ),
                          InputWidget.LitText(context, "cs::업태::input",
                            label: "업태", width: 250,
                            onEdited: (i, data) { cs.businessType = data; },
                            text: cs.businessType,
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.LitText(context, "cs::종목::input",
                              label: "종목", width: 250,
                              onEdited: (i, data) { cs.businessItem = data.toString().split(','); },
                              text: cs.businessItem.join(', '), value: cs.businessItem.join(','),
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.LitText(context, "cs대표이름",
                            label: "대표이름", width: 250,
                            onEdited: (i, data) { cs.representative = data; },
                            text: cs.representative,
                            setState: () { setState(() {}); },
                          ),
                          ListBoxT.Rows(
                            spacingWidget: TextT.Lit(text:'  ㅡ  ', bold: true),
                            children: [
                              InputWidget.LitText(context, "cs::사업자등록번호1::input",
                                label: "사업자등록번호", width: 70,
                                onEdited: (i, data) { cs.businessRegistrationNumber['0'] = data; },
                                text: cs.businessRegistrationNumber['0'],
                                setState: () { setState(() {}); },
                              ),
                              InputWidget.LitText(context, "cs::사업자등록번호2::input",
                                width: 70,
                                onEdited: (i, data) { cs.businessRegistrationNumber['1'] = data; },
                                text: cs.businessRegistrationNumber['1'],
                                setState: () { setState(() {}); },
                              ),
                              InputWidget.LitText(context, "cs::사업자등록번호3::input",
                                width: 70,
                                onEdited: (i, data) { cs.businessRegistrationNumber['2'] = data; },
                                text: cs.businessRegistrationNumber['2'],
                                setState: () { setState(() {}); },
                              ),
                            ]
                          ),
                          ListBoxT.Rows(
                              spacingWidget: TextT.Lit(text:'  ㅡ  ', bold: true),
                              children: [
                                InputWidget.LitText(context, "cs::팩스번호1::input",
                                  label: "팩스번호", width: 70,
                                  onEdited: (i, data) { cs.faxNumber['0'] = data; },
                                  text: cs.faxNumber['0'],
                                  setState: () { setState(() {}); },
                                ),
                                InputWidget.LitText(context, "cs::팩스번호2::input",
                                  width: 70,
                                  onEdited: (i, data) { cs.faxNumber['1'] = data; },
                                  text: cs.faxNumber['1'],
                                  setState: () { setState(() {}); },
                                ),
                                InputWidget.LitText(context, "cs::팩스번호3::input",
                                  width: 70,
                                  onEdited: (i, data) { cs.faxNumber['2'] = data; },
                                  text: cs.faxNumber['2'],
                                  setState: () { setState(() {}); },
                                ),
                              ]
                          ),
                          InputWidget.LitText(context, "cs담당자",
                            label: "담당자", width: 250,
                            onEdited: (i, data) { cs.manager = data; },
                            text: cs.manager,
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.LitText(context, "전화번호1",
                            label: "전화번호", width: 250,
                            onEdited: (i, data) { cs.companyPhoneNumber = data; },
                            text: cs.companyPhoneNumber,
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.LitText(context, "cs::mobile::input",
                            label: "모바일", width: 250,
                            onEdited: (i, data) { cs.phoneNumber = data; },
                            text: cs.phoneNumber,
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.LitText(context, "cs::email::input",
                            label: "이메일", width: 250,
                            onEdited: (i, data) { cs.email = data; },
                            text: cs.email,
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.LitText(context, "cs::homePageurl::input",
                            label: "홈페이지", width: 500,
                            onEdited: (i, data) { cs.website = data; },
                            text: cs.website,
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.LitText(context, "cs::address::input",
                            label: "주소", width: 500, isMultiLine: true,
                            onEdited: (i, data) { cs.address = data; },
                            text: cs.address,
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.LitText(context, "cs::memo::input",
                            label: "메모", width: 500, isMultiLine: true, expand: true,
                            onEdited: (i, data) { cs.memo = data; },
                            text: cs.memo,
                            setState: () { setState(() {}); },
                          ),

                          ListBoxT.Rows(
                            spacing: 6 * 4,
                            children: [
                              InputWidget.LitText(context, "cs::은행::input",
                                label: "은행", width: 150,
                                onEdited: (i, data) { cs.account['bank'] = data; },
                                text: cs.account['bank'],
                                setState: () { setState(() {}); },
                              ),
                              InputWidget.LitText(context, "cs::계좌번호::input",
                                label: "계좌번호", width: 200,
                                onEdited: (i, data) { cs.account['number'] = data; },
                                text: cs.account['number'],
                                setState: () { setState(() {}); },
                              ),
                              InputWidget.LitText(context, "cs::예금주::input",
                                label: "예금주", width: 150,
                                onEdited: (i, data) { cs.account['user'] = data; },
                                text: cs.account['user'],
                                setState: () { setState(() {}); },
                              ),
                            ]
                          ),
                          Container(
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    TextT.Lit(text:"첨부파일", width: 100, size: 12, bold: true),
                                    Expanded(
                                        flex: 7,
                                        child: Container(
                                          padding: EdgeInsets.all(dividHeight),
                                          child: Wrap(
                                            runSpacing: dividHeight, spacing: dividHeight,
                                            children: [
                                              for(int i = 0; i < cs.filesMap.length; i++)
                                                ButtonT.IconText(
                                                  icon: Icons.cloud_done, text: cs.filesMap.keys.elementAt(i),
                                                  onTap: () async {
                                                    var downloadUrl = cs.filesMap.values.elementAt(i);
                                                    var fileName = cs.filesMap.keys.elementAt(i);
                                                    PdfManager.OpenPdf(downloadUrl, fileName);
                                                  },
                                                  leaging: ButtonT.Icont(
                                                    icon: Icons.delete,
                                                    onTap: () {
                                                      WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
                                                      setState(() {});
                                                    }
                                                  )
                                                ),
                                              for(int i = 0; i < fileByteList.length; i++)
                                                ButtonT.IconText(
                                                    icon: Icons.file_copy_rounded, text: fileByteList.keys.elementAt(i),
                                                    onTap: () async {
                                                      PDFX.showPDFtoDialog(context, data: fileByteList.values.elementAt(i), name: fileByteList.keys.elementAt(i));
                                                    },
                                                    leaging: ButtonT.Icont(
                                                        icon: Icons.delete,
                                                        onTap: () {
                                                          fileByteList.remove(fileByteList.keys.elementAt(i));
                                                          setState(() {});
                                                        }
                                                    )
                                                ),
                                            ],
                                          ),)),
                                  ],
                                ),
                              )
                          ),
                        ],),),
                    SizedBox(height: dividHeight,),
                    ButtonT.IconText(
                        icon: Icons.file_copy_rounded, text: "첨부파일추가",
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles();
                          if( result != null && result.files.isNotEmpty ){
                            String fileName = result.files.first.name;
                            fileByteList[fileName] = result.files.first.bytes!;
                            setState(() {});
                          }
                        },
                    ),
                    SizedBox(height: dividHeight * 8,),

                    TextT.Title(text: '생산관리 - 거래처 연결품목 재고관리',),
                    SizedBox(height: dividHeight,),
                    ItemCount.OnTableHeader(),
                    Column(children: outputWidgets,),
                    SizedBox(height: dividHeight * 8,),

                    TextT.Title(text: '생산관리 - 공정관리',),
                    SizedBox(height: dividHeight,),
                    CompProcess.tableHeader(),
                    Column(children: processingWidgets,),
                    SizedBox(height: dividHeight * 8,),

                    TextT.Title(text: '매입목록',),
                    SizedBox(height: dividHeight,),
                    Container(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: puW,)),
                    SizedBox(height: dividHeight * 4,),

                    TextT.Title(text: '수납목록',),
                    SizedBox(height: dividHeight,),
                    CompTS.tableHeader(),
                    Column(children: tsWidgets,),
                    SizedBox(height: dividHeight * 4,),

                    WidgetT.title('계약목록', size: 14),
                    SizedBox(height: dividHeight,),
                    CompContract.tableHeader(),
                    Column(children: widgetsCt,),
                    SizedBox(height: dividHeight * 4,),

                    WidgetT.title("미수, 미지급 현황", size: 14),
                    SizedBox(height: dividHeight,),
                    Column(children: inputOutputWidgets,),
                  ],)
            ),
          ),

          /// action
          actionWidgets(),
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
          spacing: 6 * 4,
          children: [
            ButtonT.Text(
              text: cs.businessName + " 거래처 정보", textSize: 18, color: Colors.transparent, textColor: Colors.white
            ),
            ButtonT.IconText(
                icon: Icons.refresh, text: "새로고침", color: Colors.transparent, textColor: Colors.white.withOpacity(0.8),
                onTap: () {
                  initAsync();
                }
            ),
            Expanded(child: SizedBox()),
            ButtonT.AppbarAction("신규 매입 등록", Icons.input,
              onTap: () async {
                UIState.OpenNewWindow(context, WindowPUCreateWithCS(cs : widget.org_cs, refresh: initAsync,));
              },
            ),
            ButtonT.AppbarAction("신규 수납 등록", Icons.monetization_on_sharp,
              onTap: () async {
                UIState.OpenNewWindow(context, WindowTsCreate(cs: cs, refresh: initAsync));
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

  Widget actionWidgets() {
    return  Column(
      children: [
        /*Row(
          children: [
            *//*ButtonT.ActionLegacy("신규 품목 매입 등록",
              expend: true,
              icon: Icons.input, backgroundColor: Colors.blueGrey.withOpacity(0.5),
              onTap: () async {
                WidgetT.showSnackBar(context, text: "품목에 대한매입은 계약을 비워둘 수 없습니다. 계약화면에서 추가해주세요.");
              },
            ),*//*
          ],
        ),*/
        Row(
          children: [
            ButtonT.ActionLegacy("거래처 저장",
              expend: true, icon: Icons.save,
              backgroundColor: StyleT.accentColor.withOpacity(0.5),
              onTap: () async {
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
            ),
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
