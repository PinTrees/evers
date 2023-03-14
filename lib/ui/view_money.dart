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
import 'cs.dart';
import 'dialog_contract.dart';
import 'dl.dart';
import 'package:http/http.dart' as http;

import 'ux.dart';

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
  var balance = 0;

  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false  }) async {
    balance = 0;

    if(this.menu != menu) {
      sort = false; searchInput.text = '';
    }
    if(refresh) {
      clear();
      query = false; sort = false;
      pur_query = '';

      for(var a in SystemT.accounts.values) {
        var amount = await FireStoreT.getAmountAccount(a.id);
        Account acc = SystemT.getAccount(a.id) ?? Account.fromDatabase({});
        account[a.id] = amount + acc.balanceStartAt;
      }
      account.forEach((key, value) { balance += value; });
    }

    this.menu = menu;

    Widget titleMenu = SizedBox();
    Widget bottomWidget = SizedBox();

    List<Widget> childrenW = [];
    if(menu == '금전출납현황') {
      childrenW.clear();
      titleMenu = Column(
        children: [
          Row(
            children: [
              WidgetT.title('목록', size: 18),
              SizedBox(width: divideHeight * 2,),
              WidgetT.text('( 거래 기록 )', size: 12,)
            ],
          ),
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
                  WidgetT.excelGrid(textLite: true, text: StyleT.dateFormatAtEpoch(tmpTs.transactionAt.toString()), width: 100, ),
                  WidgetT.excelGrid(textLite: true, text: '${SystemT.getCSName(tmpTs.csUid)}', width: 200,),
                  Expanded(child: WidgetT.excelGrid(textLite: false, text: tmpTs.summary, width: 999,)),
                  WidgetT.excelGrid(text: (tmpTs.type != 'PU') ? StyleT.krwInt(tmpTs.amount) : '', width: 100,
                      textColor: (tmpTs.type != 'PU') ? Colors.blue.withOpacity(1) : null),
                  WidgetT.excelGrid(text: (tmpTs.type != 'RE') ? StyleT.krwInt(tmpTs.amount) : '', width: 100,
                      textColor: (tmpTs.type != 'RE') ? Colors.red.withOpacity(1) : null),
                  WidgetT.excelGrid(textLite: true, text: SystemT.getAccountName(tmpTs.account), width: 200, ),
                  Expanded(child: WidgetT.excelGrid(textLite: true, text: tmpTs.memo, width: 999,)),
                  InkWell(
                      onTap: () {

                      },
                      child: WidgetT.iconMini(Icons.open_in_new, size: 36),
                  ),
                  WidgetEX.excelButtonIcon(icon: Icons.delete, onTap: () async {
                    var aa = await DialogT.showAlertDl(context, text: '데이터를 삭제하시겠습니까?');
                    if(aa) {
                      await FireStoreT.deleteTs(tmpTs);
                      WidgetT.showSnackBar(context, text: '거래 데이터를 삭제했습니다.');
                    }
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
                    if(menu == '금전출납현황')
                      Container( padding: EdgeInsets.fromLTRB(divideHeight * 4, 0, divideHeight * 4, divideHeight),
                        child: WidgetUI.titleRowNone([ '순번', '거래일자', '거래처', '적요', '수입', '지출', '계좌', '메모', '', ],
                            [ 32, 100, 200, 999, 100, 100, 200, 999, 64, 0,  ]),
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
