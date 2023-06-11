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
import 'package:evers/system/printform.dart';
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
class ViewPaymentPaper extends StatefulWidget {
  ViewPaymentPaper() : super(key: UniqueKey());

  @override
  _ViewPaymentPaperState createState() => _ViewPaymentPaperState();
}

/// 이 클래스는 ViewPaymentPuDelay 위젯클래스의 상태관리 클래스 입니다.
/// 거래처, 거래기록, 매입기록 정보를 관리 합니다.
class _ViewPaymentPaperState extends State<ViewPaymentPaper> {
  TextEditingController searchInput = TextEditingController();
  var divideHeight = 6.0;

  var oldBalance = 0;
  var balance = 0;
  var selBalance = 0;

  Map<dynamic, int> account = {};
  Map<dynamic, int> oldAccount = {};
  Map<dynamic, int> selAccount = {};

  List<TS> tsList = [];

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  /// 비동기 초기화자 입니다.
  void initAsync() async {
    oldBalance = 0;
    for(var a in SystemT.accounts.values) {
      var startAt = DateStyle.startAtEpoch(new DateTime(1, 1, 1));
      var lastAt = DateStyle.lastOneDayAtEpoch();

      var amount = await DatabaseM.getAmountAccountWithDate(a.id, startAt, lastAt);
      Account acc = SystemT.getAccount(a.id) ?? Account.fromDatabase({});
      oldAccount[a.id] = amount + acc.balanceStartAt;
    }
    oldAccount.forEach((key, value) { oldBalance += value; });

    balance = 0;
    for(var a in SystemT.accounts.values) {
      var amount = await DatabaseM.getAmountAccount(a.id,);
      Account acc = SystemT.getAccount(a.id) ?? Account.fromDatabase({});
      account[a.id] = amount + acc.balanceStartAt;
    }
    account.forEach((key, value) { balance += value; });



    for(var a in SystemT.accounts.values) {
      var startAt = DateStyle.dateEphoceD(SystemDate.selectDate['startDate']!.microsecondsSinceEpoch);
      var lastAt = DateStyle.dateEphoceD(SystemDate.selectWorkDate.microsecondsSinceEpoch);

      var amount = await DatabaseM.getAmountAccountWithDate(a.id, startAt, lastAt);
      Account acc = SystemT.getAccount(a.id) ?? Account.fromDatabase({});
      selAccount[a.id] = amount + acc.balanceStartAt;
    }

    /// 최적화 완료
    tsList = await DatabaseM.getTransactionWithDate(SystemDate.selectDate['startDate']!.microsecondsSinceEpoch, SystemDate.selectWorkDate.microsecondsSinceEpoch);
    tsList.sort((a, b) => b.transactionAt.compareTo(a.transactionAt));

    setState(() {});
  }


  /// 재걔산자 입니다.
  void refresh() async {
    WidgetT.loadingBottomSheet(context, text: "로딩중");

    for(var a in SystemT.accounts.values) {
      var startAt = DateStyle.dateEphoceD(SystemDate.selectDate['startDate']!.microsecondsSinceEpoch);
      var lastAt = DateStyle.dateEphoceD(SystemDate.selectWorkDate.microsecondsSinceEpoch);

      var amount = await DatabaseM.getAmountAccountWithDate(a.id, startAt, lastAt);
      Account acc = SystemT.getAccount(a.id) ?? Account.fromDatabase({});
      selAccount[a.id] = amount + acc.balanceStartAt;
    }

    /// 최적화 완료
    tsList = await DatabaseM.getTransactionWithDate(SystemDate.selectDate['startDate']!.microsecondsSinceEpoch, SystemDate.selectWorkDate.microsecondsSinceEpoch);
    tsList.sort((a, b) => b.transactionAt.compareTo(a.transactionAt));

    Navigator.pop(context);
    setState(() {});
  }


