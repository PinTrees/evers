import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/textinput_lit.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/json.dart';
import 'package:evers/helper/pdfx.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import '../../class/Customer.dart';
import '../../class/component/comp_ts.dart';
import '../../class/contract.dart';
import '../../class/database/item.dart';
import '../../class/system.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/excel.dart';
import '../../class/widget/messege.dart';
import '../../class/widget/text.dart';
import '../../class/widget/textInput.dart';
import '../../core/window/ResizableWindow.dart';
import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';



/// 이 윈도우 클래스는 매입추가를 위한 위젯을 렌더링 합니다.
/// 거래처가 이미 정해진 매입을 추가합니다.
/// 위젯 내부에서 거래처를 접근할 수 없습니다.
class WindowPUCreateWithCS extends WindowBaseMDI {
  Customer cs;
  Function refresh;

  WindowPUCreateWithCS({ required this.cs, required this.refresh, }) { }

  @override
  _WindowPUCreateWithCSState createState() => _WindowPUCreateWithCSState();
}
class _WindowPUCreateWithCSState extends State<WindowPUCreateWithCS> {
  var dividHeight = 6.0;
  var heightSize = 36.0;

  var payment = '매입';
  var payType = '';

  var vatTypeList = [ 0, 1, ];
  var vatTypeNameList = [ '포함', '미포함', ];
  var currentVatType = 0;


  List<Purchase> pus = [];

  List<Map<String, Uint8List>> fileByteList = [];
  Contract ct = Contract.fromDatabase({});
  var isContractLinking = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /// 최초 실행시 기초 품목매입 1개를 추가합니다.
    var pu = Purchase.fromDatabase({});
    pu.purchaseAt = DateTime.now().microsecondsSinceEpoch;
    pus.add(pu);
    fileByteList.add({});

