import 'dart:convert';
import 'dart:ui';

import 'package:evers/class/component/comp_item.dart';
import 'package:evers/class/component/comp_process.dart';
import 'package:evers/class/database/balance.dart';
import 'package:evers/class/database/process.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/dialog/dialog_itemts.dart';
import 'package:evers/dialog/dialog_tag.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_item.dart';
import 'package:evers/page/window/window_process_info.dart';
import 'package:evers/ui/dialog_revenue.dart';
import 'package:evers/ui/ex.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../class/Customer.dart';
import '../../../class/contract.dart';
import '../../../class/database/item.dart';
import '../../../class/purchase.dart';
import '../../../class/revenue.dart';
import '../../../class/schedule.dart';
import '../../../class/system.dart';
import '../../../class/system/state.dart';
import '../../../class/transaction.dart';
import '../../../class/widget/list.dart';
import '../../../class/widget/page.dart';
import '../../../class/widget/text.dart';
import '../../../helper/aes.dart';
import '../../../helper/dialog.dart';
import '../../../helper/firebaseCore.dart';
import '../../../helper/interfaceUI.dart';
import '../../../helper/pdfx.dart';
import '../../../ui/dialog_item.dart';
import '../../../ui/dl.dart';
import 'package:http/http.dart' as http;

import '../../../ui/ux.dart';

