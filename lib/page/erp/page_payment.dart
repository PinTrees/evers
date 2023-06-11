import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/database/balance.dart';
import 'package:evers/class/system/records.dart';
import 'package:evers/class/widget/page.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/info/menu.dart';
import 'package:evers/page/erp/view/view_payment_daily.dart';
import 'package:evers/page/erp/view/view_payment_list.dart';
import 'package:evers/page/erp/view/view_payment_puDelay.dart';
import 'package:evers/page/erp/view/view_payment_reDelay.dart';
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
      this.menu = menu;
      refresh = true;
    }

    if(refresh) {
      clear();
      searchInput.text = '';
      sort = false;
      currentQuery = '';

      await DatabaseM.initTsMetaData();

      sortLastAt = DateTime.now();
      sortStartAt = DateTime(sortLastAt.year, sortLastAt.month, sortLastAt.day - 180);
    }

    Widget titleMenu = const SizedBox();
    Widget bottomWidget = const SizedBox();

    List<Widget> childrenW = [];
    childrenW.clear();

    if(menu == "일계표") {
      childrenW.add(ViewPaymentDaily());
    }
    else if(menu == '금전출납현황') {
      return ViewPaymentList(infoWidget: infoWidget, topWidget: topWidget,);
    }

    /// 미수 현황
    else if(menu == ERPSubMenuInfo.paymentRevenue.displayName) {
      titleMenu = CompTS.tableHeaderPaymentRE();
      childrenW.add(ViewPaymentReDelay());
    }

    /// 미지급 현황
    else if(menu == ERPSubMenuInfo.paymentPurchase.displayName) {
      titleMenu = CompTS.tableHeaderPaymentPU();
      childrenW.add(ViewPaymentPuDelay());
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
