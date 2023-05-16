import 'dart:convert';
import 'dart:ui';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_cs.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_cs.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../class/Customer.dart';
import '../class/contract.dart';
import '../class/purchase.dart';
import '../class/revenue.dart';
import '../class/schedule.dart';
import '../class/system.dart';
import '../class/system/search.dart';
import '../class/system/state.dart';
import '../class/transaction.dart';
import '../class/widget/button.dart';
import '../helper/dialog.dart';
import '../helper/firebaseCore.dart';
import '../helper/interfaceUI.dart';
import '../helper/pdfx.dart';
import 'cs.dart';
import 'dialog_contract.dart';
import 'dl.dart';
import 'package:http/http.dart' as http;

import 'ux.dart';

/// 고객및 계약 시스템
class View_Contract extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var st_sc_vt = ScrollController();
  var st_sc_hr = ScrollController();
  var divideHeight = 6.0;
  bool sort = false;

  List<Customer> cs_list = [];
  List<Customer> cs_sort_list = [];

  List<Contract> ct_list = [];
  List<Contract> ct_sort_list = [];

  DateTime rpStartAt = DateTime.now();
  DateTime rpLastAt = DateTime.now();

  dynamic init() async {
  }
  String menu = '';

  dynamic search(String search) async {
    if(searchInput.text == '') {
      sort = false;
      FunT.setStateMain();
      return;
    }
    sort = true;
    if(menu == '고객관리') {
      await SystemT.searchCSMeta(searchInput.text,);
      cs_sort_list = await Search.searchCS();
    }
    else if(menu == '계약관리') {
      ct_sort_list = await SystemT.searchCTMeta(searchInput.text,);
    }
    FunT.setStateMain();
  }

  var menuStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.15), );
  var menuSelectStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.35), );
  var menuPadding = EdgeInsets.fromLTRB(6 * 4, 6 * 1, 6 * 4, 6 * 1);

  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false  }) async {
    if(this.menu != menu) {
      sort = false; searchInput.text = '';
    }
    this.menu = menu;

    if(refresh) {
      cs_list.clear();
      ct_list.clear();
    }

    List<Widget> childrenW = [];

    if(menu == '고객관리') {
      childrenW.clear();

      if(cs_list.length < 1) cs_list = await DatabaseM.getCustomer();

      List<Widget> widgetsCs = [];
      var data = sort ? cs_sort_list : cs_list;
      for(int i = 0; i < data.length; i++) {
        var cs = data[i];
        Widget w = SizedBox();

        w = CompCS.tableUIMain(context, cs,
          refresh: FunT.setStateMain,
          index: i + 1,
        );
        widgetsCs.add(w);
        widgetsCs.add(WidgetT.dividHorizontal(size: 0.35));
      }

      childrenW.add(Column(children: widgetsCs,));
      if(!sort) {
        childrenW.add(InkWell(
          onTap: () async {
            WidgetT.loadingBottomSheet(context, text: '로딩중');

            var list = await DatabaseM.getCustomer(startAt: cs_list.last.id);
            cs_list.addAll(list);

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
    }
    else if(menu == '계약관리') {
      childrenW.clear();

      int index = 1;
      if(ct_list.length < 1) ct_list = await DatabaseM.getContract();

      List<Widget> widgetsCt = [];
      var data = sort ? ct_sort_list : ct_list;
      for(int i = 0; i < data.length; i++) {
        var ct = data[i];
        var cs = await SystemT.getCS(ct.csUid);

        widgetsCt.add(CompContract.tableUIMain(context, ct, cs, index: index++));
        widgetsCt.add(WidgetT.dividHorizontal(size: 0.35));
      }
      childrenW.add(Column(children: widgetsCt,));

      if(!sort) {
        childrenW.add(InkWell(
          onTap: () async {
            WidgetT.loadingBottomSheet(context, text: '로딩중');

            var list = await DatabaseM.getContract(startAt: ct_list.last.id);
            ct_list.addAll(list);

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

    }

    var main = Column(
      children: [
        if(topWidget != null)
          Stack(
            children: [
              topWidget,
              Positioned(
                top: 0, bottom: 0,
                right: 0,
                child: ButtonT.IconText(
                    icon: Icons.open_in_new_sharp,
                    text: "페이지 문서로 이동",
                    color: Colors.transparent, textColor: Colors.white.withOpacity(0.7),
                    onTap: () async {
                      var url = Uri.base.toString().split('/work').first + '/documents/customer';
                      await launchUrl( Uri.parse(url), webOnlyWindowName: true ? '_blank' : '_self',);
                    }
                ),
              )
            ],
          ),

        Expanded(
          child: Row(
            children: [
              if(infoWidget != null) infoWidget,
              Expanded(
                child: Column(
                  children: [
                    WidgetT.searchBar(
                        search: (text) async {
                          WidgetT.loadingBottomSheet(context, text:'검색중');
                          await search(text);
                          Navigator.pop(context);
                        }, controller: searchInput ),
                    if(menu == '고객관리') CompCS.tableHeaderMain(),
                    if(menu == '계약관리') CompContract.tableHeaderMain(),

                    WidgetT.dividHorizontal(size: 0.7),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ListView.builder(
                                padding: EdgeInsets.all(12),
                                itemCount: childrenW.length,
                                itemBuilder: (BuildContext ctx, int idx) {
                                  if(idx >= childrenW.length) return SizedBox();
                                  return childrenW[idx];
                                }
                            ),
                          ),
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
