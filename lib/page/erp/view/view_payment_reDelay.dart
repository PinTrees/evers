import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_item.dart';
import 'package:evers/class/component/comp_process.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_re.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/system/records.dart';
import 'package:evers/class/widget/excel/excel_grid.dart';
import 'package:evers/class/widget/excel/excel_table.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/page.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/ui/dialog_revenue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../class/Customer.dart';
import '../../../class/contract.dart';
import '../../../class/database/balance.dart';
import '../../../class/purchase.dart';
import '../../../class/revenue.dart';
import '../../../class/schedule.dart';
import '../../../class/system.dart';
import '../../../class/system/search.dart';
import '../../../class/system/state.dart';
import '../../../class/transaction.dart';
import '../../../class/widget/button.dart';
import '../../../class/widget/textInput.dart';
import '../../../helper/calender.dart';
import '../../../helper/dialog.dart';
import '../../../helper/firebaseCore.dart';
import '../../../helper/interfaceUI.dart';
import '../../../helper/pdfx.dart';
import '../../../system/system_date.dart';
import 'package:http/http.dart' as http;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../ui/ux.dart';
import 'dart:js' as js;
import 'dart:html' as html;


class ViewPaymentReDelay extends StatefulWidget {
  ViewPaymentReDelay() : super(key: UniqueKey());

  @override
  _ViewPaymentReDelayState createState() => _ViewPaymentReDelayState();
}

class _ViewPaymentReDelayState extends State<ViewPaymentReDelay> {
  TextEditingController searchInput = TextEditingController();
  var divideHeight = 6.0;

  Map<Contract, Records<List<TS>, List<Revenue>>> reDelayList = {};
  Map<String, Customer> csMap = {};

  var load = true;

  @override
  void initState() {
    super.initState();
    load = true;
    initAsync();
  }

  /// 비동기 초기화자 입니다.
  void initAsync() async {
    reDelayList = await Search.searchRevCt();

    var csKeyList = [];
    /// 계약 정보에서 거래처 문서 경로 정보 추출
    reDelayList.keys.forEach((e) { csKeyList.add(e.csUid); });
    List<Customer> csList = await Search.searchCSOrder(csKeyList);

    /// 사용될 거래처 정보 미리 생성 - State 분리
    csMap.clear();
    csList.forEach((cs) { csMap[cs.id] = cs; });

    print("검색 요청 csKeyList info: ${csKeyList}");
    print("검색 결과 csList length: ${csList.length}");

    load = false;
    setState(() {});
  }


  Widget mainBuild() {
    /// 미지급 테이블 UI 목록 위젯입니다.
    List<Widget> widgets = [];
    int index = 1;
    var allP = 0, allPdP = 0;

    reDelayList.forEach((Contract ct, Records<List<TS>, List<Revenue>> value) {
      var allPayedAmount = 0, allPurchaseAmount = 0;

      /// 매출금 및 수입금 계산
      value.Item1.forEach((TS e) { allPayedAmount += e.amount; });
      value.Item2.forEach((Revenue e) { e.init(); allPurchaseAmount += e.totalPrice; });

      /// 총 매출금 및 총 수입금 계산
      allP += allPayedAmount;
      allPdP += allPurchaseAmount;

      var w = CompTS.tableUIPaymentRe(context, Records(allPurchaseAmount, allPayedAmount),
          cs: csMap[ct.csUid], ct: ct, index: index++);

      widgets.addAll([ w, WidgetT.dividHorizontal(size: 0.35) ]);
    });

    Widget bottomWidget = InkWell(
        onTap: () {},
        child: Container( height: 48,
          child: Row(
              children: [
                WidgetT.excelGrid(text: '합계', width: 148.7, label: ''),
                WidgetT.excelGrid(text: StyleT.krwInt(allP), width: 250, label: '총 매출금액'),
                WidgetT.excelGrid( width: 250, label: '총 수입금액', text: StyleT.krwInt(allPdP),),
                WidgetT.excelGrid(text: StyleT.krwInt(allP - allPdP), width: 250, label: '총 미수금액'),
              ]
          ),
        )
    );
    widgets.addAll([ bottomWidget ]);

    /// 위젯 목록은 빌드하여 반환합니다.
    return ListBoxT.Columns(children: widgets,);
  }

  @override
  Widget build(context) {
    return load ? const LinearProgressIndicator(minHeight: 2,) : mainBuild();
  }
}
