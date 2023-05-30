import 'dart:convert';
import 'dart:ui';

import 'package:evers/class/component/comp_item.dart';
import 'package:evers/class/component/comp_process.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
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
import '../../class/widget/excel.dart';
import '../../class/widget/text.dart';
import '../../core/window/ResizableWindow.dart';
import '../../core/window/window_base.dart';
import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';
import '../../ui/ux.dart';

class WindowProcessCreate extends WindowBaseMDI {
  ProcessItem process;
  Function refresh;

  WindowProcessCreate({ required this.process, required this.refresh,}) { }

  @override
  _WindowProcessCreateState createState() => _WindowProcessCreateState();
}

class _WindowProcessCreateState extends State<WindowProcessCreate> {
  var dividHeight = 6.0;

  Contract ct = Contract.fromDatabase({});
  Customer cs = Customer.fromDatabase({});

  /// 해당 매입품목에 대한 전체 공정목록
  List<ProcessItem> processAllList = [];
  /// 출고된 공정목록
  List<ProcessItem> outputList = [];
  List<ProcessItem> processList = [];

  ProcessItem inputProcess = ProcessItem.fromDatabase({});
  Item? item;

  /// 각 공정에대한 중간자재 출고품목 통합목록
  Map<String, ProcessItem> outputMap = {};
  /// 각 공정에 대한 원자재 사용량
  Map<String, double> amountMap = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /// 신규 프로세스 생성
    inputProcess = ProcessItem.fromDatabase({});
    inputProcess.date = DateTime.now().microsecondsSinceEpoch;

    item = SystemT.getItem(widget.process.itUid);
    if(item == null) return;
    if(item!.id == "") return;

    initAsync();
  }

  dynamic initAsync() async {
    setState(() {});
  }






  /// 해당 윈도우창 메인위젯 빌더입니다.
  Widget mainBuild() {
    var titleWidget = ListBoxT.Columns(
      children: [
        TextT.SubTitle(text: '현재 가공 품목',),
        SizedBox(height: dividHeight,),
        TextT.Lit(text: item!.name, size: 12),
      ]
    );

    var processInputWidget = ListBoxT.Columns(
      children: [
        TextT.SubTitle(text: '공정 및 수량 입력',),
        TextT.Lit(text: '해당 원자재 품목에 대한 공정을 추가하고 작업목록에 추가합니다.',),
        TextT.Lit(text: '가공할 수량: 원자재에 대한 가공수량입니다.',),
        TextT.Lit(text: '가공가능 최대수량: 해당 거래처 또는 계약으로 매입한 원자재의 가공한계수량입니다. 작업이 추가될경우 사용한 만큼 최대치가 반영됩니다.',),
        SizedBox(height: dividHeight,),

        Column(children: [
          WidgetUI.titleRowNone([ '가공일', '가공 공정', '가공할 수량', '가공가능 최대수량' ], [ 150, 250, 250, 250 ], lite: true, background: true),
          CompProcess.tableUIInput(
            context, inputProcess, widget.process,
            setState: () { setState(() {}); }
          ),
        ],),
      ]
    );

    return Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: ListBoxT.Columns(
              spacing: 6 * 4,
              children: [
                titleWidget,
                processInputWidget
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
      context, "가공 저장", icon: Icons.save,
      init: () {
        if(inputProcess.amount <= 0) return Messege.toReturn(context, '가공수량은 0일 수 없습니다.', false);
        if(inputProcess.type == '') return Messege.toReturn(context, '가공공정은 비워둘 수 없습니다.', false);
        return true;
      },
      altText: "신규 공정을 추가하시겠습니까?",
      onTap: () async {
        /// 최상위 부모 매입정보 상속
        inputProcess.prUid = widget.process.id;
        inputProcess.rpUid = widget.process.rpUid;
        inputProcess.itUid = widget.process.itUid;

        var result = await inputProcess.update();
        if(!result) WidgetT.showSnackBar(context, text: 'The request to write to the server for path "/purchase/:pid/item-process/:psid" failed.');
        else WidgetT.showSnackBar(context, text: '저장됨');

        widget.refresh();
        widget.parent.onCloseButtonClicked!();
      },
    );



    return Row( children: [ okWidget,], );
  }



  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}
































class WindowProcessOutputCreate extends WindowBaseMDI {
  ProcessItem process;
  Function refresh;

  WindowProcessOutputCreate({ required this.process, required this.refresh,}) { }

  @override
  _WindowProcessOutputCreateState createState() => _WindowProcessOutputCreateState();
}

class _WindowProcessOutputCreateState extends State<WindowProcessOutputCreate> {
  var dividHeight = 6.0;

  Contract ct = Contract.fromDatabase({});
  Customer cs = Customer.fromDatabase({});

  /// 해당 매입품목에 대한 전체 공정목록
  List<ProcessItem> processAllList = [];
  /// 출고된 공정목록
  List<ProcessItem> outputList = [];
  List<ProcessItem> processedList = [];

  ProcessItem inputProcess = ProcessItem.fromDatabase({});
  Item? item;

  var usedAmount = 0.0;
  var outputUsedAmount = 0.0;
  var startAmount = 0.0;

  /// 각 공정에대한 중간자재 출고품목 통합목록
  Map<String, ProcessItem> outputMap = {};
  /// 각 공정에 대한 원자재 사용량
  Map<String, double> amountMap = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /// 신규 프로세스 생성
    inputProcess = ProcessItem.fromDatabase({});
    inputProcess.date = DateTime.now().microsecondsSinceEpoch;
    startAmount = widget.process.amount;