/// work/u 페이지 하위 시스템
///
/// 생산관리 시스템 페이지 뷰어
/// @create YM
class PageFactory extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var divideHeight = 6.0;

  List<ItemTS> itemTsList = [];
  List<ItemTS> itemProductList = [];

  List<ProcessItem> processList = [];
  List<ProcessItem> processAllList = [];

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

  void query_init() {
    sort = false; query = true;
  }
  void clear() async {
    itemTsList.clear();
    itemProductList.clear();
    processAllList.clear();
    processingAmount.clear();
    processOutputAmount.clear();
    usedAmount.clear();
  }

  var menuStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.15), );
  var menuSelectStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.35), );
  var menuPadding = EdgeInsets.fromLTRB(6 * 4, 6 * 1, 6 * 4, 6 * 1);
  var disableTextColor = StyleT.titleColor.withOpacity(0.35);


  var subMenu = '생산관리';


  Map<String, double> usedAmount = {};

  /// 추후 날짜별 저장및 조회가 가능하도록 셜계해야 합니다.
  /// 현재 작업완료를 통해 완료된 모든 작업물들의 합계를 기록합니다.
  Map<String, double> processOutputAmount = {};

  /// itemUid, amount - 현재 작업이 진행중인 품목 수량을 기록합니다.
  Map<String, double> processingAmount = {};


  /// Main Widget Build Function
  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false  }) async {
    if(this.menu != menu) {
      this.menu = menu;
      sort = false; searchInput.text = '';
      refresh = true;
    }

    if(refresh) {
      clear();
      query = false; sort = false;
      pur_query = '';

      if(menu == "생산관리") {
        await ItemBalance.init();
        itemProductList = await DatabaseM.getItemTranListProduct();
        /// 추후 날짜별 목록 스냅샷에서 로드하는 형태로 변경이 필요합니다.
        processAllList = await DatabaseM.getProcessItemGroupListWithDate(all: true);

        processList.clear();
        for(var pr in processAllList) {
          /// 공정이 끝나지 않았을 경우 - 일반적으로 100개 미만일 것입니다.
          if(!pr.isDone && !pr.isOutput && pr.itUid != '') {
            processList.add(pr);
            List<ProcessItem> outputList = await DatabaseM.getProcessItemGroupByPrUid(pr.id);
            var used = 0.0;

            /// 해당 공정과 연결되어 있는 생산완료 공정을 확인하여 소모한 공정량을 산출
            outputList.forEach((e) { used += e.usedAmount.abs(); });
            usedAmount[pr.id] = used;

            /// 현재 작업중인 품목수량 산출
            /// 특정 공정에 대한 현재 작업중인 수량 산출 공식 : 공정중인 수량 = 공정시작 수량 - 사용수량
            /// 특정 품목에 대한 작업중인 수량 산출 공식 : (공정중인 수량 = 공정시작 수량 - 사용수량 ) ^ n
            if(processingAmount.containsKey(pr.itUid)) processingAmount[pr.itUid] = processingAmount[pr.itUid]! + usedAmount[pr.id]!;
            else processingAmount[pr.itUid] = pr.amount - usedAmount[pr.id]!;
          }

          /// 공정이 종료되었을 경우 - 일반적으로 매우 많은 데이터가 누적될 것입니다. - 100000개
          else {
            /// 생산량에 공정완료 수량을 산출
            if(processOutputAmount.containsKey(pr.itUid)) processOutputAmount[pr.itUid] = processOutputAmount[pr.itUid]! + pr.amount;
            else processOutputAmount[pr.itUid] = pr.amount;
          }
        }
        await SystemT.initItemBalance();
      }
    }


    List<Widget> childrenW = [];
    Widget titleWidgetT = SizedBox();


    if(menu == '품목관리') {
      childrenW.clear();
      for(int i = 0; i < SystemT.itemMaps.length; i++) {
        var itemTmp = SystemT.itemMaps.values.elementAt(i);
        Widget w = SizedBox();
        w = InkWell(
          onTap: () async {
            UIState.OpenNewWindow(context, WindowItemCreator(refresh: FunT.setRefreshMain, item: itemTmp, ));
          },
          child: Container( height: 32,
            decoration: StyleT.inkStyleNone(color: Colors.transparent),
            child: Row(
                children: [
                  WidgetT.excelGrid(label: '${i}', width: 32),
                  WidgetT.excelGrid(textLite: true, text: MetaT.itemType[itemTmp.type], width: 100,),
                  WidgetT.excelGrid(textLite: true, text: MetaT.itemGroup[itemTmp.group], width: 100,),
                  WidgetT.excelGrid(text: '${itemTmp.name}', width: 200, ),
                  WidgetT.excelGrid(textLite: true, width: 100,  text: itemTmp.unit,),
                  WidgetT.excelGrid(textLite: true, text: StyleT.krwInt(itemTmp.unitPrice), width: 120,),
                  WidgetT.excelGrid(textLite: true, text: StyleT.krwInt(itemTmp.cost), width: 120, ),
                  Expanded(child: WidgetT.excelGrid(textLite: true, width: 250, text: itemTmp.memo,),),
                  Container( height: 32, width: 32,
                    child: WidgetT.iconMini(itemTmp.display ? Icons.check_box: Icons.check_box_outline_blank),),
                  TextButton(
                      onPressed: () async {
                        UIState.OpenNewWindow(context, WindowItemCreator(refresh: FunT.setRefreshMain, item: itemTmp, ));
                      },
                      style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                      child: Container( height: 32, width: 32,
                        child: WidgetT.iconMini(Icons.create),)
                  ),
                  TextButton(
                      onPressed: () async {
                        if(await DialogT.showAlertDl(context, text: '"${itemTmp.name}" 품목을 데이터베이스에서 삭제하시겠습니까?')) {
                          await DatabaseM.deleteItem(itemTmp);
                        }
                        FunT.setStateDT();
                      },
                      style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                      child: Container( height: 32, width: 32,
                        child: WidgetT.iconMini(Icons.delete),)
                  ),
                ]
            ),
          ),
        );
        childrenW.add(w);
        childrenW.add(WidgetT.dividHorizontal(size: 0.35));
      }
    }

    else if(menu == "품목입출현황") {
      if(itemTsList.isEmpty) {
        itemTsList = await DatabaseM.getItemTranList(
          startDate: query ? rpStartAt.microsecondsSinceEpoch : null,
          lastDate: query ? rpLastAt.microsecondsSinceEpoch : null,
        );
      }



      childrenW.add(Column(
        children: [
          Row(
            children: [
              WidgetT.title('품목 입출 목록', size: 16),
              SizedBox(width: divideHeight * 2,),
              InkWell(
                  onTap: () async {
                    WidgetT.showSnackBar(context, text: "개발중 입니다.");
                  },
                  child: Container(
                    color: Colors.grey.withOpacity(0.35),
                    child: Row(
                      children: [
                        WidgetT.iconMini(Icons.add_box, size: 24, boxSize: 28),
                        WidgetT.text('신규 입출목록 추가', size: 12,),
                        SizedBox(width: divideHeight,),
                      ],
                    ),
                  )
              )
            ],
          ),
          Container(
            child: WidgetUI.titleRowNone([ '순번', '입출일', '구분', '거래처 / 계약', '품목', '수량', '습도', '저장고', '검수자', '' ],
                [ 32, 80, 50, 999, 999, 80, 80, 80, 80, 64 ]),
          ),
          WidgetT.dividHorizontal(size: 0.7),
        ],
      ));

      int i = 0;
      var data = sort ? itemTsList : itemTsList;
      for(var itemTs in data) {
        i++;
        Widget w = SizedBox();
        var cs = await SystemT.getCS(itemTs.csUid) ?? Customer.fromDatabase({});
        var ct = await SystemT.getCt(itemTs.ctUid) ?? Contract.fromDatabase({});

        w = CompItemTS.tableUIMain(context, itemTs,
          index: i, cs: cs, ct: ct,
          refresh: FunT.setRefreshMain,
        );

        childrenW.add(w);
        childrenW.add(WidgetT.dividHorizontal(size: 0.35),);
      }

      if(!sort) {
        childrenW.add(InkWell(
          onTap: () async {
            WidgetT.loadingBottomSheet(context, text: '로딩중');

            var list = await DatabaseM.getItemTranList(
              startAt: (itemTsList.length > 0) ? itemTsList.last.id : null,
              startDate: query ? rpStartAt.microsecondsSinceEpoch : null,
              lastDate: query ? rpLastAt.microsecondsSinceEpoch : null,
            );
            itemTsList.addAll(list);

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

    else if(menu == '생산관리') {
      List<Widget> itemBalanceWidgets = [];
      itemBalanceWidgets.add(ItemTS.OnBalanceTableHeader());
      SystemT.itemMaps.forEach((k, v) {
        itemBalanceWidgets.add(Container(
          height: 28,
          child: Row(
            children: [
              ExcelT.LitGrid(text: '-', width: 28),
              ExcelT.LitGrid(text: v.name, width: 200, center: true),
              ExcelT.LitGrid(text: MetaT.itemGroup[v.group] ?? '-', width: 150, center: true),
              ExcelT.LitGrid(text: StyleT.krwDouble(ItemBalance.amountItem(k)) + v.unit, width: 100, center: true),
              ExcelT.LitGrid(text: StyleT.krwDouble(processingAmount[k]) + v.unit, width: 100, center: true),
              ExcelT.LitGrid(text: StyleT.krwDouble(processOutputAmount[k]) + v.unit, width: 100, center: true),
            ],
          ),
        ));
        itemBalanceWidgets.add(WidgetT.dividHorizontal(size: 0.35));
      });

      List<Widget> processWidgets = [];
      processWidgets.add(CompProcess.tableHeader());


      if(processList.isNotEmpty) {
        Purchase? pu = await DatabaseM.getPurchaseDoc(processList.first.rpUid);
        for(var e in processList) {
          var cs = await SystemT.getCS(pu == null ? e.csUid : pu.csUid);
          processWidgets.add(CompProcess.tableUI(
              context, e, usedAmount[e.id] ?? 0.0, cs: cs,
              onTap: () async {
                var itemTs = await DatabaseM.getItemTrans(e.rpUid);
                UIState.OpenNewWindow(context, WindowItemTS(itemTS: itemTs, refresh: FunT.setRefreshMain));
              },
              setState: () { mainView(context, menu, refresh: true); },
              refresh: FunT.setRefreshMain
          ));
          processWidgets.add(WidgetT.dividHorizontal(size: 0.35));
        }
      }

      childrenW.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextT.Title(text:'가공공정 목록'),
              SizedBox(width: divideHeight,),
              ButtonT.IconText(
                  icon: Icons.add_box,
                  text: '추가',
                  onTap: () async {
                    var result = await DialogTag.createTag(context);
                    if(result != null){
                      await MetaT.init();
                      mainView(context, menu, refresh: false);
                    }
                  }
              ),
            ],
          ),
          SizedBox(height: divideHeight,),
          TextT.Lit(text: MetaT.processType.values.join(', ')),
          SizedBox(height: divideHeight * 4,),

          TextT.Title(text:'재고현황'),
          SizedBox(height: divideHeight,),
          Column( children: itemBalanceWidgets,),
          SizedBox(height: divideHeight * 4,),

          TextT.Title(text:'가공중인 품목',),
          SizedBox(height: divideHeight,),
          Column( children: processWidgets,),

          WidgetT.dividHorizontal(size: 0.7),
        ],
      ));
      childrenW.add(SizedBox(height: divideHeight,));
    }

    childrenW.insert(0, titleWidgetT);

    var main = PageWidget.MainPage(
      topWidget: topWidget,
      infoWidget: infoWidget,
      children: childrenW,
    );
    return main;
  }

  Widget build(context) {
    return Container();
  }
}
