import 'dart:convert';
import 'dart:ui';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/dialog_revenue.dart';
import 'package:evers/ui/dialog_transration.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../class/Customer.dart';
import '../class/contract.dart';
import '../class/purchase.dart';
import '../class/revenue.dart';
import '../class/schedule.dart';
import '../class/system.dart';
import '../class/transaction.dart';
import '../helper/dialog.dart';
import '../helper/firebaseCore.dart';
import '../helper/interfaceUI.dart';
import '../helper/pdfx.dart';
import '../system/system_date.dart';
import 'cs.dart';
import 'dialog_contract.dart';
import 'dl.dart';
import 'package:http/http.dart' as http;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'ux.dart';
import 'dart:js' as js;
import 'dart:html' as html;


class View_MO extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var st_sc_vt = ScrollController();
  var st_sc_hr = ScrollController();
  var divideHeight = 6.0;

  List<TS> ts_list = [];
  List<TS> ts_sort_list = [];

  bool sort = false;
  bool query = false;

  var currentView = '매입';

  var pur_sort_menu = [ '최신순',  ];
  var pur_sort_menu_date = [ '최근 1주일', '최근 1개월', '최근 3개월' ];
  var crRpmenuRp = '', pur_query = '';
  DateTime rpStartAt = DateTime.now();
  DateTime rpLastAt = DateTime.now();

  dynamic init() async {
  }
  String menu = '';

  dynamic search(String search) async {
    if(search == '') {
      sort = false;
      pur_query = '';
      query = false;
      clear();

      FunT.setStateMain();
      return;
    }

    sort = true;
    if(menu == '금전출납현황') {
      ts_sort_list = await SystemT.searchTSMeta(searchInput.text,
        startAt: (sort && query) ? rpStartAt.microsecondsSinceEpoch.toString().substring(0, 8) : null,
        lastAt: (sort && query) ? rpLastAt.microsecondsSinceEpoch.toString().substring(0, 8) : null,
      );
    }

    FunT.setStateMain();
  }
  void query_init() {
    sort = false; query = true;
    ts_list.clear();
  }
  void clear() async {
    ts_list.clear();
    await FunT.setStateMain();
  }

  var menuStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.15), );
  var menuSelectStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.35), );
  var menuPadding = EdgeInsets.fromLTRB(6 * 4, 6 * 1, 6 * 4, 6 * 1);
  var disableTextColor = StyleT.titleColor.withOpacity(0.35);

  Map<dynamic, int> account = {};
  var currentMenu = '';
  var select_year = 2022;

  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false,
  Function? setState, }) async {
    var balance = 0;

    if(this.menu != menu) {
      sort = false; searchInput.text = '';
    }
    if(refresh) {
      clear();
      query = false; sort = false;
      pur_query = '';
    }

    this.menu = menu;

    Widget titleMenu = SizedBox();
    Widget bottomWidget = SizedBox();

    List<Widget> childrenW = [];
    if(menu == '금전출납현황') {
      currentMenu = (currentMenu == '') ? '목록' : currentMenu;
      childrenW.clear();
      var titleW = Row(
        children: [
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
        ],
      );

      if(currentMenu == '목록') {
        titleMenu = Column(
          children: [
            titleW,
            Container(
              padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: Row(
                children: [
                  for(var m in pur_sort_menu_date)
                    InkWell(
                      onTap: () async {
                        if(pur_query == m) return;
                        pur_query = m;

                        query_init();

                        rpLastAt = DateTime.now();
                        if(pur_query == pur_sort_menu_date[0]) {
                          rpStartAt = DateTime.now().add(const Duration(days: -7));
                        }
                        else if(pur_query == pur_sort_menu_date[1]) {
                          rpStartAt = DateTime.now().add(const Duration(days: -30));
                        }
                        else if(pur_query == pur_sort_menu_date[2]) {
                          rpStartAt = DateTime.now().add(const Duration(days: -90));
                        }

                        FunT.setStateMain();
                      },
                      child: Container(
                        height: 32,
                        decoration: StyleT.inkStyleNone(color: Colors.transparent),
                        padding:menuPadding,
                        child: WidgetT.text(m, size: 14, bold: true,
                            color: (m == pur_query) ? StyleT.titleColor : StyleT.textColor.withOpacity(0.5)),
                      ),
                    ),

                  SizedBox(width: divideHeight * 4,),

                  InkWell(
                    onTap: () async {
                      var selectedDate = await showDatePicker(
                        context: context,
                        initialDate: rpStartAt, // 초깃값
                        firstDate: DateTime(2018), // 시작일
                        lastDate: DateTime(2030), // 마지막일
                      );
                      if(selectedDate != null) {
                        if (selectedDate.microsecondsSinceEpoch < rpLastAt.microsecondsSinceEpoch) rpStartAt = selectedDate;
                        pur_query = '';
                      }
                      FunT.setStateMain();
                    },
                    child: Container(
                      height: 32,
                      padding: EdgeInsets.all(divideHeight),
                      alignment: Alignment.center,
                      decoration: StyleT.inkStyleNone(color: Colors.transparent),
                      child:WidgetT.text(StyleT.dateFormat(rpStartAt), size: 14, bold: true,
                          color: (pur_query == '기간검색') ? StyleT.titleColor : StyleT.textColor.withOpacity(0.5)),
                    ),
                  ),
                  WidgetT.text('~',  size: 14, color: StyleT.textColor.withOpacity(0.5)),
                  InkWell(
                    onTap: () async {
                      var selectedDate = await showDatePicker(
                        context: context,
                        initialDate: rpLastAt, // 초깃값
                        firstDate: DateTime(2018), // 시작일
                        lastDate: DateTime(2030), // 마지막일
                      );
                      if(selectedDate != null) {
                        rpLastAt = selectedDate;
                        pur_query = '';
                      }
                      FunT.setStateMain();
                    },
                    child: Container(
                      height: 32,
                      padding: EdgeInsets.all(divideHeight),
                      alignment: Alignment.center,
                      decoration: StyleT.inkStyleNone(color: Colors.transparent),
                      child:WidgetT.text(StyleT.dateFormat(rpLastAt), size: 14, bold: true,
                          color: (pur_query == '기간검색') ? StyleT.titleColor : StyleT.textColor.withOpacity(0.5)),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      pur_query = '기간검색';
                      query_init();
                      FunT.setStateMain();
                    },
                    child: Container(
                      height: 32,
                      decoration: StyleT.inkStyleNone(color: Colors.transparent),
                      padding: EdgeInsets.all(divideHeight),
                      child: WidgetT.text('기간검색', size: 14, bold: true,
                          color: (pur_query == '기간검색') ? StyleT.titleColor : StyleT.textColor.withOpacity(0.5)),
                    ),
                  ),
                  SizedBox(width: divideHeight * 4,),
                  InkWell(
                    onTap: () async {
                      pur_query = '';
                      query = false;
                      clear();
                      FunT.setStateMain();
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

        if(ts_list.length < 1) {
          ts_list = await FireStoreT.getTransaction(
            startDate: query ? rpStartAt.microsecondsSinceEpoch : null,
            lastDate: query ? rpLastAt.microsecondsSinceEpoch : null,
          );
        }

        var datas = sort ? ts_sort_list : ts_list;
        for(int i = 0; i < datas.length; i++) {
          var tmpTs = datas[i];
          Account? account = SystemT.getAccount(tmpTs.account);
          Widget w = SizedBox();
          var cs = await SystemT.getCS(tmpTs.csUid);


          w = InkWell(
            onTap: () async {
              await DialogTS.showInfoTs(context, org: tmpTs);
            },
            child: Container(
              height: 36 + divideHeight,
              decoration: StyleT.inkStyleNone(color: Colors.transparent),
              child: Row(
                  children: [
                    WidgetT.excelGrid(label: '${i}', width: 32),
                    WidgetT.excelGrid(textSize: 10, textLite: true, text: tmpTs.id, width: 80),
                    WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.dateFormatAtEpoch(tmpTs.transactionAt.toString()), width: 80, ),
                    WidgetT.excelGrid(textSize: 10, textLite: true, text: (cs.businessName == '') ? 'ㅡ' : cs.businessName, width: 200,),
                    Expanded(child: WidgetT.excelGrid(textSize: 10, textLite: false, text: tmpTs.summary, width: 999,)),
                    WidgetT.excelGrid(textSize: 10, text: StyleT.krwInt(tmpTs.amount), width: 100,
                        textColor: (tmpTs.type != 'PU') ? Colors.blue.withOpacity(0.7) : Colors.red.withOpacity(0.7)),
                    WidgetT.excelGrid(textSize: 10, textLite: true, text: SystemT.getAccountName(tmpTs.account), width: 100, ),
                    Expanded(child: WidgetT.excelGrid(textSize: 10, textLite: true, text: tmpTs.memo, width: 999,)),
                    InkWell(
                      onTap: () {

                      },
                      child: WidgetT.iconMini(Icons.open_in_new, size: 36),
                    ),
                    WidgetEX.excelButtonIcon(icon: Icons.delete, onTap: () async {
                      if(!await DialogT.showAlertDl(context, text: '데이터를 삭제하시겠습니까?')){
                        WidgetT.showSnackBar(context, text: '삭제 취소됨');
                        return;
                      }
                      WidgetT.loadingBottomSheet(context, text: '삭제중');
                      var ret = await tmpTs.delete();
                      Navigator.pop(context);

                      if(ret) WidgetT.showSnackBar(context, text: '삭제됨');
                      else WidgetT.showSnackBar(context, text: '삭제에 실패했습니다. 나중에 다시 시도해 주세요.');
                    }),
                  ]
              ),
            ),
          );
          childrenW.add(w);
          childrenW.add(WidgetT.dividHorizontal(size: 0.35));
        }

        if(!sort) {
          childrenW.add(InkWell(
            onTap: () async {
              WidgetT.loadingBottomSheet(context, text: '로딩중');

              var list = await FireStoreT.getTransaction(
                startAt: ts_list.last.id,
                startDate: query ? rpStartAt.microsecondsSinceEpoch: null,
                lastDate: query ? rpLastAt.microsecondsSinceEpoch : null,
              );
              ts_list.addAll(list);

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
        }

        for(var a in SystemT.accounts.values) {
          var amount = await FireStoreT.getAmountAccount(a.id);
          Account acc = SystemT.getAccount(a.id) ?? Account.fromDatabase({});
          account[a.id] = amount + acc.balanceStartAt;
        }
        account.forEach((key, value) { balance += value; });

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
                        WidgetT.excelGrid(text: '잔고', width: 250, label: ''),
                        Expanded(child: WidgetT.excelGrid(text: StyleT.krwInt(balance), width: 999, label: '총 금액 ')),
                        InkWell(
                          onTap: () {
                          },
                          child: WidgetT.iconMini(Icons.open_in_new, size: 36),
                        ),
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

          var amount = await FireStoreT.getAmountAccountWithDate(a.id, startAt, lastAt);
          Account acc = SystemT.getAccount(a.id) ?? Account.fromDatabase({});
          oldAccount[a.id] = amount + acc.balanceStartAt;
        }
        oldAccount.forEach((key, value) { oldBalance += value; });

        balance = 0;
        for(var a in SystemT.accounts.values) {
          var amount = await FireStoreT.getAmountAccount(a.id,);
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

        List<TS> tsList = await FireStoreT.getTransactionWithDate(SystemDate.selectDate['startDate']!.microsecondsSinceEpoch,
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

          var amount = await FireStoreT.getAmountAccountWithDate(a.id, startAt, lastAt);
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


                    //final printDoc = pw.Document();
                    /*await for (var page in Printing.raster(await doc.save(), pages: [0, 1], dpi: 72)) {
                      final image = await page.toPng();
                      //final imagePdf = pw.MemoryImage(aa!.buffer.asUint8List(aa!.offsetInBytes, aa!.lengthInBytes));
                      final imagePdf = pw.MemoryImage(image);
                      printDoc.addPage(pw.Page(
                          pageFormat: PdfPageFormat.a4,
                          margin: const pw.EdgeInsets.all(0),
                          build: (pw.Context context) {
                            return pw.Center(
                              child: pw.Image(imagePdf),
                            );
                          }));
                    }*/

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
                    //await StorageHub.updateFile('tmp', 'printing file upload', data, 'printing.pdf');
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
      List<Customer> cs = await FireStoreT.getCSWithRe();

      List<Widget> widgets = [];
      var allP = 0, allPdP = 0;
      for(int i = 0; i < cs.length; i++) {
        var c = cs[i];
        var cts = (await c.getContractList()) ?? [];
        var allPay = 0, allPayedAmount = 0;
        for(var ct in cts) {
          List<TS> ts = await FireStoreT.getTransactionCt(ct.id);
          List<Revenue> pu = await FireStoreT.getRevenueOnlyContract(ct.id);
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

      bottomWidget = Column(
        children: [
          WidgetT.dividHorizontal(size: 1),
          InkWell(
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
          ),
        ],
      );
    }
    else if(menu == '미지급현황') {
      List<Customer> cs = await FireStoreT.getCSWithTs();

      List<Widget> widgets = [];
      var allP = 0, allPdP = 0;
      for(int i = 0; i < cs.length; i++) {
        var c = cs[i];
        Map<dynamic, TS> ts = await FireStoreT.getTS_CS_PU_date(c.id);
        List<Purchase> pu = await FireStoreT.getPur_withCS(c.id);
        var allPay = 0, allPayedAmount = 0;
        pu.forEach((e) { allPay += e.totalPrice; });
        ts.forEach((key, value) { if(value.type == 'PU') allPayedAmount += value.amount; });
        if((allPay - allPayedAmount) == 0) continue;

        allP += allPay; allPdP += allPayedAmount;

        var w = InkWell(
            onTap: () {},
            child: Container( height: 42,
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
      var tsW =  Column(children: widgets,);
      childrenW.add(tsW);
      childrenW.add(SizedBox(height: divideHeight * 3,));

      bottomWidget = Column(
        children: [
          WidgetT.dividHorizontal(size: 1),
          InkWell(
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
          ),
        ],
      );
    }

    var main = Column(
      children: [
        if(topWidget != null) topWidget,
        Expanded(
          child: Row(
            children: [
              if(infoWidget != null) infoWidget,
              Expanded(
                child: Column(
                  children: [
                    WidgetT.searchBar(search: (text) async {
                      WidgetT.loadingBottomSheet(context, text:'검색중');
                      await search(text);
                      Navigator.pop(context);
                    }, controller: searchInput ),
                    titleMenu,
                    if(menu == '금전출납현황' && currentMenu == '목록')
                      Container( padding: EdgeInsets.fromLTRB(divideHeight * 1, 0, divideHeight * 1, divideHeight),
                        child: WidgetUI.titleRowNone([ '순번', '거래번호', '거래일자', '거래처', '적요', '수입/지출', '계좌', '메모', '', ],
                            [ 32, 80, 80, 200, 999, 100, 100, 999, 64, 0,  ]),
                      ),
                    if(menu == '금전출납현황' && currentMenu == '금전출납부')
                      Container( padding: EdgeInsets.fromLTRB(divideHeight, 0, divideHeight, divideHeight),
                        child: WidgetUI.titleRowNone([ '순번', '계좌', '잔고', '전일잔고', '변동금', '수입', '지출', ],
                            [ 32, 200, 100, 100, 100, 100, 100, 100  ]),
                      ),
                    WidgetT.dividHorizontal(size: 0.7),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(12),
                        children: [
                          Column(children: childrenW,),
                          SizedBox(height: 18,),
                        ],
                      ),
                    ),
                    WidgetT.dividHorizontal(size: 0.7),
                    bottomWidget,
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return main;
  }

  Widget build(context) {
    return Container();
  }
}
