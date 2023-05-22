import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_re.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
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
import '../../class/revenue.dart';
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
class WindowReCreateWithCt extends WindowBaseMDI {
  Function refresh;
  Contract ct;

  WindowReCreateWithCt({ required this.ct, required this.refresh }) { }

  @override
  _WindowReCreateWithCtState createState() => _WindowReCreateWithCtState();
}
class _WindowReCreateWithCtState extends State<WindowReCreateWithCt> {
  var dividHeight = 6.0;
  var heightSize = 36.0;

  var payment = '매입';
  var payType = '';

  var vatTypeList = [ 0, 1, ];
  var vatTypeNameList = [ '포함', '미포함', ];
  var currentVatType = 0;

  Contract ct = Contract.fromDatabase({});
  List<Revenue> revenueList = [];

  var isContractLinking = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /// 최초 실행시 기초 품목매입 1개를 추가합니다.
    revenueList.add(Revenue.fromDatabase({ 'revenueAt': DateTime.now().microsecondsSinceEpoch, }));
    ct = Contract.fromDatabase(JsonManager.toJsonObject(widget.ct));
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

    var contractWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "거래처 정보", ),
        TextT.Lit(text: "${ct.csName} / ${ct.ctName}" ),
      ],
    );

    List<Widget> widgetReW = [];
    widgetReW.add(CompRE.tableHeaderInputCt());
    for(int i = 0; i < revenueList.length; i++) {
      var re = revenueList[i];

      if(re.state == "DEL") {
        revenueList.removeAt(i--);
        continue;
      }

      re.vatType = currentVatType;
      re.init();

      var w = CompRE.tableUIInputWithCs(context, re,
        index: i + 1,
        setState: () { setState(() {}); }
      );
      widgetReW.add(w);
      widgetReW.add(WidgetT.dividHorizontal(size: 0.35));
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
                  for(var re in revenueList) {
                    re.fixedVat = re.fixedSup = false;
                    re.init();
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
        TextT.SubTitle(text: '지불관련'),
        SizedBox(height: dividHeight,),
        ListBoxT.Rows(
          spacing: 6,
          children: [
            ButtonT.IconText(
                icon: payment != '매출' ? Icons.check_box_outline_blank : Icons.check_box,
                text: "매출만",
                onTap: () {  payment = '매출'; setState(() {}); }
            ),
            ButtonT.IconText(
                icon: payment != '즉시' ? Icons.check_box_outline_blank : Icons.check_box,
                text: "수금추가",
                onTap: () { payment = '즉시'; setState(() {}); }
            ),
            if(payment == '즉시')
              Row(
                children: [
                  WidgetT.dropMenuMapD(dropMenuMaps: SystemT.accounts, width: 130, label: '구분',
                    onEdite: (i, data) {
                      payType = data;
                      setState(() {});
                    },
                    text: (SystemT.accounts[payType] == null) ? '선택안됨' : SystemT.accounts[payType]!.name,
                  ),
                  SizedBox(width: dividHeight,),
                  TextT.Lit(text: '즉시수금 시 적요는 품목명으로 추가됩니다.'),
                ],
              ),
          ],
        ),
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
                contractWidget,
                SizedBox(height: 6 * 4,),
                TextT.SubTitle(text: '추가할 매출 목록'),
                SizedBox(height: dividHeight,),
                Container( child: Column(children: widgetReW,),),
                SizedBox(height: dividHeight,),
                ButtonT.IconText(
                    icon: Icons.add_box, text: "매출추가",
                    onTap: () {
                      revenueList.add(Revenue.fromDatabase({ 'revenueAt': DateTime.now().microsecondsSinceEpoch, }));
                      setState(() {});
                    }
                ),

                SizedBox(height: 6 * 8,),
                ListBoxT.Rows(
                  spacing: 6 * 8,
                  children: [
                    paymentWidget,
                    vatWidget,
                  ],
                )
              ]
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
        ButtonT.Action(
          context, "신규 매출 저장",
          altText: "신규 매출을 저장하시겠습니까?",
          backgroundColor: StyleT.accentColor.withOpacity(0.5),

          init: () {
            if(revenueList.isEmpty) return Messege.toReturn(context, "매출을 추가한 후 저장을 시도하세요.", false);
            if(payment == '즉시' && payType == '') return Messege.toReturn(context, "즉시결재를 선택시 결재방법을 비워둘 수 없습니다.", false);
            for(int i = 0; i < revenueList.length; i++) {
              if (revenueList[i].revenueAt == 0) return Messege.toReturn(context, "날짜를 정확히 입력해 주세요.", false);
              if (revenueList[i].totalPrice == 0) return Messege.toReturn(context, "매출액은 비워둘 수 없습니다.", false);
            }
            return true;
          },

          onTap: () async {
            for(int i = 0; i < revenueList.length; i++) {
              var revenue = revenueList[i];
              revenue.ctUid = ct.id;
              revenue.csUid = ct.csUid;
              var task = await revenue.update();

              if(task) {
                if(payment == '즉시') await TS.fromRe(revenue, payType, now: true).update();
              }
              else WidgetT.showSnackBar(context, text: 'Database Error');
            }

            widget.refresh();
            widget.parent.onCloseButtonClicked!();
          }
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}



