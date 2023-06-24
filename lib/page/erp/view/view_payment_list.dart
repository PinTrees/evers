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
import 'package:evers/class/widget/messege.dart';
import 'package:evers/class/widget/page.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/erp/view/view_payment_paper.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/ui/dialog_revenue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:korea_regexp/get_regexp.dart';
import 'package:korea_regexp/models/regexp_options.dart';
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



class ViewPaymentList extends StatefulWidget {
  Widget? topWidget;
  Widget? infoWidget;
  ViewPaymentList({ this.topWidget, this.infoWidget }) : super(key: UniqueKey());

  @override
  _ViewPaymentListState createState() => _ViewPaymentListState();
}

class _ViewPaymentListState extends State<ViewPaymentList> {
  TextEditingController searchInput = TextEditingController();
  var divideHeight = 6.0;
  var currentMenu = "";
  var load = true;

  var pageCountList = [ 25, 50, 100 ];
  var pageCount = 25;
  var pageIndex = 0;

  var isSearch = false;
  var isSort = false;

  List<TS> tsDateList = [];
  List<TS> tsSearchList = [];
  List<TS> tsSortList = [];

  var puSortMenu = [ '최신순',  ];
  var puSortMenuDate = [ '최근 1주일', '최근 1개월', '최근 3개월' ];
  var crRpmenuRp = '', currentQuery = '';


  var sortAccount = [];
  var sortDateDec = true;


  DateTime startAt = DateTime.now();
  DateTime lastAt = DateTime.now();

  Map<dynamic, int> account = {};
  int balance = 0;



  @override
  void initState() {
    super.initState();
    load = true;

    initAsync();
  }

  /// 비동기 초기화자 입니다.
  void initAsync() async {
    currentMenu = "목록";

    lastAt = DateTime.now();
    startAt = DateTime(2022, 1, 1);

    await DatabaseM.initMetaCSName();
    tsDateList = await DatabaseM.getTransactionWithDate(startAt.microsecondsSinceEpoch, lastAt.microsecondsSinceEpoch);

    for(var a in SystemT.accounts.values) {
      var amount = await DatabaseM.getAmountAccount(a.id);
      Account acc = SystemT.getAccount(a.id) ?? Account.fromDatabase({});
      account[a.id] = amount + acc.balanceStartAt;
    }
    account.forEach((key, value) { balance += value; });


    load = false;
    setState(() {});
  }

  /// 보유한 거래기록 데이터를 바탕으로 검색을 시도합니다.
  dynamic search(String text) async {
    load = true;
    setState(() {});

    if(text.trim() == "") {
      load = isSearch = false;
      setState(() {});
      return;
    }

    text = text.trim();

    late RegExp regExp;
    try { regExp = getRegExp(text, RegExpOptions(initialSearch: true, startsWith: false, endsWith: false)); }
    catch (e) { print(e); }

    tsSearchList.clear();
    for(var ts in isSort ? tsSortList : tsDateList) {
      var match = false;
      if(regExp.hasMatch(ts.summary)) match = true;
      else if(regExp.hasMatch(ts.id)) match = true;
      else if(regExp.hasMatch(SystemT.getAccountName(ts.account))) match = true;
      else if(regExp.hasMatch(SystemT.getCSName(ts.csUid))) match = true;
      else if(regExp.hasMatch(ts.memo)) match = true;

      if(match) tsSearchList.add(ts);
    }

    Messege.show(context, "${tsSearchList.length} 건의 거래 기록 정보가 검색되었습니다.");

    isSearch = true;
    load = false;
    setState(() {});
  }

  /// 원본 거래기록 정보를 바탕으로 정렬을 시도합니다.
  dynamic sort() async {
    if(sortAccount.isEmpty) {
      isSort = false;
      return;
    }

    isSort = load = true;
    setState(() {});

    tsSortList.clear();
    for(var ts in tsDateList) {
      var match = false;
      if(sortAccount.contains(ts.account)) match = true;

      if(match) tsSortList.add(ts);
    }

    load = false;
    setState(() {});
  }

  /// 거래기록 데이터를 새로고침 합니다.
  dynamic fetch () async {
    isSearch = false;

    load = true;
    setState(() {});

    tsDateList.clear();
    tsDateList = await DatabaseM.getTransactionWithDate(startAt.microsecondsSinceEpoch, lastAt.microsecondsSinceEpoch);

    pageIndex = 0;
    load = false;
    setState(() {});
  }