    initAsync();
  }

  /// 이 함수는 동기 초기화를 시도합니다.
  /// 상속구조로 재설계 되어야 합니다.
  void initAsync() async {
    setState(() {});
  }


  ///  이 함수는 매인 위젯을 렌더링 합니다.
  ///  상속구조로 재설계 되어야 합니디.
  Widget mainBuild() {
    List<Widget> widgetsPu = [];
    widgetsPu.add(CompPU.tableHeader());
    for(int i = 0; i < pus.length; i++) {
      var pu = pus[i];
      var fileMap = fileByteList[i] as Map<String, Uint8List>;

      if(pu.state == "DEL") {
        pus.removeAt(i);
        fileByteList.removeAt(i--);
        continue;
      }

      pu.vatType = currentVatType;
      pu.init();

      var w = CompPU.tableUIInput(context, pu,
        index: i + 1,
        fileByteList: fileMap,
        setState: () { setState(() {}); }
      );
      widgetsPu.add(w);
      widgetsPu.add(WidgetT.dividHorizontal(size: 0.35));
    }

    var dividCol = Column(
      children: [
        SizedBox(height: dividHeight * 4,),
        SizedBox(height: dividHeight * 4,),
      ],
    );

    return Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextT.SubTitle(text: "거래처 정보"),
                TextT.Lit(text: widget.cs.businessName),
                dividCol,

                TextT.SubTitle(text: "매입 추가 목록"),
                SizedBox(height: dividHeight,),
                Column( children: widgetsPu, ),
                SizedBox(height: dividHeight,),
                Row(
                  children: [
                    ButtonT.IconText(
                      icon: Icons.add_box,
                      text: "매입추가",
                      onTap: () {
                        var p = Purchase.fromDatabase({});
                        p.purchaseAt = DateTime.now().microsecondsSinceEpoch;
                        pus.add(p);
                        fileByteList.add({});
                        setState(() {});
                      },
                    ),
                    SizedBox(width: dividHeight,),
                    WidgetT.title('지불관련', width: 100 ),
                    ListBoxT.Rows(
                      spacing: 6,
                      children: [
                        for(var v in vatTypeList)
                          ButtonT.IconText(
                            icon: currentVatType != v ? Icons.check_box_outline_blank : Icons.check_box,
                            text: '부가세 ' + vatTypeNameList[v],
                            onTap: () {
                              currentVatType = v;
                              setState(() {});
                            }
                          ),
                      ],
                    ),
                    SizedBox(width: 6,),
                    WidgetT.text('품목 직접 입력시 재고 및 단가 연동 불가.   연동이 필요한 품목은 생산관리에서 추가후 입력해 주세요.', size: 10),
                  ],
                ),

                dividCol,

                TextT.SubTitle(text: "지불관련"),
                SizedBox(height: dividHeight,),
                ListBoxT.Rows(
                  spacing: 6,
                  children: [
                    ButtonT.IconText(
                      icon: payment != '매입' ? Icons.check_box_outline_blank : Icons.check_box,
                      text: "매입만",
                      onTap: () {
                        payment = '매입';
                        setState(() {});
                      },
                    ),
                    ButtonT.IconText(
                      icon: payment != '즉시' ? Icons.check_box_outline_blank : Icons.check_box,
                      text: "즉시지불",
                      onTap: () {
                        payment = '즉시';
                        setState(() {});
                      },
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

          /// action
          buildAction(),
        ],
      ),
    );
  }


  /// 이 함수는 하단의 액션버튼 위젯을 렌더링 합니다.
  /// 상속구조로 재설계 되어야 합니다.
  Widget buildAction() {
    return Row(
      children: [
        ButtonT.ActionLegacy("매입 추가하기",
          expend: true,
          icon: Icons.save, backgroundColor: StyleT.accentColor.withOpacity(0.5),
          onTap: () async {
            if(widget.cs == null) { WidgetT.showSnackBar(context, text: '거래처는 비워둘 수 없습니다.'); return; }
            if(payment == '즉시' && payType == '') { WidgetT.showSnackBar(context, text: '결제방법은 비워둘 수 없습니다.'); return;  }

            /*for(var p in pus) {
              if(p.unitPrice == 0 || p.supplyPrice == 0) { WidgetT.showSnackBar(context, text: '매입금액은 0일 수 없습니다.'); return;  }
            }*/

            var alert = await DialogT.showAlertDl(context, text: "매입정보를 저장하시겠습니까?");
            if(alert == false) {  WidgetT.showSnackBar(context, text: '취소됨'); return;   }

            for(int i = 0; i < pus.length; i++) {
              var p = pus[i]; var files = fileByteList[i] as Map<String, Uint8List>;

              p.csUid = widget.cs!.id;
              p.vatType = currentVatType;

              /// 매입정보 추가 - 매입데이터 및 거래명세서 파일 데이터
              await p.update(files: files);
              /// 지불 정보 문서 추가
              if(payment == '즉시')
                await TS.fromPu(p, payType, now: true).update();
            }

            WidgetT.showSnackBar(context, text: '저장됨');
            widget.refresh!();
            widget.parent.onCloseButtonClicked!();
          },
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}







/// 이 윈도우 클래스는 매입추가를 위한 위젯을 렌더링합니다.
/// 모든 매입추가 기능은 이 위젯을 통해 이루어져야 합니다
/// 일반매입추가, 품목매입추가,
/// 거래처를 사용자가 위젯 내부에서 선택할 수 있는 옵션을 제공하기 위해서는 반드시 이 클래스를 생성해야 합니다.
///
/// showCreateNormalPu 함수가 마이그레이션 되었습니다.
///
///
/// @Create YM
/// @Version 1.0.0
class WindowPUCreate extends WindowBaseMDI {
  Function refresh;
  Contract? ct;
  bool isItemPurchase;

  WindowPUCreate({ this.ct, required this.refresh, this.isItemPurchase=false }) { }

  @override
  _WindowPUCreateState createState() => _WindowPUCreateState();
}
class _WindowPUCreateState extends State<WindowPUCreate> {
  var dividHeight = 6.0;
  var heightSize = 36.0;

  var payment = '매입';
  var payType = '';

  var vatTypeList = [ 0, 1, ];
  var vatTypeNameList = [ '포함', '미포함', ];
  var currentVatType = 0;

  List<Purchase> pus = [];
  List<ItemTS> itemTs = [];

  List<Map<String, Uint8List>> fileByteList = [];
  Contract? ct;
  Customer? cs;

  var isContractLinking = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /// 최초 실행시 기초 품목매입 1개를 추가합니다.
    var pu = Purchase.fromDatabase({});
    pu.purchaseAt = DateTime.now().microsecondsSinceEpoch;
    pus.add(pu);
    fileByteList.add({});

    if(widget.isItemPurchase) {
      var its = ItemTS.fromDatabase({});
      its.date = DateTime.now().microsecondsSinceEpoch;
      itemTs.add(its);
    }

    if(widget.ct != null) ct = Contract.fromDatabase(JsonManager.toJsonObject(widget.ct!));

    initAsync();
  }

  /// 이 함수는 동기 초기화를 시도합니다.
  /// 상속구조로 재설계 되어야 합니다.
  void initAsync() async {
    setState(() {});
  }


  ///  이 함수는 매인 위젯을 렌더링 합니다.
  ///  상속구조로 재설계 되어야 합니디.
  Widget mainBuild() {
    Widget mainWidget = SizedBox();

    if(!widget.isItemPurchase) mainWidget = buildPurchaseNormal();
    else mainWidget = buildPurchaseWithItem();


    return Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView( padding: EdgeInsets.all(18), child: mainWidget, ),

          /// action
          buildAction(),
        ],
      ),
    );
  }





  /// 이 함수는 일반매입정보를 입력하는 위젯을 생성하고 반환합니다.
  Widget buildPurchaseNormal() {
    Widget contractWidget = SizedBox();
    if(widget.ct != null) {
      contractWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextT.SubTitle(text: "계약 정보"),
          TextT.Lit(text: "${ct!.csName} / ${ct!.ctName}"),
        ],
      );
    }
    else {
      contractWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextT.SubTitle(text: "거래처 정보"),
          TextT.Lit(text: cs == null ? '-' : cs?.businessName),
          SizedBox(height: dividHeight,),
          ButtonT.IconText(
              icon: Icons.change_circle, text: "거래처 변경",
              onTap: () async {
                cs = await DialogT.selectCS(context);
                setState(() {});
              }
          ),
        ],
      );
    }

    List<Widget> widgetsPu = [];
    widgetsPu.add(CompPU.tableHeaderInput());
    for(int i = 0; i < pus.length; i++) {
      var pu = pus[i];
      var fileMap = fileByteList[i] as Map<String, Uint8List>;

      if(pu.state == "DEL") {
        pus.removeAt(i);
        fileByteList.removeAt(i--);
        continue;
      }

      pu.vatType = currentVatType;
      pu.init();

      var w = CompPU.tableUIInput(context, pu,
          index: i + 1,
          fileByteList: fileMap,
          setState: () { setState(() {}); }
      );
      widgetsPu.add(w);
      widgetsPu.add(WidgetT.dividHorizontal(size: 0.35));
    }

    var purchaseInputWidget = ListBoxT.Columns(
      children: [
        TextT.SubTitle(text: "매입 추가 목록"),
        SizedBox(height: dividHeight,),
        Column( children: widgetsPu, ),
        SizedBox(height: dividHeight,),
        Row(
          children: [
            ButtonT.IconText(
              icon: Icons.add_box,
              text: "매입추가",
              onTap: () {
                var p = Purchase.fromDatabase({});
                p.purchaseAt = DateTime.now().microsecondsSinceEpoch;
                pus.add(p);
                fileByteList.add({});
                setState(() {});
              },
            ),
            SizedBox(width: dividHeight,),
            WidgetT.text('품목 직접 입력시 재고 및 단가 연동 불가.   연동이 필요한 품목은 생산관리에서 추가후 입력해 주세요.', size: 10),
          ],
        ),
      ],
    );

    var vatWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "부가세 설정"),
        SizedBox(height: dividHeight,),
        ListBoxT.Rows(
            spacing: 6,
            children: [
              for(var v in vatTypeList)
                ButtonT.IconText(
                    icon: currentVatType == v ? Icons.check_box : Icons.check_box_outline_blank,
                    text: vatTypeNameList[v],
                    onTap: () {
                      currentVatType = v;
                      setState(() {});
                    }
                ),
              ButtonT.IconText(
                  icon: Icons.auto_mode,
                  text: "부가세 및 공급가액 자동계산",
                  onTap: () {
                    for(var pu in pus) {
                      pu.fixedVat = pu.fixedSup = false;
                      pu.init();
                    }
                    setState(() {});
                  }
              )
            ]
        )
      ],
    );
    var paymentWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "지불관련"),
        SizedBox(height: dividHeight,),
        ListBoxT.Rows(
          spacing: 6,
          children: [
            ButtonT.IconText(
              icon: payment != '매입' ? Icons.check_box_outline_blank : Icons.check_box,
              text: "매입만",
              onTap: () {
                payment = '매입';
                setState(() {});
              },
            ),
            ButtonT.IconText(
              icon: payment != '즉시' ? Icons.check_box_outline_blank : Icons.check_box,
              text: "즉시지불",
              onTap: () {
                payment = '즉시';
                setState(() {});
              },
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
    );


    return ListBoxT.Columns(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6 * 4,
      children: [
        contractWidget,
        purchaseInputWidget,
        ListBoxT.Rows( spacing: 6 * 8, children: [ paymentWidget, vatWidget ] ),
      ],
    );
  }

  /// 이 함수는 품목매입정보를 입력하는 위젯을 생성하고 반환합니다.
  Widget buildPurchaseWithItem() {

    var titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text:'원자재 품목 매입 등록유형' ),
        SizedBox(height: 6,),
        TextT.Lit(text:'원자재 및 재고관리가 필요한 매입 건에 대해 작성하는 등록유형입니다.\n계약이 반드시 필요합니다.' ),
      ],
    );

    Widget contractWidget = SizedBox();
    if(widget.ct != null) {
      contractWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextT.SubTitle(text: "계약 정보"),
          TextT.Lit(text: "${ct!.csName} / ${ct!.ctName}"),
        ],
      );
    }
    else {
      contractWidget =  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextT.SubTitle(text: "계약 정보"),
          TextT.Lit(text: ct == null ? '-' : "${ct!.csName} / ${ct!.ctName}" ),
          SizedBox(height: dividHeight,),
          ButtonT.IconText(
              icon: Icons.change_circle, text: "계약 검색",
              onTap: () async {
                ct = await DialogT.selectCt(context);
                setState(() {});
              }
          ),
        ],
      );
    }

    List<Widget> purchaseWidgets = [];
    for(int i = 0; i < pus.length; i++) {
    Widget w = SizedBox();
    var pu = pus[i];
    var it = itemTs[i];
    var fileMap = fileByteList[i] as Map<String, Uint8List>;

    pu.vatType = currentVatType;
    pu.init();

    w = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 기초 매입 입력 시스템
        CompPU.tableUIInput(context, pu,
            index: i + 1,
            fileByteList: fileMap,
            setState: () { setState(() {}); }
        ),

        /// 품목 매입 관련 추가 작성사항 UI 출력 로직 시작분
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          spacing: 6 * 4, runSpacing: 4,
          children: [
            /// 검수자 입력
            LitTextInput(style: LitTextFieldStyle( height: 28, width: 150, ), params: LitTextParams(
              label: "담당자(검수자)",
              onEdited: (data) {
                it.manager = data;
                setState(() {});
              },
              text: it.manager, value: it.manager,
            )),

            /// 보관 창고 입력
            InputWidget.LitText(context, 'puit.storageLC', index: i,
              label: '저장위치', width: 150, textSize: 10,
              onEdited: (i, data) {
                it.storageLC = data;
              },
              setState: () { setState(() {}); },
              text: it.storageLC,
              value: it.storageLC,
            ),

            /// 측정 습도 입력
            InputWidget.LitText(context, 'puit.rh', index: i,
              label: '측정 습도', width: 150, textSize: 10,
              onEdited: (i, data) {
                it.rh = double.tryParse(data) ?? 0.0;
              },
              setState: () { setState(() {}); },
              text: it.rh.toString(),
              value: it.rh.toString(),
            ),

            /// 작성자 입력
            InputWidget.LitText(context, 'puit.writer', index: i,
              label: '작성자', width: 150, textSize: 10,
              onEdited: (i, data) {
                it.writer = data;
              },
              setState: () { setState(() {}); },
              text: it.writer.toString(),
              value: it.writer.toString(),
            ),
          ],
        ),

        SizedBox(height: 6,)
      ],
    );
    purchaseWidgets.add(w);
    purchaseWidgets.add(WidgetT.dividHorizontal(size: 0.35));
  }



    var purchaseInputWidget = ListBoxT.Columns(
      children: [
        TextT.SubTitle(text: "추가할 매입목록"),
        SizedBox(height: 6,),
        CompPU.tableHeaderInput(),
        for(var w in purchaseWidgets) w,
      ],
    );

    var vatWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "부가세 설정"),
        SizedBox(height: dividHeight,),
        ListBoxT.Rows(
            spacing: 6,
            children: [
              for(var v in vatTypeList)
                ButtonT.IconText(
                    icon: currentVatType == v ? Icons.check_box : Icons.check_box_outline_blank,
                    text: vatTypeNameList[v],
                    onTap: () {
                      currentVatType = v;
                      setState(() {});
                    }
                ),
              ButtonT.IconText(
                  icon: Icons.auto_mode,
                  text: "부가세 및 공급가액 자동계산",
                  onTap: () {
                    for(var pu in pus) {
                      pu.fixedVat = pu.fixedSup = false;
                      pu.init();
                    }
                    setState(() {});
                  }
              )
            ]
        )
      ],
    );
    var paymentWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "지불관련"),
        SizedBox(height: dividHeight,),
        ListBoxT.Rows(
          spacing: 6,
          children: [
            ButtonT.IconText(
              icon: payment != '매입' ? Icons.check_box_outline_blank : Icons.check_box,
              text: "매입만",
              onTap: () {
                payment = '매입';
                setState(() {});
              },
            ),
            ButtonT.IconText(
              icon: payment != '즉시' ? Icons.check_box_outline_blank : Icons.check_box,
              text: "즉시지불",
              onTap: () {
                payment = '즉시';
                setState(() {});
              },
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
    );

    return ListBoxT.Columns(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6 * 4,
      children: [
        titleWidget,
        contractWidget,
        purchaseInputWidget,
        ListBoxT.Rows( spacing: 6 * 8, children: [ paymentWidget, vatWidget ] ),
      ],
    );
  }

  /// 이 함수는 기록한 품목 매입정보를 데이터베이스에 저장하고 결과를 반환합니다.
  void itemPurchaseSave() async {
    /// ==========================================================
    /// =============== Init =====================================
    if(ct == null)  return Messege.toReturn(context, '계약은 비워둘 수 없습니다.', false);
    if(ct!.ctName  == '') return Messege.toReturn(context, '계약은 비워둘 수 없습니다.', false);

    if(itemTs.length != pus.length) return Messege.toReturn(context, '내부 정보가 올바르지 않습니다. 창을 종료하고 다시 시도해 주세요.', false);
    if(payment == '즉시' && payType == '') return Messege.toReturn(context, '결제방법은 비워둘 수 없습니다.', false);

    for(var pu in pus) {
      var item = SystemT.getItem(pu.item);
      if(item == null) return Messege.toReturn(context, '품목은 등록된 품목목록에서만 추가되어야 합니다.', false);
    }


    /// ==========================================================
    /// =============== Alert =====================================
    var alert = await DialogT.showAlertDl(context, text: "매입정보를 저장하시겠습니까?");
    if(alert == false) return Messege.toReturn(context, '취소됨', false);


    /// ==========================================================
    /// =============== Database Update =====================================
    for(int i = 0; i < pus.length; i++) {
      var p = pus[i];
      var it = itemTs[i];
      var files = fileByteList[i] as Map<String, Uint8List>;

      p.ctUid = ct!.id;
      p.csUid = ct!.csUid;
      p.vatType = currentVatType;
      p.isItemTs = true;

      await p.update(files: files, itemTs: it);
      if(payment == '즉시') await TS.fromPu(p, payType, now: true).update();
    }


    /// ==========================================================
    /// =============== Exit =====================================
    WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
    Navigator.pop(context);
  }

  /// 이 함수는 기록한 일반 매입정보를 데이터베이스에 저장하고 결과를 반환합니다.
  void normalPurchaseSave() async {
    if(cs == null) { WidgetT.showSnackBar(context, text: '거래처는 비워둘 수 없습니다.'); return; }
    if(payment == '즉시' && payType == '') { WidgetT.showSnackBar(context, text: '결제방법은 비워둘 수 없습니다.'); return;  }

    /*for(var p in pus) {
      if(p.unitPrice == 0 || p.supplyPrice == 0) { WidgetT.showSnackBar(context, text: '매입금액은 0일 수 없습니다.'); return;  }
    }*/

    var alert = await DialogT.showAlertDl(context, text: "매입정보를 저장하시겠습니까?");
    if(alert == false) {  WidgetT.showSnackBar(context, text: '취소됨'); return;   }

    for(int i = 0; i < pus.length; i++) {
      var p = pus[i]; var files = fileByteList[i] as Map<String, Uint8List>;

      p.csUid = cs!.id;
      p.vatType = currentVatType;

      if(widget.ct != null) p.ctUid = widget.ct!.id;

      /// 매입정보 추가 - 매입데이터 및 거래명세서 파일 데이터
      await p.update(files: files);
      /// 지불 정보 문서 추가
      if(payment == '즉시')
        await TS.fromPu(p, payType, now: true).update();
    }

    WidgetT.showSnackBar(context, text: '저장됨');
    widget.refresh!();
    widget.parent.onCloseButtonClicked!();
  }



  /// 이 함수는 하단의 액션버튼 위젯을 렌더링 합니다.
  /// 상속구조로 재설계 되어야 합니다.
  Widget buildAction() {


    Function onSave = () {};
    if(widget.isItemPurchase) onSave = itemPurchaseSave;
    else onSave = normalPurchaseSave;

    return Row(
      children: [
        ButtonT.ActionLegacy("매입 추가하기",
          expend: true,
          icon: Icons.save, backgroundColor: StyleT.accentColor.withOpacity(0.5),
          onTap: onSave,
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}
