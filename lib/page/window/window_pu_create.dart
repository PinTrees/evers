import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/json.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/cs.dart';
import 'package:evers/ui/dialog_item.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
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
import '../../class/widget/text.dart';
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

            for(var p in pus) {
              if(p.unitPrice == 0 || p.supplyPrice == 0) { WidgetT.showSnackBar(context, text: '매입금액은 0일 수 없습니다.'); return;  }
            }

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
/// 거래처를 사용자가 위젯 내부에서 선택할 수 있는 옵션을 제공하기 위해서는 반드시 이 클래스를 생성해야 합니다.
///
/// showCreateNormalPu 함수가 마이그레이션 되었습니다.
///
/// @Create YM
/// @Version 1.0.0
class WindowPUCreate extends WindowBaseMDI {
  Function refresh;
  Contract? ct;
  WindowPUCreate({ this.ct, required this.refresh, }) { }

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

  List<Map<String, Uint8List>> fileByteList = [];
  Contract? ct;
  Customer? cs;

  var isContractLinking = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //widget.parent.title = '수납 개별 상세정보 수정창';

    /// 최초 실행시 기초 품목매입 1개를 추가합니다.
    var pu = Purchase.fromDatabase({});
    pu.purchaseAt = DateTime.now().microsecondsSinceEpoch;
    pus.add(pu);
    fileByteList.add({});

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
          TextT.Title(text: "거래처 정보"),
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


    var dividCol =  SizedBox(height: dividHeight * 8,);

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
                SizedBox(height: dividHeight,),
                contractWidget,
                dividCol,

                TextT.Title(text: "매입 추가 목록"),
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

                dividCol,
                ListBoxT.Rows( spacing: 6 * 8, children: [ paymentWidget, vatWidget ] ),
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
            if(cs == null) { WidgetT.showSnackBar(context, text: '거래처는 비워둘 수 없습니다.'); return; }
            if(payment == '즉시' && payType == '') { WidgetT.showSnackBar(context, text: '결제방법은 비워둘 수 없습니다.'); return;  }

            for(var p in pus) {
              if(p.unitPrice == 0 || p.supplyPrice == 0) { WidgetT.showSnackBar(context, text: '매입금액은 0일 수 없습니다.'); return;  }
            }

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
