import 'dart:convert';
import 'dart:ui';

import 'package:evers/class/component/comp_item.dart';
import 'package:evers/class/component/comp_process.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/json.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/dialog_item.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import '../../class/Customer.dart';
import '../../class/component/comp_ts.dart';
import '../../class/contract.dart';
import '../../class/database/item.dart';
import '../../class/database/process.dart';
import '../../class/system.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/text.dart';
import '../../core/window/ResizableWindow.dart';
import '../../core/window/window_base.dart';
import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';
import '../../ui/ux.dart';

class WindowItemTS extends WindowBaseMDI {
  ItemTS itemTS;
  Function refresh;

  WindowItemTS({ required this.itemTS, required this.refresh,}) { }

  @override
  _WindowItemTsState createState() => _WindowItemTsState();
}

class _WindowItemTsState extends State<WindowItemTS> {
  var dividHeight = 6.0;

  Contract? ct;
  Customer cs = Customer.fromDatabase({});

  /// 해당 매입품목에 대한 전체 공정목록
  List<ProcessItem> processAllList = [];
  /// 출고된 공정목록
  List<ProcessItem> outputList = [];
  List<ProcessItem> processList = [];

  ItemTS itemTs = ItemTS.fromDatabase({});

  /// 각 공정에대한 중간자재 출고품목 통합목록
  Map<String, ProcessItem> outputMap = {};
  /// 각 공정에 대한 원자재 사용량
  Map<String, double> amountMap = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /// 객체 깊은 복사
    itemTs = ItemTS.fromDatabase(JsonManager.toJsonObject(widget.itemTS));

    initAsync();
  }

  dynamic initAsync() async {
    ct = await DatabaseM.getContractDoc(itemTs.ctUid);
    cs = await DatabaseM.getCustomerDoc(itemTs.csUid);

    /// 해당 매입품목에 대한 전체 공정목록
    processAllList = await DatabaseM.getItemProcessPu(itemTs.rpUid == '' ? '-' : itemTs.rpUid);
    /// 출고된 공정목록
    outputList = processAllList.where((e) => e.isOutput).toList();
    processList = processAllList.where((e) => !e.isOutput).toList();

    processAllList.forEach((e) {
      if(e.prUid == '') return;
      if(amountMap.containsKey(e.prUid)) amountMap[e.prUid] = amountMap[e.prUid]! + e.usedAmount.abs();
      else amountMap[e.prUid] = e.usedAmount.abs();
    });

    outputList.forEach((e) {
      if(outputMap.containsKey(e.itUid)) outputMap[e.itUid]!.amount += e.amount.abs();
      else outputMap[e.itUid] = ProcessItem.fromDatabase(e.toJson());
    });

    /// Debug
    print(itemTs.rpUid);

    setState(() {});
  }



  /// 해당 윈도우창 메인위젯 빌더입니다.
  Widget mainBuild() {
    List<Widget> widgetsPu = [ CompItemTS.tableHeader() ];
    var w = CompItemTS.tableUI(
      context, itemTs,
      setState: () { setState(() {}); },
    );
    widgetsPu.add(w);

    List<Widget> outputWidgets = [ CompProcess.tableHeaderOutput() ];
    List<Widget> processingWidgets = [ CompProcess.tableHeader() ];


    /// 최초 매입한 원물기록입니다. 기초 품목에 대한 가공가능목록 생성
    var usedCount = 0.0;
    processAllList.forEach((e) { if(e.prUid.trim() == itemTs.rpUid || e.prUid.trim() == '') usedCount += e.amount.abs(); });
    if(itemTs.amount - usedCount.abs() > 0) {
      var w = CompItemTS.tableUIOutput(
        context, itemTs, usedCount,
        setState: () { setState(() {}); },
        refresh: () async {
          await initAsync();
        }
      );
      outputWidgets.add(w);
      outputWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }


    /// 매입원물에 대한 가공공정을 완료한 2차 가공품입니다.
    /// 대부분 해당 원물가공공정에 대해 생략할 수 있습니다. - 2차 가공품
    outputMap.values.forEach((e) {
      var w = CompProcess.tableUIOutput(
          context, e, itemTs, amountMap.containsKey(e.id) ? amountMap[e.id]! : 0.0,
        setState: () { setState(() {}); },
        refresh: () async {
          initAsync();
        },
      );
      outputWidgets.add(w);
      outputWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    });


    /// 현재 진행되고 있는 가공목록 및 상태를 표시합니다.
    for(var e in processAllList) {
      //initAsync();
      var w = CompProcess.tableUI(
        context, e, amountMap.containsKey(e.id) ? amountMap[e.id]! : 0.0,
        setState: () { setState(() {}); },
        refresh: () { initAsync(); }
      );
      processingWidgets.add(w);
      processingWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }


    return Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextT.Lit(text: "매입한 품목의 각 품목별 가공기록을 확인하는 화면입니다.",),
                SizedBox(height: dividHeight * 4,),
                TextT.SubTitle(text: '거래처'),
                TextT.Lit(text: (cs != null) ? cs!.businessName : '',),
                SizedBox(height: dividHeight * 4,),

                TextT.SubTitle(text:'품목매입정보',),
                SizedBox(height: dividHeight,),
                Column(children: widgetsPu, ),
                SizedBox(height: dividHeight * 4,),

                TextT.SubTitle(text: '가공가능한 목록',),
                SizedBox(height: dividHeight,),
                Column(children: outputWidgets, ),
                SizedBox(height: dividHeight * 4,),

                TextT.SubTitle(text: '가공중인 목록',),
                SizedBox(height: dividHeight,),
                Column(children: processingWidgets, ),
                SizedBox(height: dividHeight * 4,),

                TextT.SubTitle(text: '품목가공로그',),
                TextT.Lit(text: '해당 품목에 대한 모든 가공공정의 로그 목록입니다.', size: 10,),
              ],
            ),
          ),

          /// action
          buildAction(),
        ],
      ),
    );
  }


  Widget buildAction() {
    var okWidget = ButtonT.Action(
      context, "확인", icon: Icons.check_circle,
      onTap: () {
        //widget.refresh();
        widget.parent.onCloseButtonClicked!();
      }
    );

    return Row( children: [ okWidget,], );
  }



  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}
