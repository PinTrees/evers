import 'dart:convert';
import 'dart:ui';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_re_create.dart';
import 'package:evers/ui/dialog_revenue.dart';
import 'package:evers/ui/dialog_transration.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../class/Customer.dart';
import '../class/contract.dart';
import '../class/purchase.dart';
import '../class/revenue.dart';
import '../class/schedule.dart';
import '../class/system.dart';
import '../class/system/search.dart';
import '../class/system/state.dart';
import '../class/transaction.dart';
import '../class/widget/text.dart';
import '../helper/dialog.dart';
import '../helper/firebaseCore.dart';
import '../helper/interfaceUI.dart';
import '../helper/pdfx.dart';
import '../page/window/window_ct.dart';
import 'cs.dart';
import 'dialog_contract.dart';
import 'dialog_pu.dart';
import 'dl.dart';
import 'package:http/http.dart' as http;

import 'ux.dart';

class View_REPU extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var scrollVertController = ScrollController();
  var scrollHorController = ScrollController();
  var divideHeight = 6.0;

  var sizePrice = 80.0;
  var sizeDate = 80.0;

  List<Purchase> puList = [];
  List<Revenue> revList = [];

  List<Purchase> puSortList = [];
  List<Revenue> reSortList = [];

  List<TS> tsList = [];
  List<TS> tsSortList = [];

  /// 검색
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
        puSortList = await SystemT.searchPuMeta(search,);
      }
      else if (currentView == '매출') {
        crRpmenuRp = ''; pur_query = '';
        reSortList = await SystemT.searchReMeta(search,);
        print(reSortList.length);
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

  var menuStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.15), );
  var menuSelectStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.35), );
  var menuPadding = EdgeInsets.fromLTRB(6 * 4, 6 * 1, 6 * 4, 6 * 1);
  var disableTextColor = StyleT.titleColor.withOpacity(0.35);

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
    Widget bottomWidget = SizedBox();

    List<Widget> childrenW = [];
    if(menu == '매입매출관리') {
      childrenW.clear();
      titleMenu = Column(
        children: [
          Row(
            children: [
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
          Row(
            children: [
              ButtonT.InfoSubMenu(
                "일반 매입 추가", Icons.add_box, width: 128,
                onTap: () async {
                  UIState.OpenNewWindow(context, WindowPUCreate(refresh: FunT.setStateMain,));
                },
              ),
              ButtonT.InfoSubMenu(
                "품목 매입 추가", Icons.add_box, width: 128,
                onTap: () async {
                  var result = await DialogPU.showCreateItemPu(context);
                  FunT.setStateMain();
                },
              ),
              ButtonT.InfoSubMenu(
                '일반 매출 추가', Icons.add_box, width: 128,
                onTap: () async {
                  UIState.OpenNewWindow(context, WindowReCreate(refresh: FunT.setStateMain,));
                },
              ),
            ],
          )
        ],
      );

      if(currentView == '매입') {
        if(puList.length < 1) puList = await DatabaseM.getPurchase(
          startDate: rpStartAt.microsecondsSinceEpoch,
          lastDate: rpLastAt.microsecondsSinceEpoch,
        );

        var data = sort ? puSortList : puList;
        for(int i = 0; i < data.length; i++) {
          Purchase pu = data[i];
          var cs = await SystemT.getCS(pu.csUid);
          childrenW.add(CompPU.tableUIMain(context, pu, index: i + 1,
            cs: cs, refresh: () { mainView(context, menu); },
          ));
          childrenW.add(WidgetT.dividHorizontal(size: 0.35),);
        }

        if(!sort)
          childrenW.add(InkWell(
          onTap: () async {
            WidgetT.loadingBottomSheet(context, text: '로딩중');

            var list = await DatabaseM.getPurchase(
              startAt: puList.last.id,
              startDate: rpStartAt.microsecondsSinceEpoch,
              lastDate: rpLastAt.microsecondsSinceEpoch,
            );
            puList.addAll(list);

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
      else if(currentView == '매출') {
        if(revList.length < 1) revList = await DatabaseM.getRevenue(
          startDate: rpStartAt.microsecondsSinceEpoch,
          lastDate: rpLastAt.microsecondsSinceEpoch,
        );

        var data = sort ? reSortList : revList;
        for(int i = 0; i < data.length; i++) {
          var rev = data[i];

          Widget w = SizedBox();
          var cs = await SystemT.getCS(rev.csUid) ?? Customer.fromDatabase({});
          var ct = await SystemT.getCt(rev.ctUid) ?? Contract.fromDatabase({});

          var item = SystemT.getItem(rev.item);
          var itemName = (item == null) ? rev.item : item!.name;

          w = InkWell(
            onTap: () async {
                UIState.OpenNewWindow(context, WindowCT(org_ct: ct!));
             },
            child: Container(
              height: 36 + divideHeight,
              decoration: StyleT.inkStyleNone(color: Colors.transparent),
              child: Row(
                  children: [
                    WidgetT.excelGrid(textSize: 8, textLite: true, text: '${i + 1}', width: 32,),
                    WidgetT.excelGrid(textSize: 8, textLite: true, text: rev.id.toString(), width: sizeDate,),
                    WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.dateFormatAtEpoch(rev.revenueAt.toString()), width: sizeDate,),
                    WidgetT.excelGrid(textSize: 10, textLite: false, text: '매출', width: 50, textColor: Colors.blueAccent.withOpacity(0.5)),

                    TextT.OnTap(
                      width: 150,
                      text: '${ cs.businessName } / ${ ct.ctName }',
                        onTap: () async {
                          UIState.OpenNewWindow(context, WindowCT(org_ct: ct!));
                        }
                    ),
                    Expanded(child: WidgetT.excelGrid(textSize: 10, width: 999,  text: itemName,)),
                    WidgetT.excelGrid(textLite: true,  text:item?.unit, width: 50),
                    WidgetT.excelGrid(textSize: 10, textLite: true, width: 50,text: StyleT.krw(rev.count.toString()),),
                    WidgetT.excelGrid(textSize: 10, textLite: true, width: sizePrice, text: StyleT.krw(rev.unitPrice.toString()),),
                    WidgetT.excelGrid(textSize: 10, textLite: true, width: sizePrice,  text: StyleT.krw(rev.supplyPrice.toString()),),
                    WidgetT.excelGrid(textSize: 10, textLite: true,  width: sizePrice,  text: StyleT.krw(rev.vat.toString()), ),
                    WidgetT.excelGrid(textSize: 10, textLite: true, width: sizePrice, text: StyleT.krw(rev.totalPrice.toString()),),
                    SizedBox(height: 28,width: 32,),
                    InkWell(
                      onTap: () async {
                        var data = await DialogRE.showInfoRe(context, org: rev);
                        if(data != null) clear();
                      },
                      child: WidgetT.iconMini(Icons.create, size: 32),
                    ),
                    InkWell(
                      onTap: () async {
                        if(!await DialogT.showAlertDl(context, text: '데이터를 삭제하시겠습니까?')) {
                          WidgetT.showSnackBar(context, text: '취소됨');
                          return;
                        }
                         var task = await rev.delete();
                        if(!task) {
                          WidgetT.showSnackBar(context, text: '삭제에 실패했습니다. 나중에 다시 시도하세요.');
                          return;
                        }
                        WidgetT.showSnackBar(context, text: '매출 데이터를 삭제했습니다.');
                        clear();
                      },
                      child: WidgetT.iconMini(Icons.delete, size: 32),
                    ),
                  ]
              ),
            ),
          );
          childrenW.add(w);
          childrenW.add(WidgetT.dividHorizontal(size: 0.35),);
        }

        if(!sort)
          childrenW.add(InkWell(
          onTap: () async {
            WidgetT.loadingBottomSheet(context, text: '로딩중');

            var list = await DatabaseM.getRevenue(
              startAt: revList.last.id,
              startDate: rpStartAt.microsecondsSinceEpoch,
              lastDate: rpLastAt.microsecondsSinceEpoch,
            );
            revList.addAll(list);

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

    else if(menu == '수납관리') {
      childrenW.clear();
      titleMenu = Column(
        children: [
          Row(
            children: [
              WidgetT.title('수납 목록', size: 18),
              SizedBox(width: divideHeight * 2,),
              WidgetT.text('( 수납 목록, 거래 기록 )', size: 12,)
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

      if(tsList.length < 1) {
        tsList = await DatabaseM.getTransaction(
          startDate: rpStartAt.microsecondsSinceEpoch,
          lastDate: rpLastAt.microsecondsSinceEpoch,
        );
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

      if(!sort) {
        childrenW.add(InkWell(
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
                    if(menu == '매입매출관리') CompPU.tableHeaderMain(),
                    if(menu == '수납관리') TS.OnTableHeaderMain(),
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
