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

class View_PLAN extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var st_sc_vt = ScrollController();
  var st_sc_hr = ScrollController();
  var divideHeight = 6.0;

  var sizePrice = 80.0;
  var sizeDate = 80.0;

  List<Purchase> pur_list = [];
  List<Revenue> rev_list = [];

  List<Plan> plan_list = [];
  
  List<Purchase> pur_sort_list = [];
  List<Revenue> rev__sort_list = [];

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
      pur_list.clear();
      rev_list.clear();
      ts_list.clear();

      FunT.setStateMain();
      return;
    }

    sort = true;
    FunT.setStateMain();
  }
  
  void query_init() {
    sort = false; query = true;
    pur_list.clear();
    rev_list.clear();
    ts_list.clear();
  }
  
  void clear() async {
    rev_list.clear();
    pur_list.clear();
    await FunT.setStateMain();
  }

  var menuStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.15), );
  var menuSelectStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.35), );
  var menuPadding = EdgeInsets.fromLTRB(6 * 4, 6 * 1, 6 * 4, 6 * 1);
  var disableTextColor = StyleT.titleColor.withOpacity(0.35);

  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false  }) async {
    if(this.menu != menu) {
      sort = false; searchInput.text = '';
    }
    if(refresh) {
      plan_list.clear();
      query = false; sort = false;
      pur_query = '';
    }

    this.menu = menu;

    Widget titleMenu = SizedBox();

    // 정적 문자열 추후 변경 필요
    List<Widget> childrenW = [];
    if(menu == '일정관리') {
      childrenW.clear();
      titleMenu = Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () async {
                  currentView = '';
                  clear();
                },
                child: Container(child: (currentView == '목록') ? WidgetT.title('목록', size: 18) : WidgetT.text('목록', size: 18, bold: true, color: disableTextColor)),
              ),
              SizedBox(width: divideHeight * 2,),
              WidgetT.text('/', size: 12),
              SizedBox(width: divideHeight * 2,),
              InkWell(
                onTap: () async {
                  currentView = '';
                  clear();
                },
                child: Container(child: (currentView == '주간') ? WidgetT.title('주간', size: 18) : WidgetT.text('주간 목록', size: 18,  bold: true, color: disableTextColor)),
              ),
              SizedBox(width: divideHeight * 2,),
              WidgetT.text('/', size: 12),
              SizedBox(width: divideHeight * 2,),
              InkWell(
                onTap: () async {
                  currentView = '';
                  clear();
                },
                child: Container(child: (currentView == '월간') ? WidgetT.title('월간', size: 18) : WidgetT.text('월간 목록', size: 18,  bold: true, color: disableTextColor)),
              ),
            ],
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
                    //searchMenuW,
                    if(menu == '매입매출관리')
                      Container( padding: EdgeInsets.fromLTRB(divideHeight * 1, 0, divideHeight * 1, divideHeight),
                        child: WidgetUI.titleRowNone([ '순번', '거래번호', '거래일', '구분', '거래처 및 계약', '품목', '단위', '수량', '단가', '공급가액', 'VAT', '합계', '' ],
                            [ 32, sizeDate, sizeDate, 50, 999, 999, 50, 50,
                              sizePrice, sizePrice, sizePrice, sizePrice, 64 + 32, 32 ]),
                      ),
                    if(menu == '수납관리')
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