    initAsync();
  }

  dynamic initAsync() async {
    item = SystemT.getItem(widget.process.itUid);
    if(item == null) return;
    if(item!.id == "") return;

    processedList = await DatabaseM.getProcessItemGroupByPrUid(widget.process.id);
    processedList.forEach((e) {
      outputUsedAmount += e.usedAmount.abs();
    });
    widget.process.amount -= outputUsedAmount.abs();

    setState(() {});
  }



  /// 해당 윈도우창 메인위젯 빌더입니다.
  Widget mainBuild() {
    var titleWidget = ListBoxT.Columns(
        children: [
          TextT.SubTitle(text: '현재 가공 품목',),
          SizedBox(height: dividHeight,),
          TextT.Lit(text: item!.name, size: 12),
        ]
    );

    var processInputWidget = ListBoxT.Columns(
        children: [
          TextT.SubTitle(text: '현재 가공품',),
          TextT.Lit(text: '${item!.name} (${ MetaT.itemGroup[item!.group] ?? '-' })',),
          SizedBox(height: dividHeight * 2,),
          TextT.SubTitle(text: '현재 가공공정',),
          TextT.Lit(text: MetaT.processType[widget.process.type],),
          SizedBox(height: dividHeight * 2,),

          TextT.SubTitle(text: '공정완료 수량 및 품목 입력',),
          TextT.Lit(text: '해당 가공공정을 일부 또는 전체를 종료하고 공정이 완료된 신규 품목을 선택하여 생산된 수량을 작성하고 재고에 반영합니다.',),
          TextT.Lit(text: '공정은 일부 완료가 가능합니다. 일부완료 시, 사용된 작업물 수량을 전체 투입수량의 비율에 맞게 조절하여 입력합니다.',),
          TextT.Lit(text: '\n완성된 품목 수량은 가공완료된 품목의 결과물 수량입니다.',),
          TextT.Lit(text: '가공완료품목은 가공완료된 품목의 최종가공형태입니다. 브라질넛 -> 세척브라질넛 (세척가공 후)',),
          SizedBox(height: dividHeight,),
          Column(children: [
            CompProcess.tableHeaderOutputCreate(),
            CompProcess.tableUIOutputCreate(
                context, inputProcess, widget.process,
              usedLimitAmount: startAmount,
              refresh: () { widget.refresh(); },
              setState: () { setState(() {}); }
            )
          ],),
        ]
    );

    return Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: ListBoxT.Columns(
              spacing: 6 * 4,
              children: [
                titleWidget,
                processInputWidget
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
    var exitWidget = ButtonT.Action(
      context, "공정 완전 종료", icon: Icons.exit_to_app,
      backgroundColor: Colors.red.withOpacity(0.5),
      init: () {
        if(widget.process.amount > 0.001) return Messege.toReturn(context, "남은 작업물 수량이 0보다 클경우 공정을 종료할 수 없습니다.", false);
        return true;
      },
        altText: "공정을 완전히 종료하시겠습니까?",
        setState: () { setState(() {}); },
      onTap: () async {
        /// 해당 생산공정이 종료되었음을 기록합니다.
        var result = await widget.process.updateOnlyIsDone();

        /// 생산공정을 통해 생산된 생산품 정보를 저장합니다.
        /// 해당 분기는 사용자가 생산품이 존재한다고 입력한 경우에만 실행됩니다.
        if(inputProcess.amount > 0
        && inputProcess.itUid != ''
        && inputProcess.usedAmount > 0) {
          inputProcess.prUid = widget.process.id;
          inputProcess.rpUid = widget.process.rpUid;
          inputProcess.isOutput = true;
          result = await inputProcess.update();
        }

        /// 데이터베이스 기록 결과
        if(!result) WidgetT.showSnackBar(context, text: 'The request to write to the server for path "/purchase/:pid/item-process/:psid" failed.');
        else WidgetT.showSnackBar(context, text: '저장됨');

        /// 현재 윈도우 종료
        widget.refresh();
        widget.parent.onCloseButtonClicked!();
      }
    );


    var saveWidget = ButtonT.Action(
        context, "공정 완료 추가", icon: Icons.save,
      setState: () { setState(() {}); },
      init: () {
        if(inputProcess.amount <= 0) return Messege.toReturn(context, '가공완료수량은 0일 수 없습니다.', false);
        if(inputProcess.itUid == '') return Messege.toReturn(context, '가공완료품목은 비워둘 수 없습니다.', false);
        if(inputProcess.usedAmount <= 0) return Messege.toReturn(context, '가공사용수량은 0일 수 없습니다.', false);
        return true;
      },
        altText: "공정을 완료하시겠습니까?",
      onTap: () async {
        /// 생산공정을 통해 생산된 생산품 정보를 저장합니다.
        inputProcess.prUid = widget.process.id;
        inputProcess.rpUid = widget.process.rpUid;
        inputProcess.isOutput = true;
        var result = await inputProcess.update();

        /// 데이터베이스 쓰기 결과
        if(!result) WidgetT.showSnackBar(context, text: 'The request to write to the server for path "/purchase/:pid/item-process/:psid" failed.');
        else WidgetT.showSnackBar(context, text: '저장됨');

        /// 현재 윈도우 종료
        widget.refresh();
        widget.parent.onCloseButtonClicked!();
      }
    );

    return Row( children: [ exitWidget, saveWidget,], );
  }



  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}
