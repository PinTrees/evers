import 'dart:convert';
import 'dart:ui';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_re.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/user.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/page.dart';
import 'package:evers/class/widget/widget.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/main.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_re_create.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/ui/dialog_revenue.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../class/Customer.dart';
import '../../../class/contract.dart';
import '../../../class/purchase.dart';
import '../../../class/revenue.dart';
import '../../../class/schedule.dart';
import '../../../class/system.dart';
import '../../../class/system/search.dart';
import '../../../class/system/state.dart';
import '../../../class/transaction.dart';
import '../../../class/widget/list.dart';
import '../../../class/widget/text.dart';
import '../../../class/widget/textInput.dart';
import '../../../helper/dialog.dart';
import '../../../helper/firebaseCore.dart';
import '../../../helper/interfaceUI.dart';
import '../../../helper/pdfx.dart';
import 'package:http/http.dart' as http;

import '../../../ui/ux.dart';

class PageRePu extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var divideHeight = 6.0;

  List<Purchase> puList = [];
  List<Revenue> revList = [];

  List<Purchase> puSortList = [];
  List<Revenue> reSortList = [];

  List<TS> tsList = [];
  List<TS> tsSortList = [];

  /// 검색 상태 변수
  bool sort = false;

  var currentView = '매입';

  var puSortMenu = [ '최신순',  ];
  var purSortMenuDate = [ '최근 1주일', '최근 1개월', '최근 3개월' ];
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
      puList.clear();
      revList.clear();
      tsList.clear();

      FunT.setStateMain();
      return;
    }

    sort = true;
    if(menu == '매입매출관리') {
      if (currentView == '매입') {
        crRpmenuRp = ''; pur_query = '';
        await Search.searchPuMeta(search);
        puSortList = await Search.searchPurchase();
      }
      else if (currentView == '매출') {
        crRpmenuRp = ''; pur_query = '';
        reSortList = await SystemT.searchReMeta(search,);
      }
    }
    else if(menu == '수납관리') {
      await SystemT.searchTSMeta(searchInput.text,
        startAt: rpStartAt.microsecondsSinceEpoch.toString().substring(0, 8),
        lastAt: rpLastAt.microsecondsSinceEpoch.toString().substring(0, 8),
      );
      tsSortList = await Search.searchTS();
    }

    FunT.setStateMain();
  }
  void query_init() {
    sort = false;
    puList.clear();
    revList.clear();
    tsList.clear();
  }
  void clear() async {
    tsList.clear();
    revList.clear();
    puList.clear();
    await FunT.setStateMain();
  }

  var menuPadding = EdgeInsets.fromLTRB(6 * 4, 6 * 1, 6 * 4, 6 * 1);
  var disableTextColor = StyleT.titleColor.withOpacity(0.35);

  /// 이 함수는 해당 페이지의 메인뷰를 구성하고 반환합니다.
  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false  }) async {
    if(this.menu != menu) {
      sort = false; searchInput.text = '';
    }

    if(refresh) {
      puList.clear();
      revList.clear();
      tsList.clear();
      sort = false;
      pur_query = '';

      rpLastAt = DateTime.now();
      rpStartAt = DateTime.now().add(const Duration(days: -180));
    }

    this.menu = menu;

    Widget titleMenu = SizedBox();

    List<Widget> widgets = [];
    if(menu == '매입매출관리') {
      widgets.clear();

      titleMenu = Column(
        children: [
          Row(
            children: [
              SizedBox(height: 64,),

              InkWell(
                onTap: () async {
                  currentView = '매입';
                  clear();
                },
                child: Container(child: (currentView == '매입') ? WidgetT.title('매입 목록', size: 18) : WidgetT.text('매입 목록', size: 18, bold: true, color: disableTextColor)),
              ),
              SizedBox(width: divideHeight * 2,),
              WidgetT.text('/', size: 12),
              SizedBox(width: divideHeight * 2,),
              InkWell(
                onTap: () async {
                  currentView = '매출';
                  clear();
                },
                child: Container(child: (currentView == '매출') ? WidgetT.title('매출 목록', size: 18) : WidgetT.text('매출 목록', size: 18,  bold: true, color: disableTextColor)),
              ),
              SizedBox(width: divideHeight * 2,),

              ListBoxT.Rows(
                spacing: 6,
                children: [
                  ButtonT.TabMenu(
                    "일반 매입 추가", Icons.input,
                    onTap: () async {
                      UIState.OpenNewWindow(context, WindowPUCreate(refresh: FunT.setStateMain,));
                    },
                  ),
                  ButtonT.TabMenu(
                    "품목 매입 추가", Icons.input,
                    onTap: () async {
                      UIState.OpenNewWindow(context, WindowPUCreate(refresh: FunT.setStateMain, isItemPurchase: true,));
                    },
                  ),
                  ButtonT.TabMenu(
                    '일반 매출 추가', Icons.output,
                    onTap: () async {
                      UIState.OpenNewWindow(context, WindowReCreate(refresh: FunT.setStateMain,));
                    },
                  ),
                ],
              ),
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
                for(var m in purSortMenuDate)
                  InkWell(
                    onTap: () async {
                      if(pur_query == m) return;
                      pur_query = m;

                      query_init();

                      rpLastAt = DateTime.now();
                      if(pur_query == purSortMenuDate[0]) {
                        rpStartAt = DateTime.now().add(const Duration(days: -7));
                      }
                      else if(pur_query == purSortMenuDate[1]) {
                        rpStartAt = DateTime.now().add(const Duration(days: -30));
                      }
                      else if(pur_query == purSortMenuDate[2]) {
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
                    puList.clear();
                    revList.clear();
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


      /// 현재 상세메뉴 분기 확인
      if(currentView == '매입') {
        /// 유저 매입정보 읽기권한 확인
        if(UserSystem.userData.isPermissioned(PermissionType.isPurchaseRead.code)) {
          widgets.add(await buildPurchaseView(context));
        }
        else {
          widgets.clear();
          widgets.add(Widgets.AccessRestriction());
        }
      }
      else if(currentView == '매출') {
        /// 유저 매출정보 읽기권한 확인
        if(UserSystem.userData.isPermissioned(PermissionType.isRevenueRead.code)) {
          widgets.add(await buildRevenueView(context));
        }
        else {
          widgets.clear();
          widgets.add(Widgets.AccessRestriction());
        }
      }
    }
    else if(menu == '수납관리') {
      widgets.clear();
      titleMenu = Column(
        children: [
          Row(
            children: [
              SizedBox(height: 64,),
              WidgetT.title('수납 목록', size: 18),
              SizedBox(width: divideHeight * 2,),
              WidgetT.text('( 수납 목록, 거래 기록 )', size: 12,),
              SizedBox(width: divideHeight * 2,),
              ButtonT.TabMenu("수납 추가", Icons.add_box,
                onTap: () { UIState.OpenNewWindow(context, WindowTsCreate(cs: null, refresh: () { FunT.setStateMain(); })); }
              ),
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
                for(var m in purSortMenuDate)
                  InkWell(
                    onTap: () async {
                      if(pur_query == m) return;
                      pur_query = m;

                      query_init();

                      rpLastAt = DateTime.now();
                      if(pur_query == purSortMenuDate[0]) {
                        rpStartAt = DateTime.now().add(const Duration(days: -7));
                      }
                      else if(pur_query == purSortMenuDate[1]) {
                        rpStartAt = DateTime.now().add(const Duration(days: -30));
                      }
                      else if(pur_query == purSortMenuDate[2]) {
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

                      clear();
                      mainView(context, menu);
                    }
                  },
                  child: Container(
                    height: 32,
                    padding: EdgeInsets.all(divideHeight),
                    alignment: Alignment.center,
                    decoration: StyleT.inkStyleNone(color: Colors.transparent),
                    child:WidgetT.text(StyleT.dateFormat(rpStartAt), size: 14, bold: true, color: StyleT.titleColor ),
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

                      clear();
                      mainView(context, menu);
                    }
                  },
                  child: Container(
                    height: 32,
                    padding: EdgeInsets.all(divideHeight),
                    alignment: Alignment.center,
                    decoration: StyleT.inkStyleNone(color: Colors.transparent),
                    child:WidgetT.text(StyleT.dateFormat(rpLastAt), size: 14, bold: true,  color: StyleT.titleColor ),
                  ),
                ),
                SizedBox(width: divideHeight * 4,),
                InkWell(
                  onTap: () async {
                    pur_query = '';
                    puList.clear();
                    revList.clear();
                    tsList.clear();
                    FunT.setStateMain();
                  },
                  child: Container( height: 32,
                    padding: menuPadding,
                    child: WidgetT.text('초기화', size: 14, bold: true,
                        color: StyleT.textColor.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

      /// 유저 수납정보 읽기권한 확인
      if(UserSystem.userData.isPermissioned(PermissionType.isPaymentRead.code)) {
        widgets.add(await buildPaymentView(context));
      }
      else {
        widgets.clear();
        widgets.add(Widgets.AccessRestriction());
      }
    }


    var main = PageWidget.MainPage(
      topWidget: topWidget,
      infoWidget: infoWidget,
      titleWidget: Column(children: [
        titleMenu,
        if(menu == '매입매출관리') CompPU.tableHeaderMain(),
        if(menu == '수납관리') TS.OnTableHeaderMain(),
      ],),
      children: widgets,
    );
    return main;
  }

  /// 이 함수는 매출화면 위젯을 구성하고 반환합니다.
  dynamic buildRevenueView(BuildContext context) async {
    List<Widget> widgets = [];

    if(revList.isEmpty) revList = await DatabaseM.getRevenue(startDate: rpStartAt.microsecondsSinceEpoch,  lastDate: rpLastAt.microsecondsSinceEpoch, );

    var data = sort ? reSortList : revList;
    int index = 1;
    for(var re in data) {
      var cs = await SystemT.getCS(re.csUid) ?? Customer.fromDatabase({});
      var ct = await SystemT.getCt(re.ctUid) ?? Contract.fromDatabase({});
      var w = CompRE.tableUIMain(context, re,
          cs: cs, ct: ct, index: index++,
          refresh: () { mainView(context, menu, refresh: true); },
          setState: FunT.setStateMain,
      );
      widgets.add(w);
      widgets.add(WidgetT.dividHorizontal(size: 0.35),);
    }

    if(!sort) {
      var moreWidget = ButtonT.IconText(
          icon: Icons.add_box, text: "더보기",
          onTap:() async {
            WidgetT.loadingBottomSheet(context, text: '로딩중');
            var list = await DatabaseM.getRevenue(
              startAt: revList.last.id,
              startDate: rpStartAt.microsecondsSinceEpoch,
              lastDate: rpLastAt.microsecondsSinceEpoch,
            );
            revList.addAll(list);
            Navigator.pop(context);
            await FunT.setStateMain();
          }
      );
      widgets.add(moreWidget);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets,);
  }

  /// 이 함수는 매입화면 위젯을 구성하고 반환합니다.
  dynamic buildPurchaseView(BuildContext context) async {
    List<Widget> widgets = [];

    if(puList.isEmpty) {
      puList = await DatabaseM.getPurchaseList( startDate: rpStartAt.microsecondsSinceEpoch, lastDate: rpLastAt.microsecondsSinceEpoch);
    }

    var data = sort ? puSortList : puList;
    int index = 1;
    for(var pu in data) {
      var cs = await SystemT.getCS(pu.csUid);
      widgets.add(CompPU.tableUIMain(context, pu, index: index++,
        cs: cs, refresh: FunT.setRefreshMain,
      ));
      widgets.add(WidgetT.dividHorizontal(size: 0.35),);
    }

    if(!sort) {
      var moreWidget = ButtonT.IconText(
        icon: Icons.add_box, text: "더보기",
        onTap: () async {
          WidgetT.loadingBottomSheet(context, text: '로딩중');
          var list = await DatabaseM.getPurchaseList(
            startAt: puList.last.id,
            startDate: rpStartAt.microsecondsSinceEpoch,
            lastDate: rpLastAt.microsecondsSinceEpoch,
          );
          puList.addAll(list);
          Navigator.pop(context);
          await FunT.setStateMain();
        }
      );
      widgets.add(moreWidget);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets,);
  }

  /// 이 함수는 수납화면 위젯을 구성하고 반환합니다.
  dynamic buildPaymentView(BuildContext context) async {
    List<Widget> widgets = [];

    if(tsList.isEmpty) tsList = await DatabaseM.getTransaction( startDate: rpStartAt.microsecondsSinceEpoch, lastDate: rpLastAt.microsecondsSinceEpoch, );

    var datas = sort ? tsSortList : tsList;
    int index = 1;
    for(var ts in datas) {
      var cs = await SystemT.getCS(ts.csUid);
      Widget w = CompTS.tableUIMain(ts,
          context: context, index: index++, cs: cs,
          setState: () { mainView(context, menu); },
          refresh: () { mainView(context, menu, refresh: true); }
      );
      widgets.add(w);
      widgets.add(WidgetT.dividHorizontal(size: 0.35));
    }

    if(!sort) {
      var moreWidget = ButtonT.IconText(
        icon: Icons.add_box, text: "더보기",
        onTap: () async {
          WidgetT.loadingBottomSheet(context, text: '로딩중');
          var list = await DatabaseM.getTransaction(
            startAt: tsList.last.id,
            startDate: rpStartAt.microsecondsSinceEpoch,
            lastDate: rpLastAt.microsecondsSinceEpoch,
          );
          tsList.addAll(list);
          Navigator.pop(context);
          await FunT.setStateMain();
        }
      );
      widgets.add(moreWidget);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets,);
  }

  Widget build(context) {
    return Container();
  }
}
