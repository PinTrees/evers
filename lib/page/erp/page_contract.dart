import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_cs.dart';
import 'package:evers/class/user.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/class/widget/widget.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_cs.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
import '../../../class/widget/page.dart';
import '../../../class/widget/textInput.dart';
import '../../../helper/dialog.dart';
import '../../../helper/firebaseCore.dart';
import '../../../helper/interfaceUI.dart';
import 'package:http/http.dart' as http;

import '../../../ui/ux.dart';

/// 고객및 계약 시스템

class PageContract extends StatefulWidget {
  Widget? topWidget;
  String menu;
  Widget? infoWidget;
  PageContract({ required this.menu,
    this.topWidget,
    this.infoWidget,
  }) { }

  @override
  _PageContractState createState() => _PageContractState();
}

class _PageContractState extends State<PageContract>  {
  TextEditingController searchInput = TextEditingController();

  /// 정렬 상태 변수
  bool sort = false;

  /// 거래처 정보 일반, 정렬 목록입니다.
  List<Customer> csList = [];
  List<Customer> csSortList = [];
  List<Customer> selectCsList = [];
  List<String> csSearchHistory = [];

  /// 계약정보 일반, 정렬 목록입니다.
  List<Contract> ctList = [];
  List<Contract> ctSortList = [];
  Map<String, Customer> ctCsMap = {};

  /// 정렬에 사용될 기준날짜 입니다.
  DateTime rpStartAt = DateTime.now();
  DateTime rpLastAt = DateTime.now();

  /// 현재 페이지에 대한 텝 상태 메뉴
  String menu = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.menu = widget.menu;

    FunT.streamSearchHistory = (searchList, selectList) async {
      csSearchHistory = searchList;
      selectCsList = await Search.searchCSOrder(selectList);
      setState(() {});
    };

    initAsync();
  }

  /// 초기화자
  dynamic initAsync() async {
    sort = false;

    await UserSystem.userData.init();

    csSearchHistory = UserSystem.userData.customerSearch;
    selectCsList = await Search.searchCSOrder(UserSystem.userData.customerSelect);

    csList = await DatabaseM.getCustomerList();
    ctList = await DatabaseM.getContract();

    for(var ct in ctList) {
      if(ctCsMap.containsKey(ct.csUid)) continue;
      ctCsMap[ct.csUid] = await SystemT.getCS(ct.csUid);
    }

    setState(() {});
  }


  /// 현재 메뉴에 대한 검색 로직을 수행하고 화면을 재구성 합니다.
  dynamic search(String search) async {
    if(searchInput.text == '') {
      sort = false;
      setState(() {});
      return;
    }
    sort = true;
    if(menu == '고객관리') {
      csSortList = await Search.searchCSMeta(searchInput.text,);
    }
    else if(menu == '계약관리') {
      ctSortList = await SystemT.searchCTMeta(searchInput.text,);
    }

    setState(() {});
  }



  /// 메인 위젯을 그리는 함수입니다.
  Widget mainView({ Widget? topWidget, Widget? infoWidget }) {
    if(menu != widget.menu) {
      menu = widget.menu;
      initAsync();
      return  PageWidget.MainPage(
        topWidget: topWidget,
        infoWidget: infoWidget,
        children: [ LinearProgressIndicator(minHeight: 2,) ],
      );
    }

    List<Widget> titleWidgets = [];
    List<Widget> widgets = [ Widgets.LoadingBar() ];

    /// 메뉴 분기
    if(menu == '고객관리') {
      titleWidgets.add(ListBoxT.Rows(
          spacing: 6,
          children: [
          TextT.SubTitle(text: "최근 열어본 거래처"),
            SizedBox(width: 6 * 2,),
            for(var cs in selectCsList)
              ButtonT.Text( text: cs.businessName,round: 8,
                  onTap: () {
                    if(cs.state == "") UIState.OpenNewWindow(context, WindowCS(org_cs: cs, refresh: () { initAsync(); },));
                  }
              ),
          ]
      ));
      titleWidgets.add(CompCS.tableHeaderMain());

      /// 고객정보 읽기권환 확인
      if(UserSystem.userData.isPermissioned(PermissionType.isCustomerRead.code)) {
        var widget = buildCustomerView(context);
        widgets.clear();
        widgets.add(widget);
      }
      else {
        widgets.clear();
        widgets.add(Widgets.AccessRestriction());
      }
    }
    else if(menu == '계약관리') {
      titleWidgets.add(CompContract.tableHeaderMain());

      /// 계약정보 읽기권환 확인
      if(UserSystem.userData.isPermissioned(PermissionType.isContractRead.code)) {
        var widget = buildContractView(context);
        widgets.clear();
        widgets.add(widget);
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
        Row(
          children: [
            TextT.Title(text: menu),
            SizedBox(width: 6 * 4,),
            InputWidget.textSearch(
                context: context,
                search: (text) async {
                  WidgetT.loadingBottomSheet(context, text:'검색중');
                  await search(text);
                  Navigator.pop(context);
                },
                //setState: () { setState(() {}); },
                suggestions: csSearchHistory,
                controller: searchInput
            ),
          ],
        ),
        for(var w in titleWidgets) w,
      ],),
      children: widgets,
    );
    return main;
  }


  Widget buildCustomerView(BuildContext context) {
    List<Widget> widgets = [];

    List<Widget> widgetsCs = [];
    int index = 1;
    var data = sort ? csSortList : csList;
    for(var cs in data) {
      var w = CompCS.tableUIMain(context, cs,
        refresh: () { initAsync(); },
        index: index++,
      );
      widgetsCs.add(w);
      widgetsCs.add(WidgetT.dividHorizontal(size: 0.35));
    }

    widgets.add(Column(children: widgetsCs,));

    if(!sort) {
      var moreWidget = ButtonT.IconText(
        icon: Icons.add_box, text: "더보기",
        onTap: () async {
          WidgetT.loadingBottomSheet(context, text: '로딩중');
          var list = await DatabaseM.getCustomerList(startAt: csList.last.id);
          csList.addAll(list);
          Navigator.pop(context);
          await FunT.setStateMain();
        }
      );
      widgets.add(moreWidget);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets,);
  }
  Widget buildContractView(BuildContext context) {
    List<Widget> widgets = [];

    var data = sort ? ctSortList : ctList;
    int index = 1;
    for(var ct in data) {
      var cs = ctCsMap[ct.csUid] ?? Customer.fromDatabase({});
      widgets.add(CompContract.tableUIMain(context, ct, cs, index: index++));
      widgets.add(WidgetT.dividHorizontal(size: 0.35));
    }

    if(!sort) {
      var moreWidget = ButtonT.IconText(
          icon: Icons.add_box, text: "더보기",
          onTap: () async {
            WidgetT.loadingBottomSheet(context);
            var list = await DatabaseM.getContract(startAt: ctList.last.id);
            ctList.addAll(list);
            Navigator.pop(context);
            await FunT.setStateMain();
          }
      );
      widgets.add(moreWidget);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets,);
  }


  @override
  Widget build(context) {
    return mainView(infoWidget: widget.infoWidget, topWidget: widget.topWidget);
  }
}