  Widget titleMenu() {
    Widget titleWidget = Row(
      children: [
        SizedBox(height: 64,),
        InkWell(
          onTap: () {
            currentMenu = '목록';
            setState(() {});
          },
          child: Row(
            children: [
              WidgetT.title('목록', size: 18),
              SizedBox(width: divideHeight * 2,),
              WidgetT.text('( 거래 기록 )', size: 12,)
            ],
          ),
        ),
        SizedBox(width: divideHeight * 2,),
        WidgetT.text('/', size: 12),
        SizedBox(width: divideHeight * 2,),
        InkWell(
          onTap: () {
            currentMenu = '금전출납부';
            setState(() {});
          },
          child: Row(
            children: [
              WidgetT.title('금전출납부', size: 18),
              SizedBox(width: divideHeight * 2,),
              WidgetT.text('( 잔고 )', size: 12,)
            ],
          ),
        ),

        SizedBox(width: divideHeight * 4,),
        ButtonT.TabMenu("수납 추가", Icons.add_box,
            onTap: () { UIState.OpenNewWindow(context, WindowTsCreate(cs: null, refresh: () { initAsync(); } )); }
        ),
      ],
    );

    if(currentMenu == "목록") {
      titleWidget = Column(
        children: [
          Row(
            children: [
              titleWidget,
              SizedBox(width: divideHeight * 3,),
              InputWidget.textSearch(
                  search: (text) async {
                    WidgetT.loadingBottomSheet(context, text:'검색중');
                    await search(text);
                    Navigator.pop(context);
                  },
                  controller: searchInput
              ),
            ],
          ),

          ListBoxT.Rows(
            spacing: 6 * 2,
              children: [
                TextT.SubTitle(text: "계좌 보기"),

                for(var ac in SystemT.accounts.values)
                  ButtonT.Text(
                    text: ac.name, height: 32, round: 8,
                    accent: sortAccount.contains(ac.id),
                    onTap: () {
                      if(sortAccount.contains(ac.id)) sortAccount.remove(ac.id);
                      else sortAccount.add(ac.id);

                      sort();
                      setState(() {});
                    }
                  ),
                ButtonT.TabMenu("계좌선택 초기화", Icons.clear,
                    onTap: () {
                      sortAccount.clear();
                      sort();
                      setState(() {});
                    }
                ),
              ]
          ),

          Container(
            padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
            child: Row(
              children: [
                for(var m in puSortMenuDate)
                  InkWell(
                    onTap: () async {
                      if(currentQuery == m) return;
                      currentQuery = m;

                      lastAt = DateTime.now();
                      if(currentQuery == puSortMenuDate[0]) {
                        startAt = DateTime(lastAt.year, lastAt.month, lastAt.day - 7);
                      }
                      else if(currentQuery == puSortMenuDate[1]) {
                        startAt = DateTime(lastAt.year, lastAt.month - 1, lastAt.day);
                      }
                      else if(currentQuery == puSortMenuDate[2]) {
                        startAt = DateTime(lastAt.year, lastAt.month - 3, lastAt.day);
                      }

                      await fetch();
                    },
                    child: Container(
                      height: 32,
                      decoration: StyleT.inkStyleNone(color: Colors.transparent),
                      padding:EdgeInsets.fromLTRB(12, 6, 12, 6),
                      child: WidgetT.text(m, size: 14, bold: true,
                          color: (m == currentQuery) ? StyleT.titleColor : StyleT.textColor.withOpacity(0.5)),
                    ),
                  ),

                SizedBox(width: divideHeight * 4,),

                InkWell(
                  onTap: () async {
                    var selectedDate = await showDatePicker(
                      context: context,
                      initialDate: startAt, // 초깃값
                      firstDate: DateTime(2018), // 시작일
                      lastDate: DateTime(2030), // 마지막일
                    );
                    if(selectedDate != null) {
                      if (selectedDate.microsecondsSinceEpoch < lastAt.microsecondsSinceEpoch)
                        startAt = selectedDate;
                      currentQuery = '';

                      await fetch();
                    }
                  },
                  child: Container(
                    height: 32,
                    padding: EdgeInsets.all(divideHeight),
                    alignment: Alignment.center,
                    decoration: StyleT.inkStyleNone(color: Colors.transparent),
                    child:WidgetT.text(StyleT.dateFormat(startAt), size: 14, bold: true, color: StyleT.titleColor),
                  ),
                ),
                WidgetT.text('~',  size: 14, color: StyleT.textColor.withOpacity(0.5)),
                InkWell(
                  onTap: () async {
                    var selectedDate = await showDatePicker(
                      context: context,
                      initialDate: lastAt, // 초깃값
                      firstDate: DateTime(2018), // 시작일
                      lastDate: DateTime(2030), // 마지막일
                    );
                    if(selectedDate != null) {
                      lastAt = selectedDate;
                      currentQuery = '';

                      await fetch();
                    }
                  },
                  child: Container(
                    height: 32,
                    padding: EdgeInsets.all(divideHeight),
                    alignment: Alignment.center,
                    decoration: StyleT.inkStyleNone(color: Colors.transparent),
                    child:WidgetT.text(StyleT.dateFormat(lastAt), size: 14, bold: true, color: StyleT.titleColor),
                  ),
                ),

                SizedBox(width: divideHeight * 4,),

                ButtonT.TabMenu("검색 초기화", Icons.refresh,
                  onTap: () async {
                    lastAt = DateTime.now();
                    startAt = DateTime(2022);
                    await fetch();
                  }
                ),
              ],
            ),
          ),
        ],
      );
    }

    return titleWidget;
  }

