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


/// 이 클래스는 페이지의 View 위젯을 빌드하고 반환합니다.
/// 미 지급 현황 페이지를 빌드 합니다.
class ViewPaymentPuDelay extends StatefulWidget {
  ViewPaymentPuDelay() : super(key: UniqueKey());

  @override
  _ViewPaymentPuDelayState createState() => _ViewPaymentPuDelayState();
}

/// 이 클래스는 ViewPaymentPuDelay 위젯클래스의 상태관리 클래스 입니다.
/// 거래처, 거래기록, 매입기록 정보를 관리 합니다.
class _ViewPaymentPuDelayState extends State<ViewPaymentPuDelay> {
  TextEditingController searchInput = TextEditingController();
  var divideHeight = 6.0;

  Map<Customer, Records<List<TS>, List<Purchase>>> puDelayList = {};

  var load = true;

  @override
  void initState() {
    super.initState();
    load = true;
    initAsync();
  }

  /// 비동기 초기화자 입니다.
  void initAsync() async {
    /// 미수가 발생한 거래처 정보를 목록으로 반환 요청
    puDelayList = await Search.searchPurCs();

    load = false;
    setState(() {});
  }


  Widget mainBuild() {
    /// 미지급 테이블 UI 목록 위젯입니다.
    List<Widget> widgets = [];
    int index = 1;
    var allP = 0, allPdP = 0;
    puDelayList.forEach((Customer cs, Records<List<TS>, List<Purchase>> value) {
      var allPayedAmount = 0, allPurchaseAmount = 0;

      value.Item1.forEach((TS e) { allPayedAmount += e.amount; });
      value.Item2.forEach((Purchase e) { e.init(); allPurchaseAmount += e.totalPrice; });

      allP += allPayedAmount;
      allPdP += allPurchaseAmount;

      var w = CompTS.tableUIPaymentPU(context, Records(allPurchaseAmount, allPayedAmount), cs: cs, index: index++);
      widgets.addAll([ w, WidgetT.dividHorizontal(size: 0.35) ]);
    });

    Widget bottomWidget = InkWell(
        onTap: () {},
        child: Container( height: 48,
          child: Row(
              children: [
                WidgetT.excelGrid(text: '합계', width: 148.7, label: ''),
                WidgetT.excelGrid(text: StyleT.krwInt(allP), width: 250, label: '총 매입금액'),
                WidgetT.excelGrid( width: 250, label: '총 지급금액', text: StyleT.krwInt(allPdP),),
                WidgetT.excelGrid(text: StyleT.krwInt(allP - allPdP), width: 250, label: '총 미지급금액'),
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
