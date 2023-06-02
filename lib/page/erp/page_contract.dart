import 'dart:convert';
import 'dart:ui';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_cs.dart';
import 'package:evers/class/user.dart';
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
class PageContract extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var divideHeight = 6.0;

  /// 정렬 상태 변수
  bool sort = false;

  /// 거래처 정보 일반, 정렬 목록입니다.
  List<Customer> csList = [];
  List<Customer> csSortList = [];

  /// 계약정보 일반, 정렬 목록입니다.
  List<Contract> ctList = [];
  List<Contract> ctSortList = [];

  /// 정렬에 사용될 기준날짜 입니다.
  DateTime rpStartAt = DateTime.now();
  DateTime rpLastAt = DateTime.now();

  /// 현재 페이지에 대한 텝 상태 메뉴
  String menu = '';

  /// 초기화자
  dynamic init() async {
  }

  /// 현재 메뉴에 대한 검색 로직을 수행하고 화면을 재구성 합니다.
  dynamic search(String search) async {
    if(searchInput.text == '') {
      sort = false;
      FunT.setStateMain();
      return;
    }
    sort = true;
    if(menu == '고객관리') {
      await SystemT.searchCSMeta(searchInput.text,);
      csSortList = await Search.searchCS();
    }
    else if(menu == '계약관리') {
      ctSortList = await SystemT.searchCTMeta(searchInput.text,);
    }
    FunT.setStateMain();
  }

  /// 제거예정 코드
  var menuStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.15), );
  var menuSelectStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.35), );
  var menuPadding = EdgeInsets.fromLTRB(6 * 4, 6 * 1, 6 * 4, 6 * 1);

  ///
  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false  }) async {
    if(this.menu != menu) {
      sort = false; searchInput.text = '';
    }
    this.menu = menu;

    if(refresh) {
      csList.clear();
      ctList.clear();
    }

    List<Widget> widgets = [];
    widgets.clear();
    widgets.add(Widgets.LoadingBar());

    /// 메뉴 분기
    if(menu == '고객관리') {
      /// 고객정보 읽기권환 확인
      if(UserSystem.userData.isPermissioned(PermissionType.isCustomerRead.code)) {
        var widget = await buildCustomerView(context);
        widgets.clear();
        widgets.add(widget);
      }
      else {
        widgets.clear();
        widgets.add(Widgets.AccessRestriction());
      }
    }
    else if(menu == '계약관리') {
      /// 계약정보 읽기권환 확인
      if(UserSystem.userData.isPermissioned(PermissionType.isContractRead.code)) {
        var widget = await buildContractView(context);
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
                search: (text) async {
                  WidgetT.loadingBottomSheet(context, text:'검색중');
                  await search(text);
                  Navigator.pop(context);
                },
                controller: searchInput
            ),
          ],
        ),
        if(menu == '고객관리') CompCS.tableHeaderMain(),
        if(menu == '계약관리') CompContract.tableHeaderMain(),
      ],),
      children: widgets,
    );
    return main;
  }


  dynamic buildCustomerView(BuildContext context) async {
    List<Widget> widgets = [];

    if(csList.isEmpty) csList = await DatabaseM.getCustomer();

    List<Widget> widgetsCs = [];
    int index = 1;
    var data = sort ? csSortList : csList;
    for(var cs in data) {
      var w = CompCS.tableUIMain(context, cs,
        refresh: FunT.setStateMain,
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
          var list = await DatabaseM.getCustomer(startAt: csList.last.id);
          csList.addAll(list);
          Navigator.pop(context);
          await FunT.setStateMain();
        }
      );
      widgets.add(moreWidget);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets,);
  }

  dynamic buildContractView(BuildContext context) async {
    List<Widget> widgets = [];

    if(ctList.isEmpty) ctList = await DatabaseM.getContract();

    var data = sort ? ctSortList : ctList;
    int index = 1;
    for(var ct in data) {
      var cs = await SystemT.getCS(ct.csUid);
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


  Widget build(context) {
    return Container();
  }
}
