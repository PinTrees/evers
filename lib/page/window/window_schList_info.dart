import 'dart:convert';
import 'dart:typed_data';

import 'package:evers/class/Customer.dart';
import 'package:evers/class/component/comp_re.dart';
import 'package:evers/class/component/comp_sch.dart';
import 'package:evers/class/system/state.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_sch_create.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import '../../class/contract.dart';
import '../../class/revenue.dart';
import '../../class/schedule.dart';
import '../../class/system.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/text.dart';
import '../../helper/dialog.dart';
import '../../helper/interfaceUI.dart';
import '../../helper/pdfx.dart';
import '../../ui/ip.dart';




/// 이 윈도우 클래스는 일정목록창 위젯을 렌더링 합니다.
class WindowSchListInfo extends WindowBaseMDI {
  Function refresh;

  List<Schedule> scheduleList;
  DateTime date;

  WindowSchListInfo({required this.scheduleList, required this.date, required this.refresh, }) { }

  @override
  _WindowSchListInfoState createState() => _WindowSchListInfoState();
}
class _WindowSchListInfoState extends State<WindowSchListInfo> {
  var dividHeight = 6.0;
  var heightSize = 36.0;

  Map<String, Contract> ctMap = {};
  Map<String, Customer> csMap = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }


  /// 이 함수는 동기 초기화를 시도합니다.
  /// 상속구조로 재설계 되어야 합니다.
  dynamic initAsync() async {

    for(var sch in widget.scheduleList) {
      if(sch.ctUid != '' && !ctMap.containsKey(sch.ctUid)) {
        Contract? ct = await DatabaseM.getContractDoc(sch.ctUid);
        if(ct == null) continue;

        ctMap[sch.ctUid] = ct;
        if(ctMap.containsKey(sch.ctUid)) csMap[ct!.csUid] ??= await DatabaseM.getCustomerDoc(ct.csUid);
      }
    }

    setState(() {});
  }


  ///  이 함수는 매인 위젯을 렌더링 합니다.
  ///  상속구조로 재설계 되어야 합니디.
  Widget mainBuild() {

    List<Widget> scheduleWidgetList = [];

    int index = 1;
    widget.scheduleList.forEach((e) {
      scheduleWidgetList.add(CompSchedule.tableUI(context, e,
        ct: ctMap[e.ctUid], index: index++,
      ));
    });

    return Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: ListBoxT.Columns(
              spacing: dividHeight * 4,
              children: [
                TextT.SubTitle(text: "일정 목록 - " +  StyleT.dateFormat(widget.date)),
                CompSchedule.tableHeader(),
                Column( children: scheduleWidgetList, )
              ]
            )
          ),
          /// action
          buildAction(),
        ],
      ),
    );
  }


  /// 이 함수는 하단의 액션버튼 위젯을 렌더링 합니다.
  /// 상속구조로 재설계 되어야 합니다.
  Widget buildAction() {
    return Row(
      children: [
        Expanded(child:TextButton(
            onPressed: () async {
             UIState.OpenNewWindow(context, WindowSchCreate(ct: null, refresh: () async { await initAsync(); }));
            },
            style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
            child: Container(
                color: StyleT.accentColor.withOpacity(0.5), height: 42,
                child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WidgetT.iconMini(Icons.check_circle),
                    Text('일정 추가', style: StyleT.titleStyle(),),
                    SizedBox(width: 6,),
                  ],
                )
            )
        ),),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}