  Widget mainBuild() {
    List<Widget> widgets = [];

    for(int i = 0 ; i < account.length; i++) {
      var key = account.keys.elementAt(i);
      var value = account.values.elementAt(i);
      var w = InkWell(
        child: Container(
          height: StyleT.listHeight + divideHeight,
          child: Row(
            children: [
              WidgetT.excelGrid(textSize: 10, textLite: true, text: '${i + 1}', width: 32),
              WidgetT.excelGrid(width: 25),
              WidgetT.excelGrid(textSize: 10, textLite: false, text: SystemT.getAccountName(key), width: 200, alignment: Alignment.centerLeft),
              WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.krwInt(value), width: 100, alignment: Alignment.centerLeft),
              WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.krwInt(oldAccount[key]), width: 100, alignment: Alignment.centerLeft),
              WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.krwInt(value - (oldAccount[key] ?? 0)), width: 100, alignment: Alignment.centerLeft),
            ],
          ),
        ),
      );
      widgets.addAll([ w, WidgetT.dividHorizontal(size: 0.35) ]);
    }

    var w = InkWell(
      child: Container(
        height: StyleT.listHeight + divideHeight,
        child: Row(
          children: [
            WidgetT.excelGrid(textSize: 10, textLite: true, text: 'ㅡ', width: 32),
            WidgetT.excelGrid(width: 25),
            WidgetT.excelGrid(textSize: 10, textLite: false, text: '잔고', width: 200, alignment: Alignment.centerLeft),
            WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.krwInt(balance), width: 100, alignment: Alignment.centerLeft),
            WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.krwInt(oldBalance), width: 100, alignment: Alignment.centerLeft),
            WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.krwInt(balance - oldBalance), width: 100, alignment: Alignment.centerLeft),
          ],
        ),
      ),
    );
    widgets.addAll([ w, WidgetT.dividHorizontal(size: 0.35) ]);

    // 프린트할 거래기록의 시작날짜 / 서버안정성을 위해 기초값 최근 한달로 설정
    SystemDate.selectDate['startDate'] ??= DateTime(DateTime.now().year, DateTime.now().month, 1);
    widgets.add(SizedBox(height: divideHeight * 8,));
    var printMenuTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(),
        WidgetT.title('기간조회', size: 18),
        SizedBox(height: divideHeight,),
        Row(
          children: [
            WidgetT.titleT('잔고출력시작일자', size: 14, color: Colors.grey.withOpacity(0.75)),
            SizedBox(width: divideHeight * 2,),
            SizedBox(
              width: 100,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  focusColor: Colors.transparent,
                  focusNode: FocusNode(),
                  autofocus: false,
                  customButton: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(child: SizedBox()),
                        WidgetT.title(SystemDate.dateFormat_YYYY_kr(SystemDate.selectDate['startDate']!), size: 14),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                  items: SystemDate.years?.map((item) => DropdownMenuItem<dynamic>(
                    value: item,
                    child: Text(
                      item.toString() + '년',
                      style: StyleT.titleStyle(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                  onChanged: (value) async {
                    var org = SystemDate.selectDate['startDate']!;
                    SystemDate.selectDate['startDate'] = DateTime(value, org.month, org.day);
                    refresh();
                  },
                  itemHeight: 28,
                  itemPadding: const EdgeInsets.only(left: 16, right: 16),
                  dropdownWidth: 100,
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
                  offset: const Offset(0, 0),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  focusColor: Colors.transparent,
                  focusNode: FocusNode(),
                  autofocus: false,
                  customButton: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(child: SizedBox()),
                        WidgetT.title(SystemDate.dateFormat_MM_kr(SystemDate.selectDate['startDate']!), size: 14),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                  items: SystemDate.months?.map((item) => DropdownMenuItem<dynamic>(
                    value: item,
                    child: Text(
                      item.toString() + '월',
                      style: StyleT.titleStyle(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                  onChanged: (value) async {
                    var org = SystemDate.selectDate['startDate']!;
                    SystemDate.selectDate['startDate'] = DateTime(org.year, value, org.day);
                    refresh();
                  },
                  itemHeight: 28,
                  itemPadding: const EdgeInsets.only(left: 16, right: 16),
                  dropdownWidth: 60,
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
                  offset: const Offset(0, 0),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  focusColor: Colors.transparent,
                  focusNode: FocusNode(),
                  autofocus: false,
                  customButton: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(child: SizedBox()),
                        WidgetT.title(SystemDate.selectDate['startDate']!.day.toString() + '일', size: 14),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                  items: SystemDate.days?.map((item) => DropdownMenuItem<dynamic>(
                    value: item,
                    child: Text(
                      item.toString() + '일',
                      style: StyleT.titleStyle(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                  onChanged: (value) async {
                    var org = SystemDate.selectDate['startDate']!;
                    SystemDate.selectDate['startDate'] = DateTime(org.year, org.month, value);
                    refresh();
                  },
                  itemHeight: 28,
                  itemPadding: const EdgeInsets.only(left: 16, right: 16),
                  dropdownWidth: 60,
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
                  offset: const Offset(0, 0),
                ),
              ),
            ),
            SizedBox(width: divideHeight * 2,),
            WidgetT.text('잔고 계산에 영향을 끼치지 않으며 출력 결과 조정에만 사용됩니다.', size: 12, ),
          ],
        ),
        SizedBox(height: divideHeight,),
        Row(
          children: [
            WidgetT.titleT('잔고계산마감일자', size: 14, color: Colors.grey.withOpacity(0.75)),
            SizedBox(width: divideHeight * 2,),
            SizedBox(
              width: 100,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  focusColor: Colors.transparent,
                  focusNode: FocusNode(),
                  autofocus: false,
                  customButton: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(child: SizedBox()),
                        WidgetT.title(SystemDate.dateFormat_YYYY_kr(SystemDate.selectWorkDate), size: 14),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                  items: SystemDate.years?.map((item) => DropdownMenuItem<dynamic>(
                    value: item,
                    child: Text(
                      item.toString() + '년',
                      style: StyleT.titleStyle(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                  onChanged: (value) async {
                    var org = SystemDate.selectWorkDate;
                    SystemDate.selectWorkDate = DateTime(value, org.month, org.day);
                    refresh();
                  },
                  itemHeight: 28,
                  itemPadding: const EdgeInsets.only(left: 16, right: 16),
                  dropdownWidth: 100,
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
                  offset: const Offset(0, 0),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  focusColor: Colors.transparent,
                  focusNode: FocusNode(),
                  autofocus: false,
                  customButton: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(child: SizedBox()),
                        WidgetT.title(SystemDate.dateFormat_MM_kr(SystemDate.selectWorkDate), size: 14),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                  items: SystemDate.months?.map((item) => DropdownMenuItem<dynamic>(
                    value: item,
                    child: Text(
                      item.toString() + '월',
                      style: StyleT.titleStyle(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                  onChanged: (value) async {
                    var org = SystemDate.selectWorkDate;
                    SystemDate.selectWorkDate = DateTime(org.year, value, org.day);
                    refresh();
                  },
                  itemHeight: 28,
                  itemPadding: const EdgeInsets.only(left: 16, right: 16),
                  dropdownWidth: 60,
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
                  offset: const Offset(0, 0),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  focusColor: Colors.transparent,
                  focusNode: FocusNode(),
                  autofocus: false,
                  customButton: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(child: SizedBox()),
                        WidgetT.title(SystemDate.selectWorkDate.day.toString() + '일', size: 14),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                  items: SystemDate.days?.map((item) => DropdownMenuItem<dynamic>(
                    value: item,
                    child: Text(
                      item.toString() + '일',
                      style: StyleT.titleStyle(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                  onChanged: (value) async {
                    var org = SystemDate.selectWorkDate;
                    SystemDate.selectWorkDate = DateTime(org.year, org.month, value);
                    refresh();
                  },
                  itemHeight: 28,
                  itemPadding: const EdgeInsets.only(left: 16, right: 16),
                  dropdownWidth: 60,
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
                  offset: const Offset(0, 0),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: divideHeight,),
        Row(
          children: [
            WidgetT.titleT('기간 내 거래 목록', size: 14, color: Colors.grey.withOpacity(0.75)),
            SizedBox(width: divideHeight * 2,),
            WidgetT.title('${tsList.length} 개', size: 14,),
          ],
        ),
      ],
    );
    widgets.addAll([ printMenuTitle, SizedBox(height: divideHeight * 2,) ]);


    selAccount.forEach((key, value) { selBalance += value; });
    widgets.add(WidgetUI.titleRowNone([ '순번', '계좌', '현재일잔고', '선택일잔고', '변동금', '수입', '지출', ],
        [ 32, 200, 100, 100, 100, 100, 100, 100  ]),);
    for(int i = 0 ; i < account.length; i++) {
      var key = account.keys.elementAt(i);
      var value = account.values.elementAt(i);
      var w = InkWell(
        child: Container(
          height: StyleT.listHeight + divideHeight,
          child: Row(
            children: [
              WidgetT.excelGrid(textSize: 10, textLite: true, text: '${i + 1}', width: 32),
              WidgetT.excelGrid(width: 25),
              WidgetT.excelGrid(textSize: 10, textLite: false, text: SystemT.getAccountName(key), width: 200, alignment: Alignment.centerLeft),
              WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.krwInt(value), width: 100, alignment: Alignment.centerLeft),
              WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.krwInt(selAccount[key]), width: 100, alignment: Alignment.centerLeft),
              WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.krwInt(value - (selAccount[key] ?? 0)), width: 100, alignment: Alignment.centerLeft),
            ],
          ),
        ),
      );
      widgets.addAll([ w, WidgetT.dividHorizontal(size: 0.35) ]);
    }

    var sW = InkWell(
      child: Container(
        height: StyleT.listHeight + divideHeight,
        child: Row(
          children: [
            WidgetT.excelGrid(textSize: 10, textLite: true, text: 'ㅡ', width: 32),
            WidgetT.excelGrid(width: 25),
            WidgetT.excelGrid(textSize: 10, textLite: false, text: '잔고', width: 200, alignment: Alignment.centerLeft),
            WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.krwInt(balance), width: 100, alignment: Alignment.centerLeft),
            WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.krwInt(selBalance), width: 100, alignment: Alignment.centerLeft),
            WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.krwInt(balance - selBalance), width: 100, alignment: Alignment.centerLeft),
          ],
        ),
      ),
    );
    widgets.addAll([ sW, WidgetT.dividHorizontal(size: 0.35), SizedBox(height: divideHeight,) ]);

    /// 금전출납부 PDF 인쇄 양식 추가, 인쇄 버튼
    widgets.add(
        ListBoxT.Rows(
          spacing: 6 * 2,
          children: [
            ButtonT.IconText(
              icon: Icons.print, text: "인쇄",
              onTap: () async {
                WidgetT.loadingBottomSheet(context, text: "로딩중");
                var data = await PrintFormT.PaymentList(tsList: tsList, balance: selBalance, account: selAccount);
                Navigator.pop(context);
                await Printing.layoutPdf(onLayout: (format) async => await data);
              }
            ),
            ButtonT.IconText(
                icon: Icons.downloading, text: "파일로 다운로드",
                onTap: () async {
                  WidgetT.loadingBottomSheet(context, text: "로딩중");
                  var data = await PrintFormT.PaymentList(tsList: tsList, balance: selBalance, account: selAccount);
                  Navigator.pop(context);
                  js.context.callMethod("saveAs", <Object>[html.Blob(<Object>[data!]), '금전출납부.pdf',]);
                }
            ),
          ],
        ));

    widgets.add(SizedBox(height: divideHeight * 8,));
    widgets.add(InkWell(
      onTap: () {
        WidgetT.showSnackBar(context, text: '개발중인 기능');
      },
      child: Container(
        padding: EdgeInsets.all(18),
        child: WidgetT.title('차트로 보기', size: 12),
      ),
    ));

    /// 위젯 목록은 빌드하여 반환합니다.
    return ListBoxT.Columns(children: widgets,);
  }

  @override
  Widget build(context) {
    return mainBuild();
  }
}
