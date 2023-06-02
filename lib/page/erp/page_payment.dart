import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/system/records.dart';
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
import '../../../class/purchase.dart';
import '../../../class/revenue.dart';
import '../../../class/schedule.dart';
import '../../../class/system.dart';
import '../../../class/system/search.dart';
import '../../../class/system/state.dart';
import '../../../class/transaction.dart';
import '../../../class/widget/button.dart';
import '../../../class/widget/textInput.dart';
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



class PagePayment extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var scrollVertController = ScrollController();
  var scrollHoriController = ScrollController();
  var divideHeight = 6.0;

  List<TS> tsList = [];
  List<TS> tsSortList = [];

  bool sort = false;
  var currentView = '매입';

  var puSortMenu = [ '최신순',  ];
  var puSortMenuDate = [ '최근 1주일', '최근 1개월', '최근 3개월' ];
  var crRpmenuRp = '', currentQuery = '';

  DateTime sortStartAt = DateTime.now();
  DateTime sortLastAt = DateTime.now();

  bool initailze = false;

  dynamic init() async {}
  String menu = '';

  dynamic search(String search) async {
    if(search == '') {
      sort = false;
      currentQuery = '';
      clear();

      FunT.setStateMain();
      return;
    }

    sort = true;
    if(menu == '금전출납현황') {
      await SystemT.searchTSMeta(
        searchInput.text,
        startAt: sortStartAt.microsecondsSinceEpoch.toString().substring(0, 8),
        lastAt: sortLastAt.microsecondsSinceEpoch.toString().substring(0, 8),
      );

      tsSortList = await Search.searchTS();
    }

    FunT.setStateMain();
  }
  void query_init() {
    sort = false;
    tsList.clear();
  }
  void clear() async {
    tsList.clear();
  }

  var menuStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.15), );
  var menuSelectStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.35), );
  var menuPadding = EdgeInsets.fromLTRB(6 * 4, 6 * 1, 6 * 4, 6 * 1);
  var disableTextColor = StyleT.titleColor.withOpacity(0.35);

  Map<dynamic, int> account = {};
  var currentMenu = '';
  var select_year = 2022;


  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false,}) async {
    var balance = 0;

    if(this.menu != menu) {
      sort = false; searchInput.text = '';
    }
    if(refresh) {
      clear();
      sort = false;
      currentQuery = '';
      sortLastAt = DateTime.now();
      sortStartAt = DateTime(sortLastAt.year, sortLastAt.month, sortLastAt.day - 180);
    }

    this.menu = menu;

    Widget titleMenu = SizedBox();
    Widget bottomWidget = SizedBox();

    List<Widget> childrenW = [];
    if(menu == "일계표") {

    }
    if(menu == '금전출납현황') {
      currentMenu = (currentMenu == '') ? '목록' : currentMenu;
      childrenW.clear();
      var titleW = Row(
        children: [
          SizedBox(height: 64,),
          InkWell(
            onTap: () {
              currentMenu = '목록';
              FunT.setStateMain();
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
              FunT.setStateMain();
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
              onTap: () { UIState.OpenNewWindow(context, WindowTsCreate(cs: null, refresh: () { FunT.setStateMain(); })); }
          ),
        ],
      );

      if(currentMenu == '목록') {
        titleMenu = Column(
          children: [
            Row(
              children: [
                titleW,
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
            Container(
              padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: Row(
                children: [
                  for(var m in puSortMenuDate)
                    InkWell(
                      onTap: () async {
                        if(currentQuery == m) return;
                        currentQuery = m;
                        query_init();

                        sortLastAt = DateTime.now();
                        if(currentQuery == puSortMenuDate[0]) {
                          sortStartAt = DateTime(sortLastAt.year, sortLastAt.month, sortLastAt.day - 7);
                        }
                        else if(currentQuery == puSortMenuDate[1]) {
                          sortStartAt = DateTime(sortLastAt.year, sortLastAt.month - 1, sortLastAt.day);
                        }
                        else if(currentQuery == puSortMenuDate[2]) {
                          sortStartAt = DateTime(sortLastAt.year, sortLastAt.month - 3, sortLastAt.day);
                        }

                        FunT.setStateMain();
                      },
                      child: Container(
                        height: 32,
                        decoration: StyleT.inkStyleNone(color: Colors.transparent),
                        padding:menuPadding,
                        child: WidgetT.text(m, size: 14, bold: true,
                            color: (m == currentQuery) ? StyleT.titleColor : StyleT.textColor.withOpacity(0.5)),
                      ),
                    ),

                  SizedBox(width: divideHeight * 4,),

                  InkWell(
                    onTap: () async {
                      var selectedDate = await showDatePicker(
                        context: context,
                        initialDate: sortStartAt, // 초깃값
                        firstDate: DateTime(2018), // 시작일
                        lastDate: DateTime(2030), // 마지막일
                      );
                      if(selectedDate != null) {
                        if (selectedDate.microsecondsSinceEpoch < sortLastAt.microsecondsSinceEpoch) sortStartAt = selectedDate;
                        currentQuery = '';

                        tsSortList.clear();
                        clear();
                      }
                    },
                    child: Container(
                      height: 32,
                      padding: EdgeInsets.all(divideHeight),
                      alignment: Alignment.center,
                      decoration: StyleT.inkStyleNone(color: Colors.transparent),
                      child:WidgetT.text(StyleT.dateFormat(sortStartAt), size: 14, bold: true, color: StyleT.titleColor),
                    ),
                  ),
                  WidgetT.text('~',  size: 14, color: StyleT.textColor.withOpacity(0.5)),
                  InkWell(
                    onTap: () async {
                      var selectedDate = await showDatePicker(
                        context: context,
                        initialDate: sortLastAt, // 초깃값
                        firstDate: DateTime(2018), // 시작일
                        lastDate: DateTime(2030), // 마지막일
                      );
                      if(selectedDate != null) {
                        sortLastAt = selectedDate;
                        currentQuery = '';

                        tsSortList.clear();
                        clear();
                      }
                    },
                    child: Container(
                      height: 32,
                      padding: EdgeInsets.all(divideHeight),
                      alignment: Alignment.center,
                      decoration: StyleT.inkStyleNone(color: Colors.transparent),
                      child:WidgetT.text(StyleT.dateFormat(sortLastAt), size: 14, bold: true, color: StyleT.titleColor),
                    ),
                  ),

                  SizedBox(width: divideHeight * 4,),
                  InkWell(
                    onTap: () async {
                      await mainView(context, menu, refresh: true);
                      await FunT.setStateMain();
                    },
                    child: Container( height: 32,
                      padding: menuPadding,
                      child: WidgetT.text('검색초기화', size: 14, bold: true,
                          color: StyleT.textColor.withOpacity(0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        if(tsList.length  < 1) {
          tsList = await DatabaseM.getTransaction(   startDate: sortStartAt.microsecondsSinceEpoch,  lastDate: sortLastAt.microsecondsSinceEpoch,);
        }

        var datas = sort ? tsSortList : tsList;
        for(int i = 0; i < datas.length; i++) {
          var tmpTs = datas[i];
          var cs = await SystemT.getCS(tmpTs.csUid);
          Widget w = CompTS.tableUIMain( tmpTs,
            context: context, index: i + 1, cs: cs,
            setState: () { mainView(context, menu); },
            refresh: () { mainView(context, menu, refresh: true); }
          );
          childrenW.add(w);
          childrenW.add(WidgetT.dividHorizontal(size: 0.35));
        }

        childrenW.add(InkWell(
          onTap: () async {
            WidgetT.loadingBottomSheet(context, text: '로딩중');

            if(sort) {
              tsSortList.addAll(await Search.searchTS());
              Navigator.pop(context);
              await FunT.setStateMain();
              return;
            }

            var list = await DatabaseM.getTransaction(
              startAt: tsList.last.id,
              startDate: sortStartAt.microsecondsSinceEpoch,
              lastDate: sortLastAt.microsecondsSinceEpoch,
            );
            tsList.addAll(list);

            Navigator.pop(context);
            await FunT.setStateMain();
          },
          child: Container(
            height: 36,
            child: Row(
              children: [
                WidgetT.iconMini(Icons.add_box, size: 36),
                WidgetT.title('더보기'),
              ],
            ),
          ),
        ));

        for(var a in SystemT.accounts.values) {
          var amount = await DatabaseM.getAmountAccount(a.id);
          Account acc = SystemT.getAccount(a.id) ?? Account.fromDatabase({});
          account[a.id] = amount + acc.balanceStartAt;
        }
        account.forEach((key, value) { balance += value; });


        List<TS> tsDateList = [];
        tsDateList = await DatabaseM.getTransactionWithDate(sortStartAt.microsecondsSinceEpoch, sortLastAt.microsecondsSinceEpoch);
        var amountPu = 0;
        var amountRe = 0;
        var searchTsCount = sort ? Search.tsList.length : tsDateList.length;

        if(sort) {
          Search.tsList.forEach((e) {
            if(e == null) return;
            if(e.id == '') return;
            var val = tsDateList.firstWhere((ts) => ts.id == e.id);
            if(val != null) {
              if(val.type == 'RE') amountRe += val.amount;
              else if(val.type == 'PU') amountPu += val.amount;
            }
          });
        } else
          tsDateList.forEach((e) {
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
                        TextT.SubTitle(text: sort ? '검색된 거래수' : '기간내 거래수'),
                        SizedBox(width: 12,),
                        TextT.Lit(text: '${ searchTsCount } 건', expand: true, alignment: Alignment.centerLeft, size: 12),
                        TextT.SubTitle(text: sort ? '검색된 지출 총액' : '기간내 지출 총액'),
                        SizedBox(width: 12,),
                        TextT.Lit(text: StyleT.krwInt(amountPu), expand: true, alignment: Alignment.centerLeft, size: 12),
                        TextT.SubTitle(text: sort ? '검색된 수입 총액' : '기간내 수입 총액'),
                        SizedBox(width: 12,),
                        TextT.Lit(text: StyleT.krwInt(amountRe), expand: true, alignment: Alignment.centerLeft, size: 12),
                      ]
                  ),
                )
            ),
          ],
        );
      }

      else if(currentMenu == '금전출납부') {
        titleMenu = titleW;

        var oldBalance = 0;
        Map<dynamic, int> oldAccount = {};
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
          childrenW.add(w);
          childrenW.add(WidgetT.dividHorizontal(size: 0.35));
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
        childrenW.add(w);
        childrenW.add(WidgetT.dividHorizontal(size: 0.35));

        // 프린트할 거래기록의 시작날짜 / 서버안정성을 위해 기초값 최근 한달로 설정
        SystemDate.selectDate['startDate'] ??= DateTime(DateTime.now().year, DateTime.now().month, 1);

        /// 최적화 완료
        List<TS> tsList = await DatabaseM.getTransactionWithDate(SystemDate.selectDate['startDate']!.microsecondsSinceEpoch,
            SystemDate.selectWorkDate.microsecondsSinceEpoch);
        tsList.sort((a, b) => b.transactionAt.compareTo(a.transactionAt));

        childrenW.add(SizedBox(height: divideHeight * 8,));
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
                        await FunT.setStateMain();
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
                        await FunT.setStateMain();
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
                        await FunT.setStateMain();
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
                        await FunT.setStateMain();
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
                        await FunT.setStateMain();
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
                        await FunT.setStateMain();
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
        childrenW.add(printMenuTitle);
        childrenW.add(SizedBox(height: divideHeight * 2,));

        var selBalance = 0;
        Map<dynamic, int> selAccount = {};
        for(var a in SystemT.accounts.values) {
          var startAt = DateStyle.startAtEpoch(new DateTime(1, 1, 1));
          var lastAt = DateStyle.dateEphoceD(SystemDate.selectWorkDate.microsecondsSinceEpoch);

          var amount = await DatabaseM.getAmountAccountWithDate(a.id, startAt, lastAt);
          Account acc = SystemT.getAccount(a.id) ?? Account.fromDatabase({});
          selAccount[a.id] = amount + acc.balanceStartAt;
        }

        selAccount.forEach((key, value) { selBalance += value; });

        childrenW.add(WidgetUI.titleRowNone([ '순번', '계좌', '현재일잔고', '선택일잔고', '변동금', '수입', '지출', ],
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
          childrenW.add(w);
          childrenW.add(WidgetT.dividHorizontal(size: 0.35));
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
        childrenW.add(sW);
        childrenW.add(WidgetT.dividHorizontal(size: 0.35));

        childrenW.add(SizedBox(height: divideHeight,));

        // 03.27 금전출납부 PDF 인쇄 양식 추가
        // 인쇄 버튼
        var selBalanceCal = selBalance;
        List<List<List<String>>> tableStringList = [];
        for(int i = 0; i < (tsList.length / 35); i++) {
          tableStringList.add([]);
          for(int j = 0; j < 35; j++) {
            if((i * 35) + j >= tsList.length) break;

            tableStringList[i].add(await tsList[(i * 35) + j].getTable(selBalanceCal));
            selBalanceCal = selBalanceCal - tsList[(i * 35) + j].getAmount();
          }
        }
        childrenW.add(
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    final doc = pw.Document();

                    bool lastPage = false;
                    for(int i = 0; i < (tsList.length / 35); i++) {
                      if(i >= ((tsList.length / 35) - 1) && !(tableStringList[i].length < 24))
                        lastPage = true;

                      doc.addPage(pw.Page(
                          pageFormat: PdfPageFormat.a4,
                          margin: const pw.EdgeInsets.all(24),
                          build: (pw.Context context) {
                            return pw.Column(
                                children: [
                                  if(i == 0) pw.Text('금전출납부 (에버스)', style: pw.TextStyle(font:  StyleT.font, fontSize: 18),),
                                  pw.SizedBox(height: divideHeight * 4 ),
                                  pw.Container(
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                                    ),
                                    child: pw.Column(
                                        mainAxisSize: pw.MainAxisSize.min,
                                        children: [
                                          pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                              headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                                <String>['일자', '은행명', '예금주', '     수입     ', '     지출     ', '     잔고     ', '          적요 및 비고         '],
                                                for(var rr in tableStringList[i])
                                                  rr,
                                              ]),
                                        ]
                                    ),
                                  ),

                                  if(i >= ((tsList.length / 35) - 1) && tableStringList[i].length < 24)
                                    pw.Expanded(flex: 9, child: pw.SizedBox(height: divideHeight * 4 ),),
                                  if(i >= ((tsList.length / 35) - 1) && tableStringList[i].length < 24)
                                    pw.Row(
                                        mainAxisAlignment: pw.MainAxisAlignment.end,
                                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                                        children: [
                                          pw.Container(
                                            decoration: pw.BoxDecoration(
                                              border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                                            ),
                                            child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font,
                                                color: PdfColor.fromHex('#FFFFFF00'), fontSize: 8),
                                                tableWidth: pw.TableWidth.min,
                                                headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                                  <String>['담당', '대표',],
                                                  <String>['ㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\n', 'ㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\n',],
                                                ]),
                                          ),
                                          pw.SizedBox(width: divideHeight * 4),
                                          pw.Container(
                                              width: 256,
                                              decoration: pw.BoxDecoration(
                                                border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                                              ),
                                              child: pw.Column(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 12),
                                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                                          <String>['잔고'],
                                                        ]),
                                                    pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10),
                                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                                          for(var ac in selAccount.keys)
                                                            <String>[SystemT.getAccountName(ac), '￦ ' + StyleT.krwInt(selAccount[ac])],
                                                          <String>['합계', '￦ ' + StyleT.krwInt(selBalance)],
                                                        ]),
                                                  ]
                                              )
                                          )
                                        ]
                                    ),

                                  pw.Expanded(flex: 1, child: pw.SizedBox(height: divideHeight * 4 ),),
                                  pw.Text('${i + 1} / ${(tsList.length / 35).ceil()}', style: pw.TextStyle(font:  StyleT.font, fontSize: 8),),
                                ]
                            );
                          }));
                    }

                    if(lastPage) {
                      doc.addPage(pw.Page(
                          pageFormat: PdfPageFormat.a4,
                          margin: const pw.EdgeInsets.all(24),
                          build: (pw.Context context) {
                            return pw.Column(
                                children: [
                                  pw.Expanded(child: pw.SizedBox(height: divideHeight * 4 ),),
                                  pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Container(
                                          decoration: pw.BoxDecoration(
                                            border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                                          ),
                                          child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font,
                                              color: PdfColor.fromHex('#FFFFFF00'), fontSize: 8),
                                              tableWidth: pw.TableWidth.min,
                                              headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                                <String>['담당', '대표',],
                                                <String>['ㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\n', 'ㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\n',],
                                              ]),
                                        ),
                                        pw.SizedBox(width: divideHeight * 4),
                                        pw.Container(
                                            width: 256,
                                            decoration: pw.BoxDecoration(
                                              border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                                            ),
                                            child: pw.Column(
                                                mainAxisSize: pw.MainAxisSize.min,
                                                children: [
                                                  pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 12),
                                                      headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                                        <String>['잔고'],
                                                      ]),
                                                  pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10),
                                                      headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                                        for(var ac in selAccount.keys)
                                                          <String>[SystemT.getAccountName(ac), '￦ ' + StyleT.krwInt(selAccount[ac])],
                                                        <String>['합계', '￦ ' + StyleT.krwInt(selBalance)],
                                                      ]),
                                                ]
                                            )
                                        )
                                      ]
                                  ),
                                ]
                            );
                          }));
                    }

                    var data = await doc.save();
                    await Printing.layoutPdf(onLayout: (format) async => await data);
                  },
                  child: Container(
                    child: Row(
                      children: [
                        WidgetT.iconMini(Icons.print, size: 36),
                        WidgetT.title('인쇄', size: 12),
                        SizedBox(width: divideHeight),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: divideHeight * 2,),
                InkWell(
                  onTap: () async {
                    final doc = pw.Document();

                    bool lastPage = false;
                    for(int i = 0; i < (tsList.length / 35); i++) {
                      if(i >= ((tsList.length / 35) - 1) && !(tableStringList[i].length < 24))
                        lastPage = true;

                      doc.addPage(pw.Page(
                          pageFormat: PdfPageFormat.a4,
                          margin: const pw.EdgeInsets.all(24),
                          build: (pw.Context context) {
                            return pw.Column(
                                children: [
                                  if(i == 0) pw.Text('금전출납부 (에버스)', style: pw.TextStyle(font:  StyleT.font, fontSize: 18),),
                                  pw.SizedBox(height: divideHeight * 4 ),
                                  pw.Container(
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                                    ),
                                    child: pw.Column(
                                        mainAxisSize: pw.MainAxisSize.min,
                                        children: [
                                          pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                              headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                                <String>['일자', '은행명', '예금주', '     수입     ', '     지출     ', '     잔고     ', '          적요 및 비고         '],
                                                for(var rr in tableStringList[i])
                                                  rr,
                                              ]),
                                        ]
                                    ),
                                  ),

                                  if(i >= ((tsList.length / 35) - 1) && tableStringList[i].length < 24)
                                    pw.Expanded(flex: 9, child: pw.SizedBox(height: divideHeight * 4 ),),
                                  if(i >= ((tsList.length / 35) - 1) && tableStringList[i].length < 24)
                                    pw.Row(
                                        mainAxisAlignment: pw.MainAxisAlignment.end,
                                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                                        children: [
                                          pw.Container(
                                            decoration: pw.BoxDecoration(
                                              border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                                            ),
                                            child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font,
                                                color: PdfColor.fromHex('#FFFFFF00'), fontSize: 8),
                                                tableWidth: pw.TableWidth.min,
                                                headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                                  <String>['담당', '대표',],
                                                  <String>['ㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\n', 'ㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\n',],
                                                ]),
                                          ),
                                          pw.SizedBox(width: divideHeight * 4),
                                          pw.Container(
                                              width: 256,
                                              decoration: pw.BoxDecoration(
                                                border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                                              ),
                                              child: pw.Column(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 12),
                                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                                          <String>['잔고'],
                                                        ]),
                                                    pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10),
                                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                                          for(var ac in selAccount.keys)
                                                            <String>[SystemT.getAccountName(ac), '￦ ' + StyleT.krwInt(selAccount[ac])],
                                                          <String>['합계', '￦ ' + StyleT.krwInt(selBalance)],
                                                        ]),
                                                  ]
                                              )
                                          )
                                        ]
                                    ),

                                  pw.Expanded(flex: 1, child: pw.SizedBox(height: divideHeight * 4 ),),
                                  pw.Text('${i + 1} / ${(tsList.length / 35).ceil()}', style: pw.TextStyle(font:  StyleT.font, fontSize: 8),),
                                ]
                            );
                          }));
                    }

                    if(lastPage) {
                      doc.addPage(pw.Page(
                          pageFormat: PdfPageFormat.a4,
                          margin: const pw.EdgeInsets.all(24),
                          build: (pw.Context context) {
                            return pw.Column(
                                children: [
                                  pw.Expanded(child: pw.SizedBox(height: divideHeight * 4 ),),
                                  pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Container(
                                          decoration: pw.BoxDecoration(
                                            border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                                          ),
                                          child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font,
                                              color: PdfColor.fromHex('#FFFFFF00'), fontSize: 8),
                                              tableWidth: pw.TableWidth.min,
                                              headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                                <String>['담당', '대표',],
                                                <String>['ㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\n', 'ㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\n',],
                                              ]),
                                        ),
                                        pw.SizedBox(width: divideHeight * 4),
                                        pw.Container(
                                            width: 256,
                                            decoration: pw.BoxDecoration(
                                              border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                                            ),
                                            child: pw.Column(
                                                mainAxisSize: pw.MainAxisSize.min,
                                                children: [
                                                  pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 12),
                                                      headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                                        <String>['잔고'],
                                                      ]),
                                                  pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10),
                                                      headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                                        for(var ac in selAccount.keys)
                                                          <String>[SystemT.getAccountName(ac), '￦ ' + StyleT.krwInt(selAccount[ac])],
                                                        <String>['합계', '￦ ' + StyleT.krwInt(selBalance)],
                                                      ]),
                                                ]
                                            )
                                        )
                                      ]
                                  ),
                                ]
                            );
                          }));
                    }

                    var data = await doc.save();
                    js.context.callMethod("saveAs", <Object>[
                      html.Blob(<Object>[data!]), '금전출납부.pdf',]);
                  },
                  child: Container(
                    child: Row(
                      children: [
                        WidgetT.iconMini(Icons.downloading, size: 36),
                        WidgetT.title('파일로 다운로드', size: 12),
                        SizedBox(width: divideHeight),
                      ],
                    ),
                  ),
                ),
              ],
            ));


        childrenW.add(SizedBox(height: divideHeight * 8,));
        childrenW.add(InkWell(
          onTap: () {
            WidgetT.showSnackBar(context, text: '개발중인 기능');
          },
          child: Container(
            padding: EdgeInsets.all(18),
            child: WidgetT.title('차트로 보기', size: 12),
          ),
        ));
      }
    }
    else if(menu == '미수현황') {
      List<Customer> cs = await DatabaseM.getCSWithRe();

      List<Widget> widgets = [];
      var allP = 0, allPdP = 0;
      for(int i = 0; i < cs.length; i++) {
        var c = cs[i];
        var cts = (await c.getContractList()) ?? [];
        var allPay = 0, allPayedAmount = 0;
        for(var ct in cts) {
          List<TS> ts = await DatabaseM.getTransactionCt(ct.id);
          List<Revenue> pu = await DatabaseM.getRevenueOnlyContract(ct.id);
          pu.forEach((e) { allPay += e.totalPrice; });
          ts.forEach((value) { if(value.type == 'RE') allPayedAmount += value.amount; });

          if((allPay - allPayedAmount) == 0) continue;
          allP += allPay; allPdP += allPayedAmount;
        }

        if((allPay - allPayedAmount) != 0) {
          var w = InkWell(
              onTap: () {

              },
              child: Container( height: 36 + divideHeight,
                child: Row(
                    children: [
                      WidgetT.excelGrid(label: '${i + 1}', width: 32),
                      WidgetT.excelGrid(text: c.businessName, width: 250),
                      WidgetT.excelGrid(text: StyleT.krwInt(allPay), width: 250),
                      WidgetT.excelGrid(width: 250,text: StyleT.krwInt(allPayedAmount), ),
                      WidgetT.excelGrid( width: 250, text: StyleT.krwInt(allPay - allPayedAmount),),
                    ]
                ),
              ));
          widgets.add(w);
          widgets.add(WidgetT.dividHorizontal(size: 0.35));
        }
      }
      var tsW =  Column(children: widgets,);
      childrenW.add(tsW);
      childrenW.add(SizedBox(height: divideHeight * 3,));

      bottomWidget =  InkWell(
          onTap: () {

          },
          child: Container( height: 48,
            child: Row(
                children: [
                  WidgetT.excelGrid(text: '합계', width: 148.7, label: ''),
                  WidgetT.excelGrid(text: StyleT.krwInt(allP), width: 250, label: '총 매출금액'),
                  WidgetT.excelGrid( width: 250, label: '총 미수금액', text: StyleT.krwInt(allPdP),),
                  WidgetT.excelGrid(text: StyleT.krwInt(allP - allPdP), width: 250, label: '총 미수금'),
                ]
            ),
          )
      );
    }
    else if(menu == '미지급현황') {
      Map<Customer, Records<List<TS>, List<Purchase>>> purCsList = await Search.searchPurCs();

      /// 미지급 테이블 UI 목록 위젯입니다.
      List<Widget> widgets = [];
      int index = 1;

      var allP = 0, allPdP = 0;

      purCsList.forEach((Customer cs, Records<List<TS>, List<Purchase>> value) {
       var allPayedAmount = 0;
       var allPurchaseAmount = 0;

       value.Item1.forEach((TS e) { allPayedAmount += e.amount; });
       value.Item2.forEach((Purchase e) { e.init(); allPurchaseAmount += e.totalPrice; });

       allP += allPayedAmount;
       allPdP += allPurchaseAmount;

       var w = CompTS.tableUIPaymentPU(context, Records(allPurchaseAmount, allPayedAmount), cs: cs, index: index++);
       widgets.add(w);
       widgets.add(WidgetT.dividHorizontal(size: 0.35));
     });

      var tsW =  Column(children: widgets,);
      childrenW.add(tsW);
      childrenW.add(SizedBox(height: divideHeight * 3,));

      bottomWidget = InkWell(
          onTap: () {

          },
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
    }

    var main = PageWidget.MainPage(
      topWidget: topWidget,
      infoWidget: infoWidget,
      titleWidget: Column(
        children: [
          titleMenu,
          if(menu == '금전출납현황' && currentMenu == '목록') TS.OnTableHeaderMain(),
          if(menu == '금전출납현황' && currentMenu == '금전출납부')
            Container( padding: EdgeInsets.fromLTRB(divideHeight, 0, divideHeight, divideHeight),
              child: WidgetUI.titleRowNone([ '순번', '계좌', '잔고', '전일잔고', '변동금', '수입', '지출', ],
                  [ 32, 200, 100, 100, 100, 100, 100, 100  ]),
            ),
          if(menu == '미지급현황') CompTS.tableHeaderPaymentPU(),
        ],
      ),
      children: childrenW,
      bottomWidget: bottomWidget,
    );
    return main;
  }

  Widget build(context) {
    return Container();
  }
}