  Widget mainBuild() {
    List<Widget> widgets = [];

    if(currentMenu == '목록') {

      var dataList = isSearch ? tsSearchList : isSort ? tsSortList : tsDateList;

      int startPage = (pageCount * pageIndex);
      pageIndex == 0 ? startPage + 0 : startPage - 1;
      for(int i = startPage; i < startPage + pageCount; i++) {
        if(i >= dataList.length) break;
        var ts = dataList[i];

        Widget w = CompTS.tableUIMain( ts,
            context: context, index: i + 1,
            setState: () { setState(() {}); },
            refresh: () { initAsync(); }
        );
        widgets.addAll([w, WidgetT.dividHorizontal(size: 0.35)]);
      }

      widgets.add(SizedBox(height: 6,));
      widgets.add(
          Container(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ListBoxT.Rows(
                    spacing: 6,
                    children: [
                      for(int i = 0; i < dataList.length / pageCount; i++)
                        ButtonT.Text(
                            size: 28, accent: i == pageIndex,
                            text: (i + 1).toString(),
                            onTap: () {
                              pageIndex = i;
                              setState(() {});
                            }
                        ),
                    ]
                )
              ],
            ),
          )
      );
    }
    else if(currentMenu == "금전출납부") {
      widgets.add(ViewPaymentPaper());
    }

    /// 위젯 목록은 빌드하여 반환합니다.
    return ListBoxT.Columns(children: widgets,);
  }

  Widget bottomSheet() {
    Widget bottomWidget = const SizedBox();
    if(currentMenu == "목록") {
      var amountPu = 0, amountRe = 0;
      var dataList = isSearch ? tsSearchList : isSort ? tsSortList : tsDateList;
      var searchTsCount = dataList.length;

      dataList.forEach((e) {
        if(e.type == 'RE') amountRe += e.amount;
        else if(e.type == 'PU') amountPu += e.amount;
      });

      bottomWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            children: [
              for(var a in account.keys)
                Container( height: 28, width: 300,
                  child: WidgetT.excelGrid(textLite: true, text: SystemT.getAccountName(a) + '    ' + StyleT.krwInt(account[a]), alignment: Alignment.centerLeft, width: 300, label: ''),
                )
            ],
          ),
          WidgetT.dividHorizontal(size: 0.35),
          InkWell(
              onTap: () {

              },
              child: Container( height: 48,
                child: Row(
                    children: [
                      TextT.SubTitle(text: '총 금액'),
                      SizedBox(width: 12,),
                      TextT.Lit(text: StyleT.krwInt(balance), expand: true, alignment: Alignment.centerLeft, size: 12 ),
                      TextT.SubTitle(text: isSearch ? '검색된 거래수' : '기간내 거래수'),
                      SizedBox(width: 12,),
                      TextT.Lit(text: '${ searchTsCount } 건', expand: true, alignment: Alignment.centerLeft, size: 12),
                      TextT.SubTitle(text: isSearch ? '검색된 지출 총액' : '기간내 지출 총액'),
                      SizedBox(width: 12,),
                      TextT.Lit(text: StyleT.krwInt(amountPu), expand: true, alignment: Alignment.centerLeft, size: 12),
                      TextT.SubTitle(text: isSearch ? '검색된 수입 총액' : '기간내 수입 총액'),
                      SizedBox(width: 12,),
                      TextT.Lit(text: StyleT.krwInt(amountRe), expand: true, alignment: Alignment.centerLeft, size: 12),
                    ]
                ),
              )
          ),
        ],
      );
    }
    return bottomWidget;
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(context) {
    return PageWidget.MainPage(
      topWidget: widget.topWidget,
      infoWidget: widget.infoWidget,
      titleWidget: Column(
        children: [
          titleMenu(),
        ],
      ),
      children: [
        load ? const LinearProgressIndicator(minHeight: 2,) : mainBuild()
      ],
      bottomWidget: bottomSheet(),
    );
  }
}
